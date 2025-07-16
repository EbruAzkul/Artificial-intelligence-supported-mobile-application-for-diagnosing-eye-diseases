import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:yapayzekamobil/model/doctor.dart';
import 'package:yapayzekamobil/base_components/colors.dart';
import 'package:yapayzekamobil/base_components/icons.dart';
import 'package:yapayzekamobil/base_components/paddings.dart';
import 'package:yapayzekamobil/base_components/text_styles.dart';
import 'package:yapayzekamobil/providers/appointment/appointment_provider.dart';
import 'package:yapayzekamobil/providers/auth/auth_state.dart';

class AppointmentBookingPage extends ConsumerStatefulWidget {
  final Doctor doctor;

  const AppointmentBookingPage({super.key, required this.doctor});

  @override
  ConsumerState<AppointmentBookingPage> createState() =>
      _AppointmentBookingPageState();
}

class _AppointmentBookingPageState
    extends ConsumerState<AppointmentBookingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(appointmentProvider.notifier)
          .fetchDoctorSchedules(widget.doctor);
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointmentState = ref.watch(appointmentProvider);

    ref.listen<AppointmentState>(appointmentProvider, (previous, next) {
      if (next.errorMessage != null) {
        _showErrorSnackBar(next.errorMessage!);
      }

      if (next.appointmentCreated && previous?.appointmentCreated == false) {
        _showSuccessSnackBar('Randevu başarıyla oluşturuldu');
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
      }

      if (next.availableDates.isNotEmpty &&
          next.selectedDate == null &&
          (previous == null || previous.availableDates.isEmpty)) {
        ref
            .read(appointmentProvider.notifier)
            .selectDate(next.availableDates.first);
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        ref.read(appointmentProvider.notifier).resetState();
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Randevu Al - ${widget.doctor.name}'),
          leading: IconButton(
            splashColor: AppColors.transparent,
            highlightColor: AppColors.transparent,
            icon: SvgPicture.asset(AppIcons.leftArrowWhite),
            onPressed: () {
              ref.read(appointmentProvider.notifier).resetState();
              Navigator.of(context).pop();
            },
          ),
        ),
        body: appointmentState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildAppointmentContent(appointmentState),
      ),
    );
  }

  Widget _buildAppointmentContent(AppointmentState state) {
    if (state.errorMessage != null) {
      return _errorWidget(state);
    }

    if (state.availableDates.isEmpty) {
      return _emptyWidget();
    }

    return Column(
      children: [
        Padding(
          padding: AppPaddings.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: AppPaddings.onlyBottomPaddingSmall,
                child: Text('Tarih Seçin', style: poppins.w500.f18.black),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _selectDay(state),
              ),
            ],
          ),
        ),

        if (state.selectedDate != null)
          _selectTime(state),

        if (state.selectedSchedule != null)
          _appointmentButton(state),
      ],
    );
  }

  Center _errorWidget(AppointmentState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Bir hata oluştu',
            style: poppins.w500.f16.redMiddle,
          ),
          SizedBox(height: 16),
          Text(state.errorMessage!),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref
                .read(appointmentProvider.notifier)
                .fetchDoctorSchedules(widget.doctor),
            child: Text(
              'Tekrar Dene',
              style: poppins.w500.f13.black,
            ),
          ),
        ],
      ),
    );
  }

  Center _emptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month_outlined, size: 64, color: AppColors.gray3),
          SizedBox(height: 16),
          Text(
            'Bu doktor için müsait tarih bulunmamaktadır.',
            style: poppins.w500.f16.gray3,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Row _selectDay(AppointmentState state) {
    return Row(
      children: state.availableDates.map((date) {
        final isSelected = state.selectedDate == date;
        return GestureDetector(
          onTap: () => ref
              .read(appointmentProvider.notifier)
              .selectDate(date),
          child: Container(
            margin: AppPaddings.onlyRightPaddingSmall,
            padding: AppPaddings.horizontalMediumVerticalSmall,
            decoration: BoxDecoration(
              color:
              isSelected ? AppColors.mainColor : AppColors.gray5,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(DateFormat('dd').format(date),
                    style: poppins.w500.f18.copyWith(
                        color: isSelected
                            ? Colors.white
                            : Colors.black)),
                Text(DateFormat('MMM').format(date),
                    style: poppins.w500.f14.copyWith(
                        color: isSelected
                            ? Colors.white
                            : Colors.black)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Expanded _selectTime(AppointmentState state) {
    return Expanded(
      child: Padding(
        padding: AppPaddings.componentPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: AppPaddings.onlyBottomPaddingSmall,
              child:
              Text('Müsait Saatler', style: poppins.w500.f18.black),
            ),
            Expanded(
              child: _buildAvailableTimeSlots(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableTimeSlots(AppointmentState state) {
    final now = DateTime.now();

    final availableTimes = state.availableDates.isNotEmpty &&
        state.selectedDate != null
        ? state.schedules.where((schedule) {
      if (!schedule.available) return false;

      if (schedule.scheduleDate.year != state.selectedDate!.year ||
          schedule.scheduleDate.month != state.selectedDate!.month ||
          schedule.scheduleDate.day != state.selectedDate!.day) {
        return false;
      }

      if (state.selectedDate!.year == now.year &&
          state.selectedDate!.month == now.month &&
          state.selectedDate!.day == now.day) {
        final startTimeParts = schedule.startTime.split(':');
        final scheduleHour = int.parse(startTimeParts[0]);
        final scheduleMinute = int.parse(startTimeParts[1]);

        if (scheduleHour < now.hour ||
            (scheduleHour == now.hour && scheduleMinute <= now.minute)) {
          return false;
        }
      }

      return true;
    }).toList()
        : [];

    if (availableTimes.isEmpty) {
      return Center(
        child: Text(
          'Bu tarihte müsait zaman dilimi bulunmamaktadır.',
          style: poppins.w500.f13.gray3,
          textAlign: TextAlign.center,
        ),
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: availableTimes.length,
      itemBuilder: (context, index) {
        final schedule = availableTimes[index];
        final isSelected = state.selectedSchedule == schedule;

        return GestureDetector(
          onTap: () =>
              ref.read(appointmentProvider.notifier).selectSchedule(schedule),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.mainColor : AppColors.gray5,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text('${schedule.startTime} - ${schedule.endTime}',
                  style: poppins.w500.f14.copyWith(
                    color: isSelected ? Colors.white : Colors.black,
                  )),
            ),
          ),
        );
      },
    );
  }

  Padding _appointmentButton(AppointmentState state) {
    return Padding(
      padding: AppPaddings.componentPadding,
      child: ElevatedButton(
        onPressed: state.isLoading
            ? null
            : () {
          final authState = ref.read(authProvider);
          if (authState.user == null) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/login', (route) => false);
          } else {
            ref
                .read(appointmentProvider.notifier)
                .createAppointment(widget.doctor);
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/home', (route) => false);
          }
        },
        child: state.isLoading
            ? CircularProgressIndicator.adaptive()
            : Text('Randevu Al'),
      ),
    );
  }

}
