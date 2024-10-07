import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:webedukid/features/shop/screens/checkout/checkout.dart';  // Import the CheckoutScreen
import 'package:webedukid/features/shop/models/product_model.dart';

class NavigationController extends GetxController {
  var currentScreen = 'home'.obs;  // Default to the home screen

  // Store product for detail navigation
  ProductModel? selectedProduct;

  void navigateTo(String screenKey, {ProductModel? product}) {
    currentScreen.value = screenKey;
    if (product != null) {
      selectedProduct = product;  // Store product if navigating to product details
    }
  }

  // Method to navigate to the checkout screen
  void goToCheckoutScreen() {
    Get.to(() => CheckOutScreen());  // Navigate to the CheckoutScreen
  }
}
