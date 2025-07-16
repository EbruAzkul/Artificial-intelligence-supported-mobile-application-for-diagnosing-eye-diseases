package com.example.yapayzekabackend.repository;

import com.example.yapayzekabackend.model.Diagnosis;
import com.example.yapayzekabackend.model.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface DiagnosisRepository extends JpaRepository<Diagnosis, Long> {
    List<Diagnosis> findByUserOrderByCreatedAtDesc(User user);
    Page<Diagnosis> findByUserOrderByCreatedAtDesc(User user, Pageable pageable);
    List<Diagnosis> findByUserAndCreatedAtBetweenOrderByCreatedAtDesc(User user, LocalDateTime start, LocalDateTime end);
}