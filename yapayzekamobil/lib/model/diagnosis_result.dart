import 'package:json_annotation/json_annotation.dart';

part 'diagnosis_result.g.dart';

@JsonSerializable()
class DiagnosisResult {
  @JsonKey(name: 'predicted_class')
  final String predictedClass;

  final double confidence;

  @JsonKey(name: 'all_probabilities')
  final Map<String, double> allProbabilities;

  DiagnosisResult({
    required this.predictedClass,
    required this.confidence,
    required this.allProbabilities,
  });

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) => _$DiagnosisResultFromJson(json);
  Map<String, dynamic> toJson() => _$DiagnosisResultToJson(this);
}