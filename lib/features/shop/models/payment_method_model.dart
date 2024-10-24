
import 'package:square_in_app_payments/models.dart';

class PaymentMethodModel {
  final String name;
  final String image;
  final String? nonce; // Field to store the card nonce
  final CardDetails? cardDetails; // Field to store card details

  PaymentMethodModel({
    required this.name,
    required this.image,
    this.nonce,
    this.cardDetails, // Include this field in the constructor
  });

  factory PaymentMethodModel.empty() {
    return PaymentMethodModel(name: '', image: '', nonce: null, cardDetails: null);
  }
}
