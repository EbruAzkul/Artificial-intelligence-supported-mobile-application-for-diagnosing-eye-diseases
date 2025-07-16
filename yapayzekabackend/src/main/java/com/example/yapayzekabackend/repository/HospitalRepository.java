package com.example.yapayzekabackend.repository;

import com.example.yapayzekabackend.model.Hospital;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HospitalRepository extends JpaRepository<Hospital, Long> {
    List<Hospital> findByCity(String city);
    List<Hospital> findByCityAndDistrict(String city, String district);
    List<Hospital> findByLatitudeBetweenAndLongitudeBetween(Double minLat, Double maxLat, Double minLng, Double maxLng);
}