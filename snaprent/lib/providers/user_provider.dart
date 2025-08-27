import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snaprent/models/user_state.dart';

/// A provider that manages the user's state.
final userProvider = StateNotifierProvider<UserNotifier, User?>(
  (ref) => UserNotifier(),
);

/// A StateNotifier to manage the user's data.
class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null);

  /// Sets the user's state.
  void setUser(User user) {
    state = user;
  }

  /// Updates specific fields of the user's state.
  void updateUser({
    String? fullName,
    String? email,
    String? phone,
    String? image,
  }) {
    state = state?.copyWith(
      fullName: fullName,
      email: email,
      phone: phone,
      image: image,
    );
  }
}
