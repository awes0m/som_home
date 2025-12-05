import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../games/super_dash/audio/audio.dart';
import '../games/super_dash/game/game.dart';
import '../games/super_dash/l10n/app_localizations.dart';
import '../games/super_dash/settings/persistence/local_storage_settings_persistence.dart';
import '../games/super_dash/settings/settings_controller.dart';
import '../games/super_dash/share/share.dart';

class SuperDashPage extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const SuperDashPage({super.key, this.onBackPressed});

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
      return const Center(child: CircularProgressIndicator());
    }

    return Localizations(
      locale: const Locale('en', 'US'),
      delegates: AppLocalizations.localizationsDelegates,
      child: MultiProvider(
        providers: [
          Provider<AudioController>.value(value: audioController),
          Provider<SettingsController>.value(value: settingsController),
          Provider<ShareController>.value(value: shareController),
          Provider<VoidCallback>.value(value: widget.onBackPressed ?? () {}),
        ],
        child: BlocProvider(
          create: (context) => GameBloc(),
          child: const Game(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    audioController.dispose();
    super.dispose();
  }
}
