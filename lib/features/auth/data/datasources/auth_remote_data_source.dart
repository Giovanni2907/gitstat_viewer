import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gitstat_viewer/features/auth/data/models/device_code_response.dart';

/// Résultat d'un appel de polling vers GitHub
class PollResult {
  final String? accessToken;
  final int? newInterval; // non-null seulement si GitHub renvoie "slow_down"

  PollResult({this.accessToken, this.newInterval});

  bool get isSuccess => accessToken != null;
  bool get isSlowDown => newInterval != null;
}

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  // Options réutilisables pour forcer GitHub à répondre en JSON
  static final _options = Options(
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  // 1. Demander le code à afficher à l'utilisateur
  Future<DeviceCodeResponse> requestDeviceCode() async {
    final clientId = dotenv.env['GITHUB_CLIENT_ID'];

    final response = await _dio.post(
      'https://github.com/login/device/code',
      data: {
        'client_id': clientId,
        'scope': 'read:user repo',
      },
      options: _options,
    );

    return DeviceCodeResponse.fromJson(response.data);
  }

  // 2. Vérifier si l'utilisateur a validé le code dans son navigateur (Polling)
  Future<PollResult> pollForAccessToken(String deviceCode) async {
    final clientId = dotenv.env['GITHUB_CLIENT_ID'];

    try {
      final response = await _dio.post(
        'https://github.com/login/oauth/access_token',
        data: {
          'client_id': clientId,
          'device_code': deviceCode,
          'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
        },
        options: _options,
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        // 1. Le token est présent : succès
        if (data.containsKey('access_token')) {
          return PollResult(accessToken: data['access_token'] as String);
        }

        // 2. GitHub renvoie une erreur
        if (data.containsKey('error')) {
          final error = data['error'];

          if (error == 'authorization_pending') {
            // On continue d'attendre, rien de spécial à faire
            return PollResult();
          }

          if (error == 'slow_down') {
            // GitHub demande de ralentir : on relaie le nouvel intervalle
            final newInterval = data['interval'] as int? ?? 10;
            return PollResult(newInterval: newInterval);
          }

          if (error == 'expired_token') {
            throw Exception('Le code d\'autorisation a expiré.');
          }

          if (error == 'access_denied') {
            throw Exception('L\'accès a été refusé.');
          }

          // Toute autre erreur inconnue : on ne l'avale pas silencieusement
          throw Exception('Erreur GitHub : $error');
        }
      }

      return PollResult();
    } on DioException catch (e) {
      // Inspection de la réponse Dio si GitHub renvoie un code 400 Bad Request
      final responseData = e.response?.data;
      if (responseData is Map) {
        final error = responseData['error'];
        if (error == 'authorization_pending') {
          return PollResult();
        }
        if (error == 'slow_down') {
          final newInterval = responseData['interval'] as int? ?? 10;
          return PollResult(newInterval: newInterval);
        }
      }
      rethrow;
    }
  }
}