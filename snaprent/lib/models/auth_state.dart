import 'dart:convert';

class AuthState {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String userId;

  AuthState({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.userId,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get willExpireSoon =>
      DateTime.now().add(const Duration(minutes: 1)).isAfter(expiresAt);

  AuthState copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? userId,
  }) {
    return AuthState(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresAt': expiresAt.toIso8601String(),
    'userId': userId,
  };

  factory AuthState.fromJson(Map<String, dynamic> json) {
    return AuthState(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      userId: json['userId'] as String,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}
