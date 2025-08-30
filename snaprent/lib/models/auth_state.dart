class User {
  String fullName;
  String email;
  String phone;
  String? image;
  String? provider;

  User({
    required this.fullName,
    required this.email,
    required this.phone,
    this.image,
    this.provider,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      image: json['image'],
      provider: json['provider'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'image': image,
      'provider': provider,
    };
  }
}

class AuthState {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String userId;
  final User? user;

  AuthState({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.userId,
    this.user,
  });

  // Add the missing isExpired getter here
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isAuthenticated => accessToken.isNotEmpty && !isExpired;

  // You can also add the willExpireSoon getter if you need it
  bool get willExpireSoon =>
      DateTime.now().add(const Duration(minutes: 1)).isAfter(expiresAt);

  AuthState copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? userId,
    User? user,
  }) {
    return AuthState(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      userId: userId ?? this.userId,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresAt': expiresAt.toIso8601String(),
    'userId': userId,
    'user': user?.toJson(),
  };

  factory AuthState.fromJson(Map<String, dynamic> json) {
    return AuthState(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      userId: json['userId'] as String,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}
