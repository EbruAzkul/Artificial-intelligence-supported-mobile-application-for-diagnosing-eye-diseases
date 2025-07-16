import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yapayzekamobil/model/doctor.dart';
import 'package:yapayzekamobil/model/hospital.dart';

import '../api/api_service.dart';

class HospitalService {
  final ApiServiceInterface _apiService;

  HospitalService(this._apiService);

  Future<List<Hospital>> getHospitalsByCity({
    required String city,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final queryParams = {
        'city': city,
        if (latitude != null) 'latitude': latitude.toString(),
        if (longitude != null) 'longitude': longitude.toString(),
      };

      debugPrint('Hastane isteği: /api/hospitals/by-city?city=$city');

      final response = await _apiService.get(
          '/api/hospitals/by-city',
          queryParameters: queryParams
      );

      debugPrint('Hastane yanıtı alındı');
      debugPrint('Response type: ${response.runtimeType}');

      if (response is List) {
        debugPrint('Response is List with ${response.length} items');
      } else if (response is Map) {
        debugPrint('Response is Map with keys: ${response.keys.join(", ")}');
      } else {
        debugPrint('Response is: $response');
      }

      List<Hospital> hospitals = [];

      if (response is List) {
        debugPrint('API yanıtı liste formatında, ${response.length} hastane var');

        for (var item in response) {
          try {
            List<Doctor> doctors = [];

            if (item['doctors'] != null) {
              var doctorList = item['doctors'] as List;
              debugPrint('Hastane ${item['name']}: ${doctorList.length} doktor var');

              for (var docItem in doctorList) {
                try {
                  Doctor doctor = Doctor(
                    id: docItem['id'],
                    name: docItem['name'] ?? 'İsimsiz Doktor',
                    specialty: docItem['specialty'] ?? 'Belirtilmemiş',
                    contactNumber: docItem['contactNumber'],
                    hospitalId: item['id'],
                    availableDays: docItem['availableDays'] is List
                        ? List<String>.from(docItem['availableDays'])
                        : [],
                  );

                  debugPrint('Eklenen doktor: ${doctor.name}, Hastane ID: ${doctor.hospitalId}');

                  doctors.add(doctor);
                } catch (e) {
                  debugPrint('Doktor parse hatası: $e');
                  debugPrint('Hatalı doktor verisi: $docItem');
                }
              }
            } else {
              debugPrint('Hastane ${item['name']}: Doktor listesi bulunamadı veya boş');
            }

            Hospital hospital = Hospital(
              id: item['id'],
              name: item['name'] ?? 'İsimsiz Hastane',
              city: item['city'] ?? '',
              district: item['district'] ?? '',
              address: item['address'] ?? '',
              phone: item['phone'] ?? '',
              latitude: item['latitude'] is num ? item['latitude'].toDouble() : null,
              longitude: item['longitude'] is num ? item['longitude'].toDouble() : null,
              doctors: doctors,
            );

            debugPrint('Eklenen hastane: ${hospital.name}, Doktor sayısı: ${hospital.doctors?.length ?? 0}');

            hospitals.add(hospital);
          } catch (e) {
            debugPrint('Hastane parse hatası: $e');
            debugPrint('Hatalı hastane verisi: $item');
          }
        }
      } else if (response is Map && response['data'] is List) {
        var hospitalList = response['data'] as List;
        debugPrint('API yanıtı data wrapper içinde, ${hospitalList.length} hastane var');
      } else {
        debugPrint('API yanıtı beklenen formatta değil: ${response.runtimeType}');
      }

      debugPrint('Parsed ${hospitals.length} hospitals');
      for (var hospital in hospitals) {
        debugPrint('Hastane: ${hospital.name}, ID: ${hospital.id}');
        debugPrint('Doktor sayısı: ${hospital.doctors?.length ?? 0}');

        if (hospital.doctors != null && hospital.doctors!.isNotEmpty) {
          debugPrint('Doktorlar:');
          for (var doctor in hospital.doctors!) {
            debugPrint('- ${doctor.name} (${doctor.specialty})');
          }
        } else {
          debugPrint('Hastanede doktor bulunamadı');
        }
      }

      return hospitals;
    } catch (e, stackTrace) {
      debugPrint('Hastaneler alınırken hata: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  List<Doctor> filterDoctorsBySpecialty(List<Hospital> hospitals, String specialty) {
    List<Doctor> result = [];

    debugPrint('$specialty uzmanlığına göre doktorlar filtreleniyor');
    int totalDoctors = 0;

    for (var hospital in hospitals) {
      if (hospital.doctors != null) {
        totalDoctors += hospital.doctors!.length;

        final matchingDoctors = hospital.doctors!.where((doctor) =>
        doctor.specialty.toLowerCase() == specialty.toLowerCase()
        ).toList();

        debugPrint('${hospital.name}: ${matchingDoctors.length} uygun doktor bulundu');
        result.addAll(matchingDoctors);
      }
    }

    debugPrint('Toplam $totalDoctors doktor içinden ${result.length} doktor filtrelendi');
    return result;
  }

  List<Doctor> getAllDoctors(List<Hospital> hospitals) {
    List<Doctor> result = [];

    for (var hospital in hospitals) {
      if (hospital.doctors != null) {
        result.addAll(hospital.doctors!);
      }
    }

    return result;
  }

  Future<Hospital?> getHospitalById(int hospitalId) async {
    try {
      debugPrint('Hastane getiriliyor, ID: $hospitalId');

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

        Hospital hospital = Hospital(
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

        return hospital;
      }
      return null;
    } catch (e) {
      debugPrint('Hastane bilgileri alınırken hata: $e');
      return null;
    }
  }

  static final hospitalServiceProvider = Provider<HospitalService>((ref) {
    final apiService = ref.watch(apiServiceProvider);
    return HospitalService(apiService);
  });
}