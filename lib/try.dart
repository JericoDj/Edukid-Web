import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(TryApp());
}

// Static user representation
TryUser? currentUser;

class TryUser {
  final String name;
  TryUser({required this.name});
}

class TryApp extends StatelessWidget {
  TryApp({Key? key}) : super(key: key);

  // Define the GoRouter
  final GoRouter _router = GoRouter(
    routes: [
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => HomeScreen(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => LoginScreen(),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Web App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
    );
  }
}

// AppShell widget with AppBar and Drawer
class AppShell extends StatefulWidget {
  final Widget child;

  AppShell({required this.child});

  @override
  _AppShellState createState() => _AppShellState();
}

// AppShell state
class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // To control the drawer

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the scaffold key
      appBar: AppBar(
        title: Text('Flutter Web App'),
        backgroundColor: Colors.blue, // Set AppBar color to blue
        iconTheme: IconThemeData(color: Colors.white), // Set icon color to white
        actions: [
          IconButton(
            icon: Icon(Icons.menu_book), // Use any icon you prefer
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer(); // Open the drawer
            },
          ),
        ],
      ),
      drawer: Container(
        margin: EdgeInsets.only(top: kToolbarHeight), // Ensure Drawer starts below the AppBar
        child: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              currentUser == null
                  ? ListTile(
                leading: Icon(Icons.login),
                title: Text('Login'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  context.go('/login');
                },
              )
                  : ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () {
                  setState(() {
                    currentUser = null;
                  });
                  Navigator.pop(context); // Close the drawer
                  context.go('/');
                },
              ),
            ],
          ),
        ),
      ),
      body: widget.child,
    );
  }
}

// HomeScreen widget
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        currentUser == null
            ? 'Welcome, Guest!'
            : 'Welcome, ${currentUser!.name}!',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

// LoginScreen widget
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

// LoginScreen state with a simple login form
class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();

  void _login() {
    if (_usernameController.text.trim().isEmpty) {
      // Simple validation to prevent empty usernames
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a username')),
      );
      return;
    }

    setState(() {
      currentUser = TryUser(name: _usernameController.text.trim());
    });
    context.go('/'); // Navigate back to home after login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove AppBar here as it's provided by the AppShell
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center the form vertically
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Enter Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Login'),
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
