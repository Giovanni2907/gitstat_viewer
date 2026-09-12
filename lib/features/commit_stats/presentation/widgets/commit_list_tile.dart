import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/commit_model.dart';

/// Ligne d'un commit dans l'historique : avatar, titre, auteur, date.
class CommitListTile extends StatelessWidget {
  final CommitModel commit;

  const CommitListTile({super.key, required this.commit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListTile(
      leading: commit.authorAvatarUrl != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(commit.authorAvatarUrl!),
              onBackgroundImageError: (_, _) {},
            )
          : CircleAvatar(
              backgroundColor: colors.primary,
              child: Text(
                commit.authorName.isNotEmpty
                    ? commit.authorName[0].toUpperCase()
                    : '?',
                style: TextStyle(color: colors.onPrimary),
              ),
            ),
      title: Text(
        commit.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface),
      ),
      subtitle: Text(
        '${commit.authorName} • ${commit.shortSha} • ${DateFormat('dd/MM/yyyy à HH:mm').format(commit.date.toLocal())}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall
            ?.copyWith(color: colors.onSurfaceVariant),
      ),
      trailing: commit.htmlUrl.isEmpty
          ? null
          : IconButton(
              icon: Icon(Icons.open_in_new, color: colors.primary, size: 20),
              tooltip: 'Voir sur GitHub',
              onPressed: () async {
                final uri = Uri.parse(commit.htmlUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
    );
  }
}
