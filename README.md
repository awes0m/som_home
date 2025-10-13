# Personal Homepage - Flutter Web App

A modern, feature-rich Flutter web application that functions as your personal browser homepage with Google Search, bookmarks management, task tracking, customizable backgrounds, and embedded mini-games.

## ✨ Features

### 🏠 Home Screen
- **Centered Google Search Bar**: Auto-focused search with live query input
- **Real-time Clock**: Displays current time and date
- **Favorite Bookmarks**: Quick access to your most-used bookmarks
- **Beautiful UI**: Minimalist design inspired by Chrome's new tab page

### 🔖 Bookmarks Manager
- **Full CRUD Operations**: Add, edit, delete bookmarks with ease
- **Import/Export**: 
  - Import from HTML files (standard browser export format)
  - Export as JSON for backup
- **Organization**:
  - Create folders to organize bookmarks
  - Mark bookmarks as favorites
  - Search through all bookmarks
- **Persistent Storage**: All data saved locally using Hive

### 🌆 Background Customization
- **Multiple Options**:
  - Set background from network URL
  - Upload local image files
  - Choose from preset wallpapers
  - Use default gradient (light/dark mode)
- **Theme Support**: Automatic overlay adjustment for light/dark modes

### ✅ Tasks Manager
- **Task Management**: Create, edit, delete, and mark tasks complete
- **Rich Features**:
  - Add notes to tasks
  - Set due dates with calendar picker
  - Categorize tasks
  - Track overdue tasks
- **Summary Dashboard**: View active, completed, and overdue task counts
- **Persistent Storage**: All tasks saved locally

### 🎮 Mini-Games
Four fully functional games embedded in the app:

1. **Snake Game**
   - Classic snake gameplay
   - Arrow key or button controls
   - Score tracking
   - Collision detection

2. **Flappy Bird**
   - Tap/click to jump mechanic
   - Procedurally generated pipes
   - Score system
   - Smooth animations

3. **Tic-Tac-Toe**
   - Classic X and O game
   - Win detection with highlighting
   - Draw detection
   - Instant reset

4. **Memory Match**
   - Card matching game
   - Move counter
   - Match tracking
   - Completion celebration

### ⚙️ Settings
- **Theme Control**: Light, Dark, or System theme
- **Background Management**: Easy access to all background options
- **Data Management**: Reset all bookmarks and tasks
- **App Information**: Version and about details

## 🛠️ Tech Stack

- **Flutter 3.22+**: Latest Flutter framework
- **Material 3**: Modern design system
- **Hive**: Fast, local storage solution
- **Provider**: State management
- **URL Launcher**: Open links in browser
- **File Picker**: Import/upload functionality
- **Google Fonts**: Beautiful typography

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── theme/
│   │   └── app_theme.dart            # Theme configuration
│   ├── storage/
│   │   └── hive_service.dart         # Local storage service
│   ├── models/
│   │   └── models.dart               # Data models
│   └── providers/
│       └── providers.dart            # State management providers
├── pages/
│   ├── main_navigation.dart          # Main navigation wrapper
│   ├── home_page.dart                # Home screen with search
│   ├── bookmarks_page.dart           # Bookmarks management
│   ├── tasks_page.dart               # Task manager
│   ├── games_page.dart               # Games launcher
│   └── settings_page.dart            # Settings and preferences
└── games/
    ├── snake_game.dart               # Snake game implementation
    ├── flappy_bird_game.dart         # Flappy Bird clone
    ├── tic_tac_toe_game.dart         # Tic-Tac-Toe game
    └── memory_match_game.dart        # Memory matching game
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.22 or higher
- Dart SDK 3.0 or higher
- Web browser (Chrome recommended for development)

### Installation

1. **Clone the repository** (or create the project):
```bash
flutter create personal_homepage
cd personal_homepage
```

2. **Copy all the source files** into their respective directories as shown in the project structure

3. **Update `pubspec.yaml`** with the dependencies listed in the pubspec.yaml file

4. **Get dependencies**:
```bash
flutter pub get
```

5. **Run the app**:
```bash
flutter run -d chrome
```

For production build:
```bash
flutter build web
```

## 📖 Usage Guide

### Adding Bookmarks
1. Navigate to the Bookmarks tab
2. Click "Add" button
3. Fill in title, URL, and optional folder
4. Mark as favorite if desired
5. Click "Add" to save

### Importing Bookmarks
1. Export bookmarks from your browser (HTML format)
2. Go to Bookmarks tab
3. Click the import icon
4. Select your HTML or JSON file
5. Bookmarks will be automatically imported

### Managing Tasks
1. Navigate to Tasks tab
2. Click "Add Task"
3. Enter task details, optional notes, category, and due date
4. Click checkbox to mark complete
5. Use menu to edit or delete

### Playing Games
1. Navigate to Games tab
2. Click on any game card to launch
3. Follow on-screen instructions for controls
4. Use back button to return to games menu

### Customizing Background
1. Go to Settings tab
2. Choose from:
   - Enter URL directly
   - Upload local image
   - Select from preset wallpapers
   - Clear to use default gradient

## 🔧 Configuration

### Adding More Default Wallpapers
Edit `settings_page.dart` and add URLs to the `defaultWallpapers` list:

```dart
final List<String> defaultWallpapers = [
  'https://your-image-url.com/image1.jpg',
  'https://your-image-url.com/image2.jpg',
  // Add more...
];
```

### Customizing Theme Colors
Edit `core/theme/app_theme.dart`:

```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.blue, // Change to your preferred color
  brightness: Brightness.light,
),
```

## 🎯 Key Features Explained

### Offline-First Design
- All data stored locally using Hive
- No internet required after initial load (except for external images)
- Works as a Progressive Web App (PWA)

### Responsive Layout
- Adapts to different screen sizes
- Desktop: Side navigation rail
- Mobile: Bottom navigation bar
- Touch and keyboard support

### Extensibility
- Modular architecture makes it easy to add new features
- New games can be added by creating a new file in `games/` directory
- Provider pattern allows easy state management additions

## 🐛 Known Issues & Limitations

1. **Browser Storage**: Uses Hive for storage, not browser localStorage (by design for Flutter Web compatibility)
2. **Image Upload**: Local images are converted to base64, which may impact performance for very large images
3. **Games**: Games are not optimized for mobile touch controls (best played on desktop)

## 🚀 Future Enhancements

Potential features to add:
- [ ] Weather widget
- [ ] RSS feed reader
- [ ] Pomodoro timer
- [ ] Notes section
- [ ] Calendar integration
- [ ] More games
- [ ] Cloud sync option
- [ ] Browser extension version

## 📝 License

This project is open source and available for personal and commercial use.

## 🤝 Contributing

Contributions are welcome! To add new features:

1. Follow the existing code structure
2. Add provider if state management is needed
3. Update navigation in `main_navigation.dart`
4. Document your changes

## 💡 Tips

- **Search Shortcut**: The search bar auto-focuses on home page
- **Keyboard Navigation**: Use arrow keys in Snake game
- **Quick Access**: Mark frequently used bookmarks as favorites
- **Organization**: Use folders to categorize bookmarks
- **Backup**: Regularly export bookmarks as JSON

## 🎨 Customization Ideas

- Change the color scheme in `app_theme.dart`
- Add your own wallpapers to the preset list
- Modify game difficulty in respective game files
- Add custom categories for tasks
- Create additional game modes

---

**Built with ❤️ using Flutter**

For questions or issues, refer to the Flutter documentation at [flutter.dev](https://flutter.dev)