// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnosis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Diagnosis _$DiagnosisFromJson(Map<String, dynamic> json) => Diagnosis(
      id: (json['id'] as num?)?.toInt(),
      predictedClass: json['predicted_class'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      allProbabilities:
          (json['all_probabilities'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      notes: json['notes'] as String?,
      imagePath: json['image_path'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$DiagnosisToJson(Diagnosis instance) => <String, dynamic>{
      'id': instance.id,
      'predicted_class': instance.predictedClass,
      'confidence': instance.confidence,
      'all_probabilities': instance.allProbabilities,
      'notes': instance.notes,
      'image_path': instance.imagePath,
      'created_at': instance.createdAt?.toIso8601String(),
    };
