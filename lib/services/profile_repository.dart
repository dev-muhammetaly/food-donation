import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class ProfileRepository extends ChangeNotifier {
  static const _storageKey = 'communitycare_profile';

  UserProfile? _profile;
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  UserProfile? get profile => _profile;

  Future<void> load({bool seedDemoData = false}) async {
    final storedJson = await _preferences.getString(_storageKey);

    if (storedJson != null) {
      _profile = UserProfile.fromJson(
        Map<String, dynamic>.from(jsonDecode(storedJson) as Map),
      );
    } else if (seedDemoData) {
      _profile = _buildDemoProfile();
      await _save();
    }

    notifyListeners();
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    _profile = updatedProfile;
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    if (_profile == null) return;
    await _preferences.setString(_storageKey, jsonEncode(_profile!.toJson()));
  }

  UserProfile _buildDemoProfile() {
    return const UserProfile(
      id: 'demo-donor',
      fullName: 'Demo Donor',
      email: 'demo.donor@communitycare.app',
      phone: '+60 12-345 6789',
      accountType: AccountType.donor,
      address: 'Greenwood Community Centre, Kuala Lumpur',
      donationsCount: 4,
      requestsCount: 1,
      mealsImpact: 30,
    );
  }
}
