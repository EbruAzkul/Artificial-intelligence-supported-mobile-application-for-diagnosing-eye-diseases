package com.example.yapayzekabackend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalTime;


@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DoctorScheduleDTO {
    private Long id;
    private DoctorSimpleDTO doctor;
    private HospitalSimpleDTO hospital;
    private LocalDate scheduleDate;
    private LocalTime startTime;
    private LocalTime endTime;
    private boolean available;
}