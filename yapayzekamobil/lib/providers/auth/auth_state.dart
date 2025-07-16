import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:yapayzekamobil/services/auth/auth_service.dart';
import '../../model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  final bool isAuthenticated;
  final String? token;
  final String? publicId;
  final String? name;
  final String? email;
  final User? user;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.isAuthenticated = false,
    this.token,
    this.publicId,
    this.name,
    this.email,
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? token,
    String? publicId,
    String? name,
    String? email,
    User? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      publicId: publicId ?? this.publicId,
      name: name ?? this.name,
      email: email ?? this.email,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthServiceInterface _authService;

  AuthNotifier(this._authService) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _authService.login(request);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response.token);
      await prefs.setString('publicId', response.publicId);
      await prefs.setString('name', response.name);
      await prefs.setString('email', response.email);

      if (response.id != null) {
        await prefs.setInt('userId', response.id!);
        debugPrint('User ID kaydedildi: ${response.id}');
      } else {
        debugPrint('Backend, User ID dönmedi!');
      }

      final user = User(
        id: response.id,
        email: response.email,
        name: response.name,
        publicId: response.publicId,
        createdAt: DateTime.now(),
      );

      debugPrint('Kullanıcı giriş yaptı: ${user.name}, ID: ${user.id}, Email: ${user.email}');

      state = state.copyWith(
        isAuthenticated: true,
        token: response.token,
        publicId: response.publicId,
        name: response.name,
        email: response.email,
        user: user,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Giriş hatası: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> register(String name, String email, String password, String publicId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final request = RegisterRequest(
        name: name,
        email: email,
        password: password,
        publicId: publicId,
      );
      final response = await _authService.register(request);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response.token);
      await prefs.setString('publicId', response.publicId);
      await prefs.setString('name', response.name);
      await prefs.setString('email', response.email);

      if (response.id != null) {
        await prefs.setInt('userId', response.id!);
        debugPrint('User ID kaydedildi: ${response.id}');
      } else {
        debugPrint('Backend, User ID dönmedi!');
      }

      User user = User(
        id: response.id,
        email: response.email,
        name: response.name,
        publicId: response.publicId,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        isAuthenticated: true,
        token: response.token,
        publicId: response.publicId,
        name: response.name,
        email: response.email,
        user: user,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Kayıt hatası: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      state = state.copyWith(isLoading: true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        try {
          final name = prefs.getString('name');
          final publicId = prefs.getString('publicId');
          final email = prefs.getString('email');
          final userId = prefs.getInt('userId');

          debugPrint('Auth check: Token bulundu');
          debugPrint('Kullanıcı: $name ($email)');
          debugPrint('Public ID: $publicId');
          debugPrint('User ID: $userId');

          User? user;
          if (publicId != null && email != null) {
            user = User(
              id: userId,
              email: email,
              name: name ?? 'Kullanıcı',
              publicId: publicId,
              createdAt: DateTime.now(),
            );
            debugPrint('Kullanıcı bilgileri yüklendi');
          }

          state = state.copyWith(
            isAuthenticated: true,
            token: token,
            publicId: publicId,
            name: name,
            email: email,
            user: user,
            isLoading: false,
          );
        } catch (e) {
          debugPrint('Auth status detay hatası: $e');
          state = state.copyWith(isAuthenticated: false, isLoading: false);
        }
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint('Auth check top-level error: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('publicId');
      await prefs.remove('name');
      await prefs.remove('email');
      await prefs.clear();

      state = AuthState();
    } catch (e) {
      debugPrint('Logout error: $e');
      state = AuthState();
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});