/// Helper utility for getting jewellery image paths
/// Returns appropriate image based on category
class JewelleryImageHelper {
  JewelleryImageHelper._();

  /// Returns the asset path for a jewellery image based on category
  /// 
  /// - Gold: returns 'assets/images/gold_insurance.png'
  /// - Silver: returns 'assets/images/silver_insurance.png'
  /// - Diamond: returns 'assets/images/diamond_insurance.png'
  /// - Platinum: returns 'assets/images/platinum_insurance.png'
  /// - Default: returns gold image
  static String getImagePath(String category) {
    switch (category.toLowerCase()) {
      case 'gold':
        return 'assets/images/gold_insurance.png';
      case 'silver':
        return 'assets/images/silver_insurance.png';
      case 'diamond':
        return 'assets/images/diamond_insurance.png';
      case 'platinum':
        return 'assets/images/platinum_insurance.png';
      default:
        return 'assets/images/gold_insurance.png'; // Default to gold
    }
  }
}

