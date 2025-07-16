import 'package:flutter/material.dart';
import 'package:yapayzekamobil/base_components/colors.dart';
import 'package:yapayzekamobil/base_components/doctor_card/doctor_card.dart';
import 'package:yapayzekamobil/base_components/paddings.dart';
import 'package:yapayzekamobil/base_components/text_styles.dart';
import 'package:yapayzekamobil/model/hospital.dart';

class HospitalInfo extends StatelessWidget {
  const HospitalInfo(
      {super.key,
        required this.hospital,
        this.scrollController,
        this.appointmentCheck = false,
        this.isRecommended = false});

  final Hospital hospital;
  final ScrollController? scrollController;
  final bool? appointmentCheck;
  final bool? isRecommended;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: AppPaddings.componentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            margin: AppPaddings.onlyBottomPadding,
            child: Padding(
              padding: AppPaddings.componentPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_hospital_outlined,
                          color: AppColors.mainColor),
                      Padding(
                        padding: AppPaddings.onlyLeftPaddingSmall,
                        child: Text('Hastane Bilgileri',
                            style: poppins.w600.f16.black),
                      ),
                    ],
                  ),
                  Divider(),
                  Padding(
                    padding: AppPaddings.onlyTopPaddingSmall,
                    child: _buildInfoRow(Icons.local_hospital_outlined,
                        'Hastane Adı', hospital.name),
                  ),
                  _buildInfoRow(Icons.location_on, 'Adres',
                      '${hospital.address}, ${hospital.district}, ${hospital.city}'),
                  _buildInfoRow(Icons.phone, 'Telefon', hospital.phone),
                ],
              ),
            ),
          ),

          Padding(
            padding: AppPaddings.onlyBottomPadding,
            child: Row(
              children: [
                Padding(
                  padding: AppPaddings.onlyRightPaddingSmall,
                  child: Icon(Icons.people_outline, color: AppColors.mainColor),
                ),
                Text('Doktorlar (${hospital.doctors?.length ?? 0})',
                    style: poppins.w600.f16.black),
              ],
            ),
          ),

          Builder(
            builder: (context) {
              final doctors = hospital.doctors;

              if (doctors == null || doctors.isEmpty) {
                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: AppPaddings.componentPadding,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_off,
                              size: 48, color: AppColors.gray3),
                          Padding(
                            padding: AppPaddings.onlyTopPadding,
                            child: Text(
                              'Bu hastanede kayıtlı doktor bulunmamaktadır.',
                              textAlign: TextAlign.center,
                              style: poppins.w500.f14.gray3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doctor = doctors[index];
                  return DoctorCard(
                    doctor: doctor,
                    hospital: hospital,
                    hospitalInfo: false,
                    isRecommended: isRecommended,
                    appointmentCheck: appointmentCheck,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: AppPaddings.onlyBottomPaddingSmall,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: AppPaddings.onlyRightPaddingSmall,
            child: Icon(icon, size: 16, color: AppColors.gray3),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: poppins.w500.f12.gray3,
                ),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
