import 'package:json_annotation/json_annotation.dart';
import 'doctor.dart';

part 'hospital.g.dart';

@JsonSerializable()
class Hospital {
  final int? id;
  final String name;
  final String city;
  final String district;
  final String address;
  final String phone;
  final double? latitude;
  final double? longitude;

  final List<Doctor>? doctors;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  Hospital({
    this.id,
    required this.name,
    required this.city,
    required this.district,
    required this.address,
    required this.phone,
    this.latitude,
    this.longitude,
    this.doctors,
    this.createdAt,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) => _$HospitalFromJson(json);
  Map<String, dynamic> toJson() => _$HospitalToJson(this);
}