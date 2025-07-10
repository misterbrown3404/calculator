import 'package:calculator/screen/calculatorScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF1E1E1E),
      ),
      home: CalculatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
