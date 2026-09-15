import 'package:gitstat_viewer/features/dashboard/presentation/screens/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:gitstat_viewer/features/auth/presentation/screens/auth_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/auth',
  routes: [
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: ((context, state) => const HomeScreen())
    ),

  ],
);