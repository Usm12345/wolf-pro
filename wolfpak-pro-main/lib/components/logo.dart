import 'package:flutter/material.dart';
import 'package:wolfpak/constants/colors.dart';

class Logo extends StatelessWidget {
  final double height;

  const Logo({super.key, this.height = 128});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'WOLF PAK PRO',
      style: TextStyle(
        fontFamily: 'Roboto Slab',
        fontSize: 32,
        color: white4,
      ),
    );
  }
}
