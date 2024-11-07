import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webedukid/features/shop/models/product_model.dart';
import 'package:webedukid/features/shop/controller/category_controller.dart';
import '../../common/data/repositories.authentication/bookings/booking_order_repository.dart';
import '../shop/models/booking_orders_model.dart';
import '../shop/models/category_model.dart';
import '../shop/models/brand_model.dart';
import 'package:collection/collection.dart';

class NavigationController extends GetxController {
  var currentScreen = 'home'.obs;

  // Store product for detail navigation
  ProductModel? selectedProduct;

  // Store selected brand for brand navigation
  BrandModel? selectedBrand;

  // Store selected category for subcategory navigation as Rx
  var selectedCategory = Rx<CategoryModel?>(null);
  var userBookings = <BookingOrderModel>[].obs;

  // Getter for selected category
  CategoryModel? get getCategory => selectedCategory.value;

  // Setter for selected category
  set setCategory(CategoryModel? value) {
    selectedCategory.value = value;
  }

  void navigateTo(String screenKey, {ProductModel? product, BrandModel? brand, CategoryModel? category}) {
    currentScreen.value = screenKey;

    if (product != null) selectedProduct = product;
    if (brand != null) selectedBrand = brand;
    if (category != null) setCategory = category;

    if (screenKey != 'subcategories') clearSelectedCategory();
  }

  void forceReloadScreen(String screenKey) {
    currentScreen.value = '';
    Future.delayed(Duration(milliseconds: 100), () {
      currentScreen.value = screenKey;
    });
  }

  void goToCheckoutScreen(BuildContext context) {
    clearSelectedCategory();
    context.go('/checkout');
  }

  Future<void> fetchUserBookings() async {
    try {
      final bookings = await BookingOrderRepository.instance.fetchUserBookings();
      userBookings.assignAll(bookings);
    } catch (e) {
      print('Error fetching bookings: $e');
    }
  }

  void selectCategoryByName(String categoryName) {
    final categoryController = Get.find<CategoryController>();
    final category = categoryController.categories.firstWhereOrNull(
          (cat) => cat.name == categoryName,
    );
    selectedCategory.value = category;  // Assigning to .value here
  }

  // Update observeCategoryChanges to clear selection when navigating to '/home'
  void observeCategoryChanges(BuildContext context) {
    selectedCategory.listen((category) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (category != null) {
          context.go('/home/${category.name}');
        } else {
          // Clear category when going back to `/home`
          clearSelectedCategory();
          context.go('/home');
        }
      });
    });
  }

  // Method to update the selected category using CategoryModel, not just name
  void updateCategory(String categoryName) {
    final categoryController = Get.find<CategoryController>();
    final category = categoryController.categories.firstWhereOrNull(
          (cat) => cat.name == categoryName,
    );
    selectedCategory.value = category; // Set the model, not just the name
  }

  void navigateToSubCategories(BuildContext context, CategoryModel category) {
    selectedCategory.value = category; // Set the selected category
    Get.find<CategoryController>().setSelectedCategory(category);
    context.go('/subcategories/${category.id}');
  }

  void clearSelectedCategory() {
    selectedCategory.value = null;  // Clear the selected category
  }
}
