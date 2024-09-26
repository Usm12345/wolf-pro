import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wolfpak/components/button.dart';
import 'package:wolfpak/components/clickable_text.dart';
import 'package:wolfpak/components/input_field.dart';
import 'package:wolfpak/components/logo.dart';
import 'package:wolfpak/components/mascot.dart';
import 'package:wolfpak/components/typography.dart';
import 'package:wolfpak/constants/api.dart';
import 'package:wolfpak/constants/gap.dart';

import 'package:http/http.dart' as http;

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<StatefulWidget> createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

  bool _isValidEmail(String email) {
    String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regex = RegExp(emailPattern);
    return regex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.isNotEmpty;
  }

  Future<void> _signIn() async {
    setState(() {
      isLoading = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

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

    if (!_isValidPassword(password)) {
      Fluttertoast.showToast(
        msg: "Empty password.",
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

    final url = Uri.parse('$baseApiUrl/auth/sign-in');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 400) {
      Fluttertoast.showToast(
        msg: "Invalid credentials.",
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
    } else if (response.statusCode == 404) {
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
    }

    final body = jsonDecode(response.body);
    prefs.setString('userUuid', body['uuid']!);
    prefs.setString('userName', body['name']!);
    prefs.setString('userEmail', body['email']!);
    prefs.setString('userAddress', body['address']!);
    prefs.setString('userCity', body['city']!);
    prefs.setString('userState', body['state']!);
    prefs.setString('userZipCode', body['zipCode']!);
    prefs.setString('userPhoneNumber', body['phoneNumber']!);

    setState(() {
      isLoading = false;
    });

    if (!mounted) {
      return;
    }

    Fluttertoast.showToast(
      msg: "Success.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/main',
      (Route<dynamic> route) => false,
    );
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
                const H1('Sign In'),
                gap8,
                const Text("Enter your credentials to proceed."),
                gap32,
                InputField(
                  controller: _emailController,
                  hintText: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                gap16,
                InputField(
                  controller: _passwordController,
                  hintText: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                gap16,
                Align(
                  alignment: Alignment.centerRight,
                  child: ClickableText(
                    'Forgot Password?',
                    onTap: () {
                      Navigator.of(context).pushNamed('/forgot-password');
                    },
                  ),
                ),
                gap32,
                Button(
                  "SUBMIT",
                  enabled: !isLoading,
                  onPressed: _signIn,
                ),
                gap4,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Don\'t have an account?'),
                    gap8,
                    ClickableText(
                      "Sign Up",
                      onTap: () {
                        Navigator.of(context).pushNamed('/sign-up');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
