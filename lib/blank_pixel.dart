import 'package:flutter/material.dart';

class BlankPixel extends StatelessWidget {
  const BlankPixel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Container(
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 246, 205, 84),
            borderRadius: BorderRadius.circular(0)),
      ),
    );
  }
}
