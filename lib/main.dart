import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ksa_maps/ui/home/home_page.dart';

import 'di/dependency_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await D.build();
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KSA MAPS',
      themeMode: ThemeMode.system,
      darkTheme: ThemeData(
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(selectedItemColor: Colors.blue),
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      theme: ThemeData(
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(selectedItemColor: Colors.blue),

        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
