enum AccountType { donor, recipient }

extension AccountTypeText on AccountType {
  String get label {
    switch (this) {
      case AccountType.donor:
        return 'Donor';
      case AccountType.recipient:
        return 'Recipient';
    }
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.accountType,
    required this.address,
    required this.donationsCount,
    required this.requestsCount,
    required this.mealsImpact,
    this.profileImagePath,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final AccountType accountType;
  final String address;

  // These are display counters. Member 2/3/4 modules own the real
  // donation/request records; once merged, compute these from their
  // repositories instead of storing them here.
  final int donationsCount;
  final int requestsCount;
  final int mealsImpact;

  final String? profileImagePath;

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    AccountType? accountType,
    String? address,
    int? donationsCount,
    int? requestsCount,
    int? mealsImpact,
    String? profileImagePath,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      accountType: accountType ?? this.accountType,
      address: address ?? this.address,
      donationsCount: donationsCount ?? this.donationsCount,
      requestsCount: requestsCount ?? this.requestsCount,
      mealsImpact: mealsImpact ?? this.mealsImpact,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'accountType': accountType.name,
      'address': address,
      'donationsCount': donationsCount,
      'requestsCount': requestsCount,
      'mealsImpact': mealsImpact,
      'profileImagePath': profileImagePath,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      accountType: AccountType.values.firstWhere(
        (type) => type.name == json['accountType'],
        orElse: () => AccountType.donor,
      ),
      address: json['address'] as String,
      donationsCount: (json['donationsCount'] as num?)?.toInt() ?? 0,
      requestsCount: (json['requestsCount'] as num?)?.toInt() ?? 0,
      mealsImpact: (json['mealsImpact'] as num?)?.toInt() ?? 0,
      profileImagePath: json['profileImagePath'] as String?,
    );
  }
}

/// Lightweight user model from Member 1's authentication module.
/// Uses the [AccountType] enum already defined in this file.
class UserModel {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.accountType,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final AccountType accountType;

  String get firstName => fullName.trim().split(' ').first;

  Map<String, dynamic> toMap() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'address': address,
    'accountType': accountType.name,
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'] as String,
    fullName: map['fullName'] as String,
    email: map['email'] as String,
    phone: map['phone'] as String? ?? '',
    address: map['address'] as String? ?? '',
    accountType: AccountType.values.firstWhere(
      (t) => t.name == map['accountType'],
      orElse: () => AccountType.donor,
    ),
  );
}
