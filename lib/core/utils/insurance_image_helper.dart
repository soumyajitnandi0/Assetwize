/// Utility class for mapping insurance types to their corresponding images
///
/// This helper provides a centralized way to get the correct image asset
/// path based on the insurance type selected by the user.
class InsuranceImageHelper {
  InsuranceImageHelper._();

  /// Maps insurance type to corresponding image asset path
  ///
  /// [type] - The insurance type (e.g., "Health", "Life", "Travel", "Accident")
  ///
  /// Returns the asset path for the insurance type image.
  /// Returns a default placeholder if type is not recognized.
  static String getImagePath(String type) {
    // Normalize the type to handle case variations
    final normalizedType = type.toLowerCase().trim();

    switch (normalizedType) {
      case 'health':
        return 'assets/images/health_insurance.png';
      case 'life':
        return 'assets/images/life_insurance.jpg';
      case 'travel':
        return 'assets/images/travel_insurance.png';
      case 'accident':
        return 'assets/images/accident_insurance.png';
      default:
        // Return a default image or the first available image
        return 'assets/images/health_insurance.png';
    }
  }

  /// Gets image path from insurance type string that may contain category
  ///
  /// Handles formats like "Personal - Health" or just "Health"
  ///
  /// [typeString] - The full type string (e.g., "Personal - Health")
  ///
  /// Returns the asset path for the insurance type image.
  static String getImagePathFromTypeString(String typeString) {
    // Extract the type from strings like "Personal - Health" or "Asset - Life"
    final parts = typeString.split('-');
    final type = parts.isNotEmpty ? parts.last.trim() : typeString.trim();
    return getImagePath(type);
  }
}
