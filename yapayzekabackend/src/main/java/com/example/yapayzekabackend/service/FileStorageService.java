package com.example.yapayzekabackend.service;

import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@Service
public class FileStorageService {

    @Value("${file.upload-dir}")
    private String uploadDir;

    private Path fileStoragePath;

    @PostConstruct
    public void init() {
        this.fileStoragePath = Paths.get(uploadDir).toAbsolutePath().normalize();

        try {
            Files.createDirectories(this.fileStoragePath);
        } catch (IOException e) {
            throw new RuntimeException("Dosya yükleme dizini oluşturulamadı", e);
        }
    }

    public String storeFile(MultipartFile file, String userId) throws IOException {

        String fileName = UUID.randomUUID().toString() + "_" + userId + "_" +
                System.currentTimeMillis() + getFileExtension(file.getOriginalFilename());


        Path targetLocation = this.fileStoragePath.resolve(fileName);


        Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);

        return fileName;
    }

    public File getFile(String fileName) {
        Path filePath = this.fileStoragePath.resolve(fileName).normalize();
        return filePath.toFile();
    }

    public boolean deleteFile(String fileName) {
        try {
            Path filePath = this.fileStoragePath.resolve(fileName).normalize();
            return Files.deleteIfExists(filePath);
        } catch (IOException e) {
            return false;
        }
    }

    private String getFileExtension(String fileName) {
        if (fileName == null) {
            return "";
        }
        String[] parts = fileName.split("\\.");
        return parts.length > 1 ? "." + parts[parts.length - 1] : "";
    }
}