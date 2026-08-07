import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_profile.dart';
import '../services/profile_image_service.dart';
import '../services/profile_repository.dart';
import '../widgets/profile_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.profile,
    required this.profileRepository,
  });

  final UserProfile profile;
  final ProfileRepository profileRepository;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileImageService = ProfileImageService();

  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  String? _profileImagePath;
  late AccountType _accountType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _addressController = TextEditingController(text: widget.profile.address);
    _profileImagePath = widget.profile.profileImagePath;
    _accountType = widget.profile.accountType;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final storedPath = await _profileImageService.pickAndStoreImage(source);
    if (storedPath == null) return;

    setState(() => _profileImagePath = storedPath);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final updatedProfile = widget.profile.copyWith(
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      profileImagePath: _profileImagePath,
      accountType: _accountType,
    );

    await widget.profileRepository.updateProfile(updatedProfile);

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: ProfileAvatar(
                imagePath: _profileImagePath,
                onEditTap: _pickImage,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Please enter your full name'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Please enter your phone number'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              maxLines: 2,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Please enter your address'
                  : null,
            ),
            const SizedBox(height: 20),
            const Text(
              'Account type',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            SegmentedButton<AccountType>(
              segments: AccountType.values
                  .map(
                    (type) => ButtonSegment(
                      value: type,
                      label: Text(type.label),
                    ),
                  )
                  .toList(),
              selected: {_accountType},
              onSelectionChanged: (selection) =>
                  setState(() => _accountType = selection.first),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save Changes'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _isSaving ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
