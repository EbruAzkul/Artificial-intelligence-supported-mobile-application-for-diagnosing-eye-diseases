import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:yapayzekamobil/base_components/border_radius.dart';
import 'package:yapayzekamobil/base_components/colors.dart';
import 'package:yapayzekamobil/base_components/custom_rich_text/custom_rich_text.dart';
import 'package:yapayzekamobil/base_components/icons.dart';
import 'package:yapayzekamobil/base_components/name_avatar/name_avatar.dart';
import 'package:yapayzekamobil/base_components/paddings.dart';
import 'package:yapayzekamobil/base_components/text_styles.dart';
import 'package:yapayzekamobil/providers/appointment/appointment_provider.dart';
import 'package:yapayzekamobil/providers/auth/auth_state.dart';
import 'package:yapayzekamobil/views/auth/login_page.dart';

import '../../providers/hospital/hospital_provider.dart';

class UserAppointmentsPage extends ConsumerStatefulWidget {
  const UserAppointmentsPage({super.key});

  @override
  ConsumerState<UserAppointmentsPage> createState() =>
      _UserAppointmentsPageState();
}

class _UserAppointmentsPageState extends ConsumerState<UserAppointmentsPage> {
  bool _isLoading = false;
  List<dynamic> _appointments = [];
  String? _errorMessage;

