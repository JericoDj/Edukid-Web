import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                  Coupon coupon = Coupon(
                    code: couponData['code'],
                    discount: couponData['discount'].toDouble(), // Convert int to double
                    expiryDate: DateTime.fromMillisecondsSinceEpoch(
                      couponData['expiryDate'].millisecondsSinceEpoch,
                    ),
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

      constraints: BoxConstraints(maxWidth: 600,), // Set a smaller maximum width for the card
      child: Card(
        elevation: 3.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(color: Colors.blue),
        ),
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Coupon Code: ${coupon.code}',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              Text(
                'Discount: ${coupon.discount}%',
                style: TextStyle(fontSize: 14.0),
              ),
              SizedBox(height: 5.0),
              Text(
                'Expiry Date: ${coupon.expiryDate.day}/${coupon.expiryDate.month}/${coupon.expiryDate.year}',
                style: TextStyle(fontSize: 14.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
