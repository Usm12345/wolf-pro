import 'dart:convert';

import 'package:flutter/gestures.dart';
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
import 'package:wolfpak/constants/colors.dart';
import 'package:wolfpak/constants/gap.dart';

import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  bool _isAgreementChecked = false;

  bool isLoading = false;

  void _toggleAgreement(bool? value) {
    setState(() {
      _isAgreementChecked = value ?? false;
    });
  }

  bool _isValidEmail(String email) {
    RegExp regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    RegExp passwordRegExp = RegExp(r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}$');
    return passwordRegExp.hasMatch(password);
  }

  Future<void> _signUp() async {
    setState(() {
      isLoading = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String address = _addressController.text.trim();
    String city = _cityController.text.trim();
    String state = _stateController.text.trim();
    String zipCode = _zipCodeController.text.trim();
    String phoneNumber = _phoneNumberController.text.trim();

    if (name.isEmpty) {
      Fluttertoast.showToast(
        msg: "Name is required.",
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

    if (!_isAgreementChecked) {
      Fluttertoast.showToast(
        msg: "Please check the Terms of Service and Privacy Policy.",
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

    Map<String, dynamic> jsonMap = {
      'name': name,
      'email': email,
      'password': password,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'phoneNumber': phoneNumber
    };

    final url = Uri.parse("$baseApiUrl/auth/sign-up");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
      body: jsonEncode(jsonMap),
    );

    if (response.statusCode == 409) {
      Fluttertoast.showToast(
        msg: "A user with that email already exists.",
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
                const H1("Sign Up"),
                gap8,
                const Text("Create an account to proceed."),
                gap32,
                InputField(
                  controller: _nameController,
                  hintText: '* Name',
                  icon: Icons.person,
                  keyboardType: TextInputType.name,
                ),
                gap16,
                InputField(
                  controller: _emailController,
                  hintText: '* Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                gap16,
                InputField(
                  controller: _passwordController,
                  hintText: '* Password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                gap16,
                InputField(
                  controller: _addressController,
                  hintText: 'Address',
                  icon: Icons.location_on,
                ),
                gap16,
                InputField(
                  controller: _cityController,
                  hintText: 'City',
                  icon: Icons.location_city,
                ),
                gap16,
                InputField(
                  controller: _stateController,
                  hintText: 'State',
                  icon: Icons.map,
                ),
                gap16,
                InputField(
                  controller: _zipCodeController,
                  hintText: 'Zip Code',
                  icon: Icons.post_add,
                ),
                gap16,
                InputField(
                  controller: _phoneNumberController,
                  hintText: 'Phone Number',
                  icon: Icons.contact_phone,
                ),
                gap16,
                Row(
                  children: [
                    Checkbox(
                      value: _isAgreementChecked,
                      onChanged: _toggleAgreement,
                      activeColor: secondaryAccent,
                    ),
                    Flexible(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: const TextStyle(color: primaryAccent),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(color: primaryAccent),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                            const TextSpan(text: '.')
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                gap32,
                Button(
                  "SUBMIT",
                  onPressed: _signUp,
                  enabled: !isLoading,
                ),
                gap4,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    gap8,
                    ClickableText(
                      "Sign In",
                      onTap: () {
                        Navigator.of(context).pushNamed('/sign-in');
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
