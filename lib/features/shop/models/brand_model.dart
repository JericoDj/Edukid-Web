import 'package:cloud_firestore/cloud_firestore.dart';

class BrandModel {
  String id;
  String name;
  String image;
  int productsCount;
  bool isFeatured;

  BrandModel({
    required this.id,
    required this.name,
    required this.image,
    required this.productsCount,
    required this.isFeatured,
  });

  /// Empty helper function for clean code
  static BrandModel empty() => BrandModel(
    id: '',
    name: '',
    image: '',
    productsCount: 0,
    isFeatured: false,
  );

  /// Convert model to JSON structure
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'Image': image,
      'ProductsCount': productsCount,
      'IsFeatured': isFeatured,
    };
  }

  /// Map JSON-oriented data to BrandModel
  factory BrandModel.fromJson(Map<String, dynamic> data) {
    if (data.isEmpty) return BrandModel.empty();
    return BrandModel(
      id: data['Id'] ?? '',
      name: data['Name'] ?? '',
      image: data['Image'] ?? '',
      isFeatured: data['IsFeatured'] ?? false,
      productsCount: int.tryParse(data['ProductsCount'].toString()) ?? 0,
    );
  }

  /// Map document snapshot from Firebase to BrandModel
  factory BrandModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data != null) {
      return BrandModel(
        id: document.id,
        name: data['Name'] ?? '',
        image: data['Image'] ?? '',
        productsCount: int.tryParse(data['ProductsCount'].toString()) ?? 0,
        isFeatured: data['IsFeatured'] ?? false,
      );
    } else {
      return BrandModel.empty();
    }
  }
}
