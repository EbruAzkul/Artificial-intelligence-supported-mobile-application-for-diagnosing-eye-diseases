package com.example.yapayzekabackend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;


@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DoctorSimpleDTO {
    private Long id;
    private String name;
    private String specialty;
    private String contactNumber;
    private List<String> availableDays;
}