import 'package:flutter/material.dart';
import 'package:front_opt120/screens/initial_screen.dart';
import 'package:front_opt120/screens/login_screen.dart';
import '../screens/admin_home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


Future main() async{
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Desenvolvimento Movel',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
       initialRoute: '/',
        routes: {
          '/': (context) => const InitialScreen(),
          '/login': (context) => const LoginPage(),
          '/adminHome': (context) => const AdminHomePage(),
        },
    );
  }
}

