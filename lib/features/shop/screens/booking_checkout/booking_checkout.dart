
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pay/pay.dart';
import 'package:webedukid/features/shop/screens/booking_checkout/widgets/booking_billing_amount_section.dart';
import 'package:webedukid/features/shop/screens/booking_checkout/widgets/booking_details.dart';
import 'package:webedukid/utils/constants/colors.dart';


import '../../../../common/widgets/appbar.dart';
import '../../../../common/widgets/customShapes/containers/rounded_container.dart';
import '../../../../common/widgets/loaders/loaders.dart';
import '../../../../common/widgets/products/cart/coupon_widget.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/helpers/pricing_calculator.dart';

import '../../../screens/personalization/controllers/address_controller.dart';
import '../../controller/bookings/booking_order_controller.dart';
import '../../controller/product/checkout_controller.dart';
import '../../controller/product/order_controller.dart';
import '../checkout/widgets/billing_address_section.dart';
import '../checkout/widgets/billing_payment_section.dart';

class BookingCheckOutScreen extends StatefulWidget {
  final List<DateTime> pickedDates;
  final List<TimeOfDay?> pickedTimes;
  final double price;

  BookingCheckOutScreen({
    Key? key,
    required this.pickedDates,
    required this.pickedTimes,
    required this.price,
  }) : super(key: key);

  @override

  _BookingCheckOutScreenState createState() => _BookingCheckOutScreenState();
}

class _BookingCheckOutScreenState extends State<BookingCheckOutScreen> {
  double subTotal = 0;
  double discount = 0; // Add a discount state

  @override
  void initState() {
    super.initState();
    calculateSubTotal(); // Calculate the subtotal when the screen is initialized
  }

  void calculateSubTotal() {
    setState(() {
      subTotal = widget.pickedDates.length * widget.price; // Calculate the subtotal
    });
    print('Subtotal: \$${subTotal.toStringAsFixed(2)}'); // Print the subtotal
  }

  // Callback for handling discount applied
  void _onDiscountApplied(double discountValue) {
    setState(() {
      discount = discountValue; // Update the discount value
    });
  }

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(()=>OrderController());
    Get.lazyPut(()=>CheckoutController());
    Get.lazyPut(()=>AddressController());
    // Subtract the discount from the subtotal to get the final total amount
    final discountedSubTotal = subTotal - (subTotal * discount / 100);
    final totalAmount = MyPricingCalculator.calculateTotalPrice(discountedSubTotal, 'US');
    final dark = MyHelperFunctions.isDarkMode(context);

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: 650,
        child: Scaffold(
          appBar: MyAppBar(
            showBackArrow: false,
            title: Text(
              'Booking Review',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(MySizes.defaultspace),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// booking details
                  BookingDetails(widget: widget),

                  const SizedBox(height: 16.0),

                  /// Coupon Code Section with discount callback
                  MyCouponCode(onDiscountApplied: _onDiscountApplied), // Pass the callback here
                  const SizedBox(height: 16.0),

                  MyRoundedContainer(
                    borderColor: MyColors.primaryColor,

                    showBorder: true,
                    padding: EdgeInsets.all(16.0),
                    backgroundColor: dark ? Colors.grey[900]! : Colors.white,
                    child: Column(
                      children: [
                        /// Pass the discount to billing section
                        MyBookingBillingAmountSection(subTotal: subTotal, discount: discount),
                        SizedBox(height: 16.0),
                        Divider(),
                        SizedBox(height: 16.0),
                        MyBillingPaymentSection(),
                        SizedBox(height: 16.0),
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
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: subTotal > 0
                  ? () {
                final controller = Get.put(BookingOrderController());

                controller.processOrder(
                  totalAmount,
                  widget.pickedDates,
                  widget.pickedTimes,
                  context, // Pass context here for GoRouter navigation
                );
              }
                  : () => MyLoaders.warningSnackBar(
                  title: 'Empty Cart',
                  message: 'Add items in the cart to proceed'
              ),
              child: Text(
                'Checkout \$$totalAmount',
                style: TextStyle(color: MyColors.primaryColor),
              ),
            ),

          ),
        ),
      ),
    );
  }
}
