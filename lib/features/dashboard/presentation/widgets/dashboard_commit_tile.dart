import 'package:flutter/material.dart';
import 'package:gitstat_viewer/core/utils/relative_time.dart';
import '../../domain/entities/dashboard_commit_entity.dart';

class DashboardCommitTile extends StatelessWidget {
  final DashboardCommitEntity commit;

  const DashboardCommitTile({super.key, required this.commit});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final shortSha =
        commit.sha.length >= 7 ? commit.sha.substring(0, 7) : commit.sha;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: colors.surfaceContainerHighest,
            backgroundImage: commit.authorAvatarUrl != null
                ? NetworkImage(commit.authorAvatarUrl!)
                : null,
            child: commit.authorAvatarUrl == null
                ? Icon(Icons.person, size: 14, color: colors.onSurfaceVariant)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commit.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.folder_outlined, size: 12, color: colors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        commit.repoName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('•', style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                    const SizedBox(width: 8),
                    Text(
                      relativeTime(commit.date),
                      style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              shortSha,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}