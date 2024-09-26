import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wolfpak/components/button.dart';
import 'package:wolfpak/components/input_field.dart';
import 'package:wolfpak/components/profile_picture.dart';
import 'package:wolfpak/constants/api.dart';
import 'package:wolfpak/constants/gap.dart';

import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  String email = '';

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  Future<void> _loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    _nameController.text = prefs.getString('userName')!;
    _addressController.text = prefs.getString('userAddress')!;
    _cityController.text = prefs.getString('userCity')!;
    _stateController.text = prefs.getString('userState')!;
    _zipCodeController.text = prefs.getString('userZipCode')!;
    _phoneNumberController.text = prefs.getString('userPhoneNumber')!;

    setState(() {
      email = prefs.getString("userEmail")!;
    });
  }

  Future<void> _signOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/sign-in',
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _showSignOutConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: _signOut,
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUser() async {
    setState(() {
      isLoading = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userUUid = prefs.getString("userUuid");

    String name = _nameController.text.trim();
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

    Map<String, dynamic> jsonMap = {
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'phoneNumber': phoneNumber
    };

    if (password.isNotEmpty) {
      RegExp passwordRegExp = RegExp(r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}$');
      if (!passwordRegExp.hasMatch(password)) {
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
      jsonMap['password'] = password;
    }

    final url = Uri.parse('$baseApiUrl/users/$userUUid');
    final _ = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
      body: jsonEncode(jsonMap),
    );

    _passwordController.text = "";

    prefs.setString('userName', name);
    prefs.setString('userAddress', address);
    prefs.setString('userCity', city);
    prefs.setString('userState', state);
    prefs.setString('userZipCode', zipCode);
    prefs.setString('userPhoneNumber', phoneNumber);

    Fluttertoast.showToast(
      msg: "Profile updated.",
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF202020),
        surfaceTintColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  kBottomNavigationBarHeight),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const ProfilePicture(),
                gap22,
                Text(email),
                gap22,
                InputField(
                  controller: _nameController,
                  hintText: '* Name',
                  icon: Icons.person,
                  keyboardType: TextInputType.name,
                ),
                gap16,
                InputField(
                  controller: _passwordController,
                  hintText: 'Set new password',
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
                gap32,
                Button(
                  "UPDATE",
                  onPressed: _updateUser,
                  enabled: !isLoading,
                ),
                Button(
                  "SIGN OUT",
                  onPressed: _showSignOutConfirmation,
                  backgroundColor: Colors.red.shade300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