  bool _isCompletedExpanded = false;
  bool _isCancelledExpanded = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserAppointments();
    });
  }

  Future<void> _loadUserAppointments() async {
    final authState = ref.read(authProvider);

    if (!authState.isAuthenticated) {
      setState(() {
        _errorMessage = 'Randevularınızı görmek için giriş yapmalısınız';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (authState.user?.id == null) {
        debugPrint('Uyarı: Kullanıcı ID bilgisi bulunamadı!');
        throw Exception('Kullanıcı bilgisi eksik. Lütfen tekrar giriş yapın.');
      }

      int userId = authState.user!.id!;
      debugPrint('Kullanıcı ID: $userId için randevular getiriliyor');

      ref.read(appointmentProvider.notifier).resetState();

      await ref
          .read(appointmentProvider.notifier)
          .fetchUserAppointments(userId);

      final appointmentState = ref.read(appointmentProvider);

      setState(() {
        _isLoading = false;
        _appointments = appointmentState.appointments;
        debugPrint('Randevular yüklendi: ${_appointments.length}');

        for (var appointment in _appointments) {
          debugPrint('Randevu DETAY: ${appointment.toString()}');
          debugPrint('Randevu ID: ${appointment['id'] ?? 'yok'}, '
              'Tarih: ${appointment['appointmentDate'] ?? 'yok'}, '
              'Durum: ${appointment['status'] ?? 'yok'}');

          final doctor = appointment['doctor'];
          if (doctor != null) {
            debugPrint('Doktor: ${doctor.toString()}');
            debugPrint('Doktor keys: ${doctor.keys.toList()}');
            debugPrint('Doktor ID: ${doctor['id'] ?? 'yok'}, '
                'Adı: ${doctor['name'] ?? 'yok'}, '
                'Uzmanlık: ${doctor['specialty'] ?? 'yok'}');

            if (doctor.containsKey('hospital')) {
              final hospital = doctor['hospital'];
              debugPrint(
                  'Hastane (doctor.hospital): ${hospital.toString()}');
            } else {
              debugPrint('doctor.hospital bulunamadı');
            }

            if (doctor.containsKey('hospitalId')) {
              debugPrint(
                  'Hastane ID (doctor.hospitalId): ${doctor['hospitalId']}');
            }

            if (appointment.containsKey('hospital')) {
              final hospital = appointment['hospital'];
              debugPrint(
                  'Hastane (appointment.hospital): ${hospital.toString()}');
            }
          } else {
            debugPrint('Doktor bilgisi bulunamadı');
          }
        }
      });
    } catch (e, stackTrace) {
      debugPrint('Randevu yükleme hatası: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
        _errorMessage =
        'Randevularınız yüklenirken bir hata oluştu: ${e.toString()}';
      });
    }
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

  Future<bool> _showCancelConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Randevu İptali'),
        content: Text('Bu randevuyu iptal etmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Vazgeç', style: poppins.w500.f13.mainColor,),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('İptal Et', style: poppins.w500.f13.redMiddle),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _cancelAppointment(int appointmentId) async {
    final confirm = await _showCancelConfirmation();

    if (!confirm) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(appointmentProvider.notifier)
          .cancelAppointment(appointmentId);
      _showSuccessSnackBar('Randevunuz iptal edildi');

      _loadUserAppointments();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(
          'Randevu iptal edilirken hata oluştu: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Randevularım'),
        leading: IconButton(
          splashColor: AppColors.transparent,
          highlightColor: AppColors.transparent,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: SvgPicture.asset(
            AppIcons.leftArrowWhite,
          ),
        ),
        actions: authState.isAuthenticated
            ? [
          IconButton(
            splashColor: AppColors.transparent,
            highlightColor: AppColors.transparent,
            icon: Icon(Icons.refresh, color: AppColors.white),
            onPressed: _loadUserAppointments,
            tooltip: 'Yenile',
          ),
        ]
            : null,
      ),
      body: !authState.isAuthenticated
          ? _buildUnauthenticatedView()
          : _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : _buildCategorizedAppointmentsList(_appointments),
    );
  }

  Widget _buildCategorizedAppointmentsList(List<dynamic> appointments) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Henüz randevunuz bulunmamaktadır',
                style: poppins.w600.f16.textMiddle),
          ],
        ),
      );
    }

    final upcomingAppointments = <dynamic>[];
    final completedAppointments = <dynamic>[];
    final cancelledAppointments = <dynamic>[];

    for (var appointment in appointments) {
      final appointmentDateTime = appointment['appointmentDate'] != null
          ? DateTime.parse(appointment['appointmentDate'].toString())
          : null;

      final status = appointment['status'] ?? '';

      if (status == 'CANCELLED') {
        cancelledAppointments.add(appointment);
      } else if (appointmentDateTime != null &&
          appointmentDateTime.isAfter(DateTime.now())) {
        upcomingAppointments.add(appointment);
      } else {
        completedAppointments.add(appointment);
      }
    }

    upcomingAppointments.sort((a, b) {
      final dateA = DateTime.parse(a['appointmentDate'].toString());
      final dateB = DateTime.parse(b['appointmentDate'].toString());
      return dateA.compareTo(dateB);
    });

    completedAppointments.sort((a, b) {
      final dateA = DateTime.parse(a['appointmentDate'].toString());
      final dateB = DateTime.parse(b['appointmentDate'].toString());
      return dateB.compareTo(dateA);
    });

    cancelledAppointments.sort((a, b) {
      final dateA = DateTime.parse(a['appointmentDate'].toString());
      final dateB = DateTime.parse(b['appointmentDate'].toString());
      return dateB.compareTo(dateA);
    });

    return SingleChildScrollView(
      padding: AppPaddings.componentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (upcomingAppointments.isNotEmpty) ...[
            Padding(
                padding: AppPaddings.onlyBottomPadding,
                child: Text(
                    'Yaklaşan Randevular',
                    style: poppins.w600.f17.black)
            ),
            ...upcomingAppointments
                .map((appointment) => _buildAppointmentCard(appointment)),
          ],

          if (completedAppointments.isNotEmpty)
            _buildAppointmentAccordion(
              title: 'Tamamlanan Randevular',
              appointments: completedAppointments,
              isExpanded: _isCompletedExpanded,
              onExpansionChanged: (value) {
                setState(() {
                  _isCompletedExpanded = value;
                });
              },
              iconColor: Colors.green,
            ),

          if (cancelledAppointments.isNotEmpty)
            _buildAppointmentAccordion(
              title: 'İptal Edilen Randevular',
              appointments: cancelledAppointments,
              isExpanded: _isCancelledExpanded,
              onExpansionChanged: (value) {
                setState(() {
                  _isCancelledExpanded = value;
                });
              },
              iconColor: Colors.red,
            ),
        ],
      ),
    );
  }

  Widget _buildAppointmentAccordion({
    required String title,
    required List<dynamic> appointments,
    required bool isExpanded,
    required Function(bool) onExpansionChanged,
    required Color iconColor,
  }) {
    return Card(
      margin: AppPaddings.onlyBottomPadding,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
              title,
              style: poppins.w600.f15.black
          ),
          leading: Icon(
            Icons.calendar_month_outlined,
            color: iconColor,
          ),
          initiallyExpanded: isExpanded,
          onExpansionChanged: onExpansionChanged,
          childrenPadding: AppPaddings.verticalSmall,
          collapsedBackgroundColor: AppColors.gray4,
          backgroundColor: AppColors.gray4,
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          children: appointments
              .map((appointment) => Padding(
            padding: AppPaddings.horizontalSmall,
            child: _buildAppointmentCard(appointment),
          ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(dynamic appointment) {
    final dateFormat = DateFormat('d MMMM yyyy');
    final timeFormat = DateFormat('HH:mm');

    final appointmentDateTime = appointment['appointmentDate'] != null
        ? DateTime.parse(appointment['appointmentDate'].toString())
        : null;

    final formattedDate = appointmentDateTime != null
        ? dateFormat.format(appointmentDateTime)
        : 'Tarih belirtilmemiş';

    final formattedTime = appointmentDateTime != null
        ? timeFormat.format(appointmentDateTime)
        : '';

    final bool isUpcoming = appointmentDateTime != null &&
        appointmentDateTime.isAfter(DateTime.now());

    final bool isCancelled = appointment['status'] == 'CANCELLED';

    Color statusColor = isCancelled
        ? AppColors.redMiddle
        : isUpcoming
        ? AppColors.greenMiddle
        : AppColors.gray3;

    Color statusBackgroundColor = isCancelled
        ? AppColors.redSoft
        : isUpcoming
        ? AppColors.greenSoft
        : AppColors.gray5;

    String statusText = isCancelled
        ? 'İptal Edildi'
        : isUpcoming
        ? 'Yaklaşan Randevu'
        : 'Tamamlandı';

    final doctor = appointment['doctor'];
    final doctorName =
    doctor != null ? doctor['name'] ?? 'İsimsiz Doktor' : 'İsimsiz Doktor';
    final doctorSpecialty = doctor != null ? doctor['specialty'] ?? '' : '';
    final doctorContact = doctor != null ? doctor['contactNumber'] ?? '' : '';

    String hospitalName = '';

    if (appointment.containsKey('hospital') &&
        appointment['hospital'] != null) {
      final hospital = appointment['hospital'];
      hospitalName = hospital['name'] ?? '';
      debugPrint('Hastane (appointment.hospital): ${hospital.toString()}');
    }
    else if (doctor != null &&
        doctor.containsKey('hospital') &&
        doctor['hospital'] != null) {
      final hospital = doctor['hospital'];
      hospitalName = hospital['name'] ?? '';
      debugPrint('Hastane (doctor.hospital): ${hospital.toString()}');
    }
    else if (doctor != null && doctor.containsKey('hospitalName')) {
      hospitalName = doctor['hospitalName'] ?? '';
    }
    else if (appointment.containsKey('hospitalName')) {
      hospitalName = appointment['hospitalName'] ?? '';
    }
    final bool hasHospitalReference = doctor != null &&
        (doctor.containsKey('hospitalId') || doctor.containsKey('hospital_id'));

    debugPrint('Appointment ID: ${appointment['id']}, '
        'Hospital Name: "$hospitalName", '
        'Has Hospital Reference: $hasHospitalReference');

    return Container(
      margin: AppPaddings.onlyBottomPadding,
      decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.mainColor, width: 1),
          borderRadius: AppBorderRadius.radius8),
      child: Padding(
        padding: AppPaddings.componentPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _statusInfo(statusBackgroundColor, statusColor, statusText),
                    Spacer(),
                    _date(formattedDate),
                  ],
                ),

                Padding(
                  padding: AppPaddings.onlyTopPadding + AppPaddings.onlyBottomPaddingSmall,
                  child: Row(
                    children: [
                      NameAvatar(
                        name: doctorName,
                        backgroundColor: AppColors.greenSoft,
                        textColor: AppColors.mainColor,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctorName,
                              style: poppins.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                              formattedTime,
                              style: poppins.w600.f17.black
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (doctorSpecialty.isNotEmpty)
                      Padding(
                        padding: AppPaddings.onlyBottomPadding2XSmall,
                        child: CustomRichText(
                          title: 'Uzmanlık: ',
                          text: doctorSpecialty,
                        ),
                      ),
                    if (doctorContact.isNotEmpty)
                      CustomRichText(
                        title: 'Telefon: ',
                        text: doctorContact,
                      ),
                  ],
                ),

                if (hospitalName.isNotEmpty)
                  InkWell(
                    onTap: () async {
                      try {
                        if (appointment['hospital'] != null) {
                          final hospitalData =
                          appointment['hospital'] as Map<String, dynamic>;
                          final hospitalId = hospitalData['id'];

                          if (hospitalId != null) {
                            await ref
                                .read(hospitalProvider.notifier)
                                .fetchHospitalDetails(hospitalId);
                            final hospitalState = ref.read(hospitalProvider);

                            if (hospitalState.currentHospital != null) {
                              await Navigator.of(context).pushNamed('/hospital',
                                  arguments: hospitalState.currentHospital);
                            } else if (hospitalState.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(hospitalState.errorMessage!),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Hastane ID bulunamadı'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Hastane bilgileri bulunamadı'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Hastane bilgileri yüklenirken bir hata oluştu'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Container(
                      margin: AppPaddings.onlyTopPaddingSmall,
                      padding: AppPaddings.componentPaddingSmall,
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColors.mainColor, width: 1),
                          borderRadius: AppBorderRadius.radius8),
                      child: Row(
                        children: [
                          Icon(Icons.local_hospital_outlined,
                              size: 16, color: AppColors.mainColor),
                          Expanded(
                            child: Padding(
                              padding: AppPaddings.horizontalSmall,
                              child: Text(hospitalName,
                                  style: poppins.w500.f14.mainColor),
                            ),
                          ),
                          SvgPicture.asset(AppIcons.circleArrowRight)
                        ],
                      ),
                    ),
                  ),

                if (hospitalName.isEmpty && hasHospitalReference)
                  Padding(
                    padding: AppPaddings.onlyTopPaddingSmall,
                    child: Row(
                      children: [
                        Icon(Icons.local_hospital, size: 16, color: Colors.orange),
                        SizedBox(width: 4),
                        Text(
                            "Hastane bilgisi yüklenemedi",
                            style: poppins.w500.f14.redMiddle
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            Column(
              children: [
                if (isUpcoming && !isCancelled)
                  Container(
                    margin: AppPaddings.onlyTopPadding,
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.redMiddle),
                        borderRadius: AppBorderRadius.radius8
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            final appointmentId = appointment['id'];
                            if (appointmentId != null) {
                              _cancelAppointment(appointmentId);
                            }
                          },
                          icon: Icon(Icons.cancel, color: AppColors.redMiddle),
                          label: Text('Randevuyu İptal Et',
                              style: poppins.w500.f13.redMiddle),
                        ),
                      ],
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Text _date(String formattedDate) {
    return Text(
        formattedDate,
        style: poppins.w600.f14.black
    );
  }

  Container _statusInfo(Color statusBackgroundColor, Color statusColor, String statusText) {
    return Container(
      padding: AppPaddings.horizontalSmall + AppPaddings.vertical2XSmall,
      decoration: BoxDecoration(
        color: statusBackgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: statusColor),
      ),
      child: Text(
          statusText,
          style: poppins.w600.f12.copyWith(color: statusColor)
      ),
    );
  }

  Widget _buildUnauthenticatedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_circle, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Randevularınızı görmek için giriş yapmalısınız',
            textAlign: TextAlign.center,
            style: poppins.w500.f16.black,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              ).then((_) {
                final updatedAuthState = ref.read(authProvider);
                if (updatedAuthState.isAuthenticated) {
                  _loadUserAppointments();
                }
              });
            },
            child: Text('Giriş Yap'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: poppins.w500.f14.redMiddle,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadUserAppointments,
            child: Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }
}
