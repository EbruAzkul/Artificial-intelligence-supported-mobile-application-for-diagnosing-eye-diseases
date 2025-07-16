// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
      id: (json['id'] as num?)?.toInt(),
      status: json['status'] as String,
      appointmentDate: DateTime.parse(json['appointment_date'] as String),
      userId: (json['user_id'] as num?)?.toInt(),
      doctorId: (json['doctor_id'] as num?)?.toInt(),
      hospitalId: (json['hospital_id'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'appointment_date': instance.appointmentDate.toIso8601String(),
      'user_id': instance.userId,
      'doctor_id': instance.doctorId,
      'hospital_id': instance.hospitalId,
      'created_at': instance.createdAt?.toIso8601String(),
    };
