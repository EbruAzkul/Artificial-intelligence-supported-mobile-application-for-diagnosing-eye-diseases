import 'package:json_annotation/json_annotation.dart';

part 'diagnosis.g.dart';

@JsonSerializable()
class Diagnosis {
  final int? id;

  @JsonKey(name: 'predicted_class')
  final String? predictedClass;

  final double? confidence;

  @JsonKey(name: 'all_probabilities')
  final Map<String, double>? allProbabilities;

  final String? notes;

  @JsonKey(name: 'image_path')
  final String? imagePath;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  Diagnosis({
    this.id,
    this.predictedClass,
    this.confidence,
    this.allProbabilities,
    this.notes,
    this.imagePath,
    this.createdAt,
  });

  factory Diagnosis.fromJson(Map<String, dynamic> json) => _$DiagnosisFromJson(json);
  Map<String, dynamic> toJson() => _$DiagnosisToJson(this);
}