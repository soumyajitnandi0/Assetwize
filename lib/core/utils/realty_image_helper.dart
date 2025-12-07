/// Helper utility for getting realty image paths
/// Returns appropriate image based on property type
class RealtyImageHelper {
  RealtyImageHelper._();

  /// Returns the asset path for a realty image based on property type
  /// 
  /// - House: returns 'assets/images/house.png'
  /// - Apartment: returns 'assets/images/apartment.png'
  /// - Land: returns 'assets/images/land.png'
  /// - Commercial: returns 'assets/images/commercial.png'
  /// - Default: returns house image
  static String getImagePath(String propertyType) {
    switch (propertyType.toLowerCase()) {
      case 'house':
        return 'assets/images/house.png';
      case 'apartment':
        return 'assets/images/apartment.png';
      case 'land':
        return 'assets/images/land.png';
      case 'commercial':
        return 'assets/images/commercial.png';
      default:
        return 'assets/images/house.png'; // Default to house
    }
  }
}

