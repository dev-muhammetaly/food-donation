import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/food_request.dart';

/// Called whenever a request's status changes, so the donation record can
/// be kept in sync. Integration point for Member 2/3's `DonationRepository`:
///
/// ```dart
/// RequestRepository(
///   onDonationStatusChanged: (donationId, status) async {
///     if (status == RequestStatus.approved) {
///       await donationRepository.updateDonation(
///         donation.copyWith(status: DonationStatus.reserved),
///       );
///     } else if (status == RequestStatus.completed) {
///       await donationRepository.markAsCollected(donationId);
///     } else if (status == RequestStatus.rejected) {
///       await donationRepository.updateDonation(
///         donation.copyWith(status: DonationStatus.available),
///       );
///     }
///   },
/// )
/// ```
typedef DonationStatusCallback = Future<void> Function(
  String donationId,
  RequestStatus newStatus,
);

class RequestRepository extends ChangeNotifier {
  RequestRepository({this.onDonationStatusChanged});

  static const _storageKey = 'communitycare_requests';

  final List<FoodRequest> _requests = [];
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  final Random _random = Random();

  /// Optional hook so another module's repository (Member 2/3's donations)
  /// can react to a status change. Left null when this module runs on its
  /// own.
  final DonationStatusCallback? onDonationStatusChanged;

  List<FoodRequest> get requests => List.unmodifiable(_requests);

  List<FoodRequest> requestsFor(String requesterId) {
    final mine =
        _requests.where((request) => request.requesterId == requesterId).toList();
    mine.sort((a, b) => b.requestDate.compareTo(a.requestDate));
    return mine;
  }

  /// Returns true if [requesterId] already has an active (pending or
  /// approved/ready) request against [donationId]. Used to stop a recipient
  /// from submitting duplicate requests for the same donation.
  bool hasActiveRequest(String donationId, String requesterId) {
    return _requests.any(
      (request) =>
          request.donationId == donationId &&
          request.requesterId == requesterId &&
          request.status != RequestStatus.rejected &&
          request.status != RequestStatus.completed,
    );
  }

  Future<void> load({bool seedDemoData = false}) async {
    final storedJson = await _preferences.getString(_storageKey);

    _requests.clear();

    if (storedJson != null) {
      final decoded = jsonDecode(storedJson) as List<dynamic>;
      _requests.addAll(
        decoded.map(
          (item) => FoodRequest.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        ),
      );
    } else if (seedDemoData) {
      _requests.addAll(_buildDemoRequests());
      await _save();
    }

    notifyListeners();
  }

  /// Submits a new request. Throws a [StateError] if the donation is no
  /// longer available, matching the "prevent users from requesting
  /// unavailable food" requirement.
  Future<FoodRequest> createRequest({
    required String donationId,
    required String donorId,
    required String donorName,
    required String foodName,
    required String? imagePath,
    required String requesterId,
    required String requestedQuantity,
    required int peopleCount,
    required DateTime preferredPickupDateTime,
    required String messageToDonor,
    required String pickupAddress,
    required bool donationIsAvailable,
  }) async {
    if (!donationIsAvailable) {
      throw StateError('This donation is no longer available to request.');
    }

    if (hasActiveRequest(donationId, requesterId)) {
      throw StateError('You already have an active request for this item.');
    }

    final request = FoodRequest(
      id: 'req-${DateTime.now().microsecondsSinceEpoch}',
      donationId: donationId,
      donorId: donorId,
      donorName: donorName,
      foodName: foodName,
      imagePath: imagePath,
      requesterId: requesterId,
      requestedQuantity: requestedQuantity,
      peopleCount: peopleCount,
      preferredPickupDateTime: preferredPickupDateTime,
      messageToDonor: messageToDonor,
      pickupAddress: pickupAddress,
      status: RequestStatus.pending,
      requestDate: DateTime.now(),
      pickupCode: _generatePickupCode(),
    );

    _requests.add(request);
    await _saveAndNotify();
    return request;
  }

  Future<void> cancelRequest(String requestId) async {
    final index = _requests.indexWhere((request) => request.id == requestId);
    if (index == -1) return;

    if (!_requests[index].canCancel) {
      throw StateError('Only pending requests can be cancelled.');
    }

    _requests.removeAt(index);
    await _saveAndNotify();
  }

  /// Simulates the donor approving or rejecting a pending request. In the
  /// merged app this would be triggered from the donor's side of the
  /// workflow; it is exposed here so the module can be demonstrated and
  /// tested end-to-end on its own.
  Future<void> respondToRequest(String requestId, {required bool approve}) async {
    await _updateStatus(
      requestId,
      approve ? RequestStatus.approved : RequestStatus.rejected,
    );
  }

