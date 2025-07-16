package com.example.yapayzekabackend.controller;

import com.example.yapayzekabackend.dto.DoctorScheduleDTO;
import com.example.yapayzekabackend.dto.DoctorSimpleDTO;
import com.example.yapayzekabackend.dto.HospitalSimpleDTO;
import com.example.yapayzekabackend.model.Appointment;
import com.example.yapayzekabackend.model.Doctor;
import com.example.yapayzekabackend.model.DoctorSchedule;
import com.example.yapayzekabackend.model.Hospital;
import com.example.yapayzekabackend.service.DoctorScheduleService;
import com.example.yapayzekabackend.service.DoctorService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/schedules")
@RequiredArgsConstructor
public class DoctorScheduleController {

    private final DoctorScheduleService scheduleService;
    private final DoctorService doctorService;

    @PostMapping
    public ResponseEntity<?> createSchedule(@RequestBody DoctorSchedule schedule) {
        try {
            DoctorSchedule saved = scheduleService.createSchedule(schedule);
            return ResponseEntity.ok(convertToDTO(saved));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @GetMapping("/doctor/{doctorId}")
    public ResponseEntity<List<DoctorScheduleDTO>> getDoctorSchedules(@PathVariable Long doctorId) {
        List<DoctorSchedule> schedules = scheduleService.findByDoctorId(doctorId);
        List<DoctorScheduleDTO> dtos = schedules.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }

    @GetMapping("/available")
    public ResponseEntity<?> getAvailableSlots(
            @RequestParam Long doctorId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        try {
            Optional<Doctor> doctor = doctorService.findById(doctorId);
            if (doctor.isEmpty()) {
                return ResponseEntity.notFound().build();
            }

            List<LocalTime> availableSlots = scheduleService.getAvailableTimeSlots(doctorId, date);


            List<String> formattedSlots = availableSlots.stream()
                    .map(time -> time.format(DateTimeFormatter.ofPattern("HH:mm")))
                    .collect(Collectors.toList());

            return ResponseEntity.ok(formattedSlots);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    @GetMapping("/available-week")
    public ResponseEntity<?> getAvailableSlotsForWeek(@RequestParam Long doctorId) {
        try {
            Map<String, List<String>> availableSlots = scheduleService.getAvailableSlotsForWeek(doctorId);
            return ResponseEntity.ok(availableSlots);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    @PostMapping("/book-appointment")
    public ResponseEntity<?> bookAppointment(
            @RequestParam Long doctorId,
            @RequestParam String userPublicId,
            @RequestParam String appointmentDate,
            @RequestParam String appointmentTime) {

        try {

            LocalDateTime dateTime = LocalDateTime.parse(
                    appointmentDate + "T" + appointmentTime + ":00"
            );

            Appointment appointment = scheduleService.bookAppointment(doctorId, userPublicId, dateTime);
            return ResponseEntity.ok(appointment);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteSchedule(@PathVariable Long id) {
        try {
            scheduleService.deleteSchedule(id);
            return ResponseEntity.ok(Map.of("message", "Çalışma saati silindi"));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateSchedule(@PathVariable Long id, @RequestBody Map<String, Object> updateRequest) {
        try {

            Optional<DoctorSchedule> existingScheduleOpt = scheduleService.findById(id);
            if (existingScheduleOpt.isEmpty()) {
                return ResponseEntity.notFound().build();
            }

            DoctorSchedule existingSchedule = existingScheduleOpt.get();


            if (updateRequest.containsKey("available")) {
                boolean available = Boolean.parseBoolean(updateRequest.get("available").toString());
                existingSchedule.setAvailable(available);
            }


            if (updateRequest.containsKey("startTime")) {
                Object startTimeObj = updateRequest.get("startTime");
                if (startTimeObj instanceof Map) {
                    Map<String, Object> timeMap = (Map<String, Object>) startTimeObj;
                    int hour = Integer.parseInt(timeMap.get("hour").toString());
                    int minute = Integer.parseInt(timeMap.get("minute").toString());
                    existingSchedule.setStartTime(LocalTime.of(hour, minute));
                } else if (startTimeObj instanceof String) {

                    String[] parts = startTimeObj.toString().split(":");
                    int hour = Integer.parseInt(parts[0]);
                    int minute = Integer.parseInt(parts[1]);
                    existingSchedule.setStartTime(LocalTime.of(hour, minute));
                }
            }

            if (updateRequest.containsKey("endTime")) {
                Object endTimeObj = updateRequest.get("endTime");
                if (endTimeObj instanceof Map) {
                    Map<String, Object> timeMap = (Map<String, Object>) endTimeObj;
                    int hour = Integer.parseInt(timeMap.get("hour").toString());
                    int minute = Integer.parseInt(timeMap.get("minute").toString());
                    existingSchedule.setEndTime(LocalTime.of(hour, minute));
                } else if (endTimeObj instanceof String) {

                    String[] parts = endTimeObj.toString().split(":");
                    int hour = Integer.parseInt(parts[0]);
                    int minute = Integer.parseInt(parts[1]);
                    existingSchedule.setEndTime(LocalTime.of(hour, minute));
                }
            }

            // scheduleDate güncellemesi
            if (updateRequest.containsKey("scheduleDate")) {
                String dateStr = updateRequest.get("scheduleDate").toString();
                existingSchedule.setScheduleDate(LocalDate.parse(dateStr));
            }

            // Doktor güncellemesi
            if (updateRequest.containsKey("doctor") && updateRequest.get("doctor") instanceof Map) {
                Map<String, Object> doctorMap = (Map<String, Object>) updateRequest.get("doctor");
                if (doctorMap.containsKey("id")) {
                    Long doctorId = Long.valueOf(doctorMap.get("id").toString());
                    Optional<Doctor> doctorOpt = doctorService.findById(doctorId);
                    if (doctorOpt.isPresent()) {
                        existingSchedule.setDoctor(doctorOpt.get());
                    }
                }
            }


            DoctorSchedule updated = scheduleService.updateSchedule(id, existingSchedule);
            return ResponseEntity.ok(convertToDTO(updated));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", e.getMessage()));
        }
    }


    private DoctorScheduleDTO convertToDTO(DoctorSchedule schedule) {
        if (schedule == null) {
            return null;
        }

        DoctorSimpleDTO doctorDTO = null;
        HospitalSimpleDTO hospitalDTO = null;

        if (schedule.getDoctor() != null) {
            Doctor doctor = schedule.getDoctor();
            doctorDTO = DoctorSimpleDTO.builder()
                    .id(doctor.getId())
                    .name(doctor.getName())
                    .specialty(doctor.getSpecialty())
                    .contactNumber(doctor.getContactNumber())
                    .availableDays(doctor.getAvailableDays())
                    .build();


            if (doctor.getHospital() != null) {
                Hospital hospital = doctor.getHospital();
                hospitalDTO = HospitalSimpleDTO.builder()
                        .id(hospital.getId())
                        .name(hospital.getName())
                        .city(hospital.getCity())
                        .district(hospital.getDistrict())
                        .address(hospital.getAddress())
                        .phone(hospital.getPhone())
                        .build();
            }
        }

        return DoctorScheduleDTO.builder()
                .id(schedule.getId())
                .doctor(doctorDTO)
                .hospital(hospitalDTO)
                .scheduleDate(schedule.getScheduleDate())
                .startTime(schedule.getStartTime())
                .endTime(schedule.getEndTime())
                .available(schedule.isAvailable())
                .build();
    }
}