import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/firebase_options.dart';
import 'package:habit_tracker/screens/auth_wrapper.dart';

void main() async {
  //flutter engine initialization before firebase
  WidgetsFlutterBinding.ensureInitialized();

  //connect app to firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //to use riverpod in app
  runApp(ProviderScope(child: MyApp()));
}

//MyApp Class
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      home: const AuthWrapper(),
    );
  }
}
