class LoginRequest {
  final String email;
  final String password;
  final String? username;

  LoginRequest({required this.email, required this.password, this.username});

  /// Always send identifier in the 'email' field for backend compatibility.
  factory LoginRequest.fromIdentifier(String identifier, String password) {
    return LoginRequest(email: identifier, password: password);
  }

  Map<String, dynamic> toJson() {
    // Always send identifier in the 'email' field for backend compatibility.
    return {'email': email, 'password': password};
  }

  /// Build a login payload using either an email or a username as the
  /// identifier. If [identifier] contains an '@' it will be sent as
  /// `'email'`, otherwise as `'username'`.
  static Map<String, dynamic> payloadFromIdentifier(String identifier, String password) {
    // Always send the identifier in the 'email' field — the API accepts
    // either an email address or a username in this property.
    return {'email': identifier, 'password': password};
  }
}

class LoginResponse {
  final String accessToken;
  final String role;
  final int userId;
  final String? username;

  LoginResponse({required this.accessToken, required this.role, required this.userId, this.username});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final accessToken = json['accessToken'] ?? json['access_token'] ?? json['token'] ?? '';
    final role = json['role'] ?? json['userRole'] ?? json['user_role'] ?? 'User';
    final username = json['username'] ?? json['user_name']; // Add this
    final dynamic rawId = json['userId'] ?? json['user_id'] ?? json['id'];
    final int userId = rawId is int
        ? rawId
        : (rawId is String ? int.tryParse(rawId) ?? 0 : 0);

    return LoginResponse(
      accessToken: accessToken,
      role: role,
      userId: userId,
      username: username,
    );
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String role;
  final String? username;

  RegisterRequest({required this.email, required this.password, required this.role, this.username});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'email': email, 'password': password, 'role': role};
    if (username != null && username!.isNotEmpty) map['username'] = username;
    return map;
  }
}

class ChangePasswordRequest {
  final int userId;
  final String newPassword;

  ChangePasswordRequest({required this.userId, required this.newPassword});

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'newPassword': newPassword};
  }
}