// lib/core/network/auth_interceptor.dart
import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storageService;

  AuthInterceptor(this._storageService);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Récupérer le token sauvegardé via le Device Flow
    final token = await _storageService.getAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // En-têtes standards requis par l'API GitHub
    options.headers['Accept'] = 'application/vnd.github.v3+json';

    super.onRequest(options, handler);
  }
}