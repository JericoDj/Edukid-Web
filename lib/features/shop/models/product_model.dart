import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webedukid/features/shop/models/product_attribute_model.dart';
import 'package:webedukid/features/shop/models/product_variation_model.dart';

import 'brand_model.dart';

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
  String? level;
  String? chapter; // Added 'chapter' field
  String? part;    // Added 'part' field
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
    this.level,
    this.chapter, // Initialize 'chapter'
    this.part,    // Initialize 'part'
    this.description,
    this.productAttributes,
    this.productVariations,
  });


  // Static method to create an empty ProductModel
  static ProductModel empty() => ProductModel(
    id: '',
    title: '',
    stock: 0,
    price: 0.0,
    thumbnail: '',
    productType: '',
  );

  // toJson method with added fields
  Map<String, dynamic> toJson() {
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
      'Level': level,
      'Chapter': chapter, // Include 'chapter' field
      'Part': part,       // Include 'part' field
      'Brand': brand?.toJson(),
      'Description': description,
      'ProductType': productType,
      'ProductAttributes': productAttributes?.map((e) => e.toJson()).toList() ?? [],
      'ProductVariations': productVariations?.map((e) => e.toJson()).toList() ?? [],
    };
  }

  // fromSnapshot method with added fields
  factory ProductModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() == null) return ProductModel.empty();
    final data = document.data()!;

    return ProductModel(
      id: document.id,
      sku: data['SKU'] as String?,
      title: data['Title'] as String? ?? '',
      stock: data['Stock'] as int? ?? 0,
      isFeatured: data['IsFeatured'] as bool? ?? false,
      price: (data['Price'] as num?)?.toDouble() ?? 0.0,
      salePrice: (data['SalePrice'] as num?)?.toDouble() ?? 0.0,
      thumbnail: data['Thumbnail'] as String? ?? '',
      categoryId: data['CategoryId'] as String?,
      level: data['Level'] as String?,
      chapter: data['Chapter'] as String?, // Extract 'chapter'
      part: data['Part'] as String?,       // Extract 'part'
      description: data['Description'] as String?,
      productType: data['ProductType'] as String? ?? '',
      brand: data['Brand'] != null ? BrandModel.fromJson(data['Brand']) : null,
      images: data['Images'] != null ? List<String>.from(data['Images']) : [],
      productAttributes: (data['ProductAttributes'] as List<dynamic>?)
          ?.map((e) => ProductAttributeModel.fromJson(e))
          .toList() ?? [],
      productVariations: (data['ProductVariations'] as List<dynamic>?)
          ?.map((e) => ProductVariationModel.fromJson(e))
          .toList() ?? [],
    );
  }

  // fromQuerySnapshot method with added fields
  factory ProductModel.fromQuerySnapshot(QueryDocumentSnapshot<Object?> document) {
    final data = document.data() as Map<String, dynamic>;

    return ProductModel(
      id: document.id,
      sku: data['SKU'],
      title: data['Title'] ?? '',
      stock: data['Stock'] ?? 0,
      isFeatured: data['IsFeatured'] ?? false,
      price: (data['Price'] as num?)?.toDouble() ?? 0.0,
      salePrice: (data['SalePrice'] as num?)?.toDouble() ?? 0.0,
      thumbnail: data['Thumbnail'] ?? '',
      categoryId: data['CategoryId'] ?? '',
      level: data['Level'],
      chapter: data['Chapter'], // Add 'chapter' extraction
      part: data['Part'],       // Add 'part' extraction
      description: data['Description'] ?? '',
      productType: data['ProductType'] ?? '',
      brand: data['Brand'] != null ? BrandModel.fromJson(data['Brand']) : null,
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
