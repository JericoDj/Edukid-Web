import 'dart:async';


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
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

  /// Add items in the cart
  void addToCart(ProductModel product) {
    // Quantity Check
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

    // Convert the Product Model to a CartItemModel with the given quantity
    final selectedCartItem =
        convertToCartItem(product, productQuantityInCart.value);

    // Check if a similar item already exists in the cart
    int index = cartItems.indexWhere((cartItem) =>
        cartItem.productId == selectedCartItem.productId &&
        cartItem.variationId == selectedCartItem.variationId &&
        _isSameAttributes(
            cartItem.selectedVariation, selectedCartItem.selectedVariation));

    if (index >= 0) {
      // Similar item found, update its quantity
      cartItems[index].quantity += selectedCartItem.quantity;
    } else {
      // No similar item found, add the new item to the cart
      cartItems.add(selectedCartItem);
    }

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

  void addOneToCart(CartItemModel item) {
    int index = cartItems.indexWhere(
          (cartItem) =>
      cartItem.productId == item.productId &&
          cartItem.variationId == item.variationId &&
          mapEquals(cartItem.selectedVariation, item.selectedVariation),
    );

    if (index >= 0) {
      cartItems[index].quantity += 1;
    } else {
      cartItems.add(item);
    }

    updateCart();
  }

  void removeOneFromCart(CartItemModel item) {
    int index = cartItems.indexWhere(
          (cartItem) =>
      cartItem.productId == item.productId &&
          cartItem.variationId == item.variationId &&
          mapEquals(cartItem.selectedVariation, item.selectedVariation),
    );

    if (index >= 0) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity -= 1;
      } else {
        removeFromCartDialog(index);
        return; // Return to prevent updating the cart after dialog
      }
    }

    updateCart();
  }

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

  ///Initialize already added Item's Count in the cart.
  void updateAlreadyAddedProductCount(ProductModel product) {
// If product has no variations then calculate cartEntries and display total number.
// Else make default entries to 0 and show cart Entries when variation is selected.
    if (product.productType == ProductType.single.toString()) {
      productQuantityInCart.value = getProductQuantityInCart(product.id);
    } else {
// Get selected Variation if any...
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

  void saveCartItems() {
    final cartItemStrings = cartItems.map((item) => item.toJson()).toList();
    MyStorageUtility().saveData('cartItems', cartItemStrings);
  }

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

  // Add this method to remove an item from the cart
  void removeFromCart(int index) {
    cartItems.removeAt(index);
    updateCart();
    MyLoaders.customToast(message: 'Product removed from the Cart.');
  }

  void clearCart() {
    productQuantityInCart.value = 0;
    cartItems.clear();
    updateCart();
  }
}
