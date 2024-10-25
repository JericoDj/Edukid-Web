  import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:webedukid/myapp.dart';
import 'package:webedukid/utils/local_storage/storage_utility.dart';


import 'common/data/repositories.authentication/authentication_repository.dart';
import 'features/screens/gamesscreen/games screen.dart';
import 'features/screens/homescreen/HomeScreen.dart';
import 'features/shop/screens/bookings/bookings.dart';
import 'features/shop/screens/order/order.dart'; // Import your repository

void main() async {







  WidgetsFlutterBinding.ensureInitialized();
  await MyStorageUtility.init('your_bucket_name');
  await GetStorage.init();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBD-r_wCSOBKdtpuEW6ZGl1CwOUSxBfjos',
      authDomain: 'edukid-60f55.firebaseapp.com',
      projectId: 'edukid-60f55',
      storageBucket: 'edukid-60f55.appspot.com',
      messagingSenderId: '884339429918',
      appId: '1:884339429918:web:df7be70dde1d59dae7140f',
      measurementId: 'G-5DDFG7W15J',
    ),
  ).then((FirebaseApp value) {
  }).catchError((error) {
    print("Firebase initialization error: $error");
  });

  runApp( MyApp());
}
