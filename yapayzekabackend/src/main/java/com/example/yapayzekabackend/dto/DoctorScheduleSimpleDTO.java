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
public class DoctorScheduleSimpleDTO {
    private Long id;
    private LocalDate scheduleDate;
    private LocalTime startTime;
    private LocalTime endTime;
    private boolean available;
}