import 'package:flutter/material.dart';
import 'package:wolfpak/constants/colors.dart';

class ClickableText extends StatelessWidget {
  final String text;
  final void Function()? onTap;

  const ClickableText(this.text, {super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Text(text, style: const TextStyle(color: primaryAccent)),
      ),
    );
  }
}
