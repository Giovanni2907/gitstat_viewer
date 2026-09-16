import 'package:flutter/material.dart';

const Map<String, Color> _knownLanguageColors = {
  'Dart': Color(0xFF00B4AB),
  'JavaScript': Color(0xFFF7DF1E),
  'TypeScript': Color(0xFF3178C6),
  'Python': Color(0xFF3572A5),
  'Java': Color(0xFFB07219),
  'Kotlin': Color(0xFFA97BFF),
  'Swift': Color(0xFFF05138),
  'C++': Color(0xFFF34B7D),
  'C': Color(0xFF555555),
  'C#': Color(0xFF178600),
  'Go': Color(0xFF00ADD8),
  'Rust': Color(0xFFDEA584),
  'HTML': Color(0xFFE34C26),
  'CSS': Color(0xFF563D7C),
  'Shell': Color(0xFF89E051),
  'Ruby': Color(0xFF701516),
  'PHP': Color(0xFF4F5D95),
};

const List<Color> _fallbackPalette = [
  Color(0xFF4C9A2A), Color(0xFF3178C6), Color(0xFFF7DF1E),
  Color(0xFFE34C26), Color(0xFF9B59B6), Color(0xFF00ADD8),
  Color(0xFFB07219), Color(0xFF178600), Color(0xFF701516),
  Color(0xFF888888),
];

/// Couleur déterministe pour un langage : identique à chaque appel,
/// même pour les langages absents de la palette connue.
Color languageColor(String language) {
  final known = _knownLanguageColors[language];
  if (known != null) return known;
  final index =
      language.codeUnits.fold<int>(0, (sum, c) => sum + c) % _fallbackPalette.length;
  return _fallbackPalette[index];
}