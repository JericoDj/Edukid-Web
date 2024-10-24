import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:webedukid/bindings/general_bindings.dart';
import 'package:webedukid/navigation_Bar.dart';
import 'package:webedukid/utils/constants/colors.dart';
import 'package:webedukid/features/screens/homescreen/HomeScreen.dart';

import 'features/bookings/status/processing_dialog.dart';
import 'features/screens/navigation_controller.dart'; // Example page

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    Get.lazyPut(()=>NavigationController());
    return GetMaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      initialBinding: GeneralBindings(),

      // Define the initial route
      initialRoute: '/home',

      // Define named routes using getPages
      getPages: [
        GetPage(name: '/navigation', page: () => NavigationBarMenu()),
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/anotherScreen', page: () => AnotherScreen()),
        // Add more pages here as needed
      ],

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      // Optionally, define a fallback or home page (used when no route is found)
      home: const Scaffold(
        backgroundColor: MyColors.primaryColor,
        body: Center(
          child: CircularProgressIndicator(color: MyColors.white),
        ),
      ),
    );
  }
}
