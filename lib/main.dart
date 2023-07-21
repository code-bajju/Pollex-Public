import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pollex/Providers/authentication_provider.dart';
import 'package:pollex/Providers/bottom_nav_provider.dart';
import 'package:pollex/Providers/db_provider.dart';
import 'package:pollex/Providers/fetch_polls_provider.dart';
import 'package:pollex/Screens/splash_screen.dart';
import 'package:pollex/firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => BottomNavProvider()),
        ChangeNotifierProvider(create: (context) => DbProvider()),
        ChangeNotifierProvider(create: (context) => FetchPollsProvider()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        // home: MainActivityPage(),
        home: SplashScreen(),
      ),
    );
  }
}
