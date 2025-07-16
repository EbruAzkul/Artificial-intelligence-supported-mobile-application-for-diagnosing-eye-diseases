import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yapayzekamobil/model/doctor.dart';
import 'package:yapayzekamobil/model/doctor_schedule.dart';
import 'package:yapayzekamobil/providers/auth/auth_state.dart';
import 'package:yapayzekamobil/services/api/api_service.dart';
import 'package:yapayzekamobil/services/appointment/appointment_service.dart' show AppointmentService, appointmentServiceProvider;

class AppointmentState {
  final bool isLoading;
  final String? errorMessage;
  final List<DoctorSchedule> schedules;
  final List<DateTime> availableDates;
  final DateTime? selectedDate;
  final DoctorSchedule? selectedSchedule;
  final bool appointmentCreated;
  final Map<String, dynamic>? lastResponse;
  final List<dynamic> appointments;

  AppointmentState({
    this.isLoading = false,
    this.errorMessage,
    this.schedules = const [],
    this.availableDates = const [],
    this.selectedDate,
    this.selectedSchedule,
    this.appointmentCreated = false,
    this.lastResponse,
    this.appointments = const [],
  });

  AppointmentState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<DoctorSchedule>? schedules,
    List<DateTime>? availableDates,
    DateTime? selectedDate,
    DoctorSchedule? selectedSchedule,
    bool? appointmentCreated,
    Map<String, dynamic>? lastResponse,
    List<dynamic>? appointments,
  }) {
    return AppointmentState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      schedules: schedules ?? this.schedules,
      availableDates: availableDates ?? this.availableDates,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedSchedule: selectedSchedule ?? this.selectedSchedule,
      appointmentCreated: appointmentCreated ?? this.appointmentCreated,
      lastResponse: lastResponse ?? this.lastResponse,
      appointments: appointments ?? this.appointments,
    );
  }
}

class AppointmentNotifier extends StateNotifier<AppointmentState> {
  final AppointmentService _appointmentService;
  final ApiServiceInterface _apiService;
  final StateNotifierProviderRef ref;

  AppointmentNotifier(this._appointmentService, this._apiService, this.ref) : super(AppointmentState());

