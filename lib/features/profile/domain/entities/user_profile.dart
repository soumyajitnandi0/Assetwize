import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

/// User profile entity representing user's personal information
/// This is a pure domain entity with no Flutter dependencies
class UserProfile extends Equatable {
  final String? name;
  final String? phoneNumber;
  final String? email;

  const UserProfile({
    this.name,
    this.phoneNumber,
    this.email,
  });

  /// Returns true if all required fields are filled
  bool get isComplete => name != null && 
                        name!.isNotEmpty && 
                        phoneNumber != null && 
                        phoneNumber!.isNotEmpty && 
                        email != null && 
                        email!.isNotEmpty;

  /// Calculates profile completion percentage (0-100)
  int get completionPercentage {
    int completed = 0;
    const total = AppConstants.profileTotalFields;

    if (name != null && name!.isNotEmpty) completed++;
    if (phoneNumber != null && phoneNumber!.isNotEmpty) completed++;
    if (email != null && email!.isNotEmpty) completed++;

    return ((completed / total) * 100).round();
  }

  /// Returns user initials for avatar display
  String get initials {
    if (name == null || name!.isEmpty) return 'U';
    
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  /// Creates a copy of this profile with updated fields
  UserProfile copyWith({
    String? name,
    String? phoneNumber,
    String? email,
  }) {
    return UserProfile(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [name, phoneNumber, email];
}

