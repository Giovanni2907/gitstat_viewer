import '../../domain/entities/repo_entity.dart';

class RepoModel extends RepoEntity {
  const RepoModel({
    required super.id,
    required super.name,
    required super.fullName,
    required super.ownerLogin,
    super.language,
    required super.isPrivate,
    required super.htmlUrl,
    super.pushedAt,
  });

  factory RepoModel.fromJson(Map<String, dynamic> json) {
    return RepoModel(
      id: json['id'] as int,
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      ownerLogin: (json['owner'] as Map<String, dynamic>)['login'] as String,
      language: json['language'] as String?,
      isPrivate: json['private'] as bool? ?? false,
      htmlUrl: json['html_url'] as String,
      pushedAt: json['pushed_at'] == null
          ? null
          : DateTime.tryParse(json['pushed_at'] as String),
    );
  }
}