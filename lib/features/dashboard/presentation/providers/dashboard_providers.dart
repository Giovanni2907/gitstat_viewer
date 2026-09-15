import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitstat_viewer/core/network/github_api_client.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../../domain/entities/github_user_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';

final dashboardRemoteDataSourceProvider =
    Provider<DashboardRemoteDataSource>((ref) {
  final dio = ref.watch(githubApiDioProvider);
  return DashboardRemoteDataSource(dio);
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dataSource = ref.watch(dashboardRemoteDataSourceProvider);
  return DashboardRepositoryImpl(dataSource);
});

/// Profil de l'utilisateur connecté
final currentUserProvider = FutureProvider<GithubUserEntity>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getCurrentUser();
});

/// Statistiques du dashboard (dépend du profil pour connaître le login)
final dashboardStatsProvider =
    FutureProvider<DashboardStatsEntity>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  final user = await ref.watch(currentUserProvider.future);
  return repository.getDashboardStats(user.login);
});