import 'package:flutter/material.dart';

class ResultDisplay extends StatelessWidget {
  final double cgpa;
  final Color textColor; // Added for dynamic text color

  ResultDisplay({required this.cgpa, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      'CGPA: ${cgpa.toStringAsFixed(2)}',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
    );
  }
}