import 'package:flutter/material.dart';
import 'package:wolfpak/components/button.dart';
import 'package:wolfpak/components/input_field.dart';
import 'package:wolfpak/constants/colors.dart';
import 'package:wolfpak/constants/gap.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<StatefulWidget> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _shutdownVoltageController =
      TextEditingController();
  final TextEditingController _networkSSIDController =
      TextEditingController(text: "Home Network");
  final TextEditingController _networkPasswordController =
      TextEditingController(text: "Secret");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color(0xFF202020),
        surfaceTintColor: Colors.black,
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  "Shutdown Sequence Voltage",
                  style: TextStyle(fontSize: 16),
                ),
                gap8,
                const Text(
                  "Unit will shutdown outputs to avoid any battery draining too low at this voltage.",
                  style: TextStyle(fontSize: 11, color: white3),
                ),
                gap16,
                InputField(
                  controller: _shutdownVoltageController,
                  hintText: "Voltage",
                  icon: Icons.numbers,
                ),
                gap24,
                const Text(
                  "Internet Settings",
                  style: TextStyle(fontSize: 16),
                ),
                gap16,
                InputField(
                  controller: _networkSSIDController,
                  hintText: "SSID",
                  icon: Icons.network_wifi,
                ),
                gap16,
                InputField(
                  controller: _networkPasswordController,
                  hintText: "Password",
                  icon: Icons.lock,
                  obscureText: true,
                ),
                gap24,
                Button("CHANGE NETWORK", onPressed: () {})
              ],
            ),
          ),
        ),
      ),
    );
  }
}
