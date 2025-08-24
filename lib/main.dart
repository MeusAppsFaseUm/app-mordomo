import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/themes.dart';
import 'core/notification_service.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive
  await Hive.initFlutter();
  await Hive.openBox('tasks');
  await Hive.openBox('settings');

  // Notificações
  await NotificationService.initialize();

  runApp(const MordomoApp());
}

class MordomoApp extends StatefulWidget {
  const MordomoApp({super.key});

  @override
  State<MordomoApp> createState() => _MordomoAppState();
}

class _MordomoAppState extends State<MordomoApp> {
  late final Box _settingsBox;
  int _themeIndex = 0;

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box('settings');
    _themeIndex = _settingsBox.get('selectedTheme', defaultValue: 0);
  }

  void _setTheme(int index) {
    setState(() => _themeIndex = index);
    _settingsBox.put('selectedTheme', index);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mordomo',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.allThemes[_themeIndex],
      home: HomePage(
        currentThemeIndex: _themeIndex,
        onThemeChanged: _setTheme,
      ),
    );
  }
}
