/// Helper utility for getting garage/vehicle image paths
/// Returns appropriate image based on vehicle type
class GarageImageHelper {
  GarageImageHelper._();

  /// Returns the asset path for a vehicle image based on type
  /// 
  /// - Car: returns 'assets/images/car_insurance.png'
  /// - Bike: returns 'assets/images/bike_insurance.png'
  /// - Default: returns car image
  static String getImagePath(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'car':
        return 'assets/images/car_insurance.png';
      case 'bike':
        return 'assets/images/bike_insurance.png';
      default:
        return 'assets/images/car_insurance.png';
    }
  }
}

