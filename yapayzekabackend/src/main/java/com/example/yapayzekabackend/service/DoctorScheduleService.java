package com.example.yapayzekabackend.service;

import com.example.yapayzekabackend.model.Appointment;
import com.example.yapayzekabackend.model.Doctor;
import com.example.yapayzekabackend.model.DoctorSchedule;
import com.example.yapayzekabackend.model.User;
import com.example.yapayzekabackend.repository.AppointmentRepository;
import com.example.yapayzekabackend.repository.DoctorScheduleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class DoctorScheduleService {

    @Autowired
    private DoctorScheduleRepository scheduleRepository;

    @Autowired
    private AppointmentRepository appointmentRepository;

    @Autowired
    private DoctorService doctorService;

    @Autowired
    private UserService userService;


    private static final int APPOINTMENT_DURATION_MINUTES = 30;


    public Optional<DoctorSchedule> findById(Long id) {
        return scheduleRepository.findById(id);
    }

    public DoctorSchedule createSchedule(DoctorSchedule schedule) {

        if (schedule.getStartTime().isAfter(schedule.getEndTime())) {
            throw new RuntimeException("Başlangıç saati bitiş saatinden sonra olamaz");
        }

        return scheduleRepository.save(schedule);
    }


    public List<DoctorSchedule> createSchedulesForDateRange(
            Long doctorId,
            LocalDate startDate,
            LocalDate endDate,
            LocalTime startTime,
            LocalTime endTime,
            boolean available) {

        Doctor doctor = doctorService.findById(doctorId)
                .orElseThrow(() -> new RuntimeException("Doktor bulunamadı"));

        List<DoctorSchedule> createdSchedules = new ArrayList<>();
        LocalDate currentDate = startDate;

        while (!currentDate.isAfter(endDate)) {
            DoctorSchedule schedule = DoctorSchedule.builder()
                    .doctor(doctor)
                    .scheduleDate(currentDate)
                    .startTime(startTime)
                    .endTime(endTime)
                    .available(available)
                    .build();

            createdSchedules.add(scheduleRepository.save(schedule));
            currentDate = currentDate.plusDays(1);
        }

        return createdSchedules;
    }

    public List<DoctorSchedule> findByDoctorId(Long doctorId) {
        return scheduleRepository.findByDoctorId(doctorId);
    }

    public List<LocalTime> getAvailableTimeSlots(Long doctorId, LocalDate date) {

        List<DoctorSchedule> schedules = scheduleRepository.findByDoctorIdAndScheduleDate(doctorId, date);

        if (schedules.isEmpty()) {
            return List.of();
        }

        List<LocalTime> allPossibleSlots = new ArrayList<>();

        for (DoctorSchedule schedule : schedules) {
            if (!schedule.isAvailable()) {
                continue;
            }

            LocalTime current = schedule.getStartTime();
            while (current.plusMinutes(APPOINTMENT_DURATION_MINUTES).isBefore(schedule.getEndTime())
                    || current.plusMinutes(APPOINTMENT_DURATION_MINUTES).equals(schedule.getEndTime())) {
                allPossibleSlots.add(current);
                current = current.plusMinutes(APPOINTMENT_DURATION_MINUTES);
            }
        }


        LocalDateTime startOfDay = date.atStartOfDay();
        LocalDateTime endOfDay = date.plusDays(1).atStartOfDay();

        List<Appointment> existingAppointments = appointmentRepository.findByDoctorIdAndAppointmentDateBetween(
                doctorId, startOfDay, endOfDay);

        List<LocalTime> bookedTimes = existingAppointments.stream()
                .map(appointment -> appointment.getAppointmentDate().toLocalTime())
                .collect(Collectors.toList());


        return allPossibleSlots.stream()
                .filter(time -> !bookedTimes.contains(time))
                .collect(Collectors.toList());
    }

    public Map<String, List<String>> getAvailableSlotsForWeek(Long doctorId) {
        Map<String, List<String>> weekSlots = new HashMap<>();
        LocalDate today = LocalDate.now();


        for (int i = 0; i < 7; i++) {
            LocalDate date = today.plusDays(i);
            List<LocalTime> timeSlots = getAvailableTimeSlots(doctorId, date);


            List<String> formattedSlots = timeSlots.stream()
                    .map(time -> time.toString())
                    .collect(Collectors.toList());

            weekSlots.put(date.toString(), formattedSlots);
        }

        return weekSlots;
    }

    public Appointment bookAppointment(Long doctorId, String userPublicId, LocalDateTime dateTime) {

        Doctor doctor = doctorService.findById(doctorId)
                .orElseThrow(() -> new RuntimeException("Doktor bulunamadı"));

        User user = userService.findByPublicId(userPublicId)
                .orElseThrow(() -> new RuntimeException("Kullanıcı bulunamadı"));


        LocalDate date = dateTime.toLocalDate();
        LocalTime time = dateTime.toLocalTime();

        List<LocalTime> availableSlots = getAvailableTimeSlots(doctorId, date);
        if (!availableSlots.contains(time)) {
            throw new RuntimeException("Seçilen zaman dilimi müsait değil");
        }


        Appointment appointment = Appointment.builder()
                .user(user)
                .doctor(doctor)
                .appointmentDate(dateTime)
                .status("SCHEDULED")
                .build();

        return appointmentRepository.save(appointment);
    }


    public void markDateUnavailable(Long doctorId, LocalDate date) {
        Doctor doctor = doctorService.findById(doctorId)
                .orElseThrow(() -> new RuntimeException("Doktor bulunamadı"));


        List<DoctorSchedule> schedules = scheduleRepository.findByDoctorIdAndScheduleDate(doctorId, date);


        for (DoctorSchedule schedule : schedules) {
            schedule.setAvailable(false);
            scheduleRepository.save(schedule);
        }
    }

    public DoctorSchedule updateSchedule(Long id, DoctorSchedule updatedSchedule) {
        DoctorSchedule existingSchedule = scheduleRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Çalışma saati bulunamadı"));


        if (updatedSchedule.getStartTime().isAfter(updatedSchedule.getEndTime())) {
            throw new RuntimeException("Başlangıç saati bitiş saatinden sonra olamaz");
        }


        existingSchedule.setDoctor(updatedSchedule.getDoctor());
        existingSchedule.setScheduleDate(updatedSchedule.getScheduleDate());
        existingSchedule.setStartTime(updatedSchedule.getStartTime());
        existingSchedule.setEndTime(updatedSchedule.getEndTime());
        existingSchedule.setAvailable(updatedSchedule.isAvailable());

        return scheduleRepository.save(existingSchedule);
    }

    public void deleteSchedule(Long id) {
        if (!scheduleRepository.existsById(id)) {
            throw new RuntimeException("Çalışma saati bulunamadı");
        }
        scheduleRepository.deleteById(id);
    }

    public void deleteSchedulesForDateRange(Long doctorId, LocalDate startDate, LocalDate endDate) {
        List<DoctorSchedule> schedulesToDelete =
                scheduleRepository.findByDoctorIdAndScheduleDateBetween(doctorId, startDate, endDate);

        for (DoctorSchedule schedule : schedulesToDelete) {
            scheduleRepository.delete(schedule);
        }
    }
}