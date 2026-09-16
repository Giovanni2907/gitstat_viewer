import 'language_stat_entity.dart';
import 'repo_entity.dart';

class DashboardStatsEntity {
  final int repoCount;
  final int totalCommits;
  final int collaboratorsCount;
  final List<LanguageStatEntity> languageStats;
  final List<RepoEntity> repos;

  const DashboardStatsEntity({
    required this.repoCount,
    required this.totalCommits,
    required this.collaboratorsCount,
    required this.languageStats,
    required this.repos,
  });
}