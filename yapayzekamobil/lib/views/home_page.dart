import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yapayzekamobil/base_components/border_radius.dart';
import 'package:yapayzekamobil/base_components/colors.dart';
import 'package:yapayzekamobil/base_components/icons.dart';
import 'package:yapayzekamobil/base_components/paddings.dart';
import 'package:yapayzekamobil/base_components/text_styles.dart';
import 'package:yapayzekamobil/providers/auth/auth_state.dart';
import 'package:yapayzekamobil/services/location/location_service.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  LocationInfo? userLocation;
  bool isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      final locationService = ref.read(locationServiceProvider);
      final location = await locationService.getCurrentLocationDetails();

      setState(() {
        userLocation = location;
        isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        isLoadingLocation = false;
      });
      print('Konum alınamadı: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Göz Asistanı'),
        actions: [
          IconButton(
            splashColor: AppColors.transparent,
            highlightColor: AppColors.transparent,
            icon: Icon(Icons.logout, color: AppColors.white,),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLocationCard(),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: AppPaddings.componentPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Hoşgeldin, ${authState.name ?? 'Kullanıcı'}!',
                      style: poppins.w600.f20.black,
                      textAlign: TextAlign.center,
                    ),

                    Padding(
                      padding: AppPaddings.vertical,
                      child: _buildFeatureCard(
                        context,
                        title: 'AI Teşhis',
                        description: 'Yapay zeka destekli tıbbi teşhis için görüntü yükleyin',
                        icon: Icons.medical_services_outlined,
                        onTap: () {
                          Navigator.of(context).pushNamed('/diagnosis');
                        },
                      ),
                    ),


                    _buildFeatureCard(
                      context,
                      title: 'Randevularım',
                      description: 'Randevularınızı görüntüleyin ve yönetin',
                      icon: Icons.edit_calendar_outlined,
                      onTap: () {
                        Navigator.of(context).pushNamed('/userAppointments');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.mainColor, AppColors.accentColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border(top: BorderSide(color: AppColors.white, width: 1.5))
      ),
      padding: AppPaddings.componentPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppPaddings.onlyBottomPaddingSmall,
            child: Row(
              children: [
                SvgPicture.asset(AppIcons.pinpoint),
                Padding(
                  padding: AppPaddings.horizontalSmall,
                  child: Text(
                      'Konumunuz',
                      style: poppins.w600.f14.white
                  ),
                ),
              ],
            ),
          ),
          isLoadingLocation
              ? Row(
            children: [
              SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              Padding(
                padding: AppPaddings.onlyLeftPaddingSmall,
                child: Text(
                    'Konum alınıyor...',
                    style: poppins.w600.f14.white
                ),
              ),
            ],
          )
              : userLocation != null
              ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  '${userLocation!.district}, ${userLocation!.city}',
                  style: poppins.w600.f18.white
              ),
            ],
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  'Konum bilgisi alınamadı',
                  style: poppins.w600.f16.white
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white70),
                onPressed: _getUserLocation,
                tooltip: 'Konumu yenile',
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, {
        required String title,
        required String description,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.radius10,
      ),
      child: InkWell(
        borderRadius: AppBorderRadius.radius10,
        onTap: onTap,
        child: Padding(
          padding: AppPaddings.componentPadding,
          child: Row(
            children: [
              Padding(
                padding: AppPaddings.onlyRightPadding,
                child: Icon(
                  icon,
                  size: 48,
                  color: AppColors.mainColor,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: AppPaddings.onlyBottomPaddingSmall,
                      child: Text(
                        title,
                        style: poppins.w600.f16,
                      ),
                    ),
                    Text(
                      description,
                      style: poppins.f14,
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(AppIcons.circleArrowRight),
            ],
          ),
        ),
      ),
    );
  }
}