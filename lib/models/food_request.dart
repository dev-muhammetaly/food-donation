enum RequestStatus {
  pending,
  approved,
  rejected,
  readyForPickup,
  completed,
}

extension RequestStatusText on RequestStatus {
  String get label {
    switch (this) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.approved:
        return 'Approved';
      case RequestStatus.rejected:
        return 'Rejected';
      case RequestStatus.readyForPickup:
        return 'Ready for Pickup';
      case RequestStatus.completed:
        return 'Completed';
    }
  }
}

class FoodRequest {
  const FoodRequest({
    required this.id,
    required this.donationId,
    required this.donorId,
    required this.donorName,
    required this.foodName,
    required this.requesterId,
    required this.requestedQuantity,
    required this.peopleCount,
    required this.preferredPickupDateTime,
    required this.messageToDonor,
    required this.pickupAddress,
    required this.status,
    required this.requestDate,
    required this.pickupCode,
    this.imagePath,
    this.collectedAt,
  });

  final String id;

  // Links this request back to Member 2/3's donation record.
  final String donationId;
  final String donorId;
  final String donorName;
  final String foodName;
  final String? imagePath;

  // The recipient who submitted the request.
  final String requesterId;

  final String requestedQuantity;
  final int peopleCount;
  final DateTime preferredPickupDateTime;
  final String messageToDonor;

  // Carried over from the donation so Pickup Details can be shown without
  // re-fetching the donation record.
  final String pickupAddress;

  final RequestStatus status;
  final DateTime requestDate;

  // Shown on the Pickup Details page as the collection code/QR placeholder.
  final String pickupCode;

  final DateTime? collectedAt;

  bool get canCancel => status == RequestStatus.pending;

  bool get canViewPickupDetails =>
      status == RequestStatus.approved ||
      status == RequestStatus.readyForPickup ||
      status == RequestStatus.completed;

  FoodRequest copyWith({
    String? id,
    String? donationId,
    String? donorId,
    String? donorName,
    String? foodName,
    String? imagePath,
    String? requesterId,
    String? requestedQuantity,
    int? peopleCount,
    DateTime? preferredPickupDateTime,
    String? messageToDonor,
    String? pickupAddress,
    RequestStatus? status,
    DateTime? requestDate,
    String? pickupCode,
    DateTime? collectedAt,
  }) {
    return FoodRequest(
      id: id ?? this.id,
      donationId: donationId ?? this.donationId,
      donorId: donorId ?? this.donorId,
      donorName: donorName ?? this.donorName,
      foodName: foodName ?? this.foodName,
      imagePath: imagePath ?? this.imagePath,
      requesterId: requesterId ?? this.requesterId,
      requestedQuantity: requestedQuantity ?? this.requestedQuantity,
      peopleCount: peopleCount ?? this.peopleCount,
      preferredPickupDateTime:
          preferredPickupDateTime ?? this.preferredPickupDateTime,
      messageToDonor: messageToDonor ?? this.messageToDonor,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      status: status ?? this.status,
      requestDate: requestDate ?? this.requestDate,
      pickupCode: pickupCode ?? this.pickupCode,
      collectedAt: collectedAt ?? this.collectedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donationId': donationId,
      'donorId': donorId,
      'donorName': donorName,
      'foodName': foodName,
      'imagePath': imagePath,
      'requesterId': requesterId,
      'requestedQuantity': requestedQuantity,
      'peopleCount': peopleCount,
      'preferredPickupDateTime': preferredPickupDateTime.toIso8601String(),
      'messageToDonor': messageToDonor,
      'pickupAddress': pickupAddress,
      'status': status.name,
      'requestDate': requestDate.toIso8601String(),
      'pickupCode': pickupCode,
      'collectedAt': collectedAt?.toIso8601String(),
    };
  }

  factory FoodRequest.fromJson(Map<String, dynamic> json) {
    return FoodRequest(
      id: json['id'] as String,
      donationId: json['donationId'] as String,
      donorId: json['donorId'] as String,
      donorName: json['donorName'] as String,
      foodName: json['foodName'] as String,
      imagePath: json['imagePath'] as String?,
      requesterId: json['requesterId'] as String,
      requestedQuantity: json['requestedQuantity'] as String,
      peopleCount: (json['peopleCount'] as num).toInt(),
      preferredPickupDateTime: DateTime.parse(
        json['preferredPickupDateTime'] as String,
      ),
      messageToDonor: json['messageToDonor'] as String? ?? '',
      pickupAddress: json['pickupAddress'] as String,
      status: RequestStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => RequestStatus.pending,
      ),
      requestDate: DateTime.parse(json['requestDate'] as String),
      pickupCode: json['pickupCode'] as String,
      collectedAt: json['collectedAt'] != null
          ? DateTime.parse(json['collectedAt'] as String)
          : null,
    );
  }
}
