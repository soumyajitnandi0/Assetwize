# ASSETWIZE - My Insurances Feature

A Flutter application implementing the "My Insurances" feature from the AssetWize Figma prototype. Built with Clean Architecture, flutter_bloc (Cubits), and mock data ready for Firebase integration.

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/
│   ├── constants/          # App-wide constants (spacing, radii, etc.)
│   └── theme/              # Theme configuration
├── features/
│   └── insurance/
│       ├── data/           # Data layer
│       │   ├── models/     # Data models (extend domain entities)
│       │   └── repositories/  # Repository implementations
│       ├── domain/         # Business logic layer
│       │   ├── entities/   # Pure domain entities
│       │   ├── repositories/  # Repository interfaces
│       │   └── usecases/   # Business use cases
│       └── presentation/   # UI layer
│           ├── bloc/       # State management (Cubits)
│           ├── pages/      # Screen widgets
│           └── widgets/    # Reusable UI components
└── main.dart               # App entry point
```

### Key Principles

- **Domain Layer**: Pure Dart code with no Flutter dependencies
- **Data Layer**: Implements domain interfaces, handles data sources
- **Presentation Layer**: Flutter-specific UI and state management
- **Dependency Rule**: Dependencies point inward (presentation → domain ← data)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.5.4 or higher
- Dart SDK 3.5.4 or higher

### Installation

1. **Clone the repository** (if applicable) or navigate to the project directory

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate mock files for tests** (if running tests):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

### Quick Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test

# Format code
dart format .

# Analyze code
flutter analyze
```

## 📦 Dependencies

### Production Dependencies
- `flutter_bloc: ^8.1.6` - State management
- `equatable: ^2.0.5` - Value equality
- `cached_network_image: ^3.3.1` - Network image caching
- `intl: ^0.19.0` - Date formatting

### Development Dependencies
- `flutter_lints: ^4.0.0` - Linting rules
- `mockito: ^5.4.4` - Mocking for tests
- `bloc_test: ^9.1.5` - Testing BLoC/Cubits

## 🧪 Testing

The project includes unit tests for:
- Use cases (`GetInsurances`, `GetInsuranceDetail`)
- Cubits (`InsuranceListCubit`, `InsuranceDetailCubit`)

Run tests with:
```bash
flutter test
```

## 🔄 Firebase Integration

The codebase is structured to easily swap the mock repository with Firebase Firestore.

### Current Setup (Mock Data)

The app currently uses `MockInsuranceRepository` which provides hardcoded insurance data.

### Switching to Firebase

1. **Add Firebase dependencies** to `pubspec.yaml`:
   ```yaml
   dependencies:
     firebase_core: ^latest
     cloud_firestore: ^latest
   ```

2. **Initialize Firebase** in `main.dart`:
   ```dart
   import 'package:firebase_core/firebase_core.dart';
   
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     runApp(const AssetWizeApp());
   }
   ```

3. **Implement FirestoreInsuranceRepository**:
   - Open `lib/features/insurance/data/repositories/firestore_insurance_repository.dart`
   - Follow the TODO comments to implement Firestore queries
   - Example implementation:
     ```dart
     @override
     Future<List<Insurance>> getInsurances() async {
       final snapshot = await _firestore.collection('insurances').get();
       return snapshot.docs
           .map((doc) => InsuranceModel.fromFirestore(doc))
           .toList();
     }
     ```

4. **Update dependency injection** in `main.dart`:
   ```dart
   // Replace this line:
   final InsuranceRepository insuranceRepository = MockInsuranceRepository();
   
   // With this:
   final InsuranceRepository insuranceRepository = FirestoreInsuranceRepository();
   ```

That's it! The rest of the codebase remains unchanged thanks to Clean Architecture.

## 📱 Features

### My Insurances Screen
- **Header**: App title and user subtitle
- **Tab Navigation**: Horizontal scrollable tabs (My Insurances, My Garage, My Jewellery, My Real Estate)
- **New Insurance CTA**: Card prompting users to add new insurance with AI assistance
- **Insurance Grid/List**: Responsive layout (single column on mobile, grid on tablet/desktop)
- **Insurance Cards**: Display image, title, provider, policy number, and end date
- **Ask Assistant**: Quick access button on each card for AI assistance
- **Bottom Navigation**: Home, Favourites, Search, Settings

### Insurance Detail Screen
- **Full Image**: Large hero image of the insurance
- **Policy Details**: Title, provider, type, policy number, dates
- **Description**: Additional information about the policy
- **Metadata**: Flexible additional data display
- **Action Buttons**: Register/Renew and Ask Assistant CTAs

## 🎨 Design System

The app follows a consistent design system defined in:
- `lib/core/theme/app_theme.dart` - Theme configuration
- `lib/core/constants/app_constants.dart` - Design tokens (spacing, radii, etc.)

### Color Palette
- **Primary Green**: `#2E7D32` (ASSETWIZE branding)
- **Accent Yellow**: `#FFC107` (CTA buttons)
- **Text Primary**: `#212121` (Dark grey)
- **Text Secondary**: `#757575` (Medium grey)

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   └── theme/
│       └── app_theme.dart
├── features/
│   └── insurance/
│       ├── data/
│       │   ├── models/
│       │   │   └── insurance_model.dart
│       │   └── repositories/
│       │       ├── mock_insurance_repository.dart
│       │       └── firestore_insurance_repository.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── insurance.dart
│       │   ├── repositories/
│       │   │   └── insurance_repository.dart
│       │   └── usecases/
│       │       ├── get_insurances.dart
│       │       └── get_insurance_detail.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── insurance_list_cubit.dart
│           │   ├── insurance_list_state.dart
│           │   ├── insurance_detail_cubit.dart
│           │   └── insurance_detail_state.dart
│           ├── pages/
│           │   ├── insurance_list_page.dart
│           │   └── insurance_detail_page.dart
│           └── widgets/
│               ├── insurance_card.dart
│               ├── new_insurance_card.dart
│               ├── rounded_tab_bar.dart
│               └── section_header.dart
└── main.dart
```

## 🔧 Development Notes

### State Management
- Uses `flutter_bloc` with Cubits (simpler than full BLoC)
- States are immutable and extend `Equatable` for value comparison
- Error handling with retry functionality

### Image Loading
- Uses `cached_network_image` for efficient image loading and caching
- Placeholder and error widgets for better UX

### Responsive Design
- Single column layout on narrow screens (< 600px)
- Grid layout on wide screens (≥ 600px)
- Uses MediaQuery to detect screen width

### Performance Optimizations
- `const` constructors where possible
- Lazy loading with Sliver widgets
- Image caching
- Efficient rebuilds with BLoC

## 📝 Next Steps

1. **Firebase Integration**: Implement `FirestoreInsuranceRepository` (see above)
2. **Additional Features**:
   - Add new insurance flow
   - AI assistant integration
   - Search and filter functionality
   - Favorites management
3. **Other Asset Categories**: Implement My Garage, My Jewellery, My Real Estate
4. **Authentication**: Add user authentication
5. **Offline Support**: Implement local caching with Hive/SharedPreferences

## 📄 License

This project is part of the AssetWize application.

## 👥 Contributors

Built as a Flutter feature module following Clean Architecture principles.
