import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webedukid/features/shop/controller/product/variation_controller.dart';
import '../../../../common/widgets/loaders/loaders.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/local_storage/storage_utility.dart';
import '../../models/cart_item_model.dart';
import '../../models/product_model.dart';
import 'package:collection/collection.dart';

class CartController extends GetxController {
  static CartController get instance => Get.find();

  // Variables
  RxInt noOfCartItems = 0.obs;
  RxDouble totalCartPrice = 0.0.obs;
  RxInt productQuantityInCart = 0.obs;
  RxInt initialProductCount = 1.obs;
  RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final variationController = VariationController.instance;

  CartController() {
    loadCartItems();
  }

  /// Add items to the cart with a limit of 1 per product
  void addToCart(ProductModel product) async {
    // First, check if the user has already purchased the product
    bool isAlreadyPurchased = await _checkIfAlreadyPurchased(product);
    if (isAlreadyPurchased) {
      MyLoaders.warningSnackBar(
        message: 'You have already purchased this product.',
        title: 'Product Already Purchased',
      );
      return; // Exit if already purchased
    }

    // Check if the product is already in the cart
    bool isAlreadyInCart = _isAlreadyInCart(product);
    if (isAlreadyInCart) {
      MyLoaders.customToast(message: 'You can only purchase 1 copy of this eBook.');
      return; // Exit if product is already in the cart
    }

    // Quantity Check (Ensure that only 1 copy can be added)
    if (productQuantityInCart.value < 1) {
      MyLoaders.customToast(message: 'Select Quantity');
      return;
    }

    // Variation Selected?
    if (product.productType == ProductType.variable.toString() &&
        variationController.selectedVariation.value.id.isEmpty) {
      MyLoaders.customToast(message: 'Select Variation');
      return;
    }

    // Out of Stock Status
    if (product.productType == ProductType.variable.toString()) {
      if (variationController.selectedVariation.value.stock < 1) {
        MyLoaders.warningSnackBar(
            message: 'Selected variation is out of stock.', title: 'Oh Snap!');
        return;
      }
    } else {
      if (product.stock < 1) {
        MyLoaders.warningSnackBar(
            message: 'Selected Product is out of stock.', title: 'Oh Snap!');
        return;
      }
    }

    // Convert the Product Model to a CartItemModel with the given quantity (1 only)
    final selectedCartItem = convertToCartItem(product, 1);

    // Add the new item to the cart (since we already checked there isn't any in the cart)
    cartItems.add(selectedCartItem);

    updateCart();
    MyLoaders.customToast(message: 'Your Product has been added to the Cart.');
  }

  // Helper method to check if two attribute maps are the same
  bool _isSameAttributes(
      Map<String, dynamic>? attributes1, Map<String, dynamic>? attributes2) {
    if (attributes1 == null && attributes2 == null) {
      return true;
    }
    if (attributes1 == null || attributes2 == null) {
      return false;
    }
    return MapEquality().equals(attributes1, attributes2);
  }

  // Check if the product has already been purchased
  Future<bool> _checkIfAlreadyPurchased(ProductModel product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false; // If user is not logged in, no previous purchases

    final userOrders = FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('Orders');

    final querySnapshot = await userOrders.get();

    for (var doc in querySnapshot.docs) {
      final orderData = doc.data();
      final List<dynamic>? items = orderData['items'];

      if (items != null) {
        for (var item in items) {
          final String title = item['title'] ?? '';
          final Map<String, dynamic>? selectedVariation = item['selectedVariation'];

          if (title == product.title) {
            if (product.productType == ProductType.single.toString()) {
              // For single product, check by title only
              return true;
            } else if (product.productType == ProductType.variable.toString() && selectedVariation != null) {
              // For variable product, check by title and selected variations
              final String? chapter = selectedVariation['Chapter'];
              final String? part = selectedVariation['Part'];

              if (chapter == variationController.selectedVariation.value.attributeValues['Chapter'] &&
                  part == variationController.selectedVariation.value.attributeValues['Part']) {
                return true;
              }
            }
          }
        }
      }
    }
    return false;
  }

  // Check if the product is already in the cart
  bool _isAlreadyInCart(ProductModel product) {
    for (var cartItem in cartItems) {
      if (cartItem.productId == product.id) {
        // If product type is variable, check for variation as well
        if (product.productType == ProductType.variable.toString()) {
          final selectedVariation = variationController.selectedVariation.value;
          if (_isSameAttributes(cartItem.selectedVariation, selectedVariation.attributeValues)) {
            return true;
          }
        } else {
          // If product type is single, check by productId only
          return true;
        }
      }
    }
    return false;
  }

