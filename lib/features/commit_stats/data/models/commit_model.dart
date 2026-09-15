/// Modèle représentant un commit GitHub (réponse de /repos/{owner}/{repo}/commits).
class CommitModel {
  final String sha;
  final String message;
  final String authorName;
  final String? authorAvatarUrl;
  final DateTime date;
  final String htmlUrl;

  CommitModel({
    required this.sha,
    required this.message,
    required this.authorName,
    required this.date,
    this.authorAvatarUrl,
    this.htmlUrl = '',
  });

  factory CommitModel.fromJson(Map<String, dynamic> json) {
    final commit = json['commit'] as Map<String, dynamic>;
    final gitAuthor = commit['author'] as Map<String, dynamic>?;
    // "author" (compte GitHub) peut être null pour un commit sans compte associé
    final githubAuthor = json['author'] as Map<String, dynamic>?;

    return CommitModel(
      sha: json['sha'] as String,
      message: commit['message'] as String? ?? '',
      authorName: gitAuthor?['name'] as String? ?? 'Inconnu',
      authorAvatarUrl: githubAuthor?['avatar_url'] as String?,
      date: DateTime.parse(gitAuthor?['date'] as String),
      htmlUrl: json['html_url'] as String? ?? '',
    );
  }

  /// Première ligne du message de commit (le titre).
  String get title {
    final firstLine = message.split('\n').first.trim();
    return firstLine.isEmpty ? '(message vide)' : firstLine;
  }

  /// 7 premiers caractères du sha, ex. "a862f6d".
  String get shortSha => sha.substring(0, 7);
}
