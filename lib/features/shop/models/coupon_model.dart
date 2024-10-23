import 'package:flutter/foundation.dart';

class Coupon {
  final String code;
  final double discount;
  final DateTime expiryDate;

  Coupon({
    required this.code,
    required this.discount,
    required this.expiryDate,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      code: json['code'] ?? '',
      discount: (json['discount'] ?? 0.0).toDouble(),
      expiryDate: DateTime.parse(json['expiryDate'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'discount': discount,
      'expiryDate': expiryDate.toIso8601String(),
    };
  }
}
