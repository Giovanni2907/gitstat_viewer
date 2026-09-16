import '../../domain/entities/dashboard_commit_entity.dart';

class DashboardCommitModel extends DashboardCommitEntity {
  const DashboardCommitModel({
    required super.sha,
    required super.message,
    required super.authorName,
    super.authorAvatarUrl,
    required super.date,
    required super.repoName,
  });

  factory DashboardCommitModel.fromJson(
    Map<String, dynamic> json, {
    required String repoName,
  }) {
    final commit = json['commit'] as Map<String, dynamic>;
    final commitAuthor = commit['author'] as Map<String, dynamic>?;
    final topAuthor = json['author'] as Map<String, dynamic>?;

    final rawMessage = commit['message'] as String? ?? '';
    final firstLine = rawMessage.split('\n').first;

    return DashboardCommitModel(
      sha: json['sha'] as String,
      message: firstLine,
      authorName: topAuthor?['login'] as String? ??
          commitAuthor?['name'] as String? ??
          'Inconnu',
      authorAvatarUrl: topAuthor?['avatar_url'] as String?,
      date: DateTime.tryParse(commitAuthor?['date'] as String? ?? '') ??
          DateTime.now(),
      repoName: repoName,
    );
  }
}