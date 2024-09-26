class Product {
  final String name;
  final String serialNumber;
  final double batteryVoltage;
  final double current;
  final double temperature;
  final bool isActive;
  final int estimatedBatteryLife;

  const Product({
    required this.name,
    required this.serialNumber,
    this.batteryVoltage = 0,
    this.current = 0,
    this.temperature = 0,
    this.isActive = false,
    this.estimatedBatteryLife = 0,
  });
}
