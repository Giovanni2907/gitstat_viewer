import '../entities/github_user_entity.dart';
import '../entities/dashboard_stats_entity.dart';

abstract class DashboardRepository {
  Future<GithubUserEntity> getCurrentUser();
  Future<DashboardStatsEntity> getDashboardStats(String username);
}