import '../../domain/entities/user_profile.dart';

/// Data model for user profile
/// Extends the domain entity with JSON serialization capabilities
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    super.name,
    super.phoneNumber,
    super.email,
  });

  /// Creates a UserProfileModel from a domain entity
  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      name: profile.name,
      phoneNumber: profile.phoneNumber,
      email: profile.email,
    );
  }

  /// Creates a UserProfileModel from JSON
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['name'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
    );
  }

  /// Converts UserProfileModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }
}