  Future<void> fetchUserAppointments(int userId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final authState = ref.read(authProvider);

      if (!authState.isAuthenticated || authState.user?.id == null) {
        throw Exception('Kullanıcı girişi yapılmamış veya ID bilgisi eksik');
      }

      final currentUserId = authState.user!.id!;

      debugPrint('fetchUserAppointments çağrıldı, güncel kullanıcı ID: $currentUserId');

      final apiUrl = '/api/appointments/user/$currentUserId';
      debugPrint(' API isteği: $apiUrl');

      final apiResponse = await _apiService.get(apiUrl);

      debugPrint('API yanıtı türü: ${apiResponse.runtimeType}');
      debugPrint('API yanıtı: $apiResponse');

      if (apiResponse is List) {
        state = state.copyWith(
          isLoading: false,
          appointments: apiResponse,
        );
        debugPrint('Randevular başarıyla alındı: ${apiResponse.length} adet');
      } else if (apiResponse is Map && apiResponse.containsKey('data')) {
        final appointmentsData = apiResponse['data'];
        if (appointmentsData is List) {
          state = state.copyWith(
            isLoading: false,
            appointments: appointmentsData,
          );
          debugPrint('Randevular başarıyla alındı: ${appointmentsData.length} adet');
        } else {
          throw Exception('Unexpected data format: $appointmentsData');
        }
      } else {
        debugPrint('Beklenmeyen yanıt formatı: $apiResponse');
        throw Exception('Beklenmeyen yanıt formatı');
      }
    } catch (e, stackTrace) {
      debugPrint('Kullanıcı randevuları alınırken hata: $e');
      debugPrint('Stack trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Randevuları yüklerken hata oluştu: ${e.toString()}',
      );
    }
  }

  Future<void> cancelAppointment(int appointmentId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      debugPrint('Randevu iptali: ID #$appointmentId');

      await _apiService.delete('/api/appointments/$appointmentId');

      final updatedAppointments = state.appointments.where((appointment) =>
      appointment['id'] != appointmentId).toList();

      state = state.copyWith(
        isLoading: false,
        appointments: updatedAppointments,
      );

      debugPrint('Randevu başarıyla iptal edildi: ID #$appointmentId');
    } catch (e) {
      debugPrint('Randevu iptal edilirken hata: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to cancel appointment: ${e.toString()}',
      );
    }
  }

  List<DoctorSchedule> _filterPastSchedules(List<DoctorSchedule> schedules) {
    final now = DateTime.now();

    return schedules.where((schedule) {
      if (schedule.scheduleDate.year < now.year ||
          (schedule.scheduleDate.year == now.year && schedule.scheduleDate.month < now.month) ||
          (schedule.scheduleDate.year == now.year && schedule.scheduleDate.month == now.month && schedule.scheduleDate.day < now.day)) {
        return false;
      }

      if (schedule.scheduleDate.year == now.year &&
          schedule.scheduleDate.month == now.month &&
          schedule.scheduleDate.day == now.day) {

        final timeParts = schedule.startTime.split(':');
        if (timeParts.length >= 2) {
          final scheduleHour = int.tryParse(timeParts[0]) ?? 0;
          final scheduleMinute = int.tryParse(timeParts[1]) ?? 0;

          if (scheduleHour < now.hour ||
              (scheduleHour == now.hour && scheduleMinute < now.minute)) {
            return false;
          }
        }
      }

      return schedule.available;
    }).toList();
  }

  Future<void> fetchDoctorSchedules(Doctor doctor) async {
    if (doctor.id == null) {
      debugPrint('Error: Doctor ID is null');
      state = state.copyWith(
        errorMessage: 'Doctor information is incomplete',
      );
      return;
    }

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final schedules = await _appointmentService.getDoctorSchedules(doctor.id!);

      final availableSchedules = _filterPastSchedules(schedules);

      final availableDates = _appointmentService.getAvailableDates(availableSchedules);

      debugPrint('Doktor Zamanları Yüklendi:');
      debugPrint('Toplam Zaman Dilimi: ${schedules.length}');
      debugPrint('Müsait Zaman Dilimi: ${availableSchedules.length}');
      debugPrint('Müsait Günler: ${availableDates.length}');

      DateTime? firstDate = availableDates.isNotEmpty ? availableDates.first : null;
      DoctorSchedule? firstSchedule;

      if (firstDate != null) {
        final timesForFirstDate = availableSchedules.where((s) =>
        s.scheduleDate.year == firstDate.year &&
            s.scheduleDate.month == firstDate.month &&
            s.scheduleDate.day == firstDate.day
        ).toList();

        if (timesForFirstDate.isNotEmpty) {
          firstSchedule = timesForFirstDate.first;
        }
      }

      state = state.copyWith(
        isLoading: false,
        schedules: schedules,
        availableDates: availableDates,
        selectedDate: firstDate,
        selectedSchedule: firstSchedule,
      );
    } catch (e) {
      debugPrint('Doktor Zamanları Yüklenirken Hata: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load doctor schedules: ${e.toString()}',
      );
    }
  }

  void selectDate(DateTime date) {
    final availableTimes = _appointmentService.getAvailableTimesForDate(
        state.schedules,
        date
    );

    debugPrint('Tarih Seçildi:');
    debugPrint('Seçilen Tarih: $date');
    debugPrint('Müsait Zaman Dilimleri: ${availableTimes.length}');

    DoctorSchedule? firstSchedule;
    if (availableTimes.isNotEmpty) {
      firstSchedule = availableTimes.first;
    }

    state = state.copyWith(
      selectedDate: date,
      selectedSchedule: firstSchedule,
    );
  }

  void selectSchedule(DoctorSchedule schedule) {
    debugPrint('Zaman Dilimi Seçildi:');
    debugPrint('Tarih: ${schedule.scheduleDate}');
    debugPrint('Başlangıç Saati: ${schedule.startTime}');
    debugPrint('Bitiş Saati: ${schedule.endTime}');
    debugPrint('Schedule ID: ${schedule.id}');

    state = state.copyWith(
      selectedSchedule: schedule,
      appointmentCreated: false,
    );
  }

  Future<void> createAppointment(Doctor doctor) async {
    if (state.selectedSchedule == null) {
      debugPrint('Hata: Zaman dilimi seçilmedi');
      state = state.copyWith(errorMessage: 'Lütfen bir zaman dilimi seçin');
      return;
    }

    if (doctor.id == null) {
      debugPrint('Hata: Doktor ID null');
      state = state.copyWith(errorMessage: 'Doktor bilgisi eksik');
      return;
    }

    if (doctor.hospitalId == null) {
      debugPrint('Hata: Hastane ID null');
      state = state.copyWith(errorMessage: 'Hastane bilgisi eksik');
      return;
    }

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final authState = ref.read(authProvider);

      debugPrint('Auth Status Check:');
      debugPrint('Is Authenticated: ${authState.isAuthenticated}');
      debugPrint('User Object: ${authState.user}');
      if (authState.user != null) {
        debugPrint('User ID: ${authState.user!.id}');
        debugPrint('User Email: ${authState.user!.email}');
        debugPrint('User Name: ${authState.user!.name}');
      }

      if (!authState.isAuthenticated || authState.user == null) {
        throw Exception('Randevu almak için giriş yapmalısınız');
      }

      if (authState.user!.id == null) {
        throw Exception('Kullanıcı ID bilgisi eksik. Lütfen tekrar giriş yapın.');
      }

      if (state.selectedSchedule!.id == null) {
        throw Exception('Schedule ID not found');
      }

      debugPrint('Randevu Oluşturma Akışı Başlatılıyor:');
      debugPrint('Kullanıcı ID: ${authState.user!.id}');
      debugPrint('Doktor ID: ${doctor.id}');
      debugPrint('Hastane ID: ${doctor.hospitalId}');
      debugPrint('Schedule ID: ${state.selectedSchedule!.id}');
      debugPrint('Schedule Date: ${state.selectedSchedule!.scheduleDate.toIso8601String()}');
      debugPrint('Start Time: ${state.selectedSchedule!.startTime}');

      final scheduleDate = state.selectedSchedule!.scheduleDate;
      final startTimeComponents = state.selectedSchedule!.startTime.split(':');
      final hour = int.parse(startTimeComponents[0]);
      final minute = int.parse(startTimeComponents[1]);

      final appointmentDateTime = DateTime(
          scheduleDate.year,
          scheduleDate.month,
          scheduleDate.day,
          hour,
          minute
      );

      final appointmentData = {
        'appointmentDate': appointmentDateTime.toIso8601String(),
        'status': 'CONFIRMED',
        'user': {
          'id': authState.user!.id
        },
        'doctor': {
          'id': doctor.id
        },
        'hospital': {
          'id': doctor.hospitalId
        }
      };

      debugPrint('Randevu API çağrısı yapılıyor...');
      debugPrint('Data: $appointmentData');
      debugPrint('Gönderilen hastane ID: ${doctor.hospitalId}');

      final appointmentResponse = await _apiService.post('/api/appointments', appointmentData);
      debugPrint('Randevu oluşturma yanıtı: $appointmentResponse');

    } catch (e) {
      debugPrint('$e');
    }
  }

  void resetState() {
    state = AppointmentState();
  }
}

final appointmentProvider = StateNotifierProvider<AppointmentNotifier, AppointmentState>((ref) {
  final appointmentService = ref.watch(appointmentServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  return AppointmentNotifier(appointmentService, apiService, ref);
});