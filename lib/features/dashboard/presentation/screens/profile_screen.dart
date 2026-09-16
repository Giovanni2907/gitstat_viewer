import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitstat_viewer/features/auth/presentation/providers/auth_providers.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/dashboard_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _openGithubSettings() async {
    final uri = Uri.parse('https://github.com/settings/profile');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildProfileActions(BuildContext context, WidgetRef ref) {
  final settingsButton = ElevatedButton.icon(
    icon: const Icon(Icons.settings_rounded),
    label: const Text('Paramètres GitHub'),
    onPressed: _openGithubSettings,
  );

  final logoutButton = OutlinedButton.icon(
    icon: const Icon(Icons.logout_rounded),
    label: const Text('Se déconnecter'),
    onPressed: () => ref.read(authProvider.notifier).logout(),
  );

  return LayoutBuilder(
    builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 480;

      if (isWide) {
        // Web/large écran : boutons côte à côte, largeur maîtrisée et centrée
        // au lieu d'étirer toute la largeur disponible.
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Row(
              children: [
                Expanded(child: settingsButton),
                const SizedBox(width: 12),
                Expanded(child: logoutButton),
              ],
            ),
          ),
        );
      }

      // Mobile : empilés pleine largeur pour rester faciles à toucher.
      return Column(
        children: [
          SizedBox(width: double.infinity, child: settingsButton),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: logoutButton),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erreur : $error')),
        data: (user) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundImage: NetworkImage(user.avatarUrl),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                user.name ?? user.login,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Text(
                '@${user.login}',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
              ),
            ),
            if (user.bio != null && user.bio!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Center(child: Text(user.bio!, textAlign: TextAlign.center)),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ProfileStat(label: 'Dépôts publics', value: '${user.publicRepos}'),
                _ProfileStat(label: 'Followers', value: '${user.followers}'),
                _ProfileStat(label: 'Following', value: '${user.following}'),
              ],
            ),
            const SizedBox(height: 32),
            _buildProfileActions(context, ref),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
      ],
    );
  }
}