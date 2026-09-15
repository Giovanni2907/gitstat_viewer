import '../../domain/entities/github_user_entity.dart';

class GithubUserModel extends GithubUserEntity {
  const GithubUserModel({
    required super.login,
    super.name,
    required super.avatarUrl,
    super.bio,
    required super.publicRepos,
    required super.followers,
    required super.following,
    required super.htmlUrl,
  });

  factory GithubUserModel.fromJson(Map<String, dynamic> json) {
    return GithubUserModel(
      login: json['login'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String,
      bio: json['bio'] as String?,
      publicRepos: json['public_repos'] as int? ?? 0,
      followers: json['followers'] as int? ?? 0,
      following: json['following'] as int? ?? 0,
      htmlUrl: json['html_url'] as String,
    );
  }
}