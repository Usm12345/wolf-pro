import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wolfpak/components/button.dart';
import 'package:wolfpak/components/typography.dart';
import 'package:wolfpak/constants/gap.dart';
import 'package:wolfpak/constants/sources.dart';
import 'package:wolfpak/oop/product.dart';
import 'package:wolfpak/providers/products_list_provider.dart';
import 'package:wolfpak/screens/notifications_screen.dart';
import 'package:wolfpak/services/mqtt_service.dart';

class DashboardScreen extends StatefulWidget {
  final int productIndex;
  final String email;

  const DashboardScreen(this.productIndex, this.email, {super.key});

  @override
  State<StatefulWidget> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  late int productIndex;

  final Map<String, ValueNotifier<String>> topicNotifiers = {};

  final List<String> labels = ["Solar", "Inverter", "USB", "CIG", "12V", "POE"];

  List<bool> status = List.filled(6, false);

  List<double> voltages = List.filled(6, 0.0);
  List<double> currents = List.filled(6, 0.0);

  MqttService mqttService = MqttService();

  String clientIdentifier = "";

  @override
  void initState() {
    super.initState();

    productIndex = widget.productIndex;

    clientIdentifier =
        utf8.encode(widget.email).map((e) => e.toRadixString(13)).join();

    for (var topic in topics) {
      topic = '/$clientIdentifier/$topic';
      final notifier = mqttService.getNotifierForTopic(topic);
      if (notifier != null) {
        topicNotifiers[topic] = notifier;
      }
    }
  }

  String _getEstBattLife(int estBattLifeInSecs) {
    if (estBattLifeInSecs <= 0) return "0 seconds";

    final int seconds = estBattLifeInSecs % 60;
    final int minutes = (estBattLifeInSecs ~/ 60) % 60;
    final int hours = (estBattLifeInSecs ~/ 3600) % 24;
    final int days = estBattLifeInSecs ~/ 86400;

    if (days > 0) {
      return "$days day${days > 1 ? 's' : ''}";
    } else if (hours > 0) {
      return "$hours hour${hours > 1 ? 's' : ''}";
    } else if (minutes > 0) {
      return "$minutes minute${minutes > 1 ? 's' : ''}";
    } else {
      return "$seconds second${seconds > 1 ? 's' : ''}";
    }
  }

  Future<void> _deleteProduct() async {
    final productsProvider =
        Provider.of<ProductListProvider>(context, listen: false);
    Navigator.of(context).popUntil(ModalRoute.withName('/main'));
    productsProvider.removeProduct(productIndex);
  }

  Future<void> _showDeleteConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: _deleteProduct,
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  List<DropdownMenuEntry<int>> _getDropdownItems(List<Product> products) {
    return products.asMap().entries.map((entry) {
      int index = entry.key;
      Product product = entry.value;
      return DropdownMenuEntry<int>(
        value: index,
        label: product.name,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductListProvider>(context);

    Product product = productsProvider.products[productIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: const Color(0xFF202020),
        surfaceTintColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NotificationsScreen(productIndex),
                ),
              );
            },
          )
        ],
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
                DropdownMenu<int>(
                  enableFilter: true,
                  enableSearch: true,
                  initialSelection: productIndex,
                  onSelected: (int? value) {
                    setState(() {
                      productIndex = value!;
                    });
                  },
                  dropdownMenuEntries:
                      _getDropdownItems(productsProvider.products),
                ),
                gap44,
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF202020),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  "Volts",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                gap8,
                                ValueListenableBuilder(
                                  valueListenable: topicNotifiers[
                                      '/$clientIdentifier/bat/voltage']!,
                                  builder: (context, message, child) {
                                    return Text(
                                      "$message V",
                                      style: const TextStyle(
                                        fontFamily: 'Roboto Slab',
                                        fontSize: 24,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text(
                                  "Amps",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                gap8,
                                ValueListenableBuilder(
                                  valueListenable: topicNotifiers[
                                      '/$clientIdentifier/bat/current']!,
                                  builder: (context, message, child) {
                                    return Text(
                                      "$message A",
                                      style: const TextStyle(
                                        fontFamily: 'Roboto Slab',
                                        fontSize: 24,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const Column(
                              children: [
                                Text(
                                  "Temp",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                gap8,
                                Text(
                                  "0.0 C",
                                  style: TextStyle(
                                    fontFamily: 'Roboto Slab',
                                    fontSize: 24,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        gap16,
                        Small(
                            "Estimated Battery Life Remaining: ${_getEstBattLife(product.estimatedBatteryLife)}"),
                        gap16,
                        const Divider(color: Color(0xFF333333)),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFlexibleLabelWithIndicator(
                                      "Solar", status[Sources.solar.index]),
                                  gap4,
                                  _buildFlexibleLabelWithIndicator("Inverter",
                                      status[Sources.inverter.index]),
                                  gap4,
                                  _buildFlexibleLabelWithIndicator(
                                      "POE", status[Sources.poe.index]),
                                ],
                              ),
                            ),
                            gap16,
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Align(
                                    alignment: Alignment.topCenter,
                                    child: Text(
                                      "IN USE",
                                      style: TextStyle(
                                          color: Colors.yellow, fontSize: 16),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  gap12,
                                  Table(
                                    columnWidths: const {
                                      0: FlexColumnWidth(
                                          1), // Equal width columns
                                      1: FlexColumnWidth(1),
                                    },
                                    children: [
                                      TableRow(
                                        children: [
                                          _buildFlexibleLabelWithIndicator(
                                              "12V Out",
                                              status[Sources.v12.index]),
                                          _buildFlexibleLabelWithIndicator(
                                              "CIG", status[Sources.cig.index]),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          _buildFlexibleLabelWithIndicator(
                                              "Fan", false),
                                          _buildFlexibleLabelWithIndicator(
                                              "USB", status[Sources.usb.index]),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                gap16,
                Column(
                  children: [
                    Row(
                      children: [
                        _buildPowerOptionCard(Sources.solar.index),
                        gap16,
                        _buildPowerOptionCard(Sources.inverter.index),
                      ],
                    ),
                    gap16,
                    Row(
                      children: [
                        _buildPowerOptionCard(Sources.usb.index),
                        gap16,
                        _buildPowerOptionCard(Sources.cig.index),
                      ],
                    ),
                    gap16,
                    Row(
                      children: [
                        // _buildPowerOptionCard(Sources.v12.index),
                        // gap16,
                        _buildPowerOptionCard(Sources.poe.index),
                      ],
                    ),
                  ],
                ),
                gap32,
                Button(
                  "DELETE",
                  onPressed: _showDeleteConfirmation,
                  backgroundColor: Colors.redAccent,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlexibleLabelWithIndicator(String label, bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: active ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerOptionCard(
    int source,
  ) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF202020),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(labels[source]),
              const SizedBox(height: 8),
              _buildParameterRow("Volts", labels[source], 'voltage', 'V'),
              const SizedBox(height: 8),
              _buildParameterRow("Amps", labels[source], 'current', 'A'),
              const SizedBox(height: 8),
              Switch(
                value: status[source],
                onChanged: (value) {
                  setState(
                    () {
                      status[source] = value;
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParameterRow(
      String label, String source, String metric, String unit) {
    print('/$clientIdentifier/${source.toLowerCase()}/$metric');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        ValueListenableBuilder(
          valueListenable: topicNotifiers[
              '/$clientIdentifier/${source.toLowerCase()}/$metric']!,
          builder: (context, message, child) {
            return Text("$message $unit");
          },
        ),
      ],
    );
  }
}
