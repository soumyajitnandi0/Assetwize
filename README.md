# ASSETWIZE - Asset Management Application

A Flutter application for managing personal assets including insurances, with AI-powered assistance. Built with Clean Architecture, flutter_bloc (Cubits), and production-ready code.

## 📱 Overview

ASSETWIZE is a comprehensive asset management application that helps users organize and manage their personal assets including insurances, with features like AI chatbot assistance, notifications, and profile management.

## ✨ Features

### 🛡️ Insurance Management
- **View All Insurances**: Browse all insurance policies in a responsive grid/list layout
- **Insurance Details**: View comprehensive details for each insurance policy
- **Add New Insurance**: Complete flow to add new insurance policies with category and type selection
- **Search Insurances**: Real-time search across insurance titles, providers, policy numbers, and types
- **Insurance Categories**: 
  - My Insurances (fully functional)
  - My Garage (Coming Soon)
  - My Jewellery (Coming Soon)
  - My Realty (Coming Soon)
- **Insurance Types**: Health, Life, Travel, Accident
- **Image Support**: Automatic image assignment based on insurance type

### 🤖 AI Chatbot Assistant
- **Groq API Integration**: AI-powered chat assistant using Groq's Llama model
- **Context-Aware**: Provides insurance-specific context to the AI
- **Conversation History**: Maintains conversation context across messages
- **Multiple Sessions**: Support for multiple conversation sessions
- **Ask Assistant Button**: Quick access from insurance cards and detail pages

### 🔔 Notifications System
- **Real-Time Badge**: Unread notification count badge on profile page
- **Notification Types**:
  - Asset Added notifications
  - Profile Updated notifications
  - Insurance Expiring notifications
  - Insurance Expired notifications
- **Notification Management**:
  - Mark as read
  - Mark all as read
  - Delete notifications
  - Swipe to delete
- **Auto-Updates**: Badge updates automatically when notifications change

### 👤 Profile Management
- **User Profile**: Personal information management
- **Profile Fields**:
  - Name
  - Phone Number
  - Email
- **Profile Completion**: Visual indicator showing profile completion percentage
- **Settings**: Comprehensive settings page with various options
- **Logout**: Secure logout with data deletion warning

### 🔍 Search Functionality
- **Real-Time Search**: Debounced search with 300ms delay
- **Multi-Field Search**: Searches across:
  - Insurance title
  - Provider name
  - Policy number
  - Insurance type
  - Short description
- **Empty States**: User-friendly empty and error states

### 🎨 UI/UX Features
- **Modern Design**: Clean, modern UI following Figma prototype
- **Montserrat Font**: Consistent typography throughout
- **Responsive Layout**: Adapts to mobile, tablet, and desktop
- **Neumorphic Design**: Beautiful neumorphic elements for selectors
- **Glassmorphism**: Modern glassmorphic effects on cards
- **Smooth Animations**: Polished animations and transitions
- **Dark Mode Ready**: Theme structure supports future dark mode

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/
│   ├── bloc/              # BLoC observer
│   ├── constants/          # App-wide constants
│   ├── di/                 # Dependency injection
│   ├── error/              # Exception and failure classes
│   ├── navigation/         # Navigation setup
│   ├── services/           # Core services (Groq, Notifications, User Preferences)
│   ├── theme/              # Theme configuration
│   ├── utils/              # Utilities (logger, validators, helpers)
│   └── widgets/            # Reusable widgets
├── features/
│   ├── insurance/
│   │   ├── data/           # Data layer
│   │   │   ├── models/     # Data models
│   │   │   └── repositories/  # Repository implementations
│   │   ├── domain/         # Business logic layer
│   │   │   ├── entities/   # Pure domain entities
│   │   │   ├── repositories/  # Repository interfaces
│   │   │   └── usecases/   # Business use cases
│   │   └── presentation/   # UI layer
│   │       ├── bloc/       # State management (Cubits)
│   │       ├── pages/      # Screen widgets
│   │       └── widgets/    # Reusable UI components
│   ├── notifications/      # Notification feature (same structure)
│   ├── profile/            # Profile feature
│   └── onboarding/         # Onboarding feature
└── main.dart               # App entry point
```

### Key Principles

- **Domain Layer**: Pure Dart code with **zero Flutter dependencies**
- **Data Layer**: Implements domain interfaces, handles data sources
- **Presentation Layer**: Flutter-specific UI and state management
- **Dependency Rule**: Dependencies point inward (presentation → domain ← data)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.5.4 or higher
- Dart SDK 3.5.4 or higher
- Groq API key (for chatbot feature) - Get it from [Groq Console](https://console.groq.com/)

### Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd assetwize
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Setup environment variables**:
   - Copy `.env.example` to `.env`:
     ```bash
     cp .env.example .env
     ```
   - Edit `.env` and add your Groq API key:
     ```env
     GROQ_API_KEY=your_groq_api_key_here
     ```
   - Get your API key from [Groq Console](https://console.groq.com/)
   - See `ENV_SETUP.md` for detailed instructions

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

# Generate mock files for tests
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📦 Dependencies

### Production Dependencies
- `flutter_bloc: ^8.1.6` - State management
- `equatable: ^2.0.5` - Value equality
- `cached_network_image: ^3.3.1` - Network image caching
- `intl: ^0.19.0` - Date formatting
- `shared_preferences: ^2.2.2` - Local storage
- `google_fonts: ^6.1.0` - Google Fonts integration
- `http: ^1.2.0` - HTTP client for API calls
- `flutter_dotenv: ^5.1.0` - Environment variables management
- `get_it: ^7.7.0` - Dependency injection

### Development Dependencies
- `flutter_lints: ^4.0.0` - Linting rules
- `mockito: ^5.4.4` - Mocking for tests
- `bloc_test: ^9.1.5` - Testing BLoC/Cubits
- `build_runner: ^2.4.8` - Code generation

## 🧪 Testing

The project includes comprehensive unit tests:

- **Use Cases**: `GetInsurances`, `GetInsuranceDetail`, `AddInsurance`, `SearchInsurances`
- **Cubits**: `InsuranceListCubit`, `InsuranceDetailCubit`

Run tests with:
```bash
flutter test
```

## 🔐 Environment Variables

The app uses `flutter_dotenv` to manage sensitive configuration:

### Required Variables
- `GROQ_API_KEY`: Your Groq API key for the chatbot feature

### Setup
1. Create `.env` file in the project root
2. Add your API keys (see `.env.example` for template)
3. The `.env` file is automatically excluded from version control

See `ENV_SETUP.md` for detailed setup instructions.

## 📱 Features in Detail

### Insurance Management

#### Adding Insurance
1. Tap "New Insurance" card
2. Select category (Personal/Asset)
3. Select type (Health/Life/Travel/Accident)
4. Fill in insurance details
5. Save - automatically creates notification

#### Viewing Insurance
- Tap any insurance card to view full details
- See policy information, dates, and metadata
- Access "Ask Assistant" for AI help

#### Searching
- Use the search tab in bottom navigation
- Real-time search with debouncing
- Searches across all insurance fields

### AI Chatbot

#### Using the Chatbot
1. Tap "Ask Assistant" on any insurance card or detail page
2. Chat with AI about your insurance
3. AI has context about the specific insurance policy
4. Start new conversation anytime

#### Features
- Conversation history maintained
- Context-aware responses
- Insurance-specific guidance
- Multiple conversation sessions

### Notifications

#### Notification Types
- **Asset Added**: When you add a new insurance
- **Profile Updated**: When you update profile information
- **Insurance Expiring**: When insurance is expiring soon (future)
- **Insurance Expired**: When insurance has expired (future)

#### Managing Notifications
- Tap bell icon in profile page
- View all notifications
- Mark individual or all as read
- Swipe to delete

### Profile Management

#### Personal Information
- Edit name, phone number, and email
- Profile completion indicator
- Avatar with initials

#### Settings
- Backup settings (coming soon)
- Biometrics (coming soon)
- Legal pages (Privacy Policy, Terms, etc.)
- Logout functionality

## 🎨 Design System

### Colors
- **Primary Green**: `#065F46` - Main brand color
- **Text Primary**: `#1C1C1E` - Main text color
- **Text Secondary**: `#8E8E93` - Secondary text color
- **Accent Yellow**: `#FFC107` - CTA buttons
- **Error Red**: `#D32F2F` - Error states
- **Warning Orange**: `#F57C00` - Warning states

### Typography
- **Font Family**: Montserrat (Google Fonts)
- **Headings**: Bold, various sizes
- **Body**: Regular weight, 14-16px
- **Labels**: Medium weight, 12-14px

