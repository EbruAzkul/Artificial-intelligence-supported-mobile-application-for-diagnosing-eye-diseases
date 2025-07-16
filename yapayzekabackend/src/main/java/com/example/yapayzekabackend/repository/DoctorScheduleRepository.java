package com.example.yapayzekabackend.repository;

import com.example.yapayzekabackend.model.DoctorSchedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Repository
public interface DoctorScheduleRepository extends JpaRepository<DoctorSchedule, Long> {
    List<DoctorSchedule> findByDoctorId(Long doctorId);


    List<DoctorSchedule> findByDoctorIdAndScheduleDate(Long doctorId, LocalDate scheduleDate);


    List<DoctorSchedule> findByDoctorIdAndScheduleDateBetween(Long doctorId, LocalDate startDate, LocalDate endDate);


    boolean existsByDoctorIdAndScheduleDateAndStartTimeAndAvailable(
            Long doctorId, LocalDate scheduleDate, LocalTime startTime, boolean available);
}