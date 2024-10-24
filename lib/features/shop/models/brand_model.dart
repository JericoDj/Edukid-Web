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

  /// Empty helper function
  /// Empty constructor for clean code
  static BrandModel empty() => BrandModel(
        id: '',
        name: '',
        image: '',
        productsCount: 0,
        isFeatured: false,
      );

  /// Convert model to Json structure
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'Image': image,
      'ProductsCount': productsCount,
      'IsFeatured': isFeatured,
    };
  }

  /// Map Json oriented document snapshot from Firebase to UserModel
  factory BrandModel.fromJson(Map<String, dynamic> document) {
    final data = document;
    if (data.isEmpty) return BrandModel.empty();
    return BrandModel(
      id: data['Id'] ?? '',
      name: data['Name'] ?? '',
      image: data['Image'] ?? '',
      isFeatured: data['IsFeatured'] ?? false,
      productsCount: int.parse((data['ProductsCount'] ?? 0).toString()),
    );
  }

  /// Map Json oriented document snapshot from Firebase to UserModel
  factory BrandModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;

// Map JSON Record to the Model
      return BrandModel(
        id: document.id,
        name: data['Name'] ?? '',
        image: data['Image'] ?? '',
        productsCount: data['ProductsCount'] ?? '',
        isFeatured: data['IsFeatured'] ?? false,
      );
    } else {
      return BrandModel.empty();
    }
  }
}
