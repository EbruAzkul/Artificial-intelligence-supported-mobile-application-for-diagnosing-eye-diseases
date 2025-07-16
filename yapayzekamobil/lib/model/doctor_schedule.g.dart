// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoctorSchedule _$DoctorScheduleFromJson(Map<String, dynamic> json) =>
    DoctorSchedule(
      id: (json['id'] as num?)?.toInt(),
      scheduleDate: DateTime.parse(json['schedule_date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      doctorId: (json['doctor_id'] as num?)?.toInt(),
      hospitalId: (json['hospital_id'] as num?)?.toInt(),
      available: json['available'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$DoctorScheduleToJson(DoctorSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'schedule_date': instance.scheduleDate.toIso8601String(),
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'doctor_id': instance.doctorId,
      'hospital_id': instance.hospitalId,
      'available': instance.available,
      'created_at': instance.createdAt?.toIso8601String(),
    };
