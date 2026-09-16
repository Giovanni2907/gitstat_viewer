import '../../domain/entities/dashboard_stats_entity.dart';
import '../../domain/entities/github_user_entity.dart';
import '../../domain/entities/language_stat_entity.dart';
import '../../domain/entities/dashboard_commit_entity.dart';
import '../../domain/entities/repo_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';
import '../models/dashboard_commit_model.dart';

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
    final ownedRepos = repos.where((r) => r.ownerLogin == username).toList();

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
    uniqueCollaborators.remove(username);

    final languageCounts = <String, int>{};
    for (final repo in repos) {
      final lang = repo.language;
      if (lang == null || lang.isEmpty) continue;
      languageCounts[lang] = (languageCounts[lang] ?? 0) + 1;
    }

    final totalWithLanguage =
        languageCounts.values.fold<int>(0, (sum, c) => sum + c);

    final languageStats = languageCounts.entries.map((entry) {
      final percentage =
          totalWithLanguage == 0 ? 0.0 : (entry.value / totalWithLanguage) * 100;
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
      repos: repos,
    );
  }

  @override
  Future<List<DashboardCommitEntity>> getRecentCommits(
    List<RepoEntity> repos,
    String username,
  ) async {
    // On limite aux dépôts possédés, triés par activité la plus récente,
    // pour rester raisonnable en nombre d'appels API (rate limit GitHub).
    final ownedRepos = repos.where((r) => r.ownerLogin == username).toList()
      ..sort((a, b) {
        final aDate = a.pushedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.pushedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

    final candidateRepos = ownedRepos.take(6).toList();

    final results = await Future.wait(
      candidateRepos.map((repo) async {
        try {
          return await _remoteDataSource.getRepoCommits(
            owner: repo.ownerLogin,
            repo: repo.name,
            author: username,
            perPage: 5,
          );
        } catch (_) {
          return <DashboardCommitModel>[];
        }
      }),
    );

    final allCommits = results.expand((list) => list).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return allCommits.take(25).toList();
  }
}