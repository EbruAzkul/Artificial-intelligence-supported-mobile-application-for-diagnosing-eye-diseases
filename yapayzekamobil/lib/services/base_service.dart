import 'api/api_service.dart';

abstract class BaseService<T> {
  final ApiServiceInterface apiService;
  final String basePath;

  BaseService({required this.apiService, required this.basePath});

  Future<T> getById(String id);
  Future<List<T>> getAll();
  Future<T> create(T entity);
  Future<T> update(String id, T entity);
  Future<void> delete(String id);

  T fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson(T entity);
}

class ServiceException implements Exception {
  final String message;
  final int? statusCode;

  ServiceException(this.message, {this.statusCode});

  @override
  String toString() => 'ServiceException: $message (StatusCode: $statusCode)';
}