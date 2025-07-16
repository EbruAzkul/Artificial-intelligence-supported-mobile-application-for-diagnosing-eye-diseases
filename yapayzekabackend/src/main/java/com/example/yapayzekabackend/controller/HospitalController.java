package com.example.yapayzekabackend.controller;

import com.example.yapayzekabackend.dto.DoctorSimpleDTO;
import com.example.yapayzekabackend.dto.HospitalDTO;
import com.example.yapayzekabackend.model.Doctor;
import com.example.yapayzekabackend.model.Hospital;
import com.example.yapayzekabackend.service.HospitalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/hospitals")
public class HospitalController {
    @Autowired
    private HospitalService hospitalService;

    @GetMapping
    public ResponseEntity<List<HospitalDTO>> getAllHospitals() {
        List<Hospital> hospitals = hospitalService.getAllHospitals();
        List<HospitalDTO> hospitalDTOs = hospitals.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(hospitalDTOs);
    }

    @GetMapping("/by-city")
    public ResponseEntity<List<HospitalDTO>> getHospitalsByCity(@RequestParam String city) {
        List<Hospital> hospitals = hospitalService.getHospitalsByCity(city);
        List<HospitalDTO> hospitalDTOs = hospitals.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(hospitalDTOs);
    }

    @GetMapping("/by-city-district")
    public ResponseEntity<List<HospitalDTO>> getHospitalsByCityAndDistrict(
            @RequestParam String city,
            @RequestParam String district) {
        List<Hospital> hospitals = hospitalService.getHospitalsByCityAndDistrict(city, district);
        List<HospitalDTO> hospitalDTOs = hospitals.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(hospitalDTOs);
    }

    @GetMapping("/by-location")
    public ResponseEntity<List<HospitalDTO>> getNearbyHospitals(
            @RequestParam Double latitude,
            @RequestParam Double longitude,
            @RequestParam(defaultValue = "5.0") Double radiusKm) {
        List<Hospital> hospitals = hospitalService.getNearbyHospitals(latitude, longitude, radiusKm);
        List<HospitalDTO> hospitalDTOs = hospitals.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(hospitalDTOs);
    }

    @GetMapping("/{id}")
    public ResponseEntity<HospitalDTO> getHospitalById(@PathVariable Long id) {
        Hospital hospital = hospitalService.getHospitalById(id);
        if (hospital != null) {
            return ResponseEntity.ok(convertToDTO(hospital));
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping
    public ResponseEntity<Hospital> createHospital(@RequestBody Hospital hospital) {
        return ResponseEntity.ok(hospitalService.saveHospital(hospital));
    }


    private HospitalDTO convertToDTO(Hospital hospital) {
        if (hospital == null) {
            return null;
        }


        List<DoctorSimpleDTO> doctorDTOs = hospital.getDoctors() != null
                ? hospital.getDoctors().stream()
                .map(this::convertToDoctorSimpleDTO)
                .collect(Collectors.toList())
                : Collections.emptyList();

        return HospitalDTO.builder()
                .id(hospital.getId())
                .name(hospital.getName())
                .city(hospital.getCity())
                .district(hospital.getDistrict())
                .address(hospital.getAddress())
                .phone(hospital.getPhone())
                .latitude(hospital.getLatitude())
                .longitude(hospital.getLongitude())
                .doctors(doctorDTOs)
                .build();
    }

    private DoctorSimpleDTO convertToDoctorSimpleDTO(Doctor doctor) {
        if (doctor == null) {
            return null;
        }

        return DoctorSimpleDTO.builder()
                .id(doctor.getId())
                .name(doctor.getName())
                .specialty(doctor.getSpecialty())
                .contactNumber(doctor.getContactNumber())
                .availableDays(doctor.getAvailableDays())
                .build();
    }
}