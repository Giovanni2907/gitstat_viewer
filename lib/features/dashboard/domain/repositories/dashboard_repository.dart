import '../entities/github_user_entity.dart';
import '../entities/dashboard_stats_entity.dart';
import '../entities/dashboard_commit_entity.dart';
import '../entities/repo_entity.dart';

abstract class DashboardRepository {
  Future<GithubUserEntity> getCurrentUser();
  Future<DashboardStatsEntity> getDashboardStats(String username);

  /// Agrège les commits récents (auteur = utilisateur connecté) sur les
  /// dépôts les plus récemment poussés, pour le flux d'activité du Dashboard.
  Future<List<DashboardCommitEntity>> getRecentCommits(
    List<RepoEntity> repos,
    String username,
  );
}