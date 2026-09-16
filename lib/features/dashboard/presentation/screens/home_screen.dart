import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitstat_viewer/features/commit_stats/presentation/providers/commit_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gitstat_viewer/core/providers/navigation_providers.dart';
import 'package:gitstat_viewer/features/auth/presentation/providers/auth_providers.dart';
import 'package:gitstat_viewer/features/auth/presentation/providers/auth_state.dart';
import 'package:gitstat_viewer/features/commit_stats/presentation/screens/commit_stats_screen.dart';
import '../providers/dashboard_providers.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';

/// Coquille principale post-authentification : navigation par onglets +
/// redirection automatique vers l'écran de connexion dès que la session
/// n'est plus valide (logout manuel ou token expiré).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _screens = [
    DashboardScreen(),
    CommitStatsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is! AuthAuthenticated) {
        // Nettoie les données de l'utilisateur précédent avant de repartir
        // vers l'écran de connexion (important si un autre compte se
        // connecte ensuite).
        ref.invalidate(currentUserProvider);
        ref.invalidate(dashboardStatsProvider);
        ref.invalidate(commitStatsProvider);
        context.go('/auth'); // Adapte ce chemin si ta route diffère
      }
    });

    final currentIndex = ref.watch(currentTabIndexProvider);

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _screens),
      bottomNavigationBar: Container(
  decoration: BoxDecoration(
    border: Border(
      top: BorderSide(
        color: Theme.of(context).colorScheme.onSurface, // Récupère darkBorder ou lightBorder
        width: 0.8,
      ),
    ),
  ),
  child: NavigationBar(
    selectedIndex: currentIndex,
    onDestinationSelected: (index) =>
        ref.read(currentTabIndexProvider.notifier).state = index,
    destinations: const [
      NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
      NavigationDestination(icon: Icon(Icons.query_stats_rounded), label: 'Statistiques'),
      NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profil'),
    ],
  ),
),
    );
  }
}