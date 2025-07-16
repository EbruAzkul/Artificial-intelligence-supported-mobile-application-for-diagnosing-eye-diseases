package com.example.yapayzekabackend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Appointment DTO içinde kullanılmak üzere, sadece temel kullanıcı bilgilerini içeren DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserSimpleDTO {
    private Long id;
    private String publicId;
    private String name;
    private String email;
    private String phone;
}