import 'package:flutter/material.dart';
import 'package:gitstat_viewer/core/widgets/gh_search_field.dart';

class RepoSearchBar extends StatelessWidget {
  final TextEditingController ownerController;
  final TextEditingController repoController;
  final FocusNode? ownerFocusNode;
  final VoidCallback onSubmit;

  const RepoSearchBar({
    super.key,
    required this.ownerController,
    required this.repoController,
    required this.onSubmit,
    this.ownerFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: GhSearchField(
              controller: ownerController,
              focusNode: ownerFocusNode,
              hintText: 'Propriétaire (owner)',
              icon: Icons.person_outline,
              shortcutHint: '/',
              onSubmitted: (_) => onSubmit(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GhSearchField(
              controller: repoController,
              hintText: 'Dépôt (repo)',
              icon: Icons.folder_outlined,
              onSubmitted: (_) => onSubmit(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: onSubmit,
            icon: const Icon(Icons.search),
            label: const Text('Charger'),
          ),
        ],
      ),
    );
  }
}