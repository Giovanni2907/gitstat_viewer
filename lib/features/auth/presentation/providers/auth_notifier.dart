import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../../../core/storage/secure_storage_service.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _storageService;
  final Dio _apiDio; // client pointé sur api.github.com, pour valider le token
  Timer? _pollingTimer;
  bool _isPolling = false;

  AuthNotifier(this._remoteDataSource, this._storageService, this._apiDio)
      : super(const AuthInitial()) {
    checkExistingToken();
  }

  /// Vérifie qu'un token stocké existe ET qu'il est encore accepté par
  /// GitHub, avant de considérer l'utilisateur comme authentifié.
  Future<void> checkExistingToken() async {
    final token = await _storageService.getAccessToken();

    if (token == null || token.isEmpty) {
      state = const AuthInitial();
      return;
    }

    final isValid = await _isTokenValid();

    if (isValid) {
      state = AuthAuthenticated(accessToken: token);
    } else {
      // Token périmé/révoqué : on nettoie pour ne pas rester bloqué
      // avec un token mort à chaque prochain lancement de l'app.
      await _storageService.deleteAccessToken();
      state = const AuthInitial();
    }
  }

  Future<bool> _isTokenValid() async {
    try {
      await _apiDio.get('/user');
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return false;
      // Erreur réseau, timeout... : on ne pénalise pas l'utilisateur pour
      // un problème de connexion, on le laisse entrer, les écrans géreront
      // l'erreur individuellement si besoin.
      return true;
    } catch (_) {
      return true;
    }
  }

  Future<void> startDeviceFlow() async {
    state = const AuthRequestingCode();
    try {
      final deviceCodeResponse = await _remoteDataSource.requestDeviceCode();
      state = AuthCodeReceived(deviceCode: deviceCodeResponse);

      _startPolling(
        deviceCode: deviceCodeResponse.deviceCode,
        intervalInSeconds: deviceCodeResponse.interval,
        expiresInSeconds: deviceCodeResponse.expiresIn,
      );
    } catch (e) {
      state = AuthError(message: 'Échec de la demande de code : ${e.toString()}');
    }
  }

  void _startPolling({
    required String deviceCode,
    required int intervalInSeconds,
    required int expiresInSeconds,
  }) {
    _pollingTimer?.cancel();
    _isPolling = false;
    final startTime = DateTime.now();
    int currentInterval = intervalInSeconds < 5 ? 5 : intervalInSeconds;

    void tick(Timer timer) async {
      if (_isPolling) return;

      final elapsed = DateTime.now().difference(startTime).inSeconds;
      if (elapsed >= expiresInSeconds) {
        timer.cancel();
        state = const AuthError(message: 'Le code a expiré. Veuillez réessayer.');
        return;
      }

      try {
        _isPolling = true;
        final result = await _remoteDataSource.pollForAccessToken(deviceCode);
        _isPolling = false;

        if (result.accessToken != null) {
          timer.cancel();
          await _storageService.saveAccessToken(result.accessToken!);
          state = AuthAuthenticated(accessToken: result.accessToken!);
          return;
        }

        if (result.newInterval != null && result.newInterval! > currentInterval) {
          currentInterval = result.newInterval!;
          timer.cancel();
          _pollingTimer = Timer.periodic(Duration(seconds: currentInterval), tick);
        }
      } catch (e) {
        _isPolling = false;
        timer.cancel();
        state = AuthError(message: e.toString().replaceAll('Exception: ', ''));
      }
    }

    _pollingTimer = Timer.periodic(Duration(seconds: currentInterval), tick);
  }

  Future<void> logout() async {
    _pollingTimer?.cancel();
    _isPolling = false;
    await _storageService.deleteAccessToken();
    state = const AuthInitial();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}