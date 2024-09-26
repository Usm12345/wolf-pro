import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:wolfpak/components/button.dart';
import 'package:wolfpak/components/input_field.dart';
import 'package:wolfpak/components/logo.dart';
import 'package:wolfpak/components/mascot.dart';
import 'package:wolfpak/components/typography.dart';
import 'package:wolfpak/constants/api.dart';
import 'package:wolfpak/constants/gap.dart';

import 'package:http/http.dart' as http;

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen(this.email, {super.key});

  @override
  State<StatefulWidget> createState() => ResetPasswordScreenState();
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool isLoading = false;

  bool _isValidPassword(String password) {
    RegExp passwordRegExp = RegExp(r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}$');
    return passwordRegExp.hasMatch(password);
  }

  Future<void> _resetPassword() async {
    setState(() {
      isLoading = true;
    });

    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (!_isValidPassword(password)) {
      Fluttertoast.showToast(
        msg:
            "Password must be 8+ characters with uppercase, lowercase, and a digit.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (password != confirmPassword) {
      Fluttertoast.showToast(
        msg: "Passwords do not match.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    const uuidGenerator = Uuid();
    String uuid = uuidGenerator.v5(Uuid.NAMESPACE_DNS, widget.email);

    final url = Uri.parse('$baseApiUrl/users/$uuid');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
      body: jsonEncode({
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Password updated successfully.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Something went wrong.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = false;
    });

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacementNamed('/sign-in');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: ConstrainedBox(
          constraints:
              BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                gap72,
                const Mascot(),
                gap8,
                const Logo(),
                gap8,
                const H1("Reset Password"),
                gap8,
                const Text("Enter your new password to reset it."),
                gap32,
                InputField(
                  controller: _passwordController,
                  hintText: 'New Password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                gap16,
                InputField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                gap32,
                Button(
                  "SUBMIT",
                  onPressed: _resetPassword,
                  enabled: !isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
