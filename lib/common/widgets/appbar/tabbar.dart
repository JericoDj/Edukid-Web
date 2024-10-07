import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/device/device_utitility.dart';
import '../../../utils/helpers/helper_functions.dart';

class MyTabBar extends StatelessWidget implements PreferredSizeWidget {
  /// The tabs are dynamically created from Firestore data.
  const MyTabBar({super.key, required this.tabs, required this.controller});

  final List<Widget> tabs;
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final dark = MyHelperFunctions.isDarkMode(context);
    return Material(
      color: dark ? MyColors.black : MyColors.white,
      child: TabBar(
        tabAlignment: TabAlignment.center,
        controller: controller,
        tabs: tabs,
        isScrollable: true,
        indicatorColor: MyColors.primaryColor,
        labelColor: dark ? MyColors.white : MyColors.primaryColor,
        unselectedLabelColor: MyColors.darkGrey,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(MyDeviceUtils.getAppBarheight());
}

class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<String> categories = []; // Store the categories fetched from Firestore
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories(); // Fetch categories from Firestore
  }

  /// Fetch category names from Firestore (Categories collection)
  Future<void> fetchCategories() async {
    try {
      // Fetch the categories collection
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Categories').get();

      // Extract the category names from the documents
      List<String> categoryNames = snapshot.docs.map((doc) => doc['Name'] as String).toList();

      setState(() {
        categories = categoryNames;
        isLoading = false;

        // Initialize the TabController after fetching categories
        _tabController = TabController(length: categories.length, vsync: this);

        // Add a listener to print the selected category
        _tabController!.addListener(() {
          if (!_tabController!.indexIsChanging) {
            int selectedIndex = _tabController!.index;
            print('Selected Category: ${categories[selectedIndex]}');
          }
        });
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Store Screen"),
          bottom: MyTabBar(
            tabs: categories.map((category) => Tab(child: Text(category))).toList(),
            controller: _tabController!,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: categories.map((category) => Center(child: Text("Products for $category"))).toList(),
        ),
      ),
    );
  }
}
