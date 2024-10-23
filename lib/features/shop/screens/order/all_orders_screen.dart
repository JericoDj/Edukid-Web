import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:webedukid/features/shop/screens/order/widgets/ticket_clipper.dart';
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
    allOrdersFuture =
        _fetchAllOrders(); // Fetch the orders and bookings on init
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
        backgroundColor: isSelected ? Colors.transparent : Colors.transparent,
        elevation: 0,
        // Remove button shadow
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? Colors.yellowAccent : Colors.white,
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

  // Fetch all orders and bookings from Firebase and sort by orderDate
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

    // Sort the combined list by 'orderDate' (convert Timestamp to DateTime for comparison)
    allData.sort((a, b) {
      Timestamp? orderDateA = a['data']['orderDate'] as Timestamp?;
      Timestamp? orderDateB = b['data']['orderDate'] as Timestamp?;

      if (orderDateA != null && orderDateB != null) {
        return orderDateB.toDate().compareTo(
            orderDateA.toDate()); // Newest orders first
      } else if (orderDateA != null) {
        return -1; // If 'orderDate' is null in one, put the other first
      } else if (orderDateB != null) {
        return 1; // If 'orderDate' is null in one, put the other first
      } else {
        return 0; // Both have null orderDate
      }
    });

    return allData;
  }

  // Placeholder for body content based on selected category
  Widget _buildBodyContent() {
    if (selectedCategory == 'All Orders') {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: allOrdersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show circular progress indicator while waiting for data
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

                return GestureDetector(
                  onTap: () {
                    if (type == 'Booking') {
                      _showBookingDetailsPopup(context, data);
                    } else if (type == 'Order') {
                      _showOrderDetailsPopup(context, data);
                    }
                  },
                  child: type == 'Booking'
                      ? _buildBookingCard(type, data)
                      : _buildOrderCard(type, data),
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
                onTap: () => _showBookingDetailsPopup(context, booking),
                child: _buildBookingCard('Booking', booking),
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
                onTap: () => _showOrderDetailsPopup(context, order),
                child: _buildOrderCard('Order', order),
              );
            },
          );
        },
      );
    }
  }

  Widget _buildBookingCard(String type, Map<String, dynamic> data) {
    // Use the 'orderDate' field for bookings
    String orderDate = (data['orderDate'] != null)
        ? DateFormat.yMMMd().format((data['orderDate'] as Timestamp).toDate())
        : 'No Date';

    // For bookings, extract 'pickedDateTime' and show it as a subtitle
    String pickedDates = '';
    if (type == 'Booking' && data.containsKey('pickedDateTime')) {
      List<dynamic> pickedDateTime = data['pickedDateTime'];
      pickedDates = pickedDateTime.map((timeSlot) {
        return DateFormat.yMMMd().format(
            (timeSlot['pickedDate'] as Timestamp).toDate());
      }).join(', ');
    }

    // Use the 'id' as the title instead of a specific title field
    String id = data['id'] ?? 'No ID'; // Fallback if no ID exists

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 500.0),
      child: ClipPath(
        clipper: TicketClipper(), // Custom Clipper for the ticket shape
        child: Container(
          decoration: BoxDecoration(
            color: MyColors.primaryColor, // Educational theme with blue color
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3), // Shadow position
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(50.0, 20.0, 30.0, 20.0),
            // Adjusted padding for more space inside the ticket
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              // Centering icon vertically
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display the 'id' as the title for Bookings
                      Text(
                        'Booking ID: $id', // Use id for bookings
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: MyColors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      // Additional space between lines

                      // Subtitle: For bookings, show picked dates
                      if (pickedDates.isNotEmpty)
                        Text(
                          'Picked Dates: $pickedDates',
                          // Show picked dates as subtitle for bookings
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.yellowAccent,
                          ),
                        ),

                      // Subtitle: Show the order date as a separate line
                      Text(
                        'Order Date: $orderDate',
                        // Show order date for bookings
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.yellowAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.school, size: 40, color: MyColors.white),
                // Centered school icon for educational theme
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(String type, Map<String, dynamic> data) {
    // Use the 'orderDate' field for Orders
    String orderDate = (data['orderDate'] != null)
        ? DateFormat.yMMMd().format((data['orderDate'] as Timestamp).toDate())
        : 'No Date';

    // Extract relevant information for orders
    String id = data['id'] ?? 'No ID'; // Use id for orders
    double totalAmount = data['totalAmount'] ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 500.0),
      child: ClipPath(
        clipper: TicketClipper(), // Custom Clipper for the ticket shape
        child: Container(
          decoration: BoxDecoration(
            color: MyColors.primaryColor, // Educational theme with blue color
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3), // Shadow position
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(50.0, 20.0, 30.0, 20.0),
            // Adjusted padding for more space inside the ticket
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              // Centering icon vertically
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display only the ID for Orders
                      Text(
                        'Order ID: $id', // Use ID as the title for orders
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: MyColors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      // Additional space between lines

                      // Subtitle: Show the order date
                      Text(
                        'Order Date: $orderDate',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.yellowAccent,
                        ),
                      ),
                      SizedBox(height: 5),

                      // Subtitle: Show the total amount for orders
                      Text(
                        'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.yellowAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.shopping_cart, size: 40, color: MyColors.white),
                // Shopping cart icon for orders
              ],
            ),
          ),
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

  // Create a method to map raw status to readable status text
  String _mapStatusToReadableText(String rawStatus) {
    switch (rawStatus) {
      case 'OrderStatus.processing':
        return 'Processing';
      case 'OrderStatus.scheduled':
        return 'Scheduled';
      case 'OrderStatus.ongoing':
        return 'Ongoing';
      case 'OrderStatus.completed':
        return 'Completed';
      case 'OrderStatus.rescheduled':
        return 'Rescheduled';
      case 'OrderStatus.cancelled':
        return 'Cancelled';
      default:
        return 'Unknown Status'; // In case there is an unknown status
    }
  }

  void _showBookingDetailsPopup(BuildContext context,
      Map<String, dynamic> data) {
    // Extract pickedDate and pickedTime if they exist (for bookings)
    List<dynamic>? pickedDateTime = data['pickedDateTime'];

    // Use the 'id' in the details popup
    String id = data['id'] ?? 'No ID'; // Fallback if no ID exists

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Booking Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: MyColors.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display the ID for bookings with selectable and copyable functionality
                  Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          'Booking ID: $id', // Make ID selectable and copyable
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: MyColors.darkerGrey,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy, color: MyColors.darkerGrey),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(
                                'Booking ID copied to clipboard')),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // Display the order date for bookings
                  Text(
                    'Order Date: ${(data['orderDate'] != null)
                        ? DateFormat.yMMMd().format(
                        (data['orderDate'] as Timestamp).toDate())
                        : "No Date"}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),

                  if (pickedDateTime != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Picked Dates and Times:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: MyColors.primaryColor,
                          ),
                        ),
                        SizedBox(height: 5),
                        for (var timeSlot in pickedDateTime)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0,
                                bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Picked Date: ${DateFormat.yMMMd().format(
                                      (timeSlot['pickedDate'] as Timestamp)
                                          .toDate())}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  'Picked Time: ${DateFormat.jm().format(
                                      (timeSlot['pickedTime'] as Timestamp)
                                          .toDate())}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                  if (data.containsKey('status'))
                    Text(
                      'Status: ${_mapStatusToReadableText(data['status'])}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: MyColors.primaryColor,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showOrderDetailsPopup(BuildContext context, Map<String, dynamic> data) {
    // Extract Order ID and Items from the order data
    String id = data['id'] ?? 'No ID'; // Fallback if no ID exists
    List<dynamic>? items = data['items']; // Fetch items array if it exists

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Order Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: MyColors.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display the ID with selectable and copyable functionality
                  Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          'Order ID: $id', // Make ID selectable and copyable
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: MyColors.darkerGrey,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy, color: MyColors.darkerGrey),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Order ID copied to clipboard')),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // Display the order date
                  Text(
                    'Order Date: ${(data['orderDate'] != null)
                        ? DateFormat.yMMMd().format(
                        (data['orderDate'] as Timestamp).toDate())
                        : "No Date"}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Display the total amount if it exists
                  if (data.containsKey('totalAmount'))
                    Text(
                      'Total Amount: \$${data['totalAmount']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  SizedBox(height: 10),

                  // Display items if the 'items' array exists
                  if (items != null && items.isNotEmpty) ...[
                    Text(
                      'Items:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: MyColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: 5),

                    // Loop through each item in the array and display the title, chapter, and part
                    for (var item in items) Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display the title of the item
                          if (item.containsKey('title'))
                            Text(
                              'Title: ${item['title']}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black54,
                              ),
                            ),

                          // Display the 'Chapter' and 'Part' from 'selectedVariation' if it exists
                          if (item.containsKey('selectedVariation') &&
                              item['selectedVariation'] != null) ...[
                            if (item['selectedVariation'].containsKey(
                                'Chapter'))
                              Text(
                                'Chapter: ${item['selectedVariation']['Chapter']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black54,
                                ),
                              ),
                            if (item['selectedVariation'].containsKey('Part'))
                              Text(
                                'Part: ${item['selectedVariation']['Part']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black54,
                                ),
                              ),
                          ]
                        ],
                      ),
                    ),
                  ] else
                    Text(
                      'No items available for this order.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: MyColors.primaryColor,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}