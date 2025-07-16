package com.example.yapayzekabackend.repository;

import com.example.yapayzekabackend.model.Doctor;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

// repository/DoctorRepository.java
public interface DoctorRepository extends JpaRepository<Doctor, Long> {
    List<Doctor> findBySpecialty(String specialty);
    List<Doctor> findBySpecialtyContainingIgnoreCase(String specialty);
}