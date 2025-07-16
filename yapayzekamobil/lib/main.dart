import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yapayzekamobil/base_components/border_radius.dart';
import 'package:yapayzekamobil/base_components/colors.dart';
import 'package:yapayzekamobil/base_components/text_styles.dart';
import 'package:yapayzekamobil/model/hospital.dart';
import 'package:yapayzekamobil/providers/appointment/appointment_provider.dart';
import 'package:yapayzekamobil/views/appointment/appointment_page.dart';
import 'package:yapayzekamobil/views/appointment/user_appointment_page.dart';
import 'package:yapayzekamobil/views/auth/login_page.dart';
import 'package:yapayzekamobil/views/diagnosis/diagnosis_page.dart';
import 'package:yapayzekamobil/views/doctor/recommended_doctors_page.dart';
import 'package:yapayzekamobil/views/home_page.dart';
import 'package:yapayzekamobil/views/hospital/hospital_page.dart';
import '/model/doctor.dart';
import 'providers/auth/auth_state.dart';

class AppConfig {
  // static const String apiBaseUrl = 'http://192.168.0.150:8081'; //ev
  static const String apiBaseUrl = 'http://192.168.1.164:8081'; //kütüphane
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Medical App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.mainColor,
          primary: AppColors.mainColor,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.mainColor,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppColors.mainColor,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: poppins.w600.f18.white,
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          },
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.white,
            backgroundColor: AppColors.accentColor,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: AppBorderRadius.radius8,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.mainColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppBorderRadius.radius8,
            borderSide: BorderSide(color: AppColors.borderColor, width: 2),
          ),
          labelStyle: poppins.w600.f14.gray3,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: AppBorderRadius.radius8,
            borderSide: BorderSide.none,
          ),
        ),
      ),
      builder: (context, child) {
        return Scaffold(
          body: SafeArea(
            bottom: true,
            top: false,
            child: child!,
          ),
        );
      },
      home: AuthCheckScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/diagnosis': (context) => const DiagnosisPage(),
        '/userAppointments': (context) => const UserAppointmentsPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/doctors') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => RecommendedDoctorsPage(
              diagnosis: args['diagnosis'],
              recommendedDoctors: args['recommendedDoctors'],
            ),
          );
        } else if (settings.name == '/appointments') {
          final doctor = settings.arguments as Doctor;
          return MaterialPageRoute(
            builder: (context) => AppointmentBookingPage(doctor: doctor),
          );
        } else if (settings.name == '/hospital') {
          final hospital = settings.arguments as Hospital;
          return MaterialPageRoute(
            builder: (context) => HospitalPage(hospital: hospital,),
          );
        }
        return null;
      },
    );
  }
}

class AuthCheckScreen extends ConsumerStatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  ConsumerState<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends ConsumerState<AuthCheckScreen> {
  bool _isAuthCheckComplete = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    try {
      await ref.read(authProvider.notifier).checkAuthStatus();
    } catch (e) {
      debugPrint('Auth check error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isAuthCheckComplete = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, current) {
      if (previous?.user?.id != current.user?.id) {
        ref.read(appointmentProvider.notifier).resetState();
        debugPrint('Kullanıcı değişikliği nedeniyle randevu durumu tamamen sıfırlandı');

        if (current.isAuthenticated && previous?.user != null) {
          debugPrint('Farklı bir kullanıcıyla giriş yapıldı, önceki veriler temizlendi');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Farklı bir hesaba giriş yaptınız. Veriler güncellendi.'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    });

    if (!_isAuthCheckComplete) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Yükleniyor...'),
            ],
          ),
        ),
      );
    }

    final authState = ref.watch(authProvider);
    if (authState.isAuthenticated) {
      return const HomePage();
    } else {
      return const LoginPage();
    }
  }
}