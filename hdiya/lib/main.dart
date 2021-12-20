import 'package:flutter/material.dart';
import 'package:hdiya/pages/HomePage.dart';
import 'package:dcdg/dcdg.dart';

void main()
{
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hdya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData
      (
        scaffoldBackgroundColor: Colors.grey[300],
        dialogBackgroundColor: Colors.black,
        primarySwatch: Colors.grey,
        cardColor: Colors.white70,
        accentColor: Colors.black,
      ),
      home:HomePage()
    );
  }
}
