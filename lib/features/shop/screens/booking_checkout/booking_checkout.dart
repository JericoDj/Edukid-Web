
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pay/pay.dart';
import 'package:webedukid/features/shop/screens/booking_checkout/widgets/booking_billing_amount_section.dart';
import 'package:webedukid/features/shop/screens/booking_checkout/widgets/booking_details.dart';


import '../../../../common/widgets/appbar.dart';
import '../../../../common/widgets/customShapes/containers/rounded_container.dart';
import '../../../../common/widgets/loaders/loaders.dart';
import '../../../../common/widgets/products/cart/coupon_widget.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/helpers/pricing_calculator.dart';

import '../../controller/bookings/booking_order_controller.dart';
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
  double subTotal = 0; // Initialize subtotal

  @override
  void initState() {
    super.initState();
    calculateSubTotal(); // Calculate the subtotal when the screen is initialized
  }

  void calculateSubTotal() {
    setState(() {
      subTotal = widget.pickedDates.length * 10; // Calculate the subtotal
    });
    print('Subtotal: \$${subTotal.toStringAsFixed(2)}'); // Print the subtotal
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = MyPricingCalculator.calculateTotalPrice(subTotal, 'US');
    final dark = MyHelperFunctions.isDarkMode(context);

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: 650,
        child: Scaffold(
          appBar: MyAppBar(
            showBackArrow: true,
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
                  MyCouponCode(),
                  const SizedBox(height: 16.0),
                  MyRoundedContainer(
                    showBorder: true,
                    padding: EdgeInsets.all(16.0),
                    backgroundColor: dark ? Colors.grey[900]! : Colors.white,
                    child: Column(
                      children: [
                        MyBookingBillingAmountSection(subTotal: subTotal),
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
                controller.processOrder(totalAmount,widget.pickedDates, widget.pickedTimes);
              }
                  : () => MyLoaders.warningSnackBar(title: 'Empty Cart', message: 'Add items in the cart to proceed'),
              child: Text('Checkout \$$totalAmount'),
            ),
          ),
        ),
      ),
    );
  }
}

