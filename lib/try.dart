import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(tryApp());
}

// Static user representation
tryUser? currentUser;

class tryUser {
  final String name;
  tryUser({required this.name});
}

class tryApp extends StatelessWidget {
  tryApp({Key? key}) : super(key: key);

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Web App'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text('Menu'),
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
    setState(() {
      currentUser = tryUser(name: _usernameController.text);
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
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Enter Username',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Login'),
              onPressed: _login,
            ),
          ],
        ),
      ),
    );
  }
}
