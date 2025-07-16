import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int? id;
  final String email;
  final String name;
  final String? password;
  final String publicId;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  User({
    this.id,
    required this.email,
    required this.name,
    this.password,
    required this.publicId,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}