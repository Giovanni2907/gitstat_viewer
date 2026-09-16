import 'package:flutter/material.dart';
import 'package:gitstat_viewer/features/commit_stats/presentation/widgets/stat_card.dart';
import 'package:intl/intl.dart';
import '../providers/commit_stats_provider.dart';

class CommitMetricsRow extends StatelessWidget {
  final CommitStats stats;
  final bool isWide;

  const CommitMetricsRow({super.key, required this.stats, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final cards = [
      StatCard(icon: Icons.commit, value: '${stats.totalCommits}', label: 'Commits analysés'),
      StatCard(icon: Icons.people_alt_outlined, value: '${stats.topAuthors.length}', label: 'Top contributeurs'),
      StatCard(
        icon: Icons.schedule,
        value: stats.newestCommitDate == null
            ? '-'
            : DateFormat('dd/MM HH:mm').format(stats.newestCommitDate!.toLocal()),
        label: 'Dernier commit',
      ),
    ];

    if (isWide) {
      return Row(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            Expanded(child: cards[i]),
            if (i < cards.length - 1) const SizedBox(width: 12),
          ],
        ],
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: cards,
    );
  }
}