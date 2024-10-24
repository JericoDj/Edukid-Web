import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webedukid/utils/constants/colors.dart';

import '../../controller/coupons/coupons_controller.dart';

class Coupon {
  final String code;
  final double? discount; // Nullable double
  final DateTime expiryDate;

  Coupon({
    required this.code,
    required this.expiryDate,
    this.discount, // Nullable double
  });
}

class CouponScreen extends StatelessWidget {
  final CouponController couponController = Get.put(CouponController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coupons'),
        centerTitle: true, // Center the title
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align to top center
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(
                  () => ListView.builder(
                shrinkWrap: true,
                itemCount: couponController.coupons.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> couponData = couponController.coupons[index];

                  // Handle null values by providing defaults or checking for null
                  String code = couponData['code'] ?? 'No code available'; // Default if null
                  double? discount = couponData['discount']?.toDouble(); // Use null-aware operator
                  Timestamp? expiryTimestamp = couponData['expiryDate']; // Check for null

                  // Ensure expiry date is not null
                  DateTime expiryDate = expiryTimestamp != null
                      ? DateTime.fromMillisecondsSinceEpoch(expiryTimestamp.millisecondsSinceEpoch)
                      : DateTime.now(); // Default to now if null

                  Coupon coupon = Coupon(
                    code: code,
                    discount: discount, // Allow nullable discount
                    expiryDate: expiryDate,
                  );

                  return Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Center(
                      child: _buildCouponCard(context, coupon),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponCard(BuildContext context, Coupon coupon) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 400,
        maxHeight: 180,
      ), // Set a smaller maximum width for the card
      child: Card(
        elevation: 6.0, // Increase elevation for more depth
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // Larger border radius for rounded edges
          side: BorderSide(color: MyColors.white), // Border color
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [MyColors.primaryColor, MyColors.primaryColor], // Gradient background for card
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15.0), // Match card border radius
          ),
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCouponHeader(coupon),
              SizedBox(height: 15.0),
              _buildCouponBody(coupon),
              SizedBox(height: 10.0),
              _buildCouponFooter(coupon),
            ],
          ),
        ),
      ),
    );
  }

  // Header with Coupon Code
  Widget _buildCouponHeader(Coupon coupon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Coupon Code:',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.normal,
            color: Colors.white, // White color for contrast with the gradient
          ),
        ),
        Text(
          coupon.code,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.normal,
            color: Colors.yellowAccent, // Highlight the code in yellow
          ),
        ),
      ],
    );
  }

  // Body with Discount Information
  Widget _buildCouponBody(Coupon coupon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discount:',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            color: MyColors.primaryColor,
          ),
        ),
        SizedBox(height: 5.0),
        Text(
          coupon.discount != null ? '${coupon.discount}% Off' : 'No discount available',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: coupon.discount != null ? Colors.yellowAccent : Colors.grey,
          ),
        ),
      ],
    );
  }

  // Footer with Expiry Date
  Widget _buildCouponFooter(Coupon coupon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(Icons.date_range, color: Colors.white), // Icon for date
        SizedBox(width: 10.0),
        Text(
          'Expires on: ${coupon.expiryDate.day}/${coupon.expiryDate.month}/${coupon.expiryDate.year}',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
