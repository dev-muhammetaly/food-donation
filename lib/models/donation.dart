// different stages of a food donation
enum DonationStatus { available, requested, reserved, collected, expired }

// Adds extra functionality to DonationStatus.
extension DonationStatusText on DonationStatus {
  String get label {
    switch (this) {
      case DonationStatus.available:
        return 'Available';
      case DonationStatus.requested:
        return 'Requested';
      case DonationStatus.reserved:
        return 'Reserved';
      case DonationStatus.collected:
        return 'Collected';
      case DonationStatus.expired:
        return 'Expired';
    }
  }
}

class Donation {
  // creating a donation object with all the required fields as shown bellow
  const Donation({
    required this.id,
    required this.donorId,
    required this.foodName,
    required this.description,
    required this.category,
    required this.quantity,
    required this.servings,
    required this.preparationDate,
    required this.expiryDate,
    required this.allergyInformation,
    required this.pickupAddress,
    required this.pickupDateTime,
    required this.isFoodSafe,
    required this.status,
    required this.createdAt,
    this.imagePath,
  });

  final String id;
  final String donorId;
  final String foodName;
  final String description;
  final String category;
  final String quantity;
  final int servings;
  final DateTime preparationDate;
  final DateTime expiryDate;
  final String allergyInformation;
  final String pickupAddress;
  final DateTime pickupDateTime;
  final bool isFoodSafe;
  final DonationStatus status;
  final DateTime createdAt; // donation created first records

  // store image which may contain images from assets/images, Online or URL images
  final String? imagePath;

  // Creates a copy of the donation with updated values.
  // Onlt the provided values will be changed and the rest remains the same.
  Donation copyWith({
    String? id,
    String? donorId,
    String? foodName,
    String? description,
    String? category,
    String? quantity,
    int? servings,
    DateTime? preparationDate,
    DateTime? expiryDate,
    String? allergyInformation,
    String? pickupAddress,
    DateTime? pickupDateTime,
    bool? isFoodSafe,
    DonationStatus? status,
    DateTime? createdAt,
    String? imagePath,
  }) {
    // Use the new value if one was provided, else keep the existing value with the help of "this"
    return Donation(
      id: id ?? this.id,
      donorId: donorId ?? this.donorId,
      foodName: foodName ?? this.foodName,
      description: description ?? this.description,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      servings: servings ?? this.servings,
      preparationDate: preparationDate ?? this.preparationDate,
      expiryDate: expiryDate ?? this.expiryDate,
      allergyInformation: allergyInformation ?? this.allergyInformation,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupDateTime: pickupDateTime ?? this.pickupDateTime,
      isFoodSafe: isFoodSafe ?? this.isFoodSafe,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  // converting the Donation obj into JASON data
  // It connects to donation_repository.dart
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donorId': donorId,
      'foodName': foodName,
      'description': description,
      'category': category,
      'quantity': quantity,
      'servings': servings,
      'preparationDate': preparationDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'allergyInformation': allergyInformation,
      'pickupAddress': pickupAddress,
      'pickupDateTime': pickupDateTime.toIso8601String(),
      'isFoodSafe': isFoodSafe,
      // Saves the status as text, such as "available"
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  /*
Creates a Donation object from saved JSON data.
 connects to donation_repository.dart when the donation is saved

 */
  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'] as String,
      donorId: json['donorId'] as String,
      foodName: json['foodName'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      quantity: json['quantity'] as String,

      //Converts the saved number into an integer.
      servings: (json['servings'] as num).toInt(),
      preparationDate: DateTime.parse(json['preparationDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),

      // empty value is set if allergy information was not saved or it doesn't have one.
      allergyInformation: json['allergyInformation'] as String? ?? '',
      pickupAddress: json['pickupAddress'] as String,
      pickupDateTime: DateTime.parse(json['pickupDateTime'] as String),

      // Uses "false" if the food safety data is not there.
      isFoodSafe: json['isFoodSafe'] as bool? ?? false,

      // Finds the Donation Status that matches the saved text.
      status: DonationStatus.values.firstWhere(
        (status) => status.name == json['status'],
        // availabe if the donation text is not found
        orElse: () => DonationStatus.available,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      imagePath: json['imagePath'] as String?,
    );
  }

  bool get isAvailable => status == DonationStatus.available;
}

class DonationSummary {
  const DonationSummary({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.foodName,
    required this.category,
    required this.quantity,
    this.imagePath,
    required this.pickupAddress,
    required this.isAvailable,
  });

  final String id;
  final String donorId;
  final String donorName;
  final String foodName;
  final String category;
  final String quantity;
  final String? imagePath;
  final String pickupAddress;
  final bool isAvailable;

  factory DonationSummary.fromDonation(Donation donation, {String? donorName}) {
    return DonationSummary(
      id: donation.id,
      donorId: donation.donorId,
      donorName: donorName ?? 'Donor',
      foodName: donation.foodName,
      category: donation.category,
      quantity: donation.quantity,
      imagePath: donation.imagePath,
      pickupAddress: donation.pickupAddress,
      isAvailable: donation.isAvailable,
    );
  }
}

