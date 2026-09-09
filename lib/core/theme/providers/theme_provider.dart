import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  // Par défaut, le thème sombre GitHub (le plus populaire)
  return ThemeMode.dark;
});