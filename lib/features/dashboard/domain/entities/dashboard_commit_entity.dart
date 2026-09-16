class DashboardCommitEntity {
  final String sha;
  final String message;
  final String authorName;
  final String? authorAvatarUrl;
  final DateTime date;
  final String repoName;

  const DashboardCommitEntity({
    required this.sha,
    required this.message,
    required this.authorName,
    this.authorAvatarUrl,
    required this.date,
    required this.repoName,
  });
}