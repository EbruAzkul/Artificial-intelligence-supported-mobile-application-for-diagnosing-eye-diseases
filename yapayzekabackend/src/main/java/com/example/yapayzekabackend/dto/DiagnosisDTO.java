package com.example.yapayzekabackend.dto;

import com.example.yapayzekabackend.model.Diagnosis;
import java.time.LocalDateTime;
import java.util.Map;

public class DiagnosisDTO {
    private Long id;
    private String imagePath;
    private String predictedClass;
    private Double confidence;
    private Map<String, Double> allProbabilities;
    private String notes;
    private String doctorRecommendation; // Yeni eklenen alan
    private LocalDateTime createdAt;

    // Constructor
    public DiagnosisDTO(Diagnosis diagnosis) {
        this.id = diagnosis.getId();
        this.imagePath = diagnosis.getImagePath();
        this.predictedClass = diagnosis.getPredictedClass();
        this.confidence = diagnosis.getConfidence();
        this.allProbabilities = diagnosis.getAllProbabilities();
        this.notes = diagnosis.getNotes();
        this.doctorRecommendation = diagnosis.getDoctorRecommendation(); // Yeni alan için değer atama
        this.createdAt = diagnosis.getCreatedAt();
    }

    // Getter Methods
    public Long getId() { return id; }
    public String getImagePath() { return imagePath; }
    public String getPredictedClass() { return predictedClass; }
    public Double getConfidence() { return confidence; }
    public Map<String, Double> getAllProbabilities() { return allProbabilities; }
    public String getNotes() { return notes; }
    public String getDoctorRecommendation() { return doctorRecommendation; } // Yeni getter
    public LocalDateTime getCreatedAt() { return createdAt; }
}