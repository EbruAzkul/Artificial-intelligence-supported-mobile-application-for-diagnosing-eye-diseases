import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yapayzekamobil/base_components/doctor_card/doctor_card.dart';
import 'package:yapayzekamobil/model/diagnosis.dart';
import 'package:yapayzekamobil/model/doctor.dart';
import 'package:yapayzekamobil/model/hospital.dart';
import 'package:yapayzekamobil/base_components/colors.dart';
import 'package:yapayzekamobil/base_components/icons.dart';
import 'package:yapayzekamobil/base_components/paddings.dart';
import 'package:yapayzekamobil/base_components/text_styles.dart';
import 'package:yapayzekamobil/providers/auth/auth_state.dart';
import 'package:yapayzekamobil/providers/diagnosis/diagnosis_provider.dart';
import 'package:yapayzekamobil/providers/hospital/hospital_provider.dart';
import 'package:yapayzekamobil/views/hospital/hospital_info.dart';

class RecommendedDoctorsPage extends ConsumerStatefulWidget {
  final Diagnosis diagnosis;
  final List<Doctor> recommendedDoctors;

  const RecommendedDoctorsPage({
    super.key,
    required this.diagnosis,
    required this.recommendedDoctors
  });

  @override
  ConsumerState<RecommendedDoctorsPage> createState() => _RecommendedDoctorsPageState();
}

class _RecommendedDoctorsPageState extends ConsumerState<RecommendedDoctorsPage> {
  bool _showAllDoctors = false;

  String _mapDiagnosisToSpecialty(String? predictedClass) {
    return predictedClass ?? "Normal";
  }

  void _findDoctors() {
    final specialty = widget.diagnosis.predictedClass ?? "Normal";

    ref.read(hospitalProvider.notifier).findRecommendedHospitalsAndDoctors(
        specialty
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _findDoctors();
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

  void _showHospitalsList(BuildContext context, List<Hospital> hospitals) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _hospitalList(context, hospitals, scrollController),
      ),
    );
  }

  void _showHospitalDetails(BuildContext context, Hospital hospital) {
    debugPrint('Opening details for hospital: ${hospital.name} (ID: ${hospital.id})');
    debugPrint('Doctor count: ${hospital.doctors?.length ?? 0}');

    if (hospital.doctors != null) {
      for (var doc in hospital.doctors!) {
        debugPrint('Doctor: ${doc.name}, Specialty: ${doc.specialty}');
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _hospitalInfo(hospital, context, scrollController),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final hospitalState = ref.watch(hospitalProvider);
    final authState = ref.watch(authProvider);

    ref.listen<DiagnosisState>(diagnosisProvider, (previous, next) {
      if (next.errorMessage != null) {
        _showErrorSnackBar(next.errorMessage!);
      } else if (previous?.isLoading == true && next.isLoading == false) {
        if (previous?.currentDiagnosis?.id != null) {
          _showSuccessSnackBar('Randevu başarıyla oluşturuldu!');
        }
      }
    });

    final doctorsToShow = _showAllDoctors
        ? hospitalState.allDoctors
        : hospitalState.recommendedDoctors;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        ref.read(diagnosisProvider.notifier).resetState();
        ref.read(hospitalProvider.notifier).state = HospitalState();
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Teşhis Sonucu'),
          leading: IconButton(
            icon: SvgPicture.asset(AppIcons.leftArrowWhite),
            onPressed: () {
              ref.read(diagnosisProvider.notifier).resetState();
              ref.read(hospitalProvider.notifier).state = HospitalState();
              Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
              splashColor: AppColors.transparent,
              highlightColor: AppColors.transparent,
              icon: Icon(Icons.local_hospital_outlined, color: AppColors.white,),
              tooltip: 'Tüm Hastaneleri Göster',
              onPressed: () {
                _showHospitalsList(context, hospitalState.hospitals);
              },
            ),
            if (authState.user != null)
              IconButton(
                splashColor: AppColors.transparent,
                highlightColor: AppColors.transparent,
                icon: Icon(Icons.calendar_month_outlined, color: AppColors.white,),
                tooltip: 'Randevularım',
                onPressed: () {
                  Navigator.of(context).pushNamed('/userAppointments');
                },
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: AppPaddings.componentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDiagnosisResultCard(context),

                Padding(
                  padding: AppPaddings.onlyTopPadding + AppPaddings.onlyBottomPaddingXSmall,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Önerilen Doktorlar',
                        style: poppins,
                      ),
                      if (hospitalState.allDoctors.isNotEmpty && !hospitalState.isLoading)
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showAllDoctors = !_showAllDoctors;
                            });
                          },
                          icon: Icon(_showAllDoctors ? Icons.filter_alt : Icons.filter_alt_off),
                          label: Text(_showAllDoctors ? 'Önerilen Doktorlar' : 'Tüm Doktorlar'),
                        ),
                    ],
                  ),
                ),

                if (_showAllDoctors && !hospitalState.isLoading)
                  Padding(
                    padding: AppPaddings.onlyBottomPadding,
                    child: Text(
                        'Yakınındaki hastanelerdeki doktorlar listeleniyor',
                        style: poppins.w400.f13.mainColor
                    ),
                  ),

                if (hospitalState.isLoading)
                  const Center(
                    child: Padding(
                      padding: AppPaddings.componentPadding,
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Yakınınızdaki doktorlar aranıyor...'),
                        ],
                      ),
                    ),
                  )
                else if (doctorsToShow.isEmpty && !_showAllDoctors && hospitalState.allDoctors.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: AppPaddings.componentPadding,
                      child: Column(
                        children: [
                          const Icon(Icons.search_off, size: 48, color: Colors.grey),
                          Padding(
                            padding: AppPaddings.vertical,
                            child: Text(
                              'Bölgenizde ilgili uzmanlık alanında doktor bulunamadı.',
                              style: poppins.w500.f14.gray3,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _showAllDoctors = true;
                              });
                            },
                            icon: const Icon(Icons.list_alt),
                            label: const Text('Tüm Doktorları Göster'),
                          )
                        ],
                      ),
                    ),
                  )
                else if (doctorsToShow.isEmpty)
                    const Center(
                      child: Padding(
                        padding: AppPaddings.componentPadding,
                        child: Column(
                          children: [
                            Icon(Icons.search_off, size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Bölgenizde hiç doktor bulunamadı.',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: doctorsToShow.length,
                      itemBuilder: (context, index) {
                        final doctor = doctorsToShow[index];
                        Hospital? doctorHospital;
                        for (var hospital in hospitalState.hospitals) {
                          if (hospital.id == doctor.hospitalId) {
                            doctorHospital = hospital;
                            break;
                          }
                        }
                        return _buildDoctorCard(doctor, doctorHospital, context);
                      },
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding _closeButton(BuildContext context) {
    return Padding(
      padding: AppPaddings.onlyRightPadding,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
        child: SvgPicture.asset(AppIcons.close),
      ),
    );
  }

  Widget _buildDiagnosisResultCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppPaddings.componentPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Teşhis Sonucu',
              style: poppins,
            ),
            const SizedBox(height: 12),
            _buildResultRow(
                'Predicted Class',
                widget.diagnosis.predictedClass ?? 'N/A'
            ),
            _buildResultRow(
                'Confidence',
                '${((widget.diagnosis.confidence ?? 0) * 100).toStringAsFixed(2)}%'
            ),
            _buildResultRow(
                'Recommended Specialist',
                widget.diagnosis.predictedClass ?? 'N/A'
            ),

            const SizedBox(height: 12),
            Text(
              'Probabilities',
              style: poppins,
            ),
            ...?widget.diagnosis.allProbabilities?.entries.map((entry) =>
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text('${(entry.value * 100).toStringAsFixed(2)}%'),
                    ],
                  ),
                )
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor, Hospital? hospital, BuildContext context) {
    final hospitalState = ref.watch(hospitalProvider);

    final bool isRecommendedSpecialist =
        doctor.specialty.toLowerCase() == hospitalState.specialty.toLowerCase();

    return DoctorCard(doctor: doctor, hospital: hospital!);
  }

  Scaffold _hospitalList(BuildContext context, List<Hospital> hospitals, ScrollController scrollController) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hastane Listesi', style: poppins.w600.f16.white,),
        automaticallyImplyLeading: false,
        actions: [
          _closeButton(context)
        ],
      ),
      body: hospitals.isEmpty
          ? Center(child: Text('Hastane bulunamadı'))
          : ListView.builder(
        controller: scrollController,
        itemCount: hospitals.length,
        itemBuilder: (context, index) {
          final hospital = hospitals[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(hospital.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${hospital.address}, ${hospital.district}, ${hospital.city}'),
                  Text('Tel: ${hospital.phone}'),
                  Text('Doktor Sayısı: ${hospital.doctors?.length ?? 0}'),
                ],
              ),
              isThreeLine: true,
              trailing: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(AppIcons.circleArrowRight),
                ],
              ),
              onTap: () {
                Navigator.of(context).pop();
                _showHospitalDetails(context, hospital);
              },
            ),
          );
        },
      ),
    );
  }

  Scaffold _hospitalInfo(Hospital hospital, BuildContext context,
      ScrollController scrollController) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          hospital.name,
          style: poppins.w600.f16.white,
        ),
        leading: IconButton(
          splashColor: AppColors.transparent,
          highlightColor: AppColors.transparent,
          icon: SvgPicture.asset(AppIcons.leftArrowWhite),
          onPressed: () {
            Navigator.of(context).pop();
            _showHospitalsList(context, ref.read(hospitalProvider).hospitals);
          },
        ),
        actions: [_closeButton(context)],
      ),
      body:
      HospitalInfo(hospital: hospital, scrollController: scrollController, appointmentCheck: true, isRecommended: true,),
    );
  }
}