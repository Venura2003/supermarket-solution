import 'dart:convert';
import 'package:supermarket_flutter_app/core/services/api_service.dart';
import '../../../core/models/auth_models.dart';

class AuthRepository {
  /// WARNING: The backend expects the identifier (email or username) in the 'email' field.
  /// Always use LoginRequest.fromIdentifier and toJson for compatibility.
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await ApiService.post('/auth/login', request.toJson());
    ApiService.handleError(response);
    final data = jsonDecode(response.body);
    return LoginResponse.fromJson(data);
  }

  Future<int> register(RegisterRequest request) async {
    final response = await ApiService.post('/auth/register', request.toJson());
    ApiService.handleError(response);
    final data = jsonDecode(response.body);
    return data['userId'] as int;
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    final response = await ApiService.post('/auth/change-password', request.toJson());
    ApiService.handleError(response);
  }
}