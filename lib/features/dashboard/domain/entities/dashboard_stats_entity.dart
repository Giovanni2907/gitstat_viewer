import 'language_stat_entity.dart';

class DashboardStatsEntity {
  final int repoCount;
  final int totalCommits;
  final int collaboratorsCount;
  final List<LanguageStatEntity> languageStats;

  const DashboardStatsEntity({
    required this.repoCount,
    required this.totalCommits,
    required this.collaboratorsCount,
    required this.languageStats,
  });
}