import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokerku_apps/firebase_options.dart';

import 'app.dart';
import 'core/localization/app_localizations.dart';
import 'data/services/app_preferences.dart';
import 'data/services/isar_service.dart';
import 'data/services/revenue_cat_service.dart';
import 'data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize SharedPreferences
  await AppPreferences.init();

  // Initialize Localization from saved preference
  AppLocalizations.setLocale(AppPreferences.language);

  // Initialize Isar database
  await IsarService.db;

  // Initialize RevenueCat
  await RevenueCatService.initialize();

  // Initialize Firebase Cloud Messaging
  await NotificationService().initialize();

  runApp(const ProviderScope(child: LokerKuApp()));
}
