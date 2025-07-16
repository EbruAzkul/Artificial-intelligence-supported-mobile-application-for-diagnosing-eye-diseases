package com.example.yapayzekabackend.controller;

import com.example.yapayzekabackend.model.Diagnosis;
import com.example.yapayzekabackend.repository.DiagnosisRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.DoubleSummaryStatistics;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/statistics")
public class StatisticsController {

    @Autowired
    private DiagnosisRepository diagnosisRepository;

    @GetMapping("/summary")
    public ResponseEntity<Map<String, Object>> getSummary() {
        List<Diagnosis> allDiagnoses = diagnosisRepository.findAll();

        Map<String, Long> countByClass = allDiagnoses.stream()
                .collect(Collectors.groupingBy(Diagnosis::getPredictedClass, Collectors.counting()));

        DoubleSummaryStatistics confidenceStats = allDiagnoses.stream()
                .collect(Collectors.summarizingDouble(Diagnosis::getConfidence));

        Map<String, Object> result = Map.of(
                "countByClass", countByClass,
                "averageConfidence", confidenceStats.getAverage(),
                "totalDiagnoses", allDiagnoses.size()
        );

        return ResponseEntity.ok(result);
    }
}
