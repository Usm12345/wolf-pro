import 'package:flutter/material.dart';
import 'package:wolfpak/oop/product.dart';

class ProductListProvider with ChangeNotifier {
  final List<Product> _products = [];

  List<Product> get products => _products;

  void updateProduct(int index, Product newProduct) {
    if (index >= 0 && index < _products.length) {
      _products[index] = newProduct;
      notifyListeners();
    }
  }

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  void removeProduct(int index) {
    if (index >= 0 && index < _products.length) {
      _products.removeAt(index);
      notifyListeners();
    }
  }

  void setStates(int index, int source, bool value) {
    _products[index].state[source] = value;
  }

  void clear() {
    _products.clear();
  }

  bool exists(String serialNumber) {
    for (var product in _products) {
      if (product.serialNumber == serialNumber) {
        return true;
      }
    }
    return false;
  }
}
