import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webedukid/features/shop/models/picked_date_and_time_model.dart';

import '../../../utils/constants/enums.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../models/address_model.dart';

import 'cart_item_model.dart';

class BookingOrderModel {
  final String id;
  final String userId;
  final OrderStatus status;
  final double totalAmount;
  final DateTime orderDate;
  final String paymentMethod;
  final AddressModel? address;
  final DateTime? deliveryDate;
  final List<CartItemModel> booking;
  final List<PickedDateTimeModel> pickedDateTime;  // New property

  BookingOrderModel({
    required this.id,
    this.userId = '',
    required this.status,
    required this.totalAmount,
    required this.orderDate,
    this.paymentMethod = 'Paypal',
    this.address,
    this.deliveryDate,
    required List<PickedDateTimeModel> pickedDateTime, // Corrected initialization
    required this.booking,
  }) : this.pickedDateTime = pickedDateTime; // Assigning the parameter value to the property

  String get formattedOrderDate =>
      MyHelperFunctions.getFormattedDate(orderDate);

  String get formattedDeliveryDate => deliveryDate != null
      ? MyHelperFunctions.getFormattedDate(deliveryDate!)
      : '';

  String get orderStatusText => status == OrderStatus.delivered
      ? 'Delivered'
      : status == OrderStatus.shipped
      ? 'Shipment on the way'
      : 'Processing';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'status': status.toString(),
      'totalAmount': totalAmount,
      'orderDate': orderDate,
      'paymentMethod': paymentMethod,
      'address': address?.toJson(),
      'deliveryDate': deliveryDate,
      'booking': booking.map((item) => item.toJson()).toList(),
      'pickedDateTime': pickedDateTime.map((pickedDateTimeModel) => {
        'pickedDate': pickedDateTimeModel.pickedDate,
        'pickedTime': pickedDateTimeModel.pickedTime,
      }).toList(),
    };
  }

  factory BookingOrderModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return BookingOrderModel(
      id: data['id'] as String,
      userId: data['userId'] as String,
      status: OrderStatus.values
          .firstWhere((e) => e.toString() == data['status']),
      totalAmount: data['totalAmount'] as double,
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      paymentMethod: data['paymentMethod'] as String,
      address: AddressModel.fromMap(data['address'] as Map<String, dynamic>),
      deliveryDate: data['deliveryDate'] == null
          ? null
          : (data['deliveryDate'] as Timestamp).toDate(),
      booking: (data['booking'] as List<dynamic>)
          .map((item) => CartItemModel.fromJson(item))
          .toList(),
      pickedDateTime: (data['pickedDateTime'] as List<dynamic>).map((item) =>
          PickedDateTimeModel(
            pickedDate: (item['pickedDate'] as Timestamp).toDate(),
            pickedTime: (item['pickedTime'] as Timestamp).toDate(),
          )).toList(),
    );
  }
}