### Spacing
- **XS**: 4px
- **S**: 8px
- **M**: 16px
- **L**: 20px (main padding)
- **XL**: 24px (card spacing)
- **XXL**: 32px

### Border Radius
- **S**: 8px
- **M**: 12px
- **L**: 16px
- **XL**: 20px (main cards)
- **XXL**: 24px

## 🔄 Data Storage

### Current Implementation
- **Local Storage**: Uses SharedPreferences for persistent storage
- **Data Stored**:
  - Insurance policies
  - User preferences (name, phone, email)
  - Notifications
  - First launch flag

### Future: Firebase Integration
The codebase is structured to easily swap to Firebase Firestore:
1. Add Firebase dependencies
2. Implement Firestore repositories
3. Update dependency injection
4. No other code changes needed!

## 🏛️ Clean Architecture

### Domain Layer
- Pure Dart code, no Flutter dependencies
- Entities, repository interfaces, use cases
- Business logic and validation

### Data Layer
- Implements domain interfaces
- Handles data serialization
- Manages data sources (SharedPreferences, future: Firebase)

### Presentation Layer
- Flutter-specific UI
- BLoC/Cubits for state management
- Pages and widgets

## 🔧 Development

### Code Quality
- ✅ Clean Architecture compliance
- ✅ Proper error handling with custom exceptions
- ✅ Comprehensive logging
- ✅ Dependency injection throughout
- ✅ Zero linting errors
- ✅ All tests passing

### Best Practices
- Single Responsibility Principle
- Dependency Inversion Principle
- Immutable states
- Proper error handling
- Production-ready code

## 📄 Project Structure

```
assetwize/
├── lib/
│   ├── core/                    # Core functionality
│   │   ├── bloc/               # BLoC observer
│   │   ├── constants/          # App constants
│   │   ├── di/                 # Dependency injection
│   │   ├── error/              # Exceptions and failures
│   │   ├── navigation/         # Navigation setup
│   │   ├── services/           # Core services
│   │   ├── theme/              # Theme configuration
│   │   ├── utils/              # Utilities
│   │   └── widgets/            # Reusable widgets
│   ├── features/               # Feature modules
│   │   ├── insurance/          # Insurance feature
│   │   ├── notifications/      # Notifications feature
│   │   ├── profile/            # Profile feature
│   │   └── onboarding/         # Onboarding feature
│   └── main.dart               # App entry point
├── test/                       # Unit tests
├── assets/                     # Images and assets
├── .env                        # Environment variables (not in git)
├── .env.example                # Environment template
├── pubspec.yaml                # Dependencies
└── README.md                   # This file
```

## 🐛 Troubleshooting

### App won't start
- Check if `.env` file exists
- Verify `GROQ_API_KEY` is set in `.env`
- Run `flutter pub get`
- Try `flutter clean && flutter pub get`

### Chatbot not working
- Verify `GROQ_API_KEY` is correct in `.env`
- Check internet connection
- Check Groq API status

### Images not loading
- Verify image files exist in `assets/images/`
- Check image file names match insurance types
- Run `flutter pub get` to refresh assets

### Tests failing
- Run `flutter pub run build_runner build --delete-conflicting-outputs`
- Ensure all dependencies are installed
- Check test files are up to date

## 📝 License

This project is private and proprietary.

## 👥 Contributing

This is a private project. For contributions, please contact the project maintainers.

## 📞 Support

For issues or questions:
1. Check the troubleshooting section
2. Review `ENV_SETUP.md` for environment setup
3. Check `CODEBASE_REVIEW.md` for architecture details

## 🚧 Roadmap

### Coming Soon
- My Garage feature
- My Jewellery feature
- My Realty feature
- Backup functionality
- Biometric authentication
- Insurance expiry reminders
- Dark mode support

### Future Enhancements
- Firebase integration
- Cloud sync
- Multi-device support
- Export/Import functionality
- Advanced analytics
- Document storage

## 📚 Additional Documentation

- `ENV_SETUP.md` - Environment variables setup guide
- `CODEBASE_REVIEW.md` - Comprehensive architecture review
- `IMPROVEMENTS_SUMMARY.md` - Recent improvements documentation

---

**Built with ❤️ using Flutter and Clean Architecture**
