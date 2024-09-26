import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wolfpak/components/button.dart';
import 'package:wolfpak/components/input_field.dart';
import 'package:wolfpak/constants/colors.dart';
import 'package:wolfpak/constants/gap.dart';
import 'package:wolfpak/providers/products_list_provider.dart';

class NotificationsScreen extends StatefulWidget {
  final int productIndex;

  const NotificationsScreen(this.productIndex, {super.key});

  @override
  State<StatefulWidget> createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  final TextEditingController _productNameController = TextEditingController();

  bool lowVoltageAlarm = true;
  bool highUsageAlarm = true;
  bool overVoltageAlarm = true;
  bool highTempAlarm = true;

  @override
  void initState() {
    super.initState();

    final productsProvider =
        Provider.of<ProductListProvider>(context, listen: false);

    _productNameController.text =
        productsProvider.products[widget.productIndex].name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Device Info",
                    style: TextStyle(color: primaryAccent),
                  ),
                ),
                gap16,
                InputField(
                  controller: _productNameController,
                  hintText: "Product Name",
                  icon: Icons.abc,
                ),
                gap24,
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Notifications",
                    style: TextStyle(color: primaryAccent),
                  ),
                ),
                gap16,
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(), // Label
                    1: FixedColumnWidth(100.0), // Value
                    2: FixedColumnWidth(50.0), // Checkbox
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    const TableRow(
                      children: [
                        Text("Setting"),
                        Text("Value", textAlign: TextAlign.center),
                        Text("Notify", textAlign: TextAlign.center),
                      ],
                    ),
                    _buildTableRow("Low Voltage", "11.5", lowVoltageAlarm,
                        (value) {
                      setState(() {
                        lowVoltageAlarm = value!;
                      });
                    }),
                    _buildTableRow("High Usage", "20 A", highUsageAlarm,
                        (value) {
                      setState(() {
                        highUsageAlarm = value!;
                      });
                    }),
                    _buildTableRow("Over Voltage", "13.5", overVoltageAlarm,
                        (value) {
                      setState(() {
                        overVoltageAlarm = value!;
                      });
                    }),
                    _buildTableRow("High Temp", "125", highTempAlarm, (value) {
                      setState(() {
                        highTempAlarm = value!;
                      });
                    }),
                  ],
                ),
                gap24,
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Device Configuration",
                    style: TextStyle(color: primaryAccent),
                  ),
                ),
                gap16,
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(), // Label column
                    1: FixedColumnWidth(50.0), // Value column
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    _buildInfoRow("Inverter", "1"),
                    _buildInfoRow("POE", "1"),
                    _buildInfoRow("12V Out", "1"),
                    _buildInfoRow("USB", "1"),
                    _buildInfoRow("CIG Plug", "1"),
                  ],
                ),
                gap32,
                Button(
                  "SAVE",
                  onPressed: () {},
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(
    String label,
    String value,
    bool alarmValue,
    ValueChanged<bool?> onChanged,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(label),
        ),
        Text(value, textAlign: TextAlign.center),
        Checkbox(
          value: alarmValue,
          onChanged: onChanged,
        ),
      ],
    );
  }

  TableRow _buildInfoRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(label),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(value, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
