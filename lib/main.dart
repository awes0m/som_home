// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'auth_wrapper.dart';
import 'firebase_options.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/background_provider.dart';
import 'core/providers/bookmarks_provider.dart';
import 'core/providers/tasks_provider.dart';
import 'core/providers/greeting_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/webview_provider.dart';
import 'core/storage/hive_service.dart';
import 'main_nav.dart';
import 'pages/sign_in_page.dart';
import 'pages/sign_up_page.dart';
import 'pages/forgot_password_page.dart';
import 'tools/expense_manger/controllers/app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Register the web implementation for webview_flutter only on web platform
  if (kIsWeb) {
    WebViewPlatform.instance = WebWebViewPlatform();
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    // You can also use a `ReCaptchaEnterpriseProvider` provider instance as an
    // argument for `webProvider`
    webProvider: ReCaptchaV3Provider(
      '6Lc4ww0sAAAAADMrg8WuqQF9C4rVkmw5ikZEO9iF',
    ), //recaptcha-v3-site-key
  );
  await HiveService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return riverpod.ProviderScope(
      child: provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(create: (_) => AuthProvider()),
          provider.ChangeNotifierProvider(create: (_) => BackgroundProvider()),
          provider.ChangeNotifierProvider(create: (_) => BookmarksProvider()),
          provider.ChangeNotifierProvider(create: (_) => TasksProvider()),
          provider.ChangeNotifierProvider(create: (_) => GreetingProvider()),
          provider.ChangeNotifierProvider(create: (_) => WebViewProvider()),
          provider.ChangeNotifierProvider(create: (_) => AppController()),
        ],
        child: riverpod.Consumer(
          builder: (context, ref, _) {
            final themeMode = ref.watch(themeNotifierProvider);
            return MaterialApp(
              title: 'Personal Homepage',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue,
                  brightness: Brightness.light,
                ),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
              ),
              themeMode: themeMode,
              home: const AuthWrapper(),
              routes: {
                '/home': (context) => const MainNavigation(),
                '/sign-in': (context) => const SignInPage(),
                '/sign-up': (context) => const SignUpPage(),
                '/forgot-password': (context) => const ForgotPasswordPage(),
              },
            );
          },
        ),
      ),
    );
  }
}
