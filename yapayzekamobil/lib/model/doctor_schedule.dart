import 'package:json_annotation/json_annotation.dart';
import 'package:yapayzekamobil/model/hospital.dart';
import 'doctor.dart';

part 'doctor_schedule.g.dart';

@JsonSerializable()
class DoctorSchedule {
  final int? id;

  @JsonKey(name: 'schedule_date')
  final DateTime scheduleDate;

  @JsonKey(name: 'start_time')
  final String startTime;

  @JsonKey(name: 'end_time')
  final String endTime;

  @JsonKey(name: 'doctor_id')
  final int? doctorId;

  @JsonKey(name: 'hospital_id')
  final int? hospitalId;

  @JsonKey(ignore: true)
  final Hospital? hospital;

  @JsonKey(ignore: true)
  final Doctor? doctor;

  final bool available;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  DoctorSchedule({
    this.id,
    required this.scheduleDate,
    required this.startTime,
    required this.endTime,
    this.doctorId,
    this.hospitalId,
    this.hospital,
    this.doctor,
    this.available = true,
    this.createdAt,
  });

  factory DoctorSchedule.fromJson(Map<String, dynamic> json) {
    String processTimeString(String? timeStr) {
      if (timeStr == null || timeStr.isEmpty) {
        return "00:00";
      }
      if (timeStr.length > 5 && timeStr.contains(':')) {
        return timeStr.substring(0, 5);
      }
      return timeStr;
    }

    final String startTimeStr = json['startTime'] is String
        ? processTimeString(json['startTime'])
        : "00:00";

    final String endTimeStr = json['endTime'] is String
        ? processTimeString(json['endTime'])
        : "00:00";

    print("Doctor Schedule - Raw time: ${json['startTime']} -> Processed: $startTimeStr");

    int? docId = null;
    if (json.containsKey('doctorId')) {
      docId = json['doctorId'] as int?;
    } else if (json.containsKey('doctor_id')) {
      docId = json['doctor_id'] as int?;
    } else if (json.containsKey('doctor') && json['doctor'] is Map) {
      docId = (json['doctor'] as Map<String, dynamic>)['id'] as int?;
    }

    int? hospId = null;
    if (json.containsKey('hospitalId')) {
      hospId = json['hospitalId'] as int?;
    } else if (json.containsKey('hospital_id')) {
      hospId = json['hospital_id'] as int?;
    } else if (json.containsKey('hospital') && json['hospital'] is Map) {
      hospId = (json['hospital'] as Map<String, dynamic>)['id'] as int?;
    }

    DateTime date;
    try {
      if (json['scheduleDate'] is String) {
        date = DateTime.parse(json['scheduleDate'] as String);
      } else if (json['schedule_date'] is String) {
        date = DateTime.parse(json['schedule_date'] as String);
      } else {
        date = DateTime.now();
      }
    } catch (e) {
      print("Tarih parse hatası: $e");
      date = DateTime.now();
    }

    return DoctorSchedule(
      id: json['id'] as int?,
      scheduleDate: date,
      startTime: startTimeStr,
      endTime: endTimeStr,
      doctorId: docId,
      hospitalId: hospId,
      available: json['available'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : (json['created_at'] is String
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() => _$DoctorScheduleToJson(this);

  DateTime getStartDateTime() {
    return _parseTimeToDateTime(startTime, scheduleDate);
  }

  DateTime getEndDateTime() {
    return _parseTimeToDateTime(endTime, scheduleDate);
  }

  static DateTime _parseTimeToDateTime(String timeString, DateTime baseDate) {
    final parts = timeString.split(':');
    if (parts.length != 2) {
      print("Geçersiz zaman formatı: $timeString, varsayılan değere dönülüyor");
      return baseDate;
    }

    int hours;
    int minutes;

    try {
      hours = int.parse(parts[0]);
      minutes = int.parse(parts[1]);
    } catch (e) {
      print("Zaman parse hatası: $e");
      return baseDate;
    }

    print("Parsed time: $hours:$minutes from $timeString");

    return DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        hours,
        minutes
    );
  }

  @override
  String toString() {
    return 'DoctorSchedule(id: $id, scheduleDate: $scheduleDate, time: $startTime-$endTime, available: $available)';
  }
}