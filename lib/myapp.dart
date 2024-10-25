import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:webedukid/features/authentication/login/login.dart';
import 'package:webedukid/features/authentication/password_configuration/forget_password.dart';
import 'package:webedukid/features/screens/personalization/screens/address/address.dart';
import 'package:webedukid/features/screens/signup/widgets/signup.dart';
import 'package:webedukid/features/shop/cart/cart.dart';
import 'package:webedukid/features/shop/screens/account_privacy/account_privacy_screen.dart';
import 'package:webedukid/features/shop/screens/bookings/booking_session.dart';
import 'package:webedukid/features/shop/screens/coupons/coupons_screen.dart';
import 'package:webedukid/features/shop/screens/wishlist/wishlist.dart';
import 'package:webedukid/navigation_Bar.dart';
import 'package:webedukid/utils/constants/colors.dart';

import 'features/screens/gamesscreen/games screen.dart';
import 'features/screens/homescreen/HomeScreen.dart';
import 'features/screens/navigation_controller.dart';
import 'features/screens/profilescreen/settings.dart';
import 'features/shop/controller/category_controller.dart';
import 'features/shop/controller/product/cart_controller.dart';
import 'features/shop/controller/product/variation_controller.dart';
import 'features/shop/screens/order/all_orders_screen.dart';
import 'features/shop/screens/store/store.dart';
import 'features/shop/screens/bookings/bookings.dart';
import 'features/shop/screens/order/order.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

bool _isEditProfileDrawerOpen = false; // State for the profile drawer

// Function to toggle the edit profile drawer
void toggleEditProfileDrawer() {
  setState(() {
    _isEditProfileDrawerOpen = !_isEditProfileDrawerOpen;
  });
}

void setState(Null Function() param0) {}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // Initialize controllers with Get.lazyPut
    Get.lazyPut(() => VariationController());
    Get.lazyPut(() => CartController());
    Get.lazyPut(() => CategoryController());
    Get.lazyPut(() => NavigationController());

    // Define the GoRouter with a ShellRoute to keep NavigationBarMenu persistent
    final GoRouter router = GoRouter(
      initialLocation: '/home', // Start at home page
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return Scaffold(
              appBar: NavigationBarMenu(), // Persistent NavigationBarMenu
              endDrawerEnableOpenDragGesture: true,

              endDrawer: Drawer(
                shape: RoundedRectangleBorder(
                  // Customize the drawer shape
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: SettingsScreen(
                  isOpen: true,
                  // Keep the settings screen open when drawer is opened
                  onClose: () => Navigator.of(context).pop(),
                  // Close the drawer
                  onEditProfile: toggleEditProfileDrawer,
                  onUserAddress: () => context.go('/userAddress'),
                  onCart: () => context.go('/cart'),
                  onOrder: () => context.go('/allOrders'),
                  onWishlist: () => context.go('/wishlist'),
                  onCoupon: () => context.go('/coupon'),
                  onAccountPrivacy: () => context.go('/accountPrivacy'),
                ),
              ),

              body: child, // Render the routed screen here
            );
          },
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => HomeScreen(),
            ),
            GoRoute(
              path: '/store',
              builder: (context, state) => const StoreScreen(),
            ),
            GoRoute(
              path: '/bookings',
              builder: (context, state) => const BookingsScreen(),
            ),
            GoRoute(
              path: '/order',
              builder: (context, state) => OrderScreen(isInteractive: true),
            ),
            GoRoute(
              path: '/games',
              builder: (context, state) => const GamesScreen(),
            ),
            GoRoute(
              path: '/cart',
              builder: (context, state) => CartScreen(),
            ),
            GoRoute(
              path: '/login',
              builder: (context, state) => LoginScreen(),
            ),
            GoRoute(
              path: '/register',
              builder: (context, state) => SignUpScreen(),
            ),
            GoRoute(
                path: '/forgotPassword',
                builder: (context, state) => ForgetPasswordScreen()),

            GoRoute(
              path: '/userAddress',
              builder: (context, state) => UserAddressScreen(),
            ),
            GoRoute(
              path: '/allOrders',
              builder: (context, state) => AllOrdersScreen(isInteractive: true),
            ),
            GoRoute(
              path: '/wishlist',
              builder: (context, state) => WishlistScreen(),
            ),
            GoRoute(
              path: '/coupon',
              builder: (context, state) => CouponScreen(),
            ),
            GoRoute(
              path: '/accountPrivacy',
              builder: (context, state) => AccountPrivacyScreen(),
            ),
            GoRoute(
              path: '/bookSession',
              builder: (context, state) => BookingSessionScreen(),
            ),
            // Add other routes as needed
          ],
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router, // Use the GoRouter configuration
    );
  }
}
