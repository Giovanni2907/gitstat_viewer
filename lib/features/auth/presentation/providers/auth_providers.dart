import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitstat_viewer/core/network/github_api_client.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import 'auth_notifier.dart';
import 'auth_state.dart';

/// Provider pour la source de données distante
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AuthRemoteDataSource(dio);
});

/// Provider principal d'état d'authentification
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider); // garde ton provider existant
  final storageService = ref.watch(secureStorageProvider);
  final apiDio = ref.watch(githubApiDioProvider); // nouveau
  return AuthNotifier(remoteDataSource, storageService, apiDio);
});