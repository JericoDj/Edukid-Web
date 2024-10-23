import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';
import 'package:webedukid/features/shop/controller/brand_controller.dart';
import 'package:webedukid/utils/local_storage/storage_utility.dart';
import '../features/screens/personalization/controllers/address_controller.dart';
import '../features/shop/controller/bookings/booking_order_controller.dart';
import '../features/shop/controller/product/cart_controller.dart';
import '../features/shop/controller/product/checkout_controller.dart';
import '../features/shop/controller/product/order_controller.dart';
import '../features/shop/controller/product/variation_controller.dart';
import '../utils/network manager/network_manager.dart';


class GeneralBindings extends Bindings {
  @override
  void dependencies() {

    Get.put(NetworkManager());

    Get.lazyPut<VariationController>(() => VariationController());
    Get.put(CartController());
    Get.put(BrandController());

    Get.put(CheckoutController());
    Get.put(AddressController());
    Get.put(OrderController());  // Ensure this is here
    Get.put(BookingOrderController());
  }
}
