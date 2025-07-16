import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yapayzekamobil/model/diagnosis.dart';
import 'package:yapayzekamobil/model/doctor.dart';
import 'package:yapayzekamobil/services/api/api_service.dart';

class DiagnosisService {
  final ApiServiceInterface _apiService;

  DiagnosisService(this._apiService);

  Future<Map<String, dynamic>> createDiagnosis(
      String endpoint,
      File imageFile,
      {String? notes}
      ) async {
    try {
      final response = await _apiService.uploadFile(
        endpoint,
        imageFile,
        fields: notes != null && notes.isNotEmpty
            ? {'notes': notes}
            : {},
      );

      debugPrint('Full response in service: $response');

      final diagnosis = Diagnosis(
        id: response['id'],
        predictedClass: response['predictedClass'],
        confidence: (response['confidence'] as num).toDouble(),
        allProbabilities: Map<String, double>.from(
            response['allProbabilities'].map(
                    (key, value) => MapEntry(key, (value as num).toDouble())
            )
        ),
        notes: response['notes'],
        imagePath: response['imagePath'],
        createdAt: DateTime.parse(response['createdAt']),
      );

      return {
        'diagnosis': diagnosis,
        'recommendedDoctors': <Doctor>[],
      };
    } catch (e) {
      print('Diagnosis creation error: $e');
      rethrow;
    }
  }

  Future<Diagnosis> getDiagnosisById(int id) async {
    try {
      final response = await _apiService.get('/api/diagnoses/$id');
      return Diagnosis.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get diagnosis: $e');
    }
  }

  Future<List<Diagnosis>> getAllDiagnoses() async {
    try {
      final response = await _apiService.get('/api/diagnoses');
      return (response as List)
          .map((diagnosisJson) => Diagnosis.fromJson(diagnosisJson))
          .toList();
    } catch (e) {
      throw Exception('Failed to get diagnoses: $e');
    }
  }

  Future<List<Doctor>> getRecommendedDoctors(int diagnosisId) async {
    try {
      final response = await _apiService.get('/api/diagnoses/$diagnosisId/recommended-doctors');
      return (response as List)
          .map((doctorJson) => Doctor.fromJson(doctorJson))
          .toList();
    } catch (e) {
      throw Exception('Failed to get recommended doctors: $e');
    }
  }

  Future<dynamic> createAppointment(int diagnosisId, int doctorId) async {
    try {
      final response = await _apiService.post(
          '/api/diagnoses/$diagnosisId/appointments',
          {'doctorId': doctorId}
      );
      return response;
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }
}

final diagnosisServiceProvider = Provider<DiagnosisService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return DiagnosisService(apiService);
});