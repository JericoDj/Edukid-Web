import 'package:flutter/material.dart';

class BookingSessionModel {
  double price;
  DateTime bookingDate;
  TimeOfDay? bookingTime;
  String bookingType;

  /// Constructor
  BookingSessionModel({
    required this.price,
    required this.bookingDate,
    this.bookingTime,
    required this.bookingType,
  });

  /// Convert a BookingSessionModel to a JSON Map
  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'bookingDate': bookingDate.toString(),
      'bookingTime': bookingTime != null ? '${bookingTime!.hour}:${bookingTime!.minute}' : null,
      'bookingType': bookingType,
    };
  }

  /// Create a BookingSessionModel from a JSON Map
  factory BookingSessionModel.fromJson(Map<String, dynamic> json) {
    return BookingSessionModel(
      price: json['price']?.toDouble() ?? 0.0,
      bookingDate: DateTime.parse(json['bookingDate']),
      bookingTime: json['bookingTime'] != null
          ? TimeOfDay(
        hour: int.parse(json['bookingTime'].split(':')[0]),
        minute: int.parse(json['bookingTime'].split(':')[1]),
      )
          : null,
      bookingType: json['bookingType'],
    );
  }
}
