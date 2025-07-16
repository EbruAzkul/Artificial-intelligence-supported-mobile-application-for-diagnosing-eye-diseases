package com.example.yapayzekabackend.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DiagnosisResult {
    private String predictedClass;
    private Double confidence;
    private Map<String, Double> allProbabilities;
}