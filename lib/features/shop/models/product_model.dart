import 'package:cloud_firestore/cloud_firestore.dart';
import 'brand_model.dart';
import 'product_attribute_model.dart';
import 'product_variation_model.dart';

class ProductModel {
  String id;
  int stock;
  String? sku;
  double price;
  String title;
  DateTime? date;
  double salePrice;
  String thumbnail;
  bool? isFeatured;
  BrandModel? brand;
  String? description;
  String? categoryId;
  String? level; // Added 'level' field
  List<String>? images;
  String productType;
  List<ProductAttributeModel>? productAttributes;
  List<ProductVariationModel>? productVariations;

  ProductModel({
    required this.id,
    required this.title,
    required this.stock,
    required this.price,
    required this.thumbnail,
    required this.productType,
    this.sku,
    this.brand,
    this.date,
    this.images,
    this.salePrice = 0.0,
    this.isFeatured,
    this.categoryId,
    this.level, // Initialize 'level'
    this.description,
    this.productAttributes,
    this.productVariations,
  });

  static ProductModel empty() => ProductModel(
      id: '', title: '', stock: 0, price: 0, thumbnail: '', productType: '');

  toJson() {
    return {
      'SKU': sku,
      'Title': title,
      'Stock': stock,
      'Price': price,
      'Images': images ?? [],
      'Thumbnail': thumbnail,
      'SalePrice': salePrice,
      'IsFeatured': isFeatured,
      'CategoryId': categoryId,
      'Level': level, // Add 'level' to JSON map
      'Brand': brand!.toJson(),
      'Description': description,
      'ProductType': productType,
      'ProductAttributes': productAttributes != null
          ? productAttributes!.map((e) => e.toJson()).toList()
          : [],
      'ProductVariations': productVariations != null
          ? productVariations!.map((e) => e.toJson()).toList()
          : [],
    };
  }

  // Factory method for generating a product from Firestore data
  factory ProductModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() == null) return ProductModel.empty();
    final data = document.data()!;

    return ProductModel(
      id: document.id,
      sku: data['SKU'] as String?, // Use 'as String?' for better null safety
      title: data['Title'] as String? ?? '',
      stock: (data['Stock'] as int?) ?? 0,
      isFeatured: data['IsFeatured'] as bool? ?? false,
      price: (data['Price'] as num?)?.toDouble() ?? 0.0,
      salePrice: (data['SalePrice'] as num?)?.toDouble() ?? 0.0,
      thumbnail: data['Thumbnail'] as String? ?? '',
      categoryId: data['CategoryId'] as String? ?? '',
      level: data['Level'] as String?, // Added 'level' extraction
      description: data['Description'] as String? ?? '',
      productType: data['ProductType'] as String? ?? '',
      brand: BrandModel.fromJson(data['Brand']),
      images: data['Images'] != null ? List<String>.from(data['Images']) : [],
      productAttributes: (data['ProductAttributes'] as List<dynamic>?)
          ?.map((e) => ProductAttributeModel.fromJson(e))
          .toList() ?? [],
      productVariations: (data['ProductVariations'] as List<dynamic>?)
          ?.map((e) => ProductVariationModel.fromJson(e))
          .toList() ?? [],
    );
  }

  // Map Json oriented document snapshot from firebase model
  factory ProductModel.fromQuerySnapshot(
      QueryDocumentSnapshot<Object?> document) {
    final data = document.data() as Map<String, dynamic>;
    return ProductModel(
      id: document.id,
      sku: data['SKU'] ?? '',
      title: data['Title'] ?? '',
      stock: (data['Stock'] as int?) ?? 0,
      isFeatured: data['IsFeatured'] ?? false,
      price: (data['Price'] as num?)?.toDouble() ?? 0.0,
      salePrice: (data['SalePrice'] as num?)?.toDouble() ?? 0.0,
      thumbnail: data['Thumbnail'] ?? '',
      categoryId: data['CategoryId'] ?? '',
      level: data['Level'], // Add 'level' extraction here as well
      description: data['Description'] ?? '',
      productType: data['ProductType'] ?? '',
      brand: BrandModel.fromJson(data['Brand']),
      images: data['Images'] != null ? List<String>.from(data['Images']) : [],
      productAttributes: (data['ProductAttributes'] as List<dynamic>?)
          ?.map((e) => ProductAttributeModel.fromJson(e))
          .toList() ?? [],
      productVariations: (data['ProductVariations'] as List<dynamic>?)
          ?.map((e) => ProductVariationModel.fromJson(e))
          .toList() ?? [],
    );
  }
}
