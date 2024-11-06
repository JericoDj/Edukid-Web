import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webedukid/features/shop/screens/checkout/checkout.dart';
import 'package:webedukid/features/shop/models/product_model.dart';
import 'package:webedukid/features/shop/controller/category_controller.dart';
import '../../common/data/repositories.authentication/bookings/booking_order_repository.dart';
import '../shop/models/booking_orders_model.dart';
import '../shop/models/category_model.dart';
import '../shop/models/brand_model.dart'; // Add BrandModel import

class NavigationController extends GetxController {

  var currentScreen = 'home'.obs;  // Default to the home screen

  // Store product for detail navigation
  ProductModel? selectedProduct;

  // Store selected brand for brand navigation
  BrandModel? selectedBrand;

  // Store selected category for subcategory navigation
  Rx<CategoryModel?> _selectedCategory = Rx<CategoryModel?>(null);
  RxList<BookingOrderModel> userBookings = <BookingOrderModel>[].obs;

  // Getter for selected category
  CategoryModel? get selectedCategory => _selectedCategory.value;

  // Setter for selected category
  set selectedCategory(CategoryModel? value) {
    _selectedCategory.value = value;
  }

  // Method to navigate to a specific screen and clear selected category
  void navigateTo(String screenKey, {ProductModel? product, BrandModel? brand, CategoryModel? category}) {
    currentScreen.value = screenKey;

    // Store product if navigating to product details
    if (product != null) {
      selectedProduct = product;
    }

    // Store brand if navigating to brand products
    if (brand != null) {
      selectedBrand = brand;
    }

    // Store category if navigating to subcategories
    if (category != null) {
      selectedCategory = category;
    }

    // Clear selected category if not navigating to subcategories
    if (screenKey != 'subcategories') {
      clearSelectedCategory();
    }
  }

  // Method to force reload of the current screen
  void forceReloadScreen(String screenKey) {
    // Temporarily set to another screen and return back to the desired one
    currentScreen.value = '';
    Future.delayed(Duration(milliseconds: 100), () {
      currentScreen.value = screenKey;
    });
  }

  void goToCheckoutScreen(BuildContext context) {
    clearSelectedCategory();
    // Assuming you have a route defined for the CheckoutScreen
    context.go('/checkout');  // Change '/checkout' to the actual route path
  }

  // Method to fetch user bookings
  Future<void> fetchUserBookings() async {
    try {
      final bookings = await BookingOrderRepository.instance.fetchUserBookings();
      userBookings.assignAll(bookings); // Assign fetched bookings to observable list
    } catch (e) {
      print('Error fetching bookings: $e');
    }
  }


  // Method to select a category and navigate to SubCategoriesScreen
  void navigateToSubCategories(BuildContext context, CategoryModel category) {
    _selectedCategory.value = category; // Set the selected category
    // Update the category in the controller, if needed
    Get.find<CategoryController>().setSelectedCategory(category);

    // Navigate to the subcategories screen with the category id as a parameter
    context.go('/subcategories/${category.id}');
  }


  // Method to clear selected category
  void clearSelectedCategory() {
    _selectedCategory.value = null;  // Clear the selected category
  }
}
