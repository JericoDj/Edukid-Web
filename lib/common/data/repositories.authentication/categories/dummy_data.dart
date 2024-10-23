

import '../../../../features/shop/models/category_model.dart';
import '../../../../utils/constants/image_strings.dart';
class MyDummyData {

  static final List<CategoryModel> categories = [
  CategoryModel(id: '1', imagePath: MyImages.homeslider1, name: 'Grade 23', isFeatured: true),
  CategoryModel(id: '5', imagePath: MyImages.homeslider1, name: 'Grade 2', isFeatured: true),
  CategoryModel(id: '2', imagePath: MyImages.homeslider1, name: 'Grade 3', isFeatured: true),
  CategoryModel(id: '3', imagePath: MyImages.homeslider1, name: 'Grade 4', isFeatured: true),
  CategoryModel (id: '4', imagePath: MyImages.homeslider1, name: 'Grade 5', isFeatured: true),
  CategoryModel(id: '6', imagePath: MyImages.homeslider1, name: 'Grade 6', isFeatured: true),
  CategoryModel(id: '14', imagePath: MyImages.homeslider1, name: 'Grade 7', isFeatured: true),


    ///Beginner Worksheets
    CategoryModel(id: '8', imagePath: MyImages.homeslider2, name: 'Dummy Math', parentId: '1', isFeatured: false),
    CategoryModel(id: '9', imagePath: MyImages.homeslider2, name: 'Playful Math', parentId: '1', isFeatured: false),
    CategoryModel(id: '10', imagePath: MyImages.homeslider2, name: 'On The Go Math', parentId: '1', isFeatured: false),

    //Intermediate Worksheets
    CategoryModel(id: '11', imagePath: MyImages.homeslider2, name: 'Everyday Math', parentId: '5', isFeatured: false),
    CategoryModel(id: '12', imagePath: MyImages.homeslider2, name: 'Ready To School Math', parentId: '5', isFeatured: false),
    CategoryModel(id: '13', imagePath: MyImages.homeslider2, name: 'Assigning Math', parentId: '5', isFeatured: false),

    //Advanced Worksheets
    CategoryModel(id: '11', imagePath: MyImages.homeslider2, name: 'Algebra Math', parentId: '5', isFeatured: false),
    CategoryModel(id: '12', imagePath: MyImages.homeslider2, name: 'Competition Math', parentId: '5', isFeatured: false),
    CategoryModel(id: '13', imagePath: MyImages.homeslider2, name: 'Math Math Math', parentId: '5', isFeatured: false),


  ];





}