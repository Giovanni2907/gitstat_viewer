import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gitstat_viewer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:gitstat_viewer/features/auth/data/models/device_code_response.dart';
import 'package:gitstat_viewer/features/auth/presentation/providers/auth_notifier.dart';
import 'package:gitstat_viewer/features/auth/presentation/providers/auth_state.dart';
import 'package:gitstat_viewer/core/storage/secure_storage_service.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

class MockDio extends Mock implements Dio {}

class FakeDeviceCodeResponse extends Fake implements DeviceCodeResponse {}

void main() {
  late MockAuthRemoteDataSource remoteDataSource;
  late MockSecureStorageService storageService;
  late MockDio apiDio;

  setUpAll(() {
    registerFallbackValue('');
  });

  setUp(() {
    remoteDataSource = MockAuthRemoteDataSource();
    storageService = MockSecureStorageService();
    apiDio = MockDio();

    // Par défaut : pas de token existant au démarrage.
    when(() => storageService.getAccessToken()).thenAnswer((_) async => null);

    // Par défaut : le client API valide toujours le token (200 OK),
    // pour ne pas polluer les tests qui ne testent pas explicitement
    // la validation. Les tests qui veulent un 401 le surchargent.
    when(() => apiDio.get<dynamic>('/user')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/user'),
        statusCode: 200,
        data: {'login': 'test-user'},
      ),
    );
  });

  AuthNotifier buildNotifier() =>
      AuthNotifier(remoteDataSource, storageService, apiDio);

  group('checkExistingToken', () {
    test('passe en AuthAuthenticated si un token existe et est valide',
        () async {
      when(() => storageService.getAccessToken())
          .thenAnswer((_) async => 'existing_token');

      final notifier = buildNotifier();
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state, isA<AuthAuthenticated>());
      expect((notifier.state as AuthAuthenticated).accessToken, 'existing_token');

      notifier.dispose();
    });

    test('nettoie le token et repasse en AuthInitial si GitHub renvoie 401',
        () async {
      when(() => storageService.getAccessToken())
          .thenAnswer((_) async => 'expired_token');
      when(() => apiDio.get<dynamic>('/user')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/user'),
          response: Response(
            requestOptions: RequestOptions(path: '/user'),
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      when(() => storageService.deleteAccessToken()).thenAnswer((_) async {});

      final notifier = buildNotifier();
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state, isA<AuthInitial>());
      verify(() => storageService.deleteAccessToken()).called(1);

      notifier.dispose();
    });

    test('reste en AuthInitial si aucun token n\'existe', () async {
      final notifier = buildNotifier();
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state, isA<AuthInitial>());
      // Aucun appel réseau ne doit être fait s'il n'y a pas de token.
      verifyNever(() => apiDio.get<dynamic>('/user'));

      notifier.dispose();
    });
  });

  group('startDeviceFlow', () {
    test('passe par AuthRequestingCode puis AuthCodeReceived', () async {
      final deviceCode = DeviceCodeResponse(
        deviceCode: 'device_abc',
        userCode: 'ABCD-1234',
        verificationUri: 'https://github.com/login/device',
        interval: 5,
        expiresIn: 900,
      );

      when(() => remoteDataSource.requestDeviceCode())
          .thenAnswer((_) async => deviceCode);
      when(() => remoteDataSource.pollForAccessToken(any()))
          .thenAnswer((_) async => PollResult());

      final notifier = buildNotifier();
      await Future<void>.delayed(Duration.zero);

      await notifier.startDeviceFlow();

      expect(notifier.state, isA<AuthCodeReceived>());
      final state = notifier.state as AuthCodeReceived;
      expect(state.deviceCode.userCode, 'ABCD-1234');

      notifier.dispose();
    });

    test('passe en AuthError si la demande de code échoue', () async {
      when(() => remoteDataSource.requestDeviceCode())
          .thenThrow(Exception('network error'));

      final notifier = buildNotifier();
      await Future<void>.delayed(Duration.zero);

      await notifier.startDeviceFlow();

      expect(notifier.state, isA<AuthError>());
      notifier.dispose();
    });
  });

    group('polling', () {
    // Note : _startPolling impose un intervalle minimum de 5 secondes
    // (protection contre le spam de l'API GitHub), même si un intervalle
    // plus court est demandé. Les tests ci-dessous attendent donc au moins
    // 5s réelles par tick, avec une marge de sécurité pour la latence
    // d'ordonnancement du Timer.

    test('passe en AuthAuthenticated dès que le token arrive et le sauvegarde',
        () async {
      final deviceCode = DeviceCodeResponse(
        deviceCode: 'device_abc',
        userCode: 'ABCD-1234',
        verificationUri: 'https://github.com/login/device',
        interval: 5, // correspond au minimum réellement appliqué
        expiresIn: 60,
      );

      when(() => remoteDataSource.requestDeviceCode())
          .thenAnswer((_) async => deviceCode);
      when(() => storageService.saveAccessToken(any()))
          .thenAnswer((_) async {});

      // Le token arrive dès le premier tick pour garder le test rapide.
      when(() => remoteDataSource.pollForAccessToken(any()))
          .thenAnswer((_) async => PollResult(accessToken: 'brand_new_token'));

      final notifier = buildNotifier();
      await Future<void>.delayed(Duration.zero);
      await notifier.startDeviceFlow();

      // Attend le premier tick (5s) + marge.
      await Future<void>.delayed(const Duration(seconds: 6));

      expect(notifier.state, isA<AuthAuthenticated>());
      verify(() => storageService.saveAccessToken('brand_new_token')).called(1);

      notifier.dispose();
    }, timeout: const Timeout(Duration(seconds: 15)));

    test('passe en AuthError si le code a expiré', () async {
      final deviceCode = DeviceCodeResponse(
        deviceCode: 'device_abc',
        userCode: 'ABCD-1234',
        verificationUri: 'https://github.com/login/device',
        interval: 5,
        expiresIn: 1, // expire bien avant le premier tick à 5s
      );

      when(() => remoteDataSource.requestDeviceCode())
          .thenAnswer((_) async => deviceCode);
      when(() => remoteDataSource.pollForAccessToken(any()))
          .thenAnswer((_) async => PollResult());

      final notifier = buildNotifier();
      await Future<void>.delayed(Duration.zero);
      await notifier.startDeviceFlow();

      // Le premier tick (à 5s) doit détecter que expiresIn(1s) est dépassé.
      await Future<void>.delayed(const Duration(seconds: 6));

      expect(notifier.state, isA<AuthError>());
      expect((notifier.state as AuthError).message, contains('expiré'));

      notifier.dispose();
    }, timeout: const Timeout(Duration(seconds: 15)));
  });

  group('logout', () {
    test('supprime le token et repasse en AuthInitial', () async {
      when(() => storageService.getAccessToken())
          .thenAnswer((_) async => 'existing_token');
      when(() => storageService.deleteAccessToken()).thenAnswer((_) async {});

      final notifier = buildNotifier();
      await Future<void>.delayed(Duration.zero);
      expect(notifier.state, isA<AuthAuthenticated>());

      await notifier.logout();

      expect(notifier.state, isA<AuthInitial>());
      verify(() => storageService.deleteAccessToken()).called(1);

      notifier.dispose();
    });
  });
}