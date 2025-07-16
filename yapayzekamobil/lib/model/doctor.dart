import 'package:json_annotation/json_annotation.dart';
import 'hospital.dart';

part 'doctor.g.dart';

@JsonSerializable()
class Doctor {
  final int? id;
  final String name;

  @JsonKey(name: 'specialty')
  final String specialty;

  @JsonKey(name: 'contact_number')
  final String? contactNumber;

  @JsonKey(name: 'hospital_id')
  final int? hospitalId;

  @JsonKey(ignore: true)
  final Hospital? hospital;

  @JsonKey(name: 'available_days')
  final List<String>? availableDays;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  Doctor({
    this.id,
    required this.name,
    required this.specialty,
    this.contactNumber,
    this.hospitalId,
    this.hospital,
    this.availableDays,
    this.createdAt,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) => _$DoctorFromJson(json);
  Map<String, dynamic> toJson() => _$DoctorToJson(this);
}