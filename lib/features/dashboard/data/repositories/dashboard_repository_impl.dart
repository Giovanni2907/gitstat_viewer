import '../../domain/entities/dashboard_stats_entity.dart';
import '../../domain/entities/github_user_entity.dart';
import '../../domain/entities/language_stat_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  DashboardRepositoryImpl(this._remoteDataSource);

  @override
  Future<GithubUserEntity> getCurrentUser() {
    return _remoteDataSource.getCurrentUser();
  }

  @override
  Future<DashboardStatsEntity> getDashboardStats(String username) async {
    final repos = await _remoteDataSource.getUserRepos();

    // On ne calcule les commits/collaborateurs que sur les dépôts
    // dont l'utilisateur est propriétaire, pour éviter le bruit des forks
    // et le risque de rate-limit sur des dépôts tiers volumineux.
    final ownedRepos = repos.where((r) => r.ownerLogin == username).toList();

    // Appels en parallèle, mais on protège chaque appel individuellement
    // pour qu'un dépôt en erreur ne fasse pas échouer tout le dashboard.
    final commitCounts = await Future.wait(
      ownedRepos.map((repo) async {
        try {
          return await _remoteDataSource.getCommitCount(
            owner: repo.ownerLogin,
            repo: repo.name,
            author: username,
          );
        } catch (_) {
          return 0;
        }
      }),
    );

    final collaboratorLists = await Future.wait(
      ownedRepos.map((repo) async {
        try {
          return await _remoteDataSource.getCollaborators(
            owner: repo.ownerLogin,
            repo: repo.name,
          );
        } catch (_) {
          return <String>[];
        }
      }),
    );

    final totalCommits = commitCounts.fold<int>(0, (sum, c) => sum + c);

    final uniqueCollaborators = <String>{};
    for (final list in collaboratorLists) {
      uniqueCollaborators.addAll(list);
    }
    uniqueCollaborators.remove(username); // on exclut l'utilisateur lui-même

    // Répartition des langages : basée sur le langage principal déclaré
    // par GitHub pour chaque dépôt (champ "language" de /user/repos).
    final languageCounts = <String, int>{};
    for (final repo in repos) {
      final lang = repo.language;
      if (lang == null || lang.isEmpty) continue;
      languageCounts[lang] = (languageCounts[lang] ?? 0) + 1;
    }

    final totalWithLanguage =
        languageCounts.values.fold<int>(0, (sum, c) => sum + c);

    final languageStats = languageCounts.entries.map((entry) {
      final percentage = totalWithLanguage == 0
          ? 0.0
          : (entry.value / totalWithLanguage) * 100;
      return LanguageStatEntity(
        language: entry.key,
        repoCount: entry.value,
        percentage: percentage,
      );
    }).toList()
      ..sort((a, b) => b.percentage.compareTo(a.percentage));

    return DashboardStatsEntity(
      repoCount: repos.length,
      totalCommits: totalCommits,
      collaboratorsCount: uniqueCollaborators.length,
      languageStats: languageStats,
    );
  }
}