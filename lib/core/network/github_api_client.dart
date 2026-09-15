import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitstat_viewer/core/network/dio_client.dart';
import 'package:gitstat_viewer/core/storage/secure_storage_service.dart';

/// Client Dio dédié à l'API REST GitHub (api.github.com), distinct
/// du client OAuth (github.com) utilisé pour le Device Flow.
final githubApiDioProvider = Provider<Dio>((ref) {
  final storageService = ref.watch(secureStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.github.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/vnd.github.v3+json',
      },
    ),
  );

  dio.interceptors.add(AuthInterceptor(storageService));

  return dio;
});