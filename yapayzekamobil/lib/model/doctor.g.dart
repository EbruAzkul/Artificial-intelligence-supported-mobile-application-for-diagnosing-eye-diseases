// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Doctor _$DoctorFromJson(Map<String, dynamic> json) => Doctor(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      contactNumber: json['contact_number'] as String?,
      hospitalId: (json['hospital_id'] as num?)?.toInt(),
      availableDays: (json['available_days'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$DoctorToJson(Doctor instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'specialty': instance.specialty,
      'contact_number': instance.contactNumber,
      'hospital_id': instance.hospitalId,
      'available_days': instance.availableDays,
      'created_at': instance.createdAt?.toIso8601String(),
    };
