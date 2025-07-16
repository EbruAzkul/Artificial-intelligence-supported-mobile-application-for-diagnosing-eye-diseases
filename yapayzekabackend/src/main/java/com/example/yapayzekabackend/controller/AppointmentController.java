package com.example.yapayzekabackend.controller;

import com.example.yapayzekabackend.dto.AppointmentDTO;
import com.example.yapayzekabackend.dto.DoctorSimpleDTO;
import com.example.yapayzekabackend.dto.HospitalSimpleDTO;
import com.example.yapayzekabackend.dto.UserSimpleDTO;
import com.example.yapayzekabackend.model.Appointment;
import com.example.yapayzekabackend.model.Doctor;
import com.example.yapayzekabackend.model.Hospital;
import com.example.yapayzekabackend.model.User;
import com.example.yapayzekabackend.service.AppointmentService;
import com.example.yapayzekabackend.service.DoctorService;
import com.example.yapayzekabackend.service.HospitalService;
import com.example.yapayzekabackend.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

// AppointmentController.java - Modify to handle hospital
@RestController
@RequestMapping("/api/appointments")
@RequiredArgsConstructor
public class AppointmentController {
    private final AppointmentService appointmentService;
    private final UserService userService;
    private final DoctorService doctorService;
    private final HospitalService hospitalService; // Add HospitalService

    @PostMapping
    public ResponseEntity<?> createAppointment(@RequestBody Map<String, Object> appointmentRequest) {
        try {
            // Request'ten gerekli verileri çıkar
            Appointment appointment = new Appointment();

            // Parse AppointmentDate
            if (appointmentRequest.containsKey("appointmentDate")) {
                String dateStr = appointmentRequest.get("appointmentDate").toString();
                appointment.setAppointmentDate(java.time.LocalDateTime.parse(dateStr));
            }

            // Parse Status
            if (appointmentRequest.containsKey("status")) {
                appointment.setStatus(appointmentRequest.get("status").toString());
            } else {
                appointment.setStatus("CONFIRMED"); // Varsayılan değer
            }

            // Parse User
            if (appointmentRequest.containsKey("user") && appointmentRequest.get("user") instanceof Map) {
                Map<String, Object> userMap = (Map<String, Object>) appointmentRequest.get("user");
                if (userMap.containsKey("id")) {
                    Long userId = Long.valueOf(userMap.get("id").toString());
                    Optional<User> userOpt = userService.findById(userId);
                    if (userOpt.isPresent()) {
                        appointment.setUser(userOpt.get());
                    } else {
                        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                .body(Map.of("message", "User not found with ID: " + userId));
                    }
                }
            }

            // Parse Doctor
            if (appointmentRequest.containsKey("doctor") && appointmentRequest.get("doctor") instanceof Map) {
                Map<String, Object> doctorMap = (Map<String, Object>) appointmentRequest.get("doctor");
                if (doctorMap.containsKey("id")) {
                    Long doctorId = Long.valueOf(doctorMap.get("id").toString());
                    Optional<Doctor> doctorOpt = doctorService.findById(doctorId);
                    if (doctorOpt.isPresent()) {
                        appointment.setDoctor(doctorOpt.get());
                    } else {
                        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                .body(Map.of("message", "Doctor not found with ID: " + doctorId));
                    }
                }
            }

            // Parse Hospital
            if (appointmentRequest.containsKey("hospital") && appointmentRequest.get("hospital") instanceof Map) {
                Map<String, Object> hospitalMap = (Map<String, Object>) appointmentRequest.get("hospital");
                if (hospitalMap.containsKey("id")) {
                    Long hospitalId = Long.valueOf(hospitalMap.get("id").toString());
                    Optional<Hospital> hospitalOpt = hospitalService.findById(hospitalId);
                    if (hospitalOpt.isPresent()) {
                        appointment.setHospital(hospitalOpt.get());
                    } else {
                        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                .body(Map.of("message", "Hospital not found with ID: " + hospitalId));
                    }
                }
            }

            // Gerekli alanları kontrol et
            if (appointment.getAppointmentDate() == null) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(Map.of("message", "Appointment date is required"));
            }

            if (appointment.getUser() == null) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(Map.of("message", "User is required"));
            }

            if (appointment.getDoctor() == null) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(Map.of("message", "Doctor is required"));
            }

            if (appointment.getHospital() == null) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(Map.of("message", "Hospital is required"));
            }

            // Randevuyu kaydet
            Appointment saved = appointmentService.createAppointment(appointment);
            return ResponseEntity.ok(convertToDTO(saved));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("message", "Failed to create appointment: " + e.getMessage()));
        }
    }

    @GetMapping
    public ResponseEntity<List<AppointmentDTO>> getAllAppointments() {
        List<Appointment> appointments = appointmentService.getAllAppointments();
        List<AppointmentDTO> dtos = appointments.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<AppointmentDTO>> getUserAppointments(@PathVariable Long userId) {
        List<Appointment> appointments = appointmentService.findByUserId(userId);
        List<AppointmentDTO> dtos = appointments.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getAppointmentById(@PathVariable Long id) {
        Optional<Appointment> appointment = appointmentService.findById(id);
        if (appointment.isPresent()) {
            return ResponseEntity.ok(convertToDTO(appointment.get()));
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", "Randevu bulunamadı"));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateAppointmentStatus(
            @PathVariable Long id,
            @RequestParam String status) {
        try {
            Appointment updatedAppointment = appointmentService.updateStatus(id, status);
            return ResponseEntity.ok(convertToDTO(updatedAppointment));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> cancelAppointment(@PathVariable Long id) {
        try {
            appointmentService.cancelAppointment(id);
            return ResponseEntity.ok(Map.of("message", "Randevu iptal edildi"));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", e.getMessage()));
        }
    }


    // Entity -> DTO dönüşüm metodu
    private AppointmentDTO convertToDTO(Appointment appointment) {
        if (appointment == null) {
            return null;
        }

        DoctorSimpleDTO doctorDTO = null;
        if (appointment.getDoctor() != null) {
            Doctor doctor = appointment.getDoctor();
            doctorDTO = DoctorSimpleDTO.builder()
                    .id(doctor.getId())
                    .name(doctor.getName())
                    .specialty(doctor.getSpecialty())
                    .contactNumber(doctor.getContactNumber())
                    .availableDays(doctor.getAvailableDays())
                    .build();
        }

        UserSimpleDTO userDTO = null;
        if (appointment.getUser() != null) {
            User user = appointment.getUser();
            userDTO = UserSimpleDTO.builder()
                    .id(user.getId())
                    .publicId(user.getPublicId())
                    .name(user.getName())
                    .email(user.getEmail())
                    .build();
        }

        HospitalSimpleDTO hospitalDTO = null;
        if (appointment.getHospital() != null) {
            Hospital hospital = appointment.getHospital();
            hospitalDTO = HospitalSimpleDTO.builder()
                    .id(hospital.getId())
                    .name(hospital.getName())
                    .city(hospital.getCity())
                    .district(hospital.getDistrict())
                    .address(hospital.getAddress())
                    .phone(hospital.getPhone())
                    .build();
        }

        return AppointmentDTO.builder()
                .id(appointment.getId())
                .appointmentDate(appointment.getAppointmentDate())
                .status(appointment.getStatus())
                .doctor(doctorDTO)
                .user(userDTO)
                .hospital(hospitalDTO)
                .build();
    }
}