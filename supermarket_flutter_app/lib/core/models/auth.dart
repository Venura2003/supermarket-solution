class TokenResponse {
  final String accessToken;
  final DateTime expiresAt;
  final String tokenType;
  final String email;
  final String role;

  TokenResponse({
    required this.accessToken,
    required this.expiresAt,
    required this.tokenType,
    required this.email,
    required this.role,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['accessToken'],
      expiresAt: DateTime.parse(json['expiresAt']),
      tokenType: json['tokenType'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'expiresAt': expiresAt.toIso8601String(),
      'tokenType': tokenType,
      'email': email,
      'role': role,
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String role;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'role': role,
    };
  }
}