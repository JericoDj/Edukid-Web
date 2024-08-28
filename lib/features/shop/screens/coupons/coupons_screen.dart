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
      ),
      body: Obx(
            () => ListView.builder(
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
              child: _buildCouponCard(context, coupon),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCouponCard(BuildContext context, Coupon coupon) {
    return Card(
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
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coupon App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CouponScreen(),
    );
  }
}
