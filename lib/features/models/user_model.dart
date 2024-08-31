import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/formatters/formatter.dart';

class UserModel {
  // Keep those values final which you do not want to update
  final String id;
  String firstName;
  String lastName;
  final String username;
  final String email;
  String phoneNumber;
  String profilePicture;
  String gender;    // New field for gender
  String birthday;  // New field for birthday

  /// Constructor for UserModel.
  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.profilePicture,
    this.gender = '',    // Initialize gender with an empty string
    this.birthday = '',  // Initialize birthday with an empty string
  });

  /// Helper function to get the full name.
  String get fullName => '$firstName $lastName';

  /// Helper function to format phone number.
  String get formattedPhoneNo => MyFormatter.formatPhoneNumber(phoneNumber);

  /// Static function to split full name into first and last name.
  static List<String> nameParts(fullName) => fullName.split(" ");

  /// Static function to generate a username from the full name.
  static String generateUsername(fullName) {
    List<String> nameParts = fullName.split(" ");
    String firstName = nameParts[0].toLowerCase();
    String lastName = nameParts.length > 1 ? nameParts[1].toLowerCase() : "";

    String camelCaseUsername = "$firstName$lastName"; // Combine first and last name
    String usernameWithPrefix = "cwt_$camelCaseUsername"; // Add "cwt_" prefix
    return usernameWithPrefix;
  }

  /// Static function to create an empty user model.
  static UserModel empty() => UserModel(
    id: '',
    firstName: '',
    lastName: '',
    username: '',
    email: '',
    phoneNumber: '',
    profilePicture: '',
    gender: '',     // Initialize gender
    birthday: '',   // Initialize birthday
  );

  /// Convert model to JSON structure for storing data in Firebase.
  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'Username': username,
      'Email': email,
      'PhoneNumber': phoneNumber,
      'ProfilePicture': profilePicture,
      'Gender': gender,       // Include gender in JSON
      'Birthday': birthday,   // Include birthday in JSON
    };
  }

  /// Factory method to create a UserModel from a Firebase document snapshot.
  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return UserModel(
      id: document.id,
      firstName: data?['FirstName'] ?? '',
      lastName: data?['LastName'] ?? '',
      username: data?['Username'] ?? '',
      email: data?['Email'] ?? '',
      phoneNumber: data?['PhoneNumber'] ?? '',
      profilePicture: data?['ProfilePicture'] ?? '',
      gender: data?['Gender'] ?? '',       // Assign gender from data
      birthday: data?['Birthday'] ?? '',   // Assign birthday from data
    );
  }
}
