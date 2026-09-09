import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gitstat_viewer/features/auth/data/models/device_code_response.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  //Demander le code à afficher à l'utilisateur
  Future<DeviceCodeResponse> requestDeviceCode() async{
    final clientId = dotenv.env['GITHUB_CLIENT_ID'];

    final response = await _dio.post(
      'https://github.com/login/device/code',
      data: {
        'client_id': clientId,
        'scope': 'read:user repo', // Accès au profil et aux repos
      },
      options: Options(
        headers: {'Accept': 'application/json'},
      ),
    );

    return DeviceCodeResponse.fromJson(response.data);
  }

  // 2. Vérifier si l'utilisateur a validé le code dans son navigateur (Polling)
  Future<String?> pollForAccessToken({
    required String deviceCode,
  }) async {
    final clientId = dotenv.env['GITHUB_CLIENT_ID'];

    final response = await _dio.post(
      'https://github.com/login/oauth/access_token',
      data: {
        'client_id': clientId,
        'device_code': deviceCode,
        'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
      },
      options: Options(
        headers: {'Accept': 'application/json'},
      ),
    );

    final data = response.data;

    if (data['access_token'] != null) {
      return data['access_token'] as String; // Succès ! Token récupéré
    }

    if (data['error'] == 'authorization_pending') {
      return null; // L'utilisateur n'a pas encore validé
    }

    throw Exception('Erreur d\'authentification: ${data['error_description'] ?? data['error']}');
  }
}