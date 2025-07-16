package com.example.yapayzekabackend.service;

import com.example.yapayzekabackend.model.Diagnosis;
import com.example.yapayzekabackend.model.DiagnosisResult;
import com.example.yapayzekabackend.model.Doctor;
import com.example.yapayzekabackend.model.User;
import com.example.yapayzekabackend.repository.DiagnosisRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Slf4j
@Service
public class DiagnosisService {

    @Autowired
    private DiagnosisRepository diagnosisRepository;

    @Autowired
    private ModelService modelService;

    @Autowired
    private FileStorageService fileStorageService;

    @Autowired
    private UserService userService;

    @Autowired
    private DoctorService doctorService;


    public Diagnosis createTestDiagnosis(MultipartFile imageFile, String notes) throws IOException {
        User testUser = userService.createUniqueTestUser();

        String fileName = fileStorageService.storeFile(imageFile, testUser.getPublicId());
        File savedFile = fileStorageService.getFile(fileName);

        DiagnosisResult result = modelService.predict(savedFile);

        Diagnosis diagnosis = new Diagnosis();
        diagnosis.setUser(testUser);
        diagnosis.setImagePath(fileName);
        diagnosis.setPredictedClass(result.getPredictedClass());
        diagnosis.setConfidence(result.getConfidence());
        diagnosis.setAllProbabilities(result.getAllProbabilities());
        diagnosis.setNotes(notes);

        return diagnosisRepository.save(diagnosis);
    }

    public Diagnosis createDiagnosis(User user, MultipartFile imageFile, String notes) throws IOException {
        String fileName = fileStorageService.storeFile(imageFile, user.getPublicId());
        File savedFile = fileStorageService.getFile(fileName);

        DiagnosisResult result = modelService.predict(savedFile);

        Diagnosis diagnosis = new Diagnosis();
        diagnosis.setUser(user);
        diagnosis.setImagePath(fileName);
        diagnosis.setPredictedClass(result.getPredictedClass());
        diagnosis.setConfidence(result.getConfidence());
        diagnosis.setAllProbabilities(result.getAllProbabilities());
        diagnosis.setNotes(notes);

        String doctorRecommendation = generateDoctorRecommendation(result.getPredictedClass());
        diagnosis.setDoctorRecommendation(doctorRecommendation);

        return diagnosisRepository.save(diagnosis);
    }


    private String generateDoctorRecommendation(String predictedClass) {

        String specialty = mapDiagnosisToSpecialty(predictedClass);


        List<Doctor> recommendedDoctors = doctorService.findBySpecialty(specialty);

        if (recommendedDoctors.isEmpty()) {
            return "Bu teşhis için uygun uzman bulunamadı. Lütfen genel bir göz doktoruna başvurunuz.";
        }


        String doctorList = recommendedDoctors.stream()
                .limit(3) // En fazla 3 doktor öner
                .map(doctor -> "- Dr. " + doctor.getName() + " (" + doctor.getHospital() + ")")
                .collect(Collectors.joining("\n"));

        return String.format("Teşhisiniz (%s) için önerilen uzmanlar (%s):\n%s",
                predictedClass, specialty, doctorList);
    }


    private String mapDiagnosisToSpecialty(String predictedClass) {
        switch (predictedClass.toLowerCase()) {
            case "dr" : return "Retina Uzmanı";
            case "dme": return "Retina Uzmanı";
            case "cataract": return "Katarakt Cerrahı";
            case "glaucoma": return "Glokom Uzmanı";
            case "normal": return "Göz Hastalıkları Uzmanı";
            default: return "Göz Hastalıkları Uzmanı";
        }
    }

    public List<Diagnosis> getAllDiagnoses() {
        return diagnosisRepository.findAll();
    }

    public Optional<Diagnosis> getDiagnosisById(Long id) {
        return diagnosisRepository.findById(id);
    }

    public List<Diagnosis> getDiagnosesByUser(User user) {
        return diagnosisRepository.findByUserOrderByCreatedAtDesc(user);
    }

    public void updateDoctorRecommendation(Long diagnosisId, String recommendation) {
        diagnosisRepository.findById(diagnosisId).ifPresent(diagnosis -> {
            diagnosis.setDoctorRecommendation(recommendation);
            diagnosisRepository.save(diagnosis);
        });
    }

    public List<Doctor> getRecommendedDoctors(Long diagnosisId) {
        Optional<Diagnosis> diagnosisOpt = diagnosisRepository.findById(diagnosisId);
        if (diagnosisOpt.isPresent()) {
            String predictedClass = diagnosisOpt.get().getPredictedClass();
            String specialty = mapDiagnosisToSpecialty(predictedClass);
            return doctorService.findBySpecialty(specialty);
        }
        return List.of();
    }
}