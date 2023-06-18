
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:interiorshare/home_screen.dart';


Future<void> main() async
{
  try
  {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

  }
  catch(errorMsg)
  {
    print("Error: " + errorMsg.toString());
  }

  runApp(const MainApp());
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "InteriorShare APP",
      theme: ThemeData(
        primarySwatch: Colors.purple
        ),
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
    );
  }
}