  // Adds one to the existing quantity
  void addOneToCart(CartItemModel item) {
    final index = cartItems.indexWhere((cartItem) => cartItem.productId == item.productId);
    if (index != -1) {
      cartItems[index].quantity += 1;
      cartItems.refresh();
    }
  }
  // Method to remove one quantity of an item from the cart


  // Removes one from the existing quantity, removes the item if quantity reaches zero
  void removeOneFromCart(CartItemModel item) {
    final index = cartItems.indexWhere((cartItem) => cartItem.productId == item.productId);
    if (index != -1) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity -= 1;
      } else {
        cartItems.removeAt(index);
      }
      cartItems.refresh();
    }
  }



  // Show a dialog to confirm removal of an item from the cart
  void removeFromCartDialog(int index) {
    Completer<bool?> completer = Completer<bool?>();

    showDialog(
      context: Get.overlayContext!,
      builder: (context) {
        return AlertDialog(
          title: Text('Remove Product'),
          content: Text('Are you sure you want to remove this product?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                completer.complete(false);
                Get.back();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                completer.complete(true);
                Get.back();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    ).then((result) {
      if (result != null) {
        cartItems.removeAt(index);
        updateCart();
        MyLoaders.customToast(message: 'Product removed from the Cart.');
      }
    });
  }

  ///Initialize the product quantity for items already in the cart
  void updateAlreadyAddedProductCount(ProductModel product) {
    if (product.productType == ProductType.single.toString()) {
      productQuantityInCart.value = getProductQuantityInCart(product.id);
    } else {
      final variationId = variationController.selectedVariation.value.id;
      if (variationId.isNotEmpty) {
        productQuantityInCart.value =
            getVariationQuantityInCart(product.id, variationId);
      } else {
        productQuantityInCart.value = 0;
      }
    }
  }

  /// This function converts a Product Model to a CartItemModel
  CartItemModel convertToCartItem(ProductModel product, int quantity) {
    if (product.productType == ProductType.single.toString()) {
      // Reset Variation in case of single product type.
      variationController.resetSelectedAttributes();
    }
    final variation = variationController.selectedVariation.value;
    final isVariation = variation.id.isNotEmpty;
    final price = isVariation
        ? variation.salePrice > 0.0
        ? variation.salePrice
        : variation.price
        : product.salePrice > 0.0
        ? product.salePrice
        : product.price;

    return CartItemModel(
      productId: product.id,
      title: product.title,
      price: price,
      quantity: quantity,
      variationId: variation.id,
      image: isVariation ? variation.image : product.thumbnail,
      brandName: product.brand != null ? product.brand!.name : '',
      selectedVariation: isVariation ? variation.attributeValues : null,
    );
  }

  /// Update Cart Values
  void updateCart() {
    updateCartTotals();
    saveCartItems();
    cartItems.refresh();
  }

  // Calculate the total price and number of items in the cart
  void updateCartTotals() {
    double calculatedTotalPrice = 0.0;
    int calculatedNoOfItems = 0;

    for (var item in cartItems) {
      calculatedTotalPrice += (item.price) * item.quantity.toDouble();
      calculatedNoOfItems += item.quantity;
    }
    totalCartPrice.value = calculatedTotalPrice;
    noOfCartItems.value = calculatedNoOfItems;
  }

  // Save the cart items to local storage
  void saveCartItems() {
    final cartItemStrings = cartItems.map((item) => item.toJson()).toList();
    MyStorageUtility().saveData('cartItems', cartItemStrings);
  }

  // Load the cart items from local storage
  void loadCartItems() {
    final cartItemStrings =
    MyStorageUtility().readData<List<dynamic>>('cartItems');
    if (cartItemStrings != null) {
      cartItems.assignAll(cartItemStrings
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>)));
      updateCartTotals();
    }
  }

  int getProductQuantityInCart(String productId) {
    final foundItem = cartItems
        .where((item) => item.productId == productId)
        .fold(0, (previousValue, element) => previousValue + element.quantity);
    return foundItem;
  }

  int getVariationQuantityInCart(String productId, String variationId) {
    final foundItem = cartItems.firstWhere(
          (item) => item.productId == productId && item.variationId == variationId,
      orElse: () => CartItemModel.empty(),
    );

    return foundItem.quantity;
  }

  // Method to remove an item from the cart
  void removeFromCart(int index) {
    cartItems.removeAt(index);
    updateCart();
    MyLoaders.customToast(message: 'Product removed from the Cart.');
  }

  // Method to clear the cart
  void clearCart() {
    productQuantityInCart.value = 0;
    cartItems.clear();
    updateCart();
  }
}
