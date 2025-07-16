import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yapayzekamobil/model/doctor.dart';
import 'package:yapayzekamobil/model/hospital.dart';
import 'package:yapayzekamobil/services/hospital/hospital_service.dart';
import 'package:yapayzekamobil/services/location/location_service.dart';
import 'package:yapayzekamobil/services/api/api_service.dart';

class HospitalState {
  final bool isLoading;
  final LocationInfo? userLocation;
  final List<Hospital> hospitals;
  final List<Doctor> recommendedDoctors;
  final List<Doctor> allDoctors;
  final String specialty;
  final bool showAllDoctors;
  final String? errorMessage;
  final Hospital? currentHospital;

  HospitalState({
    this.isLoading = false,
    this.userLocation,
    this.hospitals = const [],
    this.recommendedDoctors = const [],
    this.allDoctors = const [],
    this.specialty = '',
    this.showAllDoctors = false,
    this.errorMessage,
    this.currentHospital,
  });

  HospitalState copyWith({
    bool? isLoading,
    LocationInfo? userLocation,
    List<Hospital>? hospitals,
    List<Doctor>? recommendedDoctors,
    List<Doctor>? allDoctors,
    String? specialty,
    bool? showAllDoctors,
    String? errorMessage,
    Hospital? currentHospital,
  }) {
    return HospitalState(
      isLoading: isLoading ?? this.isLoading,
      userLocation: userLocation ?? this.userLocation,
      hospitals: hospitals ?? this.hospitals,
      recommendedDoctors: recommendedDoctors ?? this.recommendedDoctors,
      allDoctors: allDoctors ?? this.allDoctors,
      specialty: specialty ?? this.specialty,
      showAllDoctors: showAllDoctors ?? this.showAllDoctors,
      errorMessage: errorMessage,
      currentHospital: currentHospital ?? this.currentHospital,
    );
  }
}

class HospitalNotifier extends StateNotifier<HospitalState> {
  final HospitalService _hospitalService;
  final LocationService _locationService;
  final ApiServiceInterface _apiService;

  HospitalNotifier(this._hospitalService, this._locationService, this._apiService)
      : super(HospitalState());

  void toggleShowAllDoctors() {
    state = state.copyWith(showAllDoctors: !state.showAllDoctors);
  }

