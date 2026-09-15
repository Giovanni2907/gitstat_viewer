class RepoEntity {
  final int id;
  final String name;
  final String fullName;
  final String ownerLogin;
  final String? language;
  final bool isPrivate;
  final String htmlUrl;

  const RepoEntity({
    required this.id,
    required this.name,
    required this.fullName,
    required this.ownerLogin,
    this.language,
    required this.isPrivate,
    required this.htmlUrl,
  });
}