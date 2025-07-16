package com.example.yapayzekabackend.service;

import com.example.yapayzekabackend.model.Hospital;
import com.example.yapayzekabackend.repository.HospitalRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;


@Service
public class HospitalService {
    @Autowired
    private HospitalRepository hospitalRepository;


    public Optional<Hospital> findById(Long id) {
        return hospitalRepository.findById(id);
    }


    public List<Hospital> getAllHospitals() {
        return hospitalRepository.findAll();
    }

    public List<Hospital> getHospitalsByCity(String city) {
        return hospitalRepository.findByCity(city);
    }

    public List<Hospital> getHospitalsByCityAndDistrict(String city, String district) {
        return hospitalRepository.findByCityAndDistrict(city, district);
    }

    public Hospital getHospitalById(Long id) {
        return hospitalRepository.findById(id).orElse(null);
    }

    public List<Hospital> getNearbyHospitals(Double lat, Double lng, Double radiusKm) {

        Double latDiff = radiusKm / 111.0;
        Double lngDiff = radiusKm / (111.0 * Math.cos(Math.toRadians(lat)));

        return hospitalRepository.findByLatitudeBetweenAndLongitudeBetween(
                lat - latDiff, lat + latDiff,
                lng - lngDiff, lng + lngDiff
        );
    }

    public Hospital saveHospital(Hospital hospital) {
        return hospitalRepository.save(hospital);
    }
}