
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pay/pay.dart';
import 'package:webedukid/features/shop/screens/checkout/widgets/billing_address_section.dart';
import 'package:webedukid/features/shop/screens/checkout/widgets/billing_amount_section.dart';
import 'package:webedukid/features/shop/screens/checkout/widgets/billing_payment_section.dart';

import '../../../../common/widgets/appbar.dart';
import '../../../../common/widgets/customShapes/containers/rounded_container.dart';
import '../../../../common/widgets/loaders/loaders.dart';
import '../../../../common/widgets/products/cart/coupon_widget.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/helpers/pricing_calculator.dart';
import '../../cart/widgets/my_cart_items_listview.dart';
import '../../controller/product/cart_controller.dart';
import '../../controller/product/order_controller.dart';

class CheckOutScreen extends StatelessWidget {
  const CheckOutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _paymentItems = <PaymentItem>[];
final cartController = CartController.instance;
final subTotal = cartController.totalCartPrice.value;
final orderController = Get.put(OrderController());
final totalAmount = MyPricingCalculator.calculateTotalPrice(subTotal, 'US');


    final dark = MyHelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: MyAppBar(
        showBackArrow: true,
        title: Text('Order Review',
            style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(MySizes.defaultspace),
          child: Column(
            children: [
              ///-- Items in Cart
              const MyCartItemsListView(showAddRemoveButtons: false),
              const SizedBox(height: MySizes.spaceBtwSections),

              /// Coupon TextField
              MyCouponCode(),
              const SizedBox(height: MySizes.spaceBtwSections),

              /// billing section
              MyRoundedContainer(
                showBorder: true,
                padding: EdgeInsets.all(MySizes.md),
                backgroundColor: dark ? MyColors.dark : MyColors.white,
                child: Column(
                  children: [
                    ///Pricing
                    MyBillingAmountSection(subTotal: subTotal,),
                    SizedBox(
                      height: MySizes.spaceBtwItems,
                    ),

                    ///Divider
                    Divider(),
                    SizedBox(
                      height: MySizes.spaceBtwItems,
                    ),

                    ///Payment Methods
                    MyBillingPaymentSection(),
                    SizedBox(
                      height: MySizes.spaceBtwItems,
                    ),

                    ///Address
                    MyBillingAddressSection(),

                  ],
                ),
              )
            ],
          ),
        ),
      ),

      /// checkout button
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(MySizes.defaultspace),
        child: ElevatedButton(
          onPressed: subTotal > 0
              ? () => orderController.processOrder(totalAmount)
              : () => MyLoaders.warningSnackBar(title: 'Empty Cart', message: 'Add items in the cart to proceed'),

          child: Text('Checkout \$$totalAmount'),
        ),
      ),
    );
  }
}
