package com.example.yapayzekabackend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;


@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HospitalSimpleDTO {
    private Long id;
    private String name;
    private String city;
    private String district;
    private String address;
    private String phone;
}