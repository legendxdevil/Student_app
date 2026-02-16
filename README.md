# Student Hub - Cross-Platform Academic Management App

A comprehensive Flutter application for students to manage academic data, calculate CGPA/percentage, track performance, and receive AI-powered study assistance.

## Features

### Core Features
- **Student Profile Setup**: Store name, course, institution, and academic preferences
- **CGPA Calculator**: Subject-wise marks input with credit-based calculation
- **Percentage Calculator**: CGPA to percentage conversion with multiple university formulas
- **Academic History**: Semester-wise tracking with performance charts
- **AI Academic Assistant**: Personalized study tips and performance analysis

### Additional Features
- **Theme Support**: Light and dark mode with Material 3 design
- **Data Export/Import**: CSV export/import for backup
- **Performance Analytics**: Visual charts showing academic trends
- **Customizable Formulas**: Support for different university grading systems

## Project Structure

```
lib/
├── main.dart                    # Application entry point
├── app.dart                     # Root app widget with theme management
├── core/
│   ├── bloc/
│   │   └── theme_bloc.dart      # Theme state management
│   ├── services/
│   │   ├── database_service.dart    # SQLite database operations
│   │   ├── storage_service.dart     # SharedPreferences wrapper
│   │   ├── cgpa_service.dart        # CGPA calculation logic
│   │   ├── percentage_service.dart  # Percentage conversion
│   │   └── percentage_converter.dart  # Conversion utilities
│   └── theme/
│       └── app_theme.dart       # Light/dark theme definitions
├── data/
│   └── models/
│       ├── student_model.dart   # Student profile data
│       ├── semester_model.dart  # Semester data
│       └── subject_model.dart   # Subject/course data
└── presentation/
    ├── navigation/
    │   └── app_router.dart      # GoRouter configuration
    ├── screens/
    │   ├── main_shell/          # Main app shell with bottom nav
    │   ├── dashboard/           # Home dashboard with stats
    │   ├── cgpa_calculator/     # CGPA calculation screen
    │   ├── percentage_calculator/ # Percentage conversion
    │   ├── academic_history/    # Academic records & charts
    │   ├── ai_assistant/        # AI chat interface
    │   ├── profile/             # Student profile management
    │   ├── settings/            # App settings & data management
    │   └── onboarding/          # First-time setup
    └── widgets/
        └── app_drawer.dart      # Navigation drawer
```

## Technical Stack

- **Framework**: Flutter 3.0+
- **State Management**: flutter_bloc
- **Database**: SQLite (sqflite)
- **Local Storage**: SharedPreferences
- **Navigation**: go_router
- **Charts**: fl_chart
- **Fonts**: Google Fonts (Poppins)

## Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.3
  sqflite: ^2.3.0
  shared_preferences: ^2.2.2
  go_router: ^12.1.1
  fl_chart: ^0.65.0
  google_fonts: ^6.1.0
  http: ^1.1.0
  file_picker: ^6.1.1
  csv: ^5.1.1
  share_plus: ^7.2.1
```

## Getting Started

### Prerequisites
- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)
- Android Studio / VS Code with Flutter extension

### Installation

1. Clone or create the project:
```bash
cd student_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Building for Production

**Android:**
```bash
flutter build apk --release
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## Features in Detail

### 1. Dashboard
- Overall CGPA display with performance classification
- Quick stats (semesters, subjects, percentage)
- Quick action buttons for navigation
- Performance trend overview

### 2. CGPA Calculator
- Add multiple subjects with credits
- Enter marks (0-100) for automatic grade calculation
- Support for 10-point and 4-point scales
- Real-time SGPA calculation
- Save results to specific semesters

### 3. Percentage Calculator
- **CGPA to Percentage**: Multiple conversion formulas
  - Default: CGPA × 9.5
  - Mumbai University: (CGPA × 7.1) + 11
  - Anna University: CGPA × 10
  - VTU: (CGPA - 0.75) × 10
  - GTU: (CGPA - 0.5) × 10
- **Marks to Percentage**: Weighted/unweighted calculation

### 4. Academic History
- Visual performance trend charts
- Semester-wise breakdown
- Subject details within each semester
- Delete/archive functionality
- Export to CSV

### 5. AI Assistant
- Context-aware responses based on academic data
- Study improvement suggestions
- Exam preparation tips
- Motivational quotes and guidance
- Performance analysis

### 6. Settings
- Theme selection (Light/Dark/System)
- Percentage formula customization
- Grade scale selection (10-point/4-point)
- Data export/import (CSV)
- Clear all data
- API key configuration for AI

## Database Schema

### Tables

1. **student_profile**
   - id, name, course, institution, academic_system, grade_scale

2. **semesters**
   - id, semester_number, semester_name, sgpa, total_credits, completed_credits, is_completed

3. **subjects**
   - id, semester_id, name, code, credits, marks_obtained, max_marks, grade, grade_points, is_backlog

4. **settings**
   - id, key, value

## Customization

### Adding New University Formula
Edit `lib/core/services/percentage_service.dart`:

```dart
case 'custom_university':
  return (cgpa * multiplier) + offset;
```

### Changing Color Scheme
Edit `lib/core/theme/app_theme.dart`:

```dart
static const Color primaryColor = Color(0xFFYourColor);
```

## Future Enhancements

- [ ] Attendance tracker
- [ ] Study planner with notifications
- [ ] Exam countdown timer
- [ ] Notes storage per subject
- [ ] Cloud sync (Firebase)
- [ ] Grade prediction using ML
- [ ] Social features (study groups)
- [ ] Dark mode scheduling

## License

MIT License - Free for educational use

## Support

For issues or feature requests, please create an issue in the project repository.

---

**Happy Studying! Track your progress, achieve your goals.**
