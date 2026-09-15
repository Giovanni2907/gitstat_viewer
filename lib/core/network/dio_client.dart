// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage_service.dart';

/// Instance Dio unique de l'application (base : API GitHub).
/// L'AuthInterceptor ajoute automatiquement le token à chaque requête.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.github.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
  dio.interceptors.add(AuthInterceptor(ref.watch(secureStorageProvider)));
  return dio;
});

/// Intercepteur HTTP pour injecter le token GitHub et les en-têtes requis
class AuthInterceptor extends Interceptor {
  final SecureStorageService _storageService;

  AuthInterceptor(this._storageService);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storageService.getAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Accept'] = 'application/vnd.github.v3+json';

    super.onRequest(options, handler);
  }
}

/// Provider exposant l'instance Dio configurée (placé AU NIVEAU RACINE)
final dioClientProvider = Provider<Dio>((ref) {
  final storageService = ref.watch(secureStorageProvider);
  
  final dio = Dio(
  BaseOptions(
    baseUrl: 'https://github.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Accept': 'application/json'},
  ),
);

dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
  error: true,
));

dio.interceptors.add(AuthInterceptor(storageService));

  return dio;
});