package com.example.yapayzekabackend.controller;

import com.example.yapayzekabackend.dto.DiagnosisDTO;
import com.example.yapayzekabackend.model.Appointment;
import com.example.yapayzekabackend.model.Diagnosis;
import com.example.yapayzekabackend.model.Doctor;
import com.example.yapayzekabackend.model.User;
import com.example.yapayzekabackend.service.AppointmentService;
import com.example.yapayzekabackend.service.DiagnosisService;
import com.example.yapayzekabackend.service.DoctorService;
import com.example.yapayzekabackend.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/diagnoses")
public class DiagnosisController {

    @Autowired
    private DiagnosisService diagnosisService;

    @Autowired
    private DoctorService doctorService;

    @Autowired
    private AppointmentService appointmentService;

    @Autowired
    private UserService userService;

    @PostMapping("/test")
    public ResponseEntity<?> createTestDiagnosis(
            @RequestParam("image") MultipartFile imageFile,
            @RequestParam(value = "notes", required = false) String notes) {

        try {
            Diagnosis diagnosis = diagnosisService.createTestDiagnosis(imageFile, notes);
            return ResponseEntity.ok(new DiagnosisDTO(diagnosis));
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("message", "Teşhis oluşturulurken hata: " + e.getMessage()));
        }
    }

    @PostMapping("/user/{publicId}")
    public ResponseEntity<?> createUserDiagnosis(
            @PathVariable String publicId,
            @RequestParam("image") MultipartFile imageFile,
            @RequestParam(value = "notes", required = false) String notes) {

        try {
            Optional<User> userOpt = userService.findByPublicId(publicId);
            if (userOpt.isEmpty()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(Map.of("message", "Kullanıcı bulunamadı"));
            }

            User user = userOpt.get();
            Diagnosis diagnosis = diagnosisService.createDiagnosis(user, imageFile, notes);

            // Teşhis sonucuna göre doktor önerilerini de getir
            List<Doctor> recommendedDoctors = diagnosisService.getRecommendedDoctors(diagnosis.getId());

            // Yanıt nesnesini oluştur
            Map<String, Object> response = new HashMap<>();
            response.put("diagnosis", new DiagnosisDTO(diagnosis));
            response.put("recommendedDoctors", recommendedDoctors);

            return ResponseEntity.ok(response);
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("message", "Teşhis oluşturulurken hata: " + e.getMessage()));
        }
    }

    @GetMapping
    public ResponseEntity<List<DiagnosisDTO>> getAllDiagnoses() {
        List<Diagnosis> diagnoses = diagnosisService.getAllDiagnoses();
        List<DiagnosisDTO> diagnosisDTOs = diagnoses.stream()
                .map(DiagnosisDTO::new)
                .collect(Collectors.toList());
        return ResponseEntity.ok(diagnosisDTOs);
    }

    @GetMapping("/test")
    public ResponseEntity<String> testApi() {
        return ResponseEntity.ok("API çalışıyor!");
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getDiagnosis(@PathVariable Long id) {
        Optional<Diagnosis> diagnosis = diagnosisService.getDiagnosisById(id);
        if (diagnosis.isPresent()) {
            return ResponseEntity.ok(new DiagnosisDTO(diagnosis.get()));
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", "Teşhis bulunamadı"));
        }
    }

    @GetMapping("/{diagnosisId}/recommended-doctors")
    public ResponseEntity<?> getRecommendedDoctors(@PathVariable Long diagnosisId) {
        Optional<Diagnosis> diagnosisOpt = diagnosisService.getDiagnosisById(diagnosisId);

        if (diagnosisOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", "Teşhis bulunamadı"));
        }

        List<Doctor> recommendedDoctors = diagnosisService.getRecommendedDoctors(diagnosisId);

        return ResponseEntity.ok(recommendedDoctors);
    }

    @PostMapping("/{diagnosisId}/appointments")
    public ResponseEntity<?> createAppointment(
            @PathVariable Long diagnosisId,
            @RequestParam Long doctorId) {

        try {
            Diagnosis diagnosis = diagnosisService.getDiagnosisById(diagnosisId)
                    .orElseThrow(() -> new RuntimeException("Teşhis bulunamadı"));

            Doctor doctor = doctorService.findById(doctorId)
                    .orElseThrow(() -> new RuntimeException("Doktor bulunamadı"));

            Appointment appointment = Appointment.builder()
                    .user(diagnosis.getUser())
                    .doctor(doctor)
                    .appointmentDate(LocalDateTime.now().plusDays(1)) // Yarın için randevu
                    .status("SCHEDULED")
                    .build();

            Appointment savedAppointment = appointmentService.createAppointment(appointment);
            return ResponseEntity.status(HttpStatus.CREATED).body(savedAppointment);

        } catch (RuntimeException e) {
            return ResponseEntity.internalServerError()
                    .body(Map.of("error", e.getMessage()));
        }
    }


}