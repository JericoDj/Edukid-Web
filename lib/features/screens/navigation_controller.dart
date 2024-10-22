import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:webedukid/features/shop/screens/checkout/checkout.dart'; // Import the CheckoutScreen
import 'package:webedukid/features/shop/models/product_model.dart';
import 'package:webedukid/features/shop/controller/category_controller.dart';
import '../shop/models/category_model.dart'; // Import CategoryModel

class NavigationController extends GetxController {
  var currentScreen = 'home'.obs;  // Default to the home screen

  // Store product for detail navigation
  ProductModel? selectedProduct;

  // Store selected category for subcategory navigation
  Rx<CategoryModel?> _selectedCategory = Rx<CategoryModel?>(null);

  // Getter for selected category
  CategoryModel? get selectedCategory => _selectedCategory.value;

  // Setter for selected category
  set selectedCategory(CategoryModel? value) {
    _selectedCategory.value = value;
  }

  // Method to navigate to a specific screen and clear selected category
  void navigateTo(String screenKey, {ProductModel? product}) {
    currentScreen.value = screenKey;

    // Store product if navigating to product details
    if (product != null) {
      selectedProduct = product;
    }

    // Clear selected category after navigating
    clearSelectedCategory();

  }

  // Method to force reload of the current screen
  void forceReloadScreen(String screenKey) {
    // Temporarily set to another screen and return back to the desired one
    currentScreen.value = '';
    Future.delayed(Duration(milliseconds: 100), () {
      currentScreen.value = screenKey;
    });
  }

  // Method to navigate to the checkout screen and clear selected category
  void goToCheckoutScreen() {
    clearSelectedCategory();
    Get.to(() => CheckOutScreen());  // Navigate to the CheckoutScreen
  }

  // Method to select a category and navigate to SubCategoriesScreen
  void navigateToSubCategories(CategoryModel category) {
    _selectedCategory.value = category;  // Set the selected category
    Get.find<CategoryController>().setSelectedCategory(category);  // Optionally call the category controller
    navigateTo('subcategories');  // Navigate to the subcategories screen
  }

  // Method to clear selected category
  void clearSelectedCategory() {
    _selectedCategory.value = null;  // Clear the selected category
  }
}
