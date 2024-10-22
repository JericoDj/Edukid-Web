import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:webedukid/utils/constants/colors.dart';

class AllOrdersScreen extends StatefulWidget {
  final bool isInteractive;

  AllOrdersScreen({required this.isInteractive});

  @override
  _AllOrdersScreenState createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  String selectedCategory = 'All Orders'; // Default category
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Future<List<Map<String, dynamic>>> allOrdersFuture;

  @override
  void initState() {
    super.initState();
    allOrdersFuture = _fetchAllOrders(); // Fetch the orders and bookings on init
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.primaryColor,
        centerTitle: true,
        title: _buildCategoryButtons(), // Buttons in the AppBar
      ),
      body: Column(
        children: [
          SizedBox(height: 20), // Add space below the AppBar
          Expanded(
            child: _buildBodyContent(), // Body content displaying orders
          ),
        ],
      ),
    );
  }

  // Method to build the buttons inside the AppBar
  Widget _buildCategoryButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCategoryButton('All Orders'),
        SizedBox(width: 10),
        _buildCategoryButton('Bookings'),
        SizedBox(width: 10),
        _buildCategoryButton('Orders'),
      ],
    );
  }

  // Method to create individual category buttons
  Widget _buildCategoryButton(String category) {
    bool isSelected = selectedCategory == category;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedCategory = category; // Update selected category
        });
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: isSelected ? Colors.yellowAccent : Colors.white,
        backgroundColor: isSelected ? Colors.transparent : Colors.transparent, // Text color
        elevation: 0, // Remove button shadow
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? Colors.yellowAccent : Colors.white, // Border color
            width: 2, // Border width
          ),
        ),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Fetch all orders and bookings from Firebase
  Future<List<Map<String, dynamic>>> _fetchAllOrders() async {
    String uid = _auth.currentUser!.uid;

    // Fetch Bookings
    QuerySnapshot bookingsSnapshot = await _firestore
        .collection('Users')
        .doc(uid)
        .collection('Bookings')
        .get();

    // Fetch Orders
    QuerySnapshot ordersSnapshot = await _firestore
        .collection('Users')
        .doc(uid)
        .collection('Orders')
        .get();

    // Combine both Bookings and Orders
    List<Map<String, dynamic>> allData = [];

    // Add Bookings to the list
    for (var doc in bookingsSnapshot.docs) {
      allData.add({
        'type': 'Booking',
        'data': doc.data(),
      });
    }

    // Add Orders to the list
    for (var doc in ordersSnapshot.docs) {
      allData.add({
        'type': 'Order',
        'data': doc.data(),
      });
    }

    return allData;
  }

  // Placeholder for body content based on selected category
  Widget _buildBodyContent() {
    if (selectedCategory == 'All Orders') {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: allOrdersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Orders or Bookings found'));
          }

          // Display All Orders and Bookings
          List<Map<String, dynamic>> allOrders = snapshot.data!;

          return SingleChildScrollView(
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: allOrders.length,
              itemBuilder: (context, index) {
                var order = allOrders[index];
                var type = order['type']; // 'Booking' or 'Order'
                var data = order['data']; // The document data

                // Use the 'orderDate' field
                String orderDate = (data['orderDate'] != null)
                    ? DateFormat.yMMMd().format((data['orderDate'] as Timestamp).toDate())
                    : 'No Date';

                return GestureDetector(
                  onTap: () => _showDetailsPopup(context, type, data),
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$type - ${data['title'] ?? "No Title"}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Order Date: $orderDate',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    } else if (selectedCategory == 'Bookings') {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchBookings(), // Fetch only bookings
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Bookings found'));
          }

          // Display only Bookings
          List<Map<String, dynamic>> bookings = snapshot.data!;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              var booking = bookings[index];

              return GestureDetector(
                onTap: () => _showDetailsPopup(context, 'Booking', booking),
                child: _buildOrderCard('Booking', booking),
              );
            },
          );
        },
      );
    } else {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchOrders(), // Fetch only orders
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Orders found'));
          }

          // Display only Orders
          List<Map<String, dynamic>> orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];

              return GestureDetector(
                onTap: () => _showDetailsPopup(context, 'Order', order),
                child: _buildOrderCard('Order', order),
              );
            },
          );
        },
      );
    }
  }

  // Method to build each order card
  Widget _buildOrderCard(String type, Map<String, dynamic> data) {
    // Use the 'orderDate' field
    String orderDate = (data['orderDate'] != null)
        ? DateFormat.yMMMd().format((data['orderDate'] as Timestamp).toDate())
        : 'No Date';

    return Card(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        child: Padding(
        padding: const EdgeInsets.all(12.0),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    '$type - ${data['title'] ?? "No Title"}',
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    ),
    ),

      SizedBox(height: 5),
      Text(
        'Order Date: $orderDate',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
      ],
    ),
    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    ],
    ),
    ),
    );
  }

  // Method to fetch only bookings
  Future<List<Map<String, dynamic>>> _fetchBookings() async {
    String uid = _auth.currentUser!.uid;

    QuerySnapshot bookingsSnapshot = await _firestore
        .collection('Users')
        .doc(uid)
        .collection('Bookings')
        .get();

    List<Map<String, dynamic>> bookings = [];

    for (var doc in bookingsSnapshot.docs) {
      bookings.add(doc.data() as Map<String, dynamic>);
    }

    return bookings;
  }

  // Method to fetch only orders
  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    String uid = _auth.currentUser!.uid;

    QuerySnapshot ordersSnapshot = await _firestore
        .collection('Users')
        .doc(uid)
        .collection('Orders')
        .get();

    List<Map<String, dynamic>> orders = [];

    for (var doc in ordersSnapshot.docs) {
      orders.add(doc.data() as Map<String, dynamic>);
    }

    return orders;
  }

  // Method to display detailed popup of the selected order/booking
  void _showDetailsPopup(BuildContext context, String type, Map<String, dynamic> data) {
    // Extract pickedDate and pickedTime if they exist (for bookings)
    List<dynamic>? pickedDateTime = data['pickedDateTime'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$type Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Title: ${data['title'] ?? "No Title"}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('Order Date: ${(data['orderDate'] != null) ? DateFormat.yMMMd().format((data['orderDate'] as Timestamp).toDate()) : "No Date"}'),
                SizedBox(height: 10),
                if (data.containsKey('totalAmount'))
                  Text('Total Amount: \$${data['totalAmount']}'),
                SizedBox(height: 10),
                if (pickedDateTime != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Picked Dates and Times:'),
                      SizedBox(height: 5),
                      for (var timeSlot in pickedDateTime)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Picked Date: ${DateFormat.yMMMd().format((timeSlot['pickedDate'] as Timestamp).toDate())}'),
                              Text('Picked Time: ${DateFormat.jm().format((timeSlot['pickedTime'] as Timestamp).toDate())}'),
                              SizedBox(height: 5),
                            ],
                          ),
                        ),
                    ],
                  ),
                if (data.containsKey('status'))
                  Text('Status: ${data['status']}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