  Future<void> fetchHospitalDetails(int hospitalId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      debugPrint('Hastane detayları getiriliyor, ID: $hospitalId');

      Hospital? hospital;

      if (state.hospitals.isNotEmpty) {
        hospital = state.hospitals.firstWhere(
              (h) => h.id == hospitalId,
          orElse: () => null as Hospital,
        );

        if (hospital != null) {
          debugPrint('Hastane state\'ten bulundu: ${hospital.name}');
        }
      }

      if (hospital == null || hospital.doctors == null || hospital.doctors!.isEmpty) {
        debugPrint('Hastane bilgileri API\'den alınıyor...');

        final response = await _apiService.get('/api/hospitals/$hospitalId');

        if (response != null) {
          List<Doctor> doctors = [];

          if (response['doctors'] != null) {
            var doctorList = response['doctors'] as List;
            debugPrint('Hastane ${response['name']}: ${doctorList.length} doktor var');

            for (var docItem in doctorList) {
              try {
                Doctor doctor = Doctor(
                  id: docItem['id'],
                  name: docItem['name'] ?? 'İsimsiz Doktor',
                  specialty: docItem['specialty'] ?? 'Belirtilmemiş',
                  contactNumber: docItem['contactNumber'],
                  hospitalId: response['id'],
                  availableDays: docItem['availableDays'] is List
                      ? List<String>.from(docItem['availableDays'])
                      : [],
                );

                doctors.add(doctor);
              } catch (e) {
                debugPrint('Doktor parse hatası: $e');
              }
            }
          }

          hospital = Hospital(
            id: response['id'],
            name: response['name'] ?? 'İsimsiz Hastane',
            city: response['city'] ?? '',
            district: response['district'] ?? '',
            address: response['address'] ?? '',
            phone: response['phone'] ?? '',
            latitude: response['latitude'] is num ? response['latitude'].toDouble() : null,
            longitude: response['longitude'] is num ? response['longitude'].toDouble() : null,
            doctors: doctors,
          );

          debugPrint('Hastane API\'den alındı: ${hospital.name}');
          debugPrint('Hastanedeki doktor sayısı: ${hospital.doctors?.length ?? 0}');
        }
      }

      if (hospital != null) {
        state = state.copyWith(
          isLoading: false,
          currentHospital: hospital,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Hastane bilgileri bulunamadı.',
        );
      }
    } catch (e) {
      debugPrint('Hastane detayları alınırken hata: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Hastane bilgileri alınırken bir hata oluştu: ${e.toString()}',
      );
    }
  }

  Future<void> loadHospitalsNearby() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final locationInfo = await _locationService.getCurrentLocationDetails();

      if (locationInfo == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Konum bilgisi alınamadı. Lütfen konum servislerini ve izinleri kontrol edin.',
        );
        return;
      }

      String city = locationInfo.city.isEmpty ? "Malatya" : locationInfo.city;

      final hospitals = await _hospitalService.getHospitalsByCity(
          city: city,
          latitude: locationInfo.latitude,
          longitude: locationInfo.longitude
      );

      debugPrint('Hastaneler yüklendi: ${hospitals.length}');

      for (var hospital in hospitals) {
        debugPrint('Hastane: ${hospital.name}, Doktor sayısı: ${hospital.doctors?.length ?? 0}');
      }

      List<Doctor> allDoctors = _hospitalService.getAllDoctors(hospitals);

      debugPrint('Toplam doktor sayısı: ${allDoctors.length}');

      for (var doctor in allDoctors) {
        debugPrint('Doktor: ${doctor.name}, Uzmanlık: ${doctor.specialty}, Hastane ID: ${doctor.hospitalId}');
      }

      state = state.copyWith(
        isLoading: false,
        hospitals: hospitals,
        userLocation: locationInfo,
        allDoctors: allDoctors,
      );
    } catch (e) {
      debugPrint('Hastane yüklenirken hata: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Hastaneler yüklenirken hata oluştu: ${e.toString()}',
      );
    }
  }

  Future<void> findRecommendedHospitalsAndDoctors(String specialty) async {
    state = state.copyWith(isLoading: true, errorMessage: null, specialty: specialty);

    try {
      final locationInfo = await _locationService.getCurrentLocationDetails();

      if (locationInfo == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Konum bilgisi alınamadı. Lütfen konum servislerini ve izinleri kontrol edin.',
        );
        return;
      }

      debugPrint('Konumdan alınan bilgiler:');
      debugPrint('Enlem: ${locationInfo.latitude}');
      debugPrint('Boylam: ${locationInfo.longitude}');
      debugPrint('Şehir: ${locationInfo.city}');
      debugPrint('İlçe: ${locationInfo.district}');

      String city = locationInfo.city.isEmpty ? "Malatya" : locationInfo.city;

      final hospitals = await _hospitalService.getHospitalsByCity(
          city: city,
          latitude: locationInfo.latitude,
          longitude: locationInfo.longitude
      );

      debugPrint('Alınan hastaneler: ${hospitals.length}');

      final allDoctors = _hospitalService.getAllDoctors(hospitals);
      debugPrint('Tüm doktorlar: ${allDoctors.length}');

      final recommendedDoctors = _hospitalService.filterDoctorsBySpecialty(hospitals, specialty);
      debugPrint('Önerilen doktorlar: ${recommendedDoctors.length}');

      state = state.copyWith(
        isLoading: false,
        userLocation: locationInfo,
        hospitals: hospitals,
        recommendedDoctors: recommendedDoctors,
        allDoctors: allDoctors,
      );
    } catch (e) {
      debugPrint('Hastane ve doktor sorgulamada hata: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Bir hata oluştu: ${e.toString()}',
      );
    }
  }
}

final hospitalProvider = StateNotifierProvider<HospitalNotifier, HospitalState>((ref) {
  final hospitalService = ref.watch(HospitalService.hospitalServiceProvider);
  final locationService = ref.watch(locationServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  return HospitalNotifier(hospitalService, locationService, apiService);
});