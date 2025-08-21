import 'package:EcoMiles/pages/getStarted.dart';
import 'package:EcoMiles/pages/modeInfo.dart';
import 'package:EcoMiles/pages/routePage.dart';
import 'package:EcoMiles/provider/loadingProvider.dart';
import 'package:EcoMiles/provider/mapProvider.dart';
import 'package:EcoMiles/provider/settingsProvider.dart';
import 'package:EcoMiles/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:EcoMiles/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:EcoMiles/pages/homePage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  await Hive.openBox('database');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LoadingProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      routes: {
        "/getStarted": (context) => const GetStartedPage(),
        "/home": (context) => const HomePage(),
        "/route": (context) => const RoutePage(),
        "modeInfo": (context) => const ModeInfoPage(),
      },
      title: 'EcoMiles',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomePage();
          } else {
            return const GetStartedPage();
          }
        },
      ),
    );
  }
}
