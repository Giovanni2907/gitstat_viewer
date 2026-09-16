import 'package:flutter/material.dart';

/// En-tête de section réutilisable : icône + titre + compteur optionnel.
/// Standardise le style des cartes (Top contributeurs, Historique, Langages...).
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, color: colors.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium
                ?.copyWith(color: colors.onSurface, fontWeight: FontWeight.w600),
          ),
        ),
        if (trailing != null)
          Text(trailing!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colors.onSurfaceVariant)),
      ],
    );
  }
}