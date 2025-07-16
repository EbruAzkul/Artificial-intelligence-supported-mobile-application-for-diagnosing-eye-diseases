package com.example.yapayzekabackend.service;

import com.example.yapayzekabackend.model.DiagnosisResult;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Map;

@Slf4j
@Service
public class ModelService {

    @Value("${model.api.url}")
    private String modelApiUrl;

    private final RestTemplate restTemplate;

    public ModelService() {
        this.restTemplate = new RestTemplate();
    }


    public boolean isModelApiHealthy() {
        try {
            ResponseEntity<Map> response = restTemplate.getForEntity(modelApiUrl + "/health", Map.class);
            return response.getStatusCode().is2xxSuccessful() &&
                    "OK".equals(response.getBody().get("status"));
        } catch (Exception e) {
            log.error("Model API sağlık kontrolü başarısız: ", e);
            return false;
        }
    }


    public DiagnosisResult predict(File imageFile) throws IOException {
        try {

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.MULTIPART_FORM_DATA);

            MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
            ByteArrayResource fileResource = new ByteArrayResource(Files.readAllBytes(imageFile.toPath())) {
                @Override
                public String getFilename() {
                    return imageFile.getName();
                }
            };

            body.add("file", fileResource);

            HttpEntity<MultiValueMap<String, Object>> requestEntity = new HttpEntity<>(body, headers);


            ResponseEntity<Map> response = restTemplate.postForEntity(
                    modelApiUrl + "/predict", requestEntity, Map.class);

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                Map<String, Object> responseBody = response.getBody();

                String predictedClass = (String) responseBody.get("predicted_class");
                Double confidence = ((Number) responseBody.get("confidence")).doubleValue();

                @SuppressWarnings("unchecked")
                Map<String, Double> allProbabilities = (Map<String, Double>) responseBody.get("all_probabilities");

                return new DiagnosisResult(predictedClass, confidence, allProbabilities);
            } else {
                throw new RuntimeException("Model API yanıt vermedi veya geçersiz yanıt verdi");
            }
        } catch (Exception e) {
            log.error("Tahmin sırasında hata oluştu: ", e);
            throw new RuntimeException("Tahmin sırasında hata oluştu: " + e.getMessage(), e);
        }
    }
}