class GithubUserEntity {
  final String login;
  final String? name;
  final String avatarUrl;
  final String? bio;
  final int publicRepos;
  final int followers;
  final int following;
  final String htmlUrl;

  const GithubUserEntity({
    required this.login,
    this.name,
    required this.avatarUrl,
    this.bio,
    required this.publicRepos,
    required this.followers,
    required this.following,
    required this.htmlUrl,
  });
}