import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wolfpak/components/button.dart';
import 'package:wolfpak/components/input_field.dart';
import 'package:wolfpak/components/logo.dart';
import 'package:wolfpak/components/mascot.dart';
import 'package:wolfpak/components/typography.dart';
import 'package:wolfpak/constants/api.dart';
import 'package:wolfpak/constants/gap.dart';

import 'package:http/http.dart' as http;
import 'package:wolfpak/screens/enter_otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<StatefulWidget> createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  bool isLoading = false;

  bool _isValidEmail(String email) {
    String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regex = RegExp(emailPattern);
    return regex.hasMatch(email);
  }

  Future<void> _generateOtp() async {
    setState(() {
      isLoading = true;
    });

    final email = _emailController.text.trim();

    if (!_isValidEmail(email)) {
      Fluttertoast.showToast(
        msg: "Invalid or empty email.",
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

    final url = Uri.parse('$baseApiUrl/auth/generate-otp');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
      body: jsonEncode({
        'email': email,
      }),
    );

    if (response.statusCode == 404) {
      Fluttertoast.showToast(
        msg: "User does not exist.",
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
    } else if (response.statusCode != 204) {
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

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => EnterOtpScreen(email)));
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
                const H1("Forgot Password?"),
                gap8,
                const Text("Enter your email to recover your account."),
                gap32,
                InputField(
                  controller: _emailController,
                  hintText: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                gap32,
                Button(
                  "SUBMIT",
                  onPressed: _generateOtp,
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
