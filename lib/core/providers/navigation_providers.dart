import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Onglet actif de la navigation principale (Dashboard / Statistiques / Profil).
final currentTabIndexProvider = StateProvider<int>((ref) => 0);