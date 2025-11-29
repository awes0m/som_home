import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../super_dash/audio/audio.dart';
import '../super_dash/game_intro/game_intro.dart';
import '../super_dash/settings/settings_controller.dart';
import '../super_dash/settings/persistence/persistence.dart';
import '../super_dash/share/share.dart';
import '../super_dash/l10n/app_localizations.dart';

class SuperDashPage extends StatefulWidget {
  const SuperDashPage({super.key});

  @override
  State<SuperDashPage> createState() => _SuperDashPageState();
}

class _SuperDashPageState extends State<SuperDashPage> {
  late AudioController audioController;
  late SettingsController settingsController;
  late ShareController shareController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    settingsController = SettingsController(
      persistence: LocalStorageSettingsPersistence(),
    );

    audioController = AudioController()..attachSettings(settingsController);
    await audioController.initialize();

    shareController = ShareController(
      gameUrl: 'https://awes0m.github.io/super_som_dash/',
    );

    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AudioController>.value(value: audioController),
        RepositoryProvider<SettingsController>.value(value: settingsController),
        RepositoryProvider<ShareController>.value(value: shareController),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Super Som Dash',
        theme: ThemeData(textTheme: const TextTheme()),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const GameIntroPage(),
      ),
    );
  }

  @override
  void dispose() {
    audioController.dispose();
    super.dispose();
  }
}
