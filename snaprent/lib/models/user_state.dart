import 'package:flutter/foundation.dart';

/// Represents a user model with their personal information.
@immutable
class User {
  final String fullName;
  final String email;
  final String phone;
  final String? image;

  const User({
    required this.fullName,
    required this.email,
    required this.phone,
    this.image,
  });

  /// Creates a new [User] instance with updated fields.
  User copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? image,
  }) {
    return User(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      image: image ?? this.image,
    );
  }
}
