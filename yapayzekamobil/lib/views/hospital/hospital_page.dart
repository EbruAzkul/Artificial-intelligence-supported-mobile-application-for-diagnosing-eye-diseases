import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yapayzekamobil/base_components/colors.dart';
import 'package:yapayzekamobil/base_components/icons.dart';
import 'package:yapayzekamobil/model/hospital.dart';
import 'package:yapayzekamobil/views/hospital/hospital_info.dart';

class HospitalPage extends StatelessWidget {
  const HospitalPage({super.key, required this.hospital});

  final Hospital hospital;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hospital.name),
        leading: IconButton(
          splashColor: AppColors.transparent,
          highlightColor: AppColors.transparent,
          icon: SvgPicture.asset(
            AppIcons.leftArrowWhite,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),

      body: HospitalInfo(hospital: hospital),
    );
  }
}
