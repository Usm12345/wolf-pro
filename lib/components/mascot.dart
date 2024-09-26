import 'package:flutter/material.dart';

class Mascot extends StatelessWidget {
  final double height;

  const Mascot({super.key, this.height = 128});

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/rasters/mascot.png', height: height);
  }
}