  Future<void> markReadyForPickup(String requestId) async {
    await _updateStatus(requestId, RequestStatus.readyForPickup);
  }

  Future<void> confirmCollection(String requestId) async {
    final index = _requests.indexWhere((request) => request.id == requestId);
    if (index == -1) return;

    _requests[index] = _requests[index].copyWith(
      status: RequestStatus.completed,
      collectedAt: DateTime.now(),
    );
    await _saveAndNotify();
    await onDonationStatusChanged?.call(
      _requests[index].donationId,
      RequestStatus.completed,
    );
  }

  Future<void> _updateStatus(String requestId, RequestStatus status) async {
    final index = _requests.indexWhere((request) => request.id == requestId);
    if (index == -1) return;

    _requests[index] = _requests[index].copyWith(status: status);
    await _saveAndNotify();
    await onDonationStatusChanged?.call(_requests[index].donationId, status);
  }

  Future<void> _saveAndNotify() async {
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final encoded = jsonEncode(
      _requests.map((request) => request.toJson()).toList(),
    );
    await _preferences.setString(_storageKey, encoded);
  }

  String _generatePickupCode() {
    final code = 100000 + _random.nextInt(899999);
    return 'FS-$code';
  }

  List<FoodRequest> _buildDemoRequests() {
    final now = DateTime.now();

    return [
      FoodRequest(
        id: 'req-demo-1',
        donationId: 'demo-2',
        donorId: 'demo-donor',
        donorName: 'Demo Donor',
        foodName: 'Cooked Pasta',
        imagePath: 'assets/images/Cooked_pasta.jpg',
        requesterId: 'demo-donor',
        requestedQuantity: '2 containers',
        peopleCount: 3,
        preferredPickupDateTime: now.add(const Duration(days: 2, hours: 2)),
        messageToDonor: 'Happy to collect any time after 5pm, thank you!',
        pickupAddress: 'Greenwood Community Centre, Kuala Lumpur',
        status: RequestStatus.pending,
        requestDate: now.subtract(const Duration(hours: 3)),
        pickupCode: 'FS-482913',
      ),
      FoodRequest(
        id: 'req-demo-2',
        donationId: 'demo-3',
        donorId: 'demo-donor',
        donorName: 'Demo Donor',
        foodName: 'Whole Grain Bread',
        imagePath: 'assets/images/Whole_Grain_Bread.jpg',
        requesterId: 'demo-donor',
        requestedQuantity: '2 loaves',
        peopleCount: 4,
        preferredPickupDateTime: now.add(const Duration(days: 1, hours: 5)),
        messageToDonor: 'Collecting on behalf of the shelter, thank you.',
        pickupAddress: 'Greenwood Community Centre, Kuala Lumpur',
        status: RequestStatus.readyForPickup,
        requestDate: now.subtract(const Duration(days: 1)),
        pickupCode: 'FS-119027',
      ),
      FoodRequest(
        id: 'req-demo-3',
        donationId: 'demo-4',
        donorId: 'demo-donor',
        donorName: 'Demo Donor',
        foodName: 'Yogurt Cups',
        imagePath: 'assets/images/Yogurt_Cups.jpg',
        requesterId: 'demo-donor',
        requestedQuantity: '4 cups',
        peopleCount: 2,
        preferredPickupDateTime: now.subtract(const Duration(days: 3)),
        messageToDonor: 'Thank you so much for this!',
        pickupAddress: 'Greenwood Community Centre, Kuala Lumpur',
        status: RequestStatus.completed,
        requestDate: now.subtract(const Duration(days: 4)),
        pickupCode: 'FS-736450',
        collectedAt: now.subtract(const Duration(days: 3)),
      ),
      FoodRequest(
        id: 'req-demo-4',
        donationId: 'demo-1',
        donorId: 'demo-donor',
        donorName: 'Demo Donor',
        foodName: 'Garden Salad',
        imagePath: 'assets/images/Salad.jpg',
        requesterId: 'demo-donor',
        requestedQuantity: '1 container',
        peopleCount: 1,
        preferredPickupDateTime: now.subtract(const Duration(days: 5)),
        messageToDonor: 'Would love to try this, thanks!',
        pickupAddress: 'Greenwood Community Centre, Kuala Lumpur',
        status: RequestStatus.rejected,
        requestDate: now.subtract(const Duration(days: 6)),
        pickupCode: 'FS-268104',
      ),
    ];
  }
}
