import 'package:flutter/material.dart';

void main() {
  runApp(WorksheetsShop());
}

class WorksheetsShop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Worksheets Shop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

// Models
class Book {
  final String id;
  final String title;
  final String author;
  final int level;
  final String description;
  final double price;
  final String imageUrl;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.level,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

// Sample Data
List<Book> featuredBooks = [
  Book(
    id: '1',
    title: 'Singapore Math Level 1',
    author: 'Author A',
    level: 1,
    description: 'An introductory book for Level 1 students.',
    price: 9.99,
    imageUrl: 'https://via.placeholder.com/150',
  ),
  Book(
    id: '2',
    title: 'Singapore Math Level 2',
    author: 'Author B',
    level: 2,
    description: 'A comprehensive guide for Level 2 students.',
    price: 12.99,
    imageUrl: 'https://via.placeholder.com/150',
  ),
  // Add more books as needed
];

// Home Screen
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Worksheets Shop'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search eBooks',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // Featured Books Carousel
          Container(
            height: 200.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: featuredBooks.length,
              itemBuilder: (context, index) {
                return FeaturedBookCard(book: featuredBooks[index]);
              },
            ),
          ),
          // Categories
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: List.generate(6, (index) {
                return CategoryCard(level: index + 1);
              }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}

// Featured Book Card
class FeaturedBookCard extends StatelessWidget {
  final Book book;

  FeaturedBookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to eBook Detail Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EbookDetailScreen(book: book),
          ),
        );
      },
      child: Container(
        width: 150.0,
        margin: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Image.network(book.imageUrl, height: 100.0),
            SizedBox(height: 8.0),
            Text(
              book.title,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Category Card
class CategoryCard extends StatelessWidget {
  final int level;

  CategoryCard({required this.level});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          // Navigate to Category Screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryScreen(level: level),
            ),
          );
        },
        child: Center(
          child: Text(
            'Level $level',
            style: TextStyle(fontSize: 24.0),
          ),
        ),
      ),
    );
  }
}

// Bottom Navigation Bar
class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0, // Set the current index
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Categories',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        // Handle navigation
      },
    );
  }
}

// App Drawer (Optional)
class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Text('Worksheets Shop'),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text('Help'),
            onTap: () {},
          ),
          ListTile(
            title: Text('Contact Us'),
            onTap: () {},
          ),
          ListTile(
            title: Text('Settings'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// eBook Detail Screen
class EbookDetailScreen extends StatelessWidget {
  final Book book;

  EbookDetailScreen({required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(book.imageUrl, height: 200.0), // eBook Cover Image
            SizedBox(height: 16.0),
            Text(
              book.title,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            Text('by ${book.author}'),
            SizedBox(height: 16.0),
            Text('\$${book.price.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 20.0, color: Colors.green)),
            SizedBox(height: 16.0),
            Text(book.description),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Add to Cart functionality
                    },
                    child: Text('Add to Cart'),
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Buy Now functionality
                    },
                    child: Text('Buy Now'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Category Screen
class CategoryScreen extends StatelessWidget {
  final int level;

  CategoryScreen({required this.level});

  @override
  Widget build(BuildContext context) {
    // Filter books by level
    List<Book> levelBooks =
    featuredBooks.where((book) => book.level == level).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Level $level Books'),
      ),
      body: ListView.builder(
        itemCount: levelBooks.length,
        itemBuilder: (context, index) {
          Book book = levelBooks[index];
          return ListTile(
            leading: Image.network(book.imageUrl),
            title: Text(book.title),
            subtitle: Text('by ${book.author}'),
            trailing: Text('\$${book.price.toStringAsFixed(2)}'),
            onTap: () {
              // Navigate to eBook Detail Screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EbookDetailScreen(book: book),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
