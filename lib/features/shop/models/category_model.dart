import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  String id;
  String name;
  String imagePath; // Update field name to store Firebase Storage path
  String parentId;

  bool isFeatured;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.isFeatured,
    this.parentId = '',
  });

  static CategoryModel empty() => CategoryModel(id: '', imagePath: '', name: '', isFeatured: false);

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'ImagePath': imagePath,
      'ParentId': parentId,
      'IsFeatured': isFeatured,
    };
  }

  factory CategoryModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return CategoryModel(
        id: document.id,
        name: data['Name'] ?? '',
        imagePath: data['ImagePath'] ?? '',
        parentId: data['ParentId'] ?? '',
        isFeatured: data['IsFeatured'] ?? false,
      );
    } else {
      return CategoryModel.empty();
    }
  }
}
