import 'package:flutter/material.dart';
import 'package:gitstat_viewer/core/widgets/section_header.dart';
import '../providers/commit_stats_provider.dart';
import 'commit_list_tile.dart';

class CommitHistoryList extends StatelessWidget {
  final CommitStats stats;

  const CommitHistoryList({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SectionHeader(
              icon: Icons.history,
              title: 'Historique des commits',
              trailing: '${stats.commits.length}',
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: stats.commits.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) => CommitListTile(commit: stats.commits[index]),
            ),
          ),
        ],
      ),
    );
  }
}