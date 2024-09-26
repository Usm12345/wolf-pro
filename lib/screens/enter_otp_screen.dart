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
import 'package:wolfpak/screens/reset_password_screen.dart';

class EnterOtpScreen extends StatefulWidget {
  final String email;

  const EnterOtpScreen(this.email, {super.key});

  @override
  State<StatefulWidget> createState() => EnterOtpScreenState();
}

class EnterOtpScreenState extends State<EnterOtpScreen> {
  final TextEditingController _otpController = TextEditingController();

  bool isLoading = false;

  Future<void> _verifyOtp() async {
    setState(() {
      isLoading = true;
    });

    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      Fluttertoast.showToast(
        msg: "Enter OTP.",
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

    final url = Uri.parse('$baseApiUrl/auth/verify-otp');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
      body: jsonEncode({
        'email': widget.email,
        'otp': otp,
      }),
    );

    if (response.statusCode != 204) {
      Fluttertoast.showToast(
        msg: "Invalid or expired OTP.",
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

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ResetPasswordScreen(widget.email)));
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
                const H1('OTP'),
                gap8,
                const Text('Enter the OTP sent to your email to proceed.'),
                gap32,
                InputField(
                  controller: _otpController,
                  hintText: 'OTP',
                  icon: Icons.security,
                  obscureText: true,
                ),
                gap32,
                Button(
                  'SUBMIT',
                  onPressed: _verifyOtp,
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
