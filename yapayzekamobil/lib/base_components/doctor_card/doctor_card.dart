import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yapayzekamobil/base_components/border_radius.dart';
import 'package:yapayzekamobil/base_components/colors.dart';
import 'package:yapayzekamobil/base_components/custom_rich_text/custom_rich_text.dart';
import 'package:yapayzekamobil/base_components/name_avatar/name_avatar.dart';
import 'package:yapayzekamobil/base_components/paddings.dart';
import 'package:yapayzekamobil/base_components/text_styles.dart';
import 'package:yapayzekamobil/model/doctor.dart';
import 'package:yapayzekamobil/model/hospital.dart';
import 'package:yapayzekamobil/providers/hospital/hospital_provider.dart';

class DoctorCard extends ConsumerStatefulWidget {
  const DoctorCard(
      {required this.doctor,
        required this.hospital,
        this.hospitalInfo = true,
        this.isRecommended = true,
        this.appointmentCheck = true,
        super.key});

  final Doctor doctor;
  final Hospital hospital;
  final bool? hospitalInfo;
  final bool? isRecommended;
  final bool? appointmentCheck;

  @override
  ConsumerState<DoctorCard> createState() => _DoctorCardState();
}

class _DoctorCardState extends ConsumerState<DoctorCard> {
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _navigateToAppointment(Doctor doctor) async {
    final result = await Navigator.of(context).pushNamed(
      '/appointments',
      arguments: doctor,
    );

    if (result == true) {
      _showSuccessSnackBar('Randevunuz başarıyla oluşturuldu');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hospitalState = ref.watch(hospitalProvider);

    final bool isRecommendedSpecialist =
        widget.doctor.specialty.toLowerCase() ==
            hospitalState.specialty.toLowerCase();

    return Container(
      margin: AppPaddings.verticalSmall,
      decoration: BoxDecoration(
        color: (isRecommendedSpecialist && (widget.isRecommended ?? true)) ? AppColors.green3 : AppColors.white,
        border: Border.all(color: AppColors.mainColor),
        borderRadius: AppBorderRadius.radius8,
      ),
      child: Padding(
        padding: AppPaddings.componentPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _doctorInfo(isRecommendedSpecialist),
            if (widget.hospitalInfo == true) ...[
              _hospitalInfo(),
            ],
            if (widget.appointmentCheck == true)
              _appointmentButton(widget.doctor),
          ],
        ),
      ),
    );
  }

  Column _doctorInfo(bool isRecommendedSpecialist) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            NameAvatar(name: widget.doctor.name),
            Expanded(
              child: Text(
                widget.doctor.name,
                style: poppins.w600.f16.black,
              ),
            ),
            if (isRecommendedSpecialist && widget.isRecommended == true)
              Chip(
                label: Text('Önerilen', style: poppins.w600.f12.mainColor),
                side: BorderSide(color: AppColors.mainColor, width: 1),
                backgroundColor: AppColors.white,
                visualDensity: VisualDensity.compact,
                padding: AppPaddings.zero,
              ),
          ],
        ),
        Padding(
          padding: AppPaddings.onlyTopPaddingSmall,
          child: Padding(
            padding: AppPaddings.onlyBottomPadding2XSmall,
            child: CustomRichText(title: 'Uzmanlık: ', text: widget.doctor.specialty),
          ),
        ),
        if (widget.doctor.contactNumber != null &&
            widget.doctor.contactNumber!.isNotEmpty)
          CustomRichText(title: 'Telefon: ', text: widget.doctor.contactNumber ?? '')
      ],
    );
  }

  Column _hospitalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppPaddings.onlyBottomPadding2XSmall +
              AppPaddings.onlyTopPadding,
          child: Row(
            children: [
              Padding(
                padding: AppPaddings.onlyRightPadding2XSmall,
                child: Icon(Icons.local_hospital_outlined,
                    size: 18, color: AppColors.mainColor),
              ),
              Expanded(
                child:
                Text(widget.hospital.name, style: poppins.w500.f14.black),
              ),
            ],
          ),
        ),
        Padding(
          padding: AppPaddings.onlyBottomPadding2XSmall,
          child: CustomRichText(
              title: 'Adres: ',
              text:
              '${widget.hospital.address}, ${widget.hospital.district}, ${widget.hospital.city}'),
        ),
        CustomRichText(title: 'Telefon: ', text: widget.hospital.phone),
      ],
    );
  }

  Container _appointmentButton(Doctor doctor) {
    return Container(
      width: double.infinity,
      margin: AppPaddings.onlyTopPadding,
      child: ElevatedButton(
        onPressed:
        doctor.id != null ? () => _navigateToAppointment(doctor) : null,
        child: const Text('Randevu Al'),
      ),
    );
  }
}
