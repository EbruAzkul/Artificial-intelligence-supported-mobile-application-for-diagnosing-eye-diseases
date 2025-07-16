package com.example.yapayzekabackend.controller;

import com.example.yapayzekabackend.dto.DoctorDTO;
import com.example.yapayzekabackend.dto.HospitalSimpleDTO;
import com.example.yapayzekabackend.model.Doctor;
import com.example.yapayzekabackend.model.Hospital;
import com.example.yapayzekabackend.service.DoctorService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/doctors")
@RequiredArgsConstructor
public class DoctorController {

    private final DoctorService doctorService;

    @PostMapping
    public ResponseEntity<Doctor> createDoctor(@RequestBody Doctor doctor) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(doctorService.createDoctor(doctor));
    }

    @GetMapping("/{id}")
    public ResponseEntity<DoctorDTO> getDoctorById(@PathVariable Long id) {
        Optional<Doctor> doctorOpt = doctorService.findById(id);
        return doctorOpt
                .map(doctor -> ResponseEntity.ok(convertToDTO(doctor)))
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping
    public ResponseEntity<List<DoctorDTO>> getAllDoctors(
            @RequestParam(required = false) String specialty) {
        List<Doctor> doctors;
        if (specialty != null) {
            doctors = doctorService.findBySpecialty(specialty);
        } else {
            doctors = doctorService.getAllDoctors();
        }

        List<DoctorDTO> doctorDTOs = doctors.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());

        return ResponseEntity.ok(doctorDTOs);
    }

    // Entity -> DTO dönüşüm metodu
    private DoctorDTO convertToDTO(Doctor doctor) {
        if (doctor == null) {
            return null;
        }

        HospitalSimpleDTO hospitalDTO = null;
        if (doctor.getHospital() != null) {
            Hospital hospital = doctor.getHospital();
            hospitalDTO = HospitalSimpleDTO.builder()
                    .id(hospital.getId())
                    .name(hospital.getName())
                    .city(hospital.getCity())
                    .district(hospital.getDistrict())
                    .address(hospital.getAddress())
                    .phone(hospital.getPhone())
                    .build();
        }

        return DoctorDTO.builder()
                .id(doctor.getId())
                .name(doctor.getName())
                .specialty(doctor.getSpecialty())
                .contactNumber(doctor.getContactNumber())
                .hospital(hospitalDTO)
                .availableDays(doctor.getAvailableDays())
                .build();
    }
}