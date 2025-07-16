package com.example.yapayzekabackend.service;

import com.example.yapayzekabackend.model.Appointment;
import com.example.yapayzekabackend.repository.AppointmentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AppointmentService {
    private final AppointmentRepository appointmentRepository;

    public List<Appointment> findByHospitalId(Long hospitalId) {
        return appointmentRepository.findByHospitalId(hospitalId);
    }

    public List<Appointment> findByHospitalIdAndDateRange(Long hospitalId, LocalDateTime start, LocalDateTime end) {
        return appointmentRepository.findByHospitalIdAndAppointmentDateBetween(hospitalId, start, end);
    }

    public Appointment createAppointment(Appointment appointment) {
        return appointmentRepository.save(appointment);
    }

    public List<Appointment> getAllAppointments() {
        return appointmentRepository.findAll();
    }

    public List<Appointment> findByUserId(Long userId) {
        return appointmentRepository.findByUserId(userId);
    }

    public Optional<Appointment> findById(Long id) {
        return appointmentRepository.findById(id);
    }

    public Appointment updateStatus(Long id, String status) {
        Appointment appointment = appointmentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Randevu bulunamadi"));


        if (!isValidStatus(status)) {
            throw new RuntimeException("Gecersiz randevu durumu: " + status);
        }

        appointment.setStatus(status);
        return appointmentRepository.save(appointment);
    }

    public void cancelAppointment(Long id) {
        Appointment appointment = appointmentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Randevu bulunamadi"));

        appointment.setStatus("CANCELLED");
        appointmentRepository.save(appointment);
    }

    public boolean cancelAppointmentForUser(Long appointmentId, Long userId) {
        Optional<Appointment> appointmentOpt = appointmentRepository.findById(appointmentId);

        if (appointmentOpt.isPresent()) {
            Appointment appointment = appointmentOpt.get();


            if (appointment.getUser().getId().equals(userId)) {
                appointment.setStatus("CANCELLED");
                appointmentRepository.save(appointment);
                return true;
            }
        }

        return false;
    }

    private boolean isValidStatus(String status) {
        return status != null && (
                status.equals("SCHEDULED") ||
                        status.equals("COMPLETED") ||
                        status.equals("CANCELLED"));
    }
}