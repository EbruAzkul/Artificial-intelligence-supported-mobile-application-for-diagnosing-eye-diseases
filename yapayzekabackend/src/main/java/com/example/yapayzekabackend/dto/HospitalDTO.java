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
public class HospitalDTO {
    private Long id;
    private String name;
    private String city;
    private String district;
    private String address;
    private String phone;
    private Double latitude;
    private Double longitude;
    private List<DoctorSimpleDTO> doctors;
}