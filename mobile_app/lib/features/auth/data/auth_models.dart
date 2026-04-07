class AuthSession {
  final String token;
  final int? userId;
  final String? name;
  final String? email;
  final String? role;

  const AuthSession({
    required this.token,
    this.userId,
    this.name,
    this.email,
    this.role,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: (json['token'] ?? '').toString(),
      userId: _asInt(json['userId'] ?? json['id']),
      name: _asNullableString(json['name']),
      email: _asNullableString(json['email']),
      role: _asNullableString(json['role']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'userId': userId,
      'name': name,
      'email': email,
      'role': role,
    };
  }

  String get displayName {
    if (name != null && name!.trim().isNotEmpty) {
      return name!.trim();
    }

    if (email != null && email!.trim().isNotEmpty) {
      return email!.trim();
    }

    if (userId != null) {
      return 'User #$userId';
    }

    return 'Authenticated user';
  }

  AuthSession copyWith({
    String? token,
    int? userId,
    String? name,
    String? email,
    String? role,
  }) {
    return AuthSession(
      token: token ?? this.token,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}

class AuthApiException implements Exception {
  final String message;

  const AuthApiException(this.message);

  @override
  String toString() => message;
}

int? _asInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is String) {
    return int.tryParse(value);
  }

  return null;
}

String? _asNullableString(dynamic value) {
  if (value == null) {
    return null;
  }

  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
