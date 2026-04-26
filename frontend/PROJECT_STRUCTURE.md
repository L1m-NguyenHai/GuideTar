# GuideTar - Professional Flutter Project Structure

## 📁 Project Structure

This project uses a **lightweight feature-first presentation structure** with shared pages kept at the root level:

```
lib/
├── config/              # App configuration
│   └── theme.dart       # Theme, colors, text styles
│
├── core/               # Core functionality
│   └── (extensions, utilities, error handling)
│
├── data/               # Data layer
│   ├── datasources/    # Remote & local data sources
│   ├── models/         # Data models
│   └── repositories/   # Repository implementations
│
├── domain/             # Domain layer (Business Logic)
│   ├── entities/       # Business entities
│   ├── repositories/   # Repository interfaces
│   └── usecases/       # Use cases
│
├── presentation/       # Presentation layer (UI)
│   ├── pages/
│   │   ├── app_root_page.dart
│   │   ├── opening_animation_page.dart
│   │   ├── login_page.dart
│   │   ├── home_page.dart
│   │   ├── profile_page.dart
│   │   ├── recent_page.dart
│   │   ├── settings_page.dart
│   │   ├── piano/
│   │   │   ├── tools/
│   │   │   │   ├── piano_toolkit_page.dart
│   │   │   │   ├── piano_sheet_play_page.dart
│   │   │   │   ├── piano_sheet_loading_page.dart
│   │   │   │   └── piano_sheet_player_page.dart
│   │   │   └── courses/
│   │   │       ├── piano_basic_courses_page.dart
│   │   │       └── piano_intro_detail_page.dart
│   │   └── guitar/
│   │       ├── tools/
│   │       │   ├── guitar_toolkit_page.dart
│   │       │   ├── guitar_ear_training_page.dart
│   │       │   ├── pro_tuner_page.dart
│   │       │   ├── chord_book_page.dart
│   │       │   ├── song_gio_chord_page.dart
│   │       │   ├── artist_jack_page.dart
│   │       │   ├── dechord_page.dart
│   │       │   └── mat_biec_page.dart
│   │       └── courses/
│   │           └── guitar_course_page.dart
│   ├── widgets/        # Reusable widgets
│   │   ├── custom_text_field.dart
│   │   ├── primary_button.dart
│   │   └── home_bottom_navbar.dart
│   └── state/          # Lightweight shared UI state
│       └── follow_state.dart
│
├── utils/              # Utilities
│   └── app_constants.dart
│
└── main.dart           # App entry point
```

## 🎨 Design System

### Colors
- **Primary**: `#FF923E` (Orange)
- **Dark BG**: `#1A1A1A`
- **Text Primary**: `#FFFFFF`
- **Text Secondary**: `#ADAAAA`

### Typography
- **Font Family**: Plus Jakarta Sans
- **Headings**: H1 (36pt, 800), H2 (24pt, 700), H3 (20pt, 700)
- **Body**: Large (18pt), Medium (16pt), Small (14pt)
- **Label**: 14pt, 600 weight, 1.4px letter spacing

### Spacing
- XS: 4px, S: 8px, M: 16px, L: 24px, XL: 32px

### Border Radius
- S: 8px, M: 12px, L: 16px, XL: 24px

## 📱 Login Screen Features

✅ Gradient background
✅ Brand header with logo and taglines
✅ Semi-transparent login card with glassmorphism effect
✅ Email input field with validation
✅ Password input field with show/hide toggle
✅ Remember me checkbox
✅ Forgot password link
✅ Login button with loading state
✅ Sign up link
✅ Vietnamese language support
✅ Responsive design

## 🚀 Getting Started

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run Application
```bash
flutter run
```

### 3. Build APK/Package
```bash
flutter build apk
flutter build ios
flutter build web
```

## 📦 Dependencies

```yaml
- google_fonts: For custom typography (Plus Jakarta Sans)
- gap: For consistent spacing between widgets
```

## 🎯 Next Steps for Development

1. **State Management**: Add Provider, Riverpod, or GetX
2. **API Integration**: Create Dio/HTTP client for backend communication
3. **Authentication**: Implement login logic with backend
4. **Navigation**: Setup named routes with GoRouter or Navigator 2.0
5. **Local Storage**: Add Hive or SharedPreferences for user data
6. **Tests**: Add unit and widget tests for components

## 📐 File Naming Conventions

- Dart files: `snake_case.dart`
- Classes: `PascalCase`
- Constants: `CONSTANT_CASE` or `camelCase`
- Private members: `_privateVariable`

## 🔍 Code Quality

- Uses Material Design 3
- Follows Dart style guide
- Organized imports
- Consistent formatting
- Type-safe code

---

**Created for GuideTar Project - Professional Music Gaming App**
