import 'package:go_router/go_router.dart';
import 'package:gitstat_viewer/features/auth/screens/auth_screen.dart'; // Ajustez selon votre chemin d'import

final GoRouter appRouter = GoRouter(
  initialLocation: '/auth',
  routes: [
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const AuthScreen(),
    ),
    // Vous ajouterez vos autres routes ici plus tard (ex: '/home', '/repos')
  ],
);