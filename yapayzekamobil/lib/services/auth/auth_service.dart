import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_service.dart';
import '../../model/user.dart';

class AuthResponse {
  final String token;
  final String publicId;
  final String name;
  final String email;
  final int? id;

  AuthResponse({
    required this.token,
    required this.publicId,
    required this.name,
    required this.email,
    this.id,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      publicId: json['publicId'],
      name: json['name'],
      email: json['email'],
      id: json['id'],
    );
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String publicId;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.publicId,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'publicId': publicId,
  };
}

abstract class AuthServiceInterface {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
  Future<User> getCurrentUser();
}

class AuthService implements AuthServiceInterface {
  final ApiServiceInterface _apiService;

  AuthService(this._apiService);

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiService.post('/api/auth/login', request.toJson());
      return AuthResponse.fromJson(response);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiService.post('/api/auth/register', request.toJson());
      return AuthResponse.fromJson(response);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiService.get('/api/users/me');
      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }
}

final authServiceProvider = Provider<AuthServiceInterface>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthService(apiService);
});