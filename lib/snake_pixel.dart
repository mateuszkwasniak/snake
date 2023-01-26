import 'package:flutter/material.dart';

class SnakePixel extends StatelessWidget {
  const SnakePixel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.green[800], borderRadius: BorderRadius.circular(0)),
      ),
    );
  }
}
