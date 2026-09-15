class LanguageStatEntity {
  final String language;
  final int repoCount;
  final double percentage; // 0.0 à 100.0

  const LanguageStatEntity({
    required this.language,
    required this.repoCount,
    required this.percentage,
  });
}