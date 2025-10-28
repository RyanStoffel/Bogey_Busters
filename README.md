# Bogey Busters

A comprehensive golf shot tracker app built with Flutter, featuring GPS distance tracking, round management, and detailed scoring.

## Features

### Core Functionality
- **GPS Shot Tracking**: Track the distance of each shot using GPS technology
- **Live Round Tracking**: Track your current round hole-by-hole with real-time scoring
- **Manual Entry**: Enter past rounds manually with full scorecard details
- **Round History**: View all your past rounds with detailed statistics
- **Course Selection**: Choose from multiple pre-loaded golf courses

### Screens
1. **Loading Screen**: Initial splash screen with app branding
2. **Login Screen**: Secure user authentication
3. **Signup Screen**: New user registration
4. **Home Screen**: Dashboard showing current round, quick actions, and recent rounds
5. **Profile Screen**: User profile with statistics and settings
6. **Past Rounds Screen**: Complete history of all played rounds
7. **Choose Course Screen**: Select a golf course to start a new round
8. **Shot Tracking Screen**: Track shots hole-by-hole with GPS distance measurement
9. **Manual Entry Screen**: Manually enter scores for past rounds
10. **End of Round Screen**: Summary and celebration screen after completing a round

### Design
- Clean, modern green color scheme
- Material Design 3 components
- Responsive layouts
- Intuitive navigation

## Technical Stack

### Framework & Language
- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language

### State Management
- **Provider**: Lightweight state management solution

### Key Dependencies
- `geolocator`: GPS location and distance tracking
- `permission_handler`: Location permission management
- `shared_preferences`: Local data storage
- `sqflite`: SQLite database for rounds
- `intl`: Date and number formatting
- `google_fonts`: Custom typography
- `uuid`: Unique ID generation

### Architecture
- **Services Layer**:
  - `AuthService`: User authentication and management
  - `LocationService`: GPS tracking and distance calculation
  - `RoundService`: Round creation, updating, and storage
  - `CourseService`: Golf course data management

- **Models**:
  - `User`: User profile information
  - `Course`: Golf course details with holes
  - `Round`: Complete round data with scores
  - `Shot`: Individual shot with GPS coordinates
  - `HoleScore`: Score for each hole

- **Providers**:
  - `AppState`: Global application state management

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode for platform-specific builds
- A physical device or emulator with GPS capabilities

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/Bogey_Busters.git
cd Bogey_Busters
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Platform-Specific Setup

#### Android
- Minimum SDK: 21 (Android 5.0)
- Location permissions are configured in `AndroidManifest.xml`

#### iOS
- iOS 11.0 or higher
- Location permissions are configured in `Info.plist`
- Background location usage is enabled for continuous tracking

## Usage

### Starting a New Round
1. Login or create an account
2. From the home screen, tap "New Round"
3. Select a golf course
4. Begin tracking your round hole-by-hole
5. Use the GPS shot tracking to record distances
6. Update stroke count for each hole
7. Complete the round and view your summary

### Manual Entry
1. From the home screen, tap "Manual Entry"
2. Select a golf course
3. Enter your scores for each hole
4. Save the round

### Viewing History
1. Navigate to "Past Rounds" from the home screen or profile
2. View all your completed rounds
3. Tap on a round to see detailed hole-by-hole scores
4. Delete rounds if needed

## Features in Detail

### GPS Distance Tracking
The app uses the device's GPS to calculate the distance between shots. When you record a shot:
1. The app captures your current GPS coordinates
2. On the next shot, it calculates the distance from the previous position
3. Distance is displayed in yards
4. All shots are saved with the round

### Score Tracking
- Real-time score calculation relative to par
- Automatic score naming (Birdie, Bogey, etc.)
- Visual indicators for score performance
- Complete scorecard view

### Data Persistence
- All data is stored locally using SharedPreferences
- No internet connection required
- User data persists between sessions

## Future Enhancements

Potential features for future versions:
- Cloud sync and backup
- Social features (share rounds, compete with friends)
- Course creation and custom courses
- Advanced statistics and analytics
- Handicap calculation
- Shot shape and club tracking
- Photo attachments for memorable shots
- Apple Watch / Wear OS companion apps

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Golf courses data (sample courses included)
- Material Design for UI components

## Support

For issues, questions, or suggestions, please open an issue on GitHub.
