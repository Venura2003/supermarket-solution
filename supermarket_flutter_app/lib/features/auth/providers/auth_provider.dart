import 'package:flutter/material.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/utils/secure_storage_util.dart';
import '../repositories/auth_repository.dart';


class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;
  String? _errorMessage;
  String? _role;
  int? _userId;
  String? _email;
  String? _token; // Added
  String? _username; // Added
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get role => _role;
  String? get userRole => _role;
  String? get error => _errorMessage;
  int? get userId => _userId;
  String? get email => _email;
  String? get token => _token; // Added
  String? get username => _username; // Added

  bool get isAuthenticated => _role != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = LoginRequest.fromIdentifier(email, password);
      final response = await _authRepository.login(request);
      await SecureStorageUtil.saveToken(response.accessToken);
      await SecureStorageUtil.saveRole(response.role);
      await SecureStorageUtil.saveUserId(response.userId);
      await SecureStorageUtil.saveEmail(email);
      if (response.username != null) await SecureStorageUtil.saveUsername(response.username!);
      
      print('[AuthProvider] Token saved after login: ${response.accessToken}');
      final checkToken = await SecureStorageUtil.getToken();
      print('[AuthProvider] Token read from storage after save: $checkToken');
      _token = response.accessToken;
      _role = response.role;
      _userId = response.userId;
      _email = email;
      _username = response.username; // Added
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<int?> register(String email, String password, String role, {String? username}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = RegisterRequest(email: email, password: password, role: role, username: username);
      final userId = await _authRepository.register(request);
      return userId;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword(int userId, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = ChangePasswordRequest(userId: userId, newPassword: newPassword);
      await _authRepository.changePassword(request);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    final token = await SecureStorageUtil.getToken();
    final storedRole = await SecureStorageUtil.getRole();
    final storedUserId = await SecureStorageUtil.getUserId();
    final storedEmail = await SecureStorageUtil.getEmail();
    final storedUsername = await SecureStorageUtil.getUsername(); // Added
    if (token != null && storedRole != null) {
      _token = token;
      _role = storedRole;
      _userId = storedUserId;
      _email = storedEmail;
      _username = storedUsername;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await SecureStorageUtil.clearAll();
    _role = null;
    _userId = null;
    _email = null;
    _username = null; // Added
    notifyListeners();
  }
}