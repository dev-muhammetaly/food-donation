import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/donation.dart';

class DonationRepository extends ChangeNotifier {
  static const _storageKey = 'communitycare_donations';

  // Bump this whenever _buildDemoDonations() changes so returning users with
  // an older, still-untouched demo set get the refreshed data (e.g. new
  // images) instead of being stuck on whatever was first seeded.
  static const _demoDataVersion = 1;
  static const _demoVersionKey = '${_storageKey}_demo_version';

  final List<Donation> _donations = [];
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  List<Donation> get donations => List.unmodifiable(_donations);

  Future<void> load({bool seedDemoData = false}) async {
    final storedJson = await _preferences.getString(_storageKey);
    final storedDemoVersion = await _preferences.getInt(_demoVersionKey);

    _donations.clear();

    if (storedJson != null) {
      final decoded = jsonDecode(storedJson) as List<dynamic>;
      _donations.addAll(
        decoded.map(
          (item) => Donation.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        ),
      );
    }

    // Only ever replace data that is still the untouched demo set, so a
    // real donation the user created is never overwritten.
    final isUnmodifiedDemoData = _donations.isNotEmpty &&
        _donations.every((donation) => donation.id.startsWith('demo-'));

    if (seedDemoData &&
        (storedJson == null ||
            (isUnmodifiedDemoData && storedDemoVersion != _demoDataVersion))) {
      _donations
        ..clear()
        ..addAll(_buildDemoDonations());
      await _save();
      await _preferences.setInt(_demoVersionKey, _demoDataVersion);
    }

    await _markPastDonationsAsExpired();
    notifyListeners();
  }

  List<Donation> donationsFor(String donorId) {
    final donorDonations = _donations
        .where((donation) => donation.donorId == donorId)
        .toList();

    donorDonations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return donorDonations;
  }

  List<Donation> get availableDonations {
    final browsable = _donations
        .where((donation) => donation.status == DonationStatus.available)
        .toList();

    browsable.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    return browsable;
  }

  Future<void> createDonation(Donation donation) async {
    _donations.add(donation);
    await _saveAndNotify();
  }

  Future<void> updateDonation(Donation updatedDonation) async {
    final index = _donations.indexWhere(
      (donation) => donation.id == updatedDonation.id,
    );

    if (index == -1) {
      throw StateError('Donation could not be found.');
    }

    _donations[index] = updatedDonation;
    await _saveAndNotify();
  }

  Future<void> deleteDonation(String donationId) async {
    _donations.removeWhere((donation) => donation.id == donationId);
    await _saveAndNotify();
  }

  Future<void> markAsCollected(String donationId) async {
    final index = _donations.indexWhere(
      (donation) => donation.id == donationId,
    );

    if (index == -1) {
      throw StateError('Donation could not be found.');
    }

    _donations[index] = _donations[index].copyWith(
      status: DonationStatus.collected,
    );
    await _saveAndNotify();
  }

  Future<void> _saveAndNotify() async {
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final encoded = jsonEncode(
      _donations.map((donation) => donation.toJson()).toList(),
    );
    await _preferences.setString(_storageKey, encoded);
  }

  Future<void> _markPastDonationsAsExpired() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var didChange = false;

    for (var index = 0; index < _donations.length; index++) {
      final donation = _donations[index];
      final expiryDay = DateTime(
        donation.expiryDate.year,
        donation.expiryDate.month,
        donation.expiryDate.day,
      );

      final mayExpire = donation.status != DonationStatus.collected &&
          donation.status != DonationStatus.expired;

      if (mayExpire && expiryDay.isBefore(today)) {
        _donations[index] = donation.copyWith(
          status: DonationStatus.expired,
        );
        didChange = true;
      }
    }

    if (didChange) {
      await _save();
    }
  }

  List<Donation> _buildDemoDonations() {
    final now = DateTime.now();

    Donation demo({
      required String id,
      required String name,
      required String category,
      required String quantity,
      required int servings,
      required DonationStatus status,
      required int dayOffset,
      required String imagePath,
    }) {
      return Donation(
        id: id,
        donorId: 'demo-donor',
        foodName: name,
        description: 'Fresh food prepared for community collection.',
        category: category,
        quantity: quantity,
        servings: servings,
        preparationDate: now,
        expiryDate: now.add(Duration(days: dayOffset + 1)),
        allergyInformation: 'Please ask the donor before collection.',
        pickupAddress: 'Greenwood Community Centre, Kuala Lumpur',
        pickupDateTime: now.add(Duration(days: dayOffset, hours: 2)),
        isFoodSafe: true,
        status: status,
        createdAt: now.subtract(Duration(hours: dayOffset)),
        imagePath: imagePath,
      );
    }

    return [
      demo(
        id: 'demo-1',
        name: 'Garden Salad',
        category: 'Cooked Food',
        quantity: '2 containers',
        servings: 4,
        status: DonationStatus.available,
        dayOffset: 1,
        imagePath: 'assets/images/Salad.jpg',

      ),
      demo(
        id: 'demo-2',
        name: 'Cooked Pasta',
        category: 'Cooked Food',
        quantity: '3 containers',
        servings: 6,
        status: DonationStatus.requested,
        dayOffset: 2,
        imagePath: 'assets/images/Cooked_pasta.jpg',
        
      ),
      demo(
        id: 'demo-3',
        name: 'Whole Grain Bread',
        category: 'Bakery',
        quantity: '4 loaves',
        servings: 12,
        status: DonationStatus.reserved,
        dayOffset: 3,
        imagePath: 'assets/images/Whole_Grain_Bread.jpg',
      ),
      demo(
        id: 'demo-4',
        name: 'Yogurt Cups',
        category: 'Dairy',
        quantity: '8 cups',
        servings: 8,
        status: DonationStatus.collected,
        dayOffset: 4,
        imagePath: 'assets/images/Yogurt_Cups.jpg',
      ),
    ];
  }
}
