import 'package:flutter/material.dart';
import 'package:wolfpak/constants/colors.dart';

class Button extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final Color backgroundColor;
  final bool enabled;

  const Button(
    this.text, {
    super.key,
    required this.onPressed,
    this.enabled = true,
    this.backgroundColor = primaryAccent,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: const Size(double.infinity, 40),
      ),
      child: Text(text),
    );
  }
}
