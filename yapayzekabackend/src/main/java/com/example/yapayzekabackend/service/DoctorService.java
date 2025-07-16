package com.example.yapayzekabackend.service;

import com.example.yapayzekabackend.model.Doctor;
import com.example.yapayzekabackend.repository.DoctorRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class DoctorService {

    private final DoctorRepository doctorRepository;


    public Doctor createDoctor(Doctor doctor) {
        return doctorRepository.save(doctor);
    }


    public Optional<Doctor> findById(Long id) {
        return doctorRepository.findById(id);
    }


    public List<Doctor> getAllDoctors() {
        return doctorRepository.findAll();
    }


    public List<Doctor> findBySpecialty(String specialty) {
        return doctorRepository.findBySpecialtyContainingIgnoreCase(specialty);
    }
}