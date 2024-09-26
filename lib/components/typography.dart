import 'package:flutter/material.dart';
import 'package:wolfpak/constants/colors.dart';

class Display extends StatelessWidget {
  final String text;

  const Display(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Roboto Slab',
          fontSize: 24,
          color: primaryAccent,
        ),
      ),
    );
  }
}

class H1 extends StatelessWidget {
  final String text;

  const H1(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Roboto Slab',
        fontSize: 20,
        color: primaryAccent,
      ),
    );
  }
}

class Slogan extends StatelessWidget {
  final String text;

  const Slogan(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: white1),
      textAlign: TextAlign.center,
    );
  }
}

class Small extends StatelessWidget {
  final String text;

  const Small(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: white3,
      ),
    );
  }
}
