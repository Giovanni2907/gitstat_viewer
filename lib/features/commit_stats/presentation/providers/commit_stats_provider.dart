import 'package:gitstat_viewer/features/commit_stats/data/models/commit_model.dart';

/// Activité d'une journée : date + nombre de commits.
class DailyCommits {
  final DateTime day;
  final int count;

  const DailyCommits({required this.day, required this.count});
}

/// Statistiques calculées localement à partir d'une liste de commits.
class CommitStats {
  final int totalCommits;
  final DateTime? newestCommitDate;
  final List<MapEntry<String, int>> topAuthors;
  final List<DailyCommits> dailyActivity;

  CommitStats({
    required this.totalCommits,
    required this.newestCommitDate,
    required this.topAuthors,
    required this.dailyActivity,
  });

  /// Nombre de jours affichés dans le graphique d'activité.
  static const int activityWindowDays = 30;

  /// Nombre maximum d'auteurs affichés dans le top contributeurs.
  static const int maxTopAuthors = 5;

  factory CommitStats.fromCommits(List<CommitModel> commits) {
    // --- 1. Top contributeurs ---
    final countByAuthor = <String, int>{};
    for (final commit in commits) {
      countByAuthor[commit.authorName] =
          (countByAuthor[commit.authorName] ?? 0) + 1;
    }
    final authors = countByAuthor.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topAuthors = authors.take(maxTopAuthors).toList();

    // --- 2. Activité par jour sur les 30 derniers jours ---
    // On ramène chaque date à son jour (minuit local) pour compter.
    final countByDay = <DateTime, int>{};
    DateTime? newest;
    for (final commit in commits) {
      final local = commit.date.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      countByDay[day] = (countByDay[day] ?? 0) + 1;
      if (newest == null || local.isAfter(newest)) newest = local;
    }

    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    final dailyActivity = <DailyCommits>[];
    for (var i = activityWindowDays - 1; i >= 0; i--) {
      final day = todayMidnight.subtract(Duration(days: i));
      dailyActivity.add(
        DailyCommits(day: day, count: countByDay[day] ?? 0),
      );
    }

    return CommitStats(
      totalCommits: commits.length,
      newestCommitDate: newest,
      topAuthors: topAuthors,
      dailyActivity: dailyActivity,
    );
  }
}
