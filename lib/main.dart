import 'package:blackjack_note/screens/home.dart';
import 'package:blackjack_note/screens/log.dart';
import 'package:blackjack_note/screens/summary.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sổ xì dách',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) {
          return const HomeScreen();
        },
        'log': (context) {
          return const LogScreen();
        },
        'summary': (context) {
          return const SummaryScreen();
        },
      },
    );
  }
}
