import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wolfpak/components/button.dart';
import 'package:wolfpak/components/typography.dart';
import 'package:wolfpak/constants/api.dart';
import 'package:wolfpak/constants/gap.dart';
import 'package:wolfpak/constants/sources.dart';
import 'package:wolfpak/oop/product.dart';
import 'package:wolfpak/providers/products_list_provider.dart';
import 'package:wolfpak/screens/notifications_screen.dart';
import 'package:wolfpak/services/mqtt_service.dart';

import 'package:http/http.dart' as http;

class DashboardScreen extends StatefulWidget {
  final int productIndex;
  final String email;

  const DashboardScreen(this.productIndex, this.email, {super.key});

  @override
  State<StatefulWidget> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  late int productIndex;
  late String productName;

  final Map<String, ValueNotifier<String>> topicNotifiers = {};

  final List<String> labels = [
    "Solar",
    "Inverter",
    "USB",
    "CIG",
    "POE"
  ]; // do not change order

  MqttService mqttService = MqttService();

  void updateInverterState() {
    if (!mounted) {
      return;
    }
    ProductListProvider productsProvider = Provider.of<ProductListProvider>(
      context,
      listen: false,
    );
    setState(() {
      productsProvider.setStates(productIndex, Sources.inverter.index,
          topicNotifiers["$productName/inverter/state"]!.value == '1');
    });
  }

  void updateCigState() {
    if (!mounted) {
      return;
    }
    ProductListProvider productsProvider = Provider.of<ProductListProvider>(
      context,
      listen: false,
    );
    setState(() {
      productsProvider.setStates(productIndex, Sources.cig.index,
          topicNotifiers["$productName/cig/state"]!.value == '1');
    });
  }

  void updatePoeState() {
    if (!mounted) {
      return;
    }
    ProductListProvider productsProvider = Provider.of<ProductListProvider>(
      context,
      listen: false,
    );
    setState(() {
      productsProvider.setStates(productIndex, Sources.poe.index,
          topicNotifiers["$productName/poe/state"]!.value == '1');
    });
  }

  void updateUsbState() {
    if (!mounted) {
      return;
    }
    ProductListProvider productsProvider = Provider.of<ProductListProvider>(
      context,
      listen: false,
    );
    setState(() {
      productsProvider.setStates(productIndex, Sources.usb.index,
          topicNotifiers["$productName/usb/state"]!.value == '1');
    });
  }

  @override
  void initState() {
    super.initState();

    productIndex = widget.productIndex;

    updateName();
    subscribeTopics();
    addListenersForSwitches();
  }

  void updateName() {
    ProductListProvider productsProvider = Provider.of<ProductListProvider>(
      context,
      listen: false,
    );
    setState(() {
      productName = productsProvider.products[productIndex].name;
    });
  }

  void subscribeTopics() {
    for (var topic in topics) {
      topic = '$productName/$topic';
      if (!topicNotifiers.containsKey(topic)) {
        final notifier = mqttService.getNotifierForTopic(topic);
        if (notifier != null) {
          topicNotifiers[topic] = notifier;
        }
      }
    }
  }

  void addListenersForSwitches() {
    topicNotifiers["$productName/inverter/state"]!
        .addListener(updateInverterState);
    topicNotifiers["$productName/cig/state"]!.addListener(updateCigState);
    topicNotifiers["$productName/poe/state"]!.addListener(updatePoeState);
    topicNotifiers["$productName/usb/state"]!.addListener(updateUsbState);
  }

  void disposeTopics() {
    topicNotifiers["$productName/inverter/state"]!
        .removeListener(updateInverterState);
    topicNotifiers["$productName/cig/state"]!
        .removeListener(updateInverterState);
    topicNotifiers["$productName/poe/state"]!
        .removeListener(updateInverterState);
    topicNotifiers["$productName/usb/state"]!
        .removeListener(updateInverterState);
    topicNotifiers.clear();
  }

  @override
  void dispose() {
    disposeTopics();

    super.dispose();
  }

  Future<void> _deleteProduct() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }
    final productsProvider = Provider.of<ProductListProvider>(
      context,
      listen: false,
    );
    final userUuid = prefs.getString('userUuid')!;
    final productSerialNumber =
        productsProvider.products[productIndex].serialNumber;
    final url =
        Uri.parse("$baseApiUrl/users/$userUuid/products/$productSerialNumber");
    final response = await http.delete(
      url,
      headers: {
        'x-api-key': apiKey,
      },
    );
    if (response.statusCode != 204) {
      Fluttertoast.showToast(
        msg: "Something went wrong.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    if (!mounted) {
      return;
    }
    Navigator.of(context).popUntil(ModalRoute.withName('/main'));
    Fluttertoast.showToast(
      msg: "Product deleted successfully.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
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
                  initialSelection: productIndex,
                  onSelected: (int? value) {
                    setState(() {
                      productIndex = value!;
                    });
                    disposeTopics();
                    updateName();
                    subscribeTopics();
                    addListenersForSwitches();
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
                                      '$productName/bat/voltage']!,
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
                                      '$productName/bat/current']!,
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
                            Column(
                              children: [
                                const Text(
                                  "Temp",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                gap8,
                                ValueListenableBuilder(
                                  valueListenable:
                                      topicNotifiers['$productName/temp']!,
                                  builder: (context, message, child) {
                                    return Text(
                                      "$message °F",
                                      style: const TextStyle(
                                        fontFamily: 'Roboto Slab',
                                        fontSize: 24,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        gap16,
                        ValueListenableBuilder(
                          valueListenable:
                              topicNotifiers['$productName/bat/soc']!,
                          builder: (context, message, child) {
                            return Small(
                              "Estimated Battery Life Remaining: $message %",
                            );
                          },
                        ),
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
                                      Sources.solar.index),
                                  gap4,
                                  _buildFlexibleLabelWithIndicator(
                                      Sources.inverter.index),
                                  gap4,
                                  _buildFlexibleLabelWithIndicator(
                                      Sources.poe.index),
                                ],
                              ),
                            ),
                            gap16,
                            Expanded(
                              flex: 1,
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
                                              Sources.cig.index),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          _buildFlexibleLabelWithIndicator(
                                              Sources.usb.index),
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
                      ],
                    ),
                    gap16,
                    Row(
                      children: [
                        _buildPowerOptionCard(Sources.inverter.index),
                        gap16,
                        _buildPowerOptionCard(Sources.cig.index),
                      ],
                    ),
                    gap16,
                    Row(
                      children: [
                        _buildPowerOptionCard(Sources.poe.index),
                        gap16,
                        _buildPowerOptionCard(Sources.usb.index),
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

  Widget _buildFlexibleLabelWithIndicator(int source) {
    final provider = Provider.of<ProductListProvider>(context);
    final active = provider.products[productIndex].state[source];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              labels[source],
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

  void updateProductState(bool value, int source, topic) {
    final productsProvider = Provider.of<ProductListProvider>(
      context,
      listen: false,
    );
    setState(() {
      productsProvider.setStates(productIndex, source, value);
    });
    mqttService.publish(topic, value.toString());
  }

  Widget _buildPowerOptionCard(
    int source,
  ) {
    final productsProvider = Provider.of<ProductListProvider>(context);
    final prefix = "$productName/${labels[source].toLowerCase()}";
    final topic = "$prefix/status";

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
              labels[source] != "Solar"
                  ? Switch(
                      value:
                          productsProvider.products[productIndex].state[source],
                      onChanged: (value) {
                        updateProductState(value, source, topic);
                      },
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParameterRow(
      String label, String source, String metric, String unit) {
    final topic = '$productName/${source.toLowerCase()}/$metric';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        ValueListenableBuilder(
          valueListenable: topicNotifiers[topic]!,
          builder: (context, message, child) {
            return Text("$message $unit");
          },
        ),
      ],
    );
  }
}
