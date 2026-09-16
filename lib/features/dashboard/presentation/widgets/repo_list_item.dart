import 'package:flutter/material.dart';
import 'package:gitstat_viewer/core/utils/language_colors.dart';
import '../../domain/entities/repo_entity.dart';

class RepoListItem extends StatelessWidget {
  final RepoEntity repo;

  const RepoListItem({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        children: [
          Icon(repo.isPrivate ? Icons.lock_outline : Icons.book_outlined,
              size: 18, color: colors.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              repo.fullName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.primary, fontWeight: FontWeight.w500),
            ),
          ),
          if (repo.language != null) ...[
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(color: languageColor(repo.language!), shape: BoxShape.circle),
            ),
            Text(repo.language!, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}