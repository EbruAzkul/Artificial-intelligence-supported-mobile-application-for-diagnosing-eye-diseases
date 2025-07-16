import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yapayzekamobil/model/doctor_schedule.dart';

import '../api/api_service.dart';

class AppointmentService {
  final ApiServiceInterface _apiService;

  AppointmentService(this._apiService);

  Future<List<DoctorSchedule>> getDoctorSchedules(int doctorId) async {
    try {
      final response = await _apiService.get('/api/schedules/doctor/$doctorId');
      debugPrint('Schedule response: $response');

      if (response is List) {
        return response.map((json) => DoctorSchedule.fromJson(json)).toList();
      } else if (response is Map && response.containsKey('data') && response['data'] is List) {
        return (response['data'] as List).map((json) => DoctorSchedule.fromJson(json)).toList();
      } else {
        debugPrint('Unexpected response format: $response');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching doctor schedules: $e');
      rethrow;
    }
  }

  List<DateTime> getAvailableDates(List<DoctorSchedule> schedules) {
    final now = DateTime.now();

    final validSchedules = schedules.where((schedule) {
      if (!schedule.available) return false;

      final scheduleDate = schedule.scheduleDate;

      if (scheduleDate.year < now.year) return false;
      if (scheduleDate.year == now.year && scheduleDate.month < now.month) return false;
      if (scheduleDate.year == now.year && scheduleDate.month == now.month && scheduleDate.day < now.day) return false;

      if (scheduleDate.year == now.year && scheduleDate.month == now.month && scheduleDate.day == now.day) {
        final timeParts = schedule.startTime.split(':');
        if (timeParts.length >= 2) {
          final scheduleHour = int.tryParse(timeParts[0]) ?? 0;
          final scheduleMinute = int.tryParse(timeParts[1]) ?? 0;

          if (scheduleHour < now.hour) return false;
          if (scheduleHour == now.hour && scheduleMinute <= now.minute) return false;
        }
      }

      return true;
    });

    final dates = validSchedules
        .map((schedule) => DateTime(
      schedule.scheduleDate.year,
      schedule.scheduleDate.month,
      schedule.scheduleDate.day,
    ))
        .toSet()
        .toList();

    dates.sort((a, b) => a.compareTo(b));

    debugPrint('Available dates after filtering: $dates');
    return dates;
  }

  List<DoctorSchedule> getAvailableTimesForDate(
      List<DoctorSchedule> schedules, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    final isToday = selectedDate.isAtSameMomentAs(today);

    final availableTimes = schedules
        .where((schedule) {
      final sameDate =
          schedule.scheduleDate.year == date.year &&
              schedule.scheduleDate.month == date.month &&
              schedule.scheduleDate.day == date.day;

      final isAvailable = schedule.available;

      if (isToday) {
        final timeParts = schedule.startTime.split(':');
        if (timeParts.length >= 2) {
          final scheduleHour = int.tryParse(timeParts[0]) ?? 0;
          final scheduleMinute = int.tryParse(timeParts[1]) ?? 0;

          if (scheduleHour < now.hour ||
              (scheduleHour == now.hour && scheduleMinute <= now.minute)) {
            return false;
          }
        }
      }

      return sameDate && isAvailable;
    })
        .toList();

    availableTimes.sort((a, b) => a.startTime.compareTo(b.startTime));

    return availableTimes;
  }

  Future<dynamic> createAppointment(Map<String, dynamic> appointmentData) async {
    try {
      debugPrint('Randevu Oluşturma İsteği Detayları:');
      appointmentData.forEach((key, value) {
        debugPrint('$key: $value');
      });

      final formattedData = _formatAppointmentData(appointmentData);

      debugPrint('POST REQUEST DETAILS:');
      debugPrint('Endpoint: /api/appointments');
      debugPrint('Data: $formattedData');

      final response = await _apiService.post('/api/appointments', formattedData);

      debugPrint('Randevu Oluşturma Yanıtı: $response');
      return response;
    } catch (e) {
      debugPrint('Randevu Oluşturma Hatası: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _formatAppointmentData(Map<String, dynamic> data) {
    final scheduleDate = DateTime.parse(data['appointmentDate']);
    final startTimeComponents = data['startTime'].split(':');
    final hour = int.parse(startTimeComponents[0]);
    final minute = int.parse(startTimeComponents[1]);

    final appointmentDateTime = DateTime(
        scheduleDate.year,
        scheduleDate.month,
        scheduleDate.day,
        hour,
        minute
    );

    final formattedData = {
      'appointmentDate': appointmentDateTime.toIso8601String(),
      'status': data['status'] ?? 'CONFIRMED',
      'user': {
        'id': data['userId']
      },
      'doctor': {
        'id': data['doctorId']
      },
      'hospital': {
        'id': data['hospitalId']
      }
    };

    debugPrint('Formatted appointment data: $formattedData');
    return formattedData;
  }

  Future<dynamic> testCreateAppointment(int doctorId, int userId, DateTime appointmentDate) async {
    final testData = {
      'appointmentDate': appointmentDate.toIso8601String(),
      'status': 'CONFIRMED',
      'user': {
        'id': userId
      },
      'doctor': {
        'id': doctorId
      }
    };

    debugPrint('TEST: Creating appointment with minimal data: $testData');
    try {
      final response = await _apiService.post('/api/appointments', testData);
      debugPrint('TEST RESPONSE: $response');
      return response;
    } catch (e) {
      debugPrint('TEST ERROR: $e');
      rethrow;
    }
  }

  Future<dynamic> updateScheduleAvailability(int scheduleId, bool available) async {
    try {
      debugPrint('Schedule Güncelleme İsteği:');
      debugPrint('Schedule ID: $scheduleId');
      debugPrint('Available: $available');

      final updateData = {
        'id': scheduleId,
        'available': available
      };

      debugPrint('Simplified update data: $updateData');

      final response = await _apiService.put('/api/schedules/$scheduleId', updateData);

      debugPrint('Schedule Güncelleme Yanıtı: $response');
      return response;
    } catch (e) {
      debugPrint('Schedule Güncelleme Hatası: $e');
      rethrow;
    }
  }
}

final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AppointmentService(apiService);
});