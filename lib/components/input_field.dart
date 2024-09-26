import 'package:flutter/material.dart';
import 'package:wolfpak/constants/colors.dart';

class InputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;

  const InputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<StatefulWidget> createState() => InputFieldState();
}

class InputFieldState extends State<InputField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: widget.controller,
        obscureText: _obscureText,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          filled: true,
          prefixIcon: Icon(widget.icon),
          hintText: widget.hintText,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: secondaryAccent),
          ),
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: _togglePasswordVisibility,
                )
              : null,
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
