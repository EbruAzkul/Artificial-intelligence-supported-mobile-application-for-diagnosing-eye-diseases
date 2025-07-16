package com.example.yapayzekabackend.controller;

import com.example.yapayzekabackend.model.Appointment;
import com.example.yapayzekabackend.model.User;
import com.example.yapayzekabackend.service.AppointmentService;
import com.example.yapayzekabackend.service.UserService;
import com.example.yapayzekabackend.repository.DiagnosisRepository;
import com.example.yapayzekabackend.dto.DiagnosisDTO;
import com.example.yapayzekabackend.model.Diagnosis;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private DiagnosisRepository diagnosisRepository;

    @Autowired
    private AppointmentService appointmentService;

    @GetMapping("/{publicId}/diagnoses")
    public ResponseEntity<List<DiagnosisDTO>> getUserDiagnoses(@PathVariable String publicId) {
        Optional<User> userOpt = userService.findByPublicId(publicId);
        if (userOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        List<DiagnosisDTO> userDiagnoses = diagnosisRepository.findAll().stream()
                .filter(d -> d.getUser().getPublicId().equals(publicId))
                .map(DiagnosisDTO::new)
                .collect(Collectors.toList());

        return ResponseEntity.ok(userDiagnoses);
    }

    @GetMapping("/{publicId}")
    public ResponseEntity<User> getUser(@PathVariable String publicId) {
        return userService.findByPublicId(publicId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping
    public ResponseEntity<List<User>> getAllUsers() {
        return ResponseEntity.ok(userService.getAllUsers());
    }

    @GetMapping("/by-email/{email}")
    public ResponseEntity<User> getUserByEmail(@PathVariable String email) {
        return userService.findByEmail(email)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }


    @DeleteMapping("/{publicId}")
    public ResponseEntity<Void> deleteUser(@PathVariable String publicId) {
        userService.deleteByPublicId(publicId);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{publicId}")
    public ResponseEntity<User> updateUser(
            @PathVariable String publicId,
            @RequestBody User userDetails) {
        return ResponseEntity.ok(userService.updateUser(publicId, userDetails));
    }

    @GetMapping("/{publicId}/appointments")
    public ResponseEntity<List<Appointment>> getUserAppointments(@PathVariable String publicId) {
        Optional<User> userOpt = userService.findByPublicId(publicId);
        if (userOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        List<Appointment> appointments = appointmentService.findByUserId(userOpt.get().getId());
        return ResponseEntity.ok(appointments);
    }

    @DeleteMapping("/appointments/{appointmentId}")
    public ResponseEntity<?> cancelAppointment(
            @PathVariable Long appointmentId,
            @RequestParam String userPublicId) {

        try {

            Optional<User> userOpt = userService.findByPublicId(userPublicId);
            if (userOpt.isEmpty()) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(Map.of("message", "Kullanıcı bulunamadı"));
            }

            boolean success = appointmentService.cancelAppointmentForUser(appointmentId, userOpt.get().getId());

            if (success) {
                return ResponseEntity.ok(Map.of("message", "Randevu başarıyla iptal edildi"));
            } else {
                return ResponseEntity.badRequest()
                        .body(Map.of("message", "Randevu iptal edilemedi. Randevu bu kullanıcıya ait olmayabilir."));
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }
}