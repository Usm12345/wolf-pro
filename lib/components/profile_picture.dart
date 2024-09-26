import 'package:flutter/material.dart';
import 'package:wolfpak/constants/colors.dart';

class ProfilePicture extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final void Function()? onPressed;

  const ProfilePicture({
    super.key,
    this.imageUrl,
    this.radius = 64.0,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFF404040),
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
        child: imageUrl == null
            ? Icon(Icons.person, size: radius, color: white4)
            : null,
      ),
    );
  }
}
