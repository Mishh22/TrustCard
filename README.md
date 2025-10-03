# TrustCard - Digital ID Verification App

A Flutter application for digital ID verification system that allows workers to create digital identity cards and customers to verify them through QR code scanning.

## Features

- **Digital ID Cards**: Create and manage digital identity cards
- **QR Code Scanning**: Scan worker IDs to verify their identity
- **Multi-Level Verification**: 
  - Basic (Phone verified)
  - Document (Documents uploaded)
  - Peer (Colleague verified)
  - Company (Officially verified)
- **Trust Scoring**: Dynamic trust score based on verification level
- **Rating System**: Rate workers after service delivery
- **Cross-Platform**: Works on both iOS and Android

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- iOS Simulator (for iOS testing)
- Android Emulator (for Android testing)

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```

### Running the App

#### iOS Simulator
```bash
flutter run -d ios
```

#### Android Emulator
```bash
flutter run -d android
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   └── user_card.dart       # User card model
├── providers/               # State management
│   ├── auth_provider.dart   # Authentication provider
│   └── card_provider.dart   # Card management provider
├── screens/                 # App screens
│   ├── home_screen.dart     # Home screen
│   ├── create_card_screen.dart # Create card screen
│   ├── scan_card_screen.dart   # QR scanner screen
│   ├── profile_screen.dart     # Profile screen
│   ├── verification_screen.dart # Verification screen
│   └── card_detail_screen.dart # Card detail screen
├── widgets/                 # Reusable widgets
│   └── digital_card_widget.dart # Digital card widget
└── utils/                   # Utilities
    ├── app_theme.dart       # App theme and colors
    └── app_router.dart      # Navigation routing
```

## Verification Levels

### Basic Verification (Yellow Badge)
- Phone number verified via OTP
- Basic trust level
- Can create and share digital ID

### Document Verification (Green Badge)
- Upload company ID card, offer letter, or salary slip
- Higher trust level
- Documents verified by system

### Peer Verification (Blue Badge)
- Verified by 2+ colleagues from same company
- Community trust level
- Colleague endorsements

### Company Verification (Gold Badge)
- Officially verified by company admin
- Highest trust level
- Company-issued verification

## Trust Score Calculation

The trust score is calculated based on:
- Verification level (40% weight)
- Customer ratings (30% weight)
- Colleague verification (20% weight)
- Document verification (10% weight)

## Dependencies

- `flutter`: SDK
- `provider`: State management
- `go_router`: Navigation
- `qr_flutter`: QR code generation
- `qr_code_scanner`: QR code scanning
- `camera`: Camera access
- `image_picker`: Image selection
- `hive`: Local storage
- `http`: API calls
- `uuid`: Unique ID generation

## Development

### Adding New Features

1. Create models in `lib/models/`
2. Add providers in `lib/providers/`
3. Create screens in `lib/screens/`
4. Add widgets in `lib/widgets/`
5. Update routing in `lib/utils/app_router.dart`

### Testing

Run tests with:
```bash
flutter test
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.
