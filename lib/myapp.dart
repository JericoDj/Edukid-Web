import 'package:flutter/material.dart';
<<<<<<< HEAD
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
=======
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:webedukid/bindings/general_bindings.dart';
import 'package:webedukid/utils/constants/colors.dart';
>>>>>>> 8d9d7c4708cd91881283eb101aa12a4d80b10623

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    Get.lazyPut(()=>NavigationController());
    return GetMaterialApp(

=======
    return GetMaterialApp(
>>>>>>> 8d9d7c4708cd91881283eb101aa12a4d80b10623
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      initialBinding: GeneralBindings(),

<<<<<<< HEAD
      // Define the initial route
      initialRoute: '/home',

      // Define named routes using getPages
      getPages: [
        GetPage(name: '/navigation', page: () => NavigationBarMenu()),
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/anotherScreen', page: () => AnotherScreen()),
        // Add more pages here as needed
      ],

=======
>>>>>>> 8d9d7c4708cd91881283eb101aa12a4d80b10623
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
<<<<<<< HEAD

      // Optionally, define a fallback or home page (used when no route is found)
      home: const Scaffold(
        backgroundColor: MyColors.primaryColor,
        body: Center(
          child: CircularProgressIndicator(color: MyColors.white),
        ),
      ),
=======
      home: const Scaffold(backgroundColor: MyColors.primaryColor,
          body:  Center(child: CircularProgressIndicator(color: MyColors.white,),)),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
>>>>>>> 8d9d7c4708cd91881283eb101aa12a4d80b10623
    );
  }
}
