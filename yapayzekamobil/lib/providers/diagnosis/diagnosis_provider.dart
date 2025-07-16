import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yapayzekamobil/model/diagnosis.dart';
import 'package:yapayzekamobil/model/doctor.dart';
import 'package:yapayzekamobil/providers/auth/auth_state.dart';
import 'package:yapayzekamobil/services/diagnosis/diagnosis_service.dart';

class DiagnosisState {
  final bool isLoading;
  final Diagnosis? currentDiagnosis;
  final List<Doctor> recommendedDoctors;
  final String? errorMessage;

  DiagnosisState({
    this.isLoading = false,
    this.currentDiagnosis,
    this.recommendedDoctors = const [],
    this.errorMessage,
  });

  DiagnosisState copyWith({
    bool? isLoading,
    Diagnosis? currentDiagnosis,
    List<Doctor>? recommendedDoctors,
    String? errorMessage,
  }) {
    return DiagnosisState(
      isLoading: isLoading ?? this.isLoading,
      currentDiagnosis: currentDiagnosis ?? this.currentDiagnosis,
      recommendedDoctors: recommendedDoctors ?? this.recommendedDoctors,
      errorMessage: errorMessage,
    );
  }
}

class DiagnosisNotifier extends StateNotifier<DiagnosisState> {
  final DiagnosisService _diagnosisService;
  final AuthState _authState;

  DiagnosisNotifier(this._diagnosisService, this._authState)
      : super(DiagnosisState());

  Future<void> createDiagnosis(File imageFile, {String? notes}) async {
    state = DiagnosisState(isLoading: true);

    try {
      final result = await _diagnosisService.createDiagnosis(
          '/api/diagnoses/test',
          imageFile,
          notes: notes
      );

      state = state.copyWith(
        isLoading: false,
        currentDiagnosis: result['diagnosis'],
        recommendedDoctors: result['recommendedDoctors'] ?? [],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void resetState() {
    state = DiagnosisState();
  }

  Future<void> fetchDiagnosisById(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final diagnosis = await _diagnosisService.getDiagnosisById(id);
      state = state.copyWith(
        isLoading: false,
        currentDiagnosis: diagnosis,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> createAppointment(int doctorId) async {
    if (state.currentDiagnosis == null) {
      state = state.copyWith(
        errorMessage: 'No diagnosis selected',
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _diagnosisService.createAppointment(
          state.currentDiagnosis!.id!,
          doctorId
      );

      state = state.copyWith(
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final diagnosisProvider = StateNotifierProvider<DiagnosisNotifier, DiagnosisState>((ref) {
  final diagnosisService = ref.watch(diagnosisServiceProvider);
  final authState = ref.watch(authProvider);
  return DiagnosisNotifier(diagnosisService, authState);
});