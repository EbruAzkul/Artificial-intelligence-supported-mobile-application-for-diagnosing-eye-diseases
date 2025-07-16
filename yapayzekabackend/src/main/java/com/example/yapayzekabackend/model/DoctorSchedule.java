package com.example.yapayzekabackend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;

@Entity
@Table(name = "doctor_schedules")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DoctorSchedule {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "doctor_id")
    private Doctor doctor;

    @ManyToOne
    @JoinColumn(name = "hospital_id")
    private Hospital hospital;

    private LocalDate scheduleDate;

    private LocalTime startTime;

    private LocalTime endTime;

    private boolean available;
}