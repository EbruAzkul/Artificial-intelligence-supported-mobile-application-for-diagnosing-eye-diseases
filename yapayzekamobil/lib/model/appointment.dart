import 'package:json_annotation/json_annotation.dart';
import '../model/hospital.dart';
import 'user.dart';
import '../model/doctor.dart';

part 'appointment.g.dart';

@JsonSerializable()
class Appointment {
  final int? id;
  final String status;

  @JsonKey(name: 'appointment_date')
  final DateTime appointmentDate;

  @JsonKey(name: 'user_id')
  final int? userId;

  @JsonKey(ignore: true)
  final User? user;

  @JsonKey(name: 'doctor_id')
  final int? doctorId;

  @JsonKey(ignore: true)
  final Doctor? doctor;

  @JsonKey(name: 'hospital_id')
  final int? hospitalId;

  @JsonKey(ignore: true)
  final Hospital? hospital;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  Appointment({
    this.id,
    required this.status,
    required this.appointmentDate,
    this.userId,
    this.user,
    this.doctorId,
    this.doctor,
    this.hospitalId,
    this.hospital,
    this.createdAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}