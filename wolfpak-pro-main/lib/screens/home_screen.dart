import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wolfpak/components/button.dart';
import 'package:wolfpak/components/input_field.dart';
import 'package:wolfpak/components/profile_picture.dart';
import 'package:wolfpak/constants/gap.dart';
import 'package:wolfpak/providers/products_list_provider.dart';
import 'package:wolfpak/screens/dashboard_screen.dart';
import 'package:wolfpak/oop/product.dart';
import 'package:wolfpak/services/mqtt_service.dart';
import 'package:wolfpak/screens/qr_code_scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productSNController = TextEditingController();
  final TextEditingController _productPinController = TextEditingController();

  final mqttService = MqttService();

  @override
  void initState() {
    super.initState();

    mqttService.connect();
  }

  @override
  void dispose() {
    mqttService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductListProvider>(context);

    Future<void> goToProduct(index) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('userEmail')!;

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DashboardScreen(index, email),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: const Color(0xFF202020),
        surfaceTintColor: Colors.black,
        actions: [
          ProfilePicture(
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
            radius: 16,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          _openAddProductPanel(context);
        },
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  kBottomNavigationBarHeight),
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 24.0, right: 24.0),
                  child: Text(
                    "Below are all the solar inverters currently connected to your device, allowing you to monitor their status and performance at a glance.",
                    textAlign: TextAlign.justify,
                  ),
                ),
                gap16,
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: productsProvider.products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      name: productsProvider.products[index].name,
                      serialNumber:
                          productsProvider.products[index].serialNumber,
                      batteryVoltage:
                          productsProvider.products[index].batteryVoltage,
                      temperature: productsProvider.products[index].temperature,
                      isActive: productsProvider.products[index].isActive,
                      onTap: () async => {await goToProduct(index)},
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addProduct() {
    final productsProvider = Provider.of<ProductListProvider>(
      context,
      listen: false,
    );

    final productName = _productNameController.text.trim();
    final productSN = _productSNController.text.trim();
    final productPin = _productPinController.text.trim();

    if (productName.isEmpty || productSN.isEmpty || productPin.isEmpty) {
      Fluttertoast.showToast(
        msg: "All fields are required.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    productsProvider.addProduct(
      Product(
        name: productName,
        serialNumber: productSN,
      ),
    );

    _productNameController.text = '';
    _productSNController.text = '';
    _productPinController.text = '';

    Navigator.pop(context);
  }

  void _openAddProductPanel(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: const Color(0xFF202020),
      context: context,
      enableDrag: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24.0,
            right: 24.0,
            top: 24.0,
          ),
          child: Wrap(
            children: [
              const ListTile(
                title: Text(
                  'Add Product',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              gap24,
              InputField(
                controller: _productNameController,
                hintText: 'Product Name',
                icon: Icons.abc,
              ),
              gap16,
              InputField(
                controller: _productSNController,
                hintText: 'Serial Number',
                icon: Icons.tag,
              ),
              gap16,
              InputField(
                controller: _productPinController,
                hintText: 'PIN',
                icon: Icons.pin,
                obscureText: true,
              ),
              gap24,
              Button(
                "ADD",
                onPressed: _addProduct,
              ),
              gap24,
              const Divider(color: Color(0xFF303030)),
              gap24,
              Button(
                "QR CODE",
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const QRViewExample(),
                    ),
                  );
                },
                backgroundColor: Colors.tealAccent,
              ),
              gap24,
            ],
          ),
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final String serialNumber;
  final double batteryVoltage;
  final double temperature;
  final bool isActive;

  final void Function()? onTap;

  const ProductCard({
    super.key,
    required this.name,
    required this.serialNumber,
    required this.batteryVoltage,
    required this.temperature,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Divider(color: Color(0xFF333333)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFFC0C0C0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      gap4,
                      Text(
                        "#$serialNumber",
                        style: const TextStyle(fontSize: 11),
                      ),
                      gap16,
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF201201),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            padding: const EdgeInsets.only(
                              left: 8,
                              top: 4,
                              right: 10,
                              bottom: 4,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.bolt,
                                  color: Colors.orange,
                                  size: 16,
                                ),
                                gap4,
                                Text(
                                  '$batteryVoltage V',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          gap8,
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF111124),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            padding: const EdgeInsets.only(
                              left: 8,
                              top: 4,
                              right: 10,
                              bottom: 4,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.thermostat,
                                  color: Colors.blue,
                                  size: 16,
                                ),
                                gap4,
                                Text(
                                  '$temperature°C',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          StatusIndicator(isActive: isActive),
        ],
      ),
    );
  }
}

class StatusIndicator extends StatelessWidget {
  final bool _isActive;

  const StatusIndicator({super.key, required bool isActive})
      : _isActive = isActive;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 24,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isActive ? "Active" : "Inactive",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                gap8,
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isActive ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
