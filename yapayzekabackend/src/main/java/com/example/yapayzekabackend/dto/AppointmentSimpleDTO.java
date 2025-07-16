package com.example.yapayzekabackend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;


@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AppointmentSimpleDTO {
    private Long id;
    private LocalDateTime appointmentDate;
    private String status;
}