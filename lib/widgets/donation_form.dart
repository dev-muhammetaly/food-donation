import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../models/donation.dart';
import '../services/image_storage_service.dart';
import '../utils/app_theme.dart';

// Reusable form used by both the Add Donation and Edit Donation screens.
class DonationForm extends StatefulWidget {
  const DonationForm({
    super.key,
    required this.submitButtonText,
    required this.onSubmit,
    this.initialDonation,
    this.showCancelButton = false,
  });

  final String submitButtonText;
  final Donation? initialDonation;
  final bool showCancelButton;
  final Future<void> Function(DonationFormData data) onSubmit;

  @override
  State<DonationForm> createState() => _DonationFormState();
}

class _DonationFormState extends State<DonationForm> {
  // Options shown in the food category dropdown.
  static const categories = [
    'Cooked Food',
    'Fresh Produce',
    'Groceries',
    'Bakery',
    'Dairy',
    'Drinks',
    'Other',
  ];

  final _formKey = GlobalKey<FormState>();
  final _imageStorageService = ImageStorageService();

  // Controllers read and update the values entered in the text fields.
  late final TextEditingController _foodNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _quantityController;
  late final TextEditingController _servingsController;
  late final TextEditingController _allergyController;
  late final TextEditingController _addressController;
  late final TextEditingController _preparationDateController;
  late final TextEditingController _expiryDateController;
  late final TextEditingController _pickupDateTimeController;

  // These variables store values that can change while the form is open.
  String? _category;
  String? _imagePath;
  DateTime? _preparationDate;
  DateTime? _expiryDate;
  DateTime? _pickupDateTime;
  bool _isFoodSafe = false;
  bool _showImageError = false;
  bool _showSafetyError = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final donation = widget.initialDonation;

    // Fill the fields with existing data when editing a donation.
    // For a new donation, the fields start empty.
    _foodNameController = TextEditingController(
      text: donation?.foodName ?? '',
    );
    _descriptionController = TextEditingController(
      text: donation?.description ?? '',
    );
    _quantityController = TextEditingController(
      text: donation?.quantity ?? '',
    );
    _servingsController = TextEditingController(
      text: donation?.servings.toString() ?? '',
    );
    _allergyController = TextEditingController(
      text: donation?.allergyInformation ?? '',
    );
    _addressController = TextEditingController(
      text: donation?.pickupAddress ?? '',
    );
    _preparationDateController = TextEditingController();
    _expiryDateController = TextEditingController();
    _pickupDateTimeController = TextEditingController();

    _category = donation?.category;
    _imagePath = donation?.imagePath;
    _preparationDate = donation?.preparationDate;
    _expiryDate = donation?.expiryDate;
    _pickupDateTime = donation?.pickupDateTime;
    _isFoodSafe = donation?.isFoodSafe ?? false;
    _updateDateText();
  }

  @override
  void dispose() {
    // Release the controllers when the form closes to prevent memory leaks.
    _foodNameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _servingsController.dispose();
    _allergyController.dispose();
    _addressController.dispose();
    _preparationDateController.dispose();
    _expiryDateController.dispose();
    _pickupDateTimeController.dispose();
    super.dispose();
  }

  void _updateDateText() {
    // Convert DateTime values into readable text for the date fields.
    final dateFormat = DateFormat('d MMM yyyy');

    _preparationDateController.text = _preparationDate == null
        ? ''
        : dateFormat.format(_preparationDate!);
    _expiryDateController.text = _expiryDate == null
        ? ''
        : dateFormat.format(_expiryDate!);
    _pickupDateTimeController.text = _pickupDateTime == null
        ? ''
        : DateFormat('d MMM yyyy, h:mm a').format(_pickupDateTime!);
  }

  Future<void> _showImageSourceSheet() async {
    // Let the user choose between the phone gallery and camera.
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add food photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose from gallery'),
                  onTap: () => Navigator.pop(
                    context,
                    ImageSource.gallery,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Take a photo'),
                  onTap: () => Navigator.pop(
                    context,
                    ImageSource.camera,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null || !mounted) {
      return;
    }

    try {
      final path = await _imageStorageService.pickAndStoreImage(source);
      if (path != null && mounted) {
        setState(() {
          _imagePath = path;
          _showImageError = false;
        });
      }
    } catch (error, stackTrace) {
      debugPrint('IMAGE SELECTION ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Image error: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
    }
  }

  Future<void> _pickPreparationDate() async {
    // Open the calendar used to select the food preparation date.
    final selected = await showDatePicker(
      context: context,
      initialDate: _preparationDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selected != null) {
      setState(() {
        _preparationDate = selected;
        _updateDateText();
      });
    }
  }

  Future<void> _pickExpiryDate() async {
    // The expiry date cannot be earlier than the preparation date.
    final selected = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? _preparationDate ?? DateTime.now(),
      firstDate: _preparationDate ?? DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selected != null) {
      setState(() {
        _expiryDate = selected;
        _updateDateText();
      });
    }
  }

  Future<void> _pickPickupDateTime() async {
    // Select the pickup date first, followed by the pickup time.
    final initial = _pickupDateTime ?? DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );

    if (selectedTime != null) {
      setState(() {
        _pickupDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        _updateDateText();
      });
    }
  }

  Future<void> _submit() async {
    // Validate all fields before sending the completed data to the parent screen.
    setState(() {
      // New donations require a photo. An older imported record without a
      // local photo can still be edited without causing a null error.
      _showImageError =
          _imagePath == null && widget.initialDonation == null;
      _showSafetyError = !_isFoodSafe;
    });

    final formIsValid = _formKey.currentState?.validate() ?? false;
    if (!formIsValid || _showImageError || _showSafetyError) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await widget.onSubmit(
        DonationFormData(
          foodName: _foodNameController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _category!,
          quantity: _quantityController.text.trim(),
          servings: int.parse(_servingsController.text.trim()),
          preparationDate: _preparationDate!,
          expiryDate: _expiryDate!,
          allergyInformation: _allergyController.text.trim(),
          pickupAddress: _addressController.text.trim(),
          pickupDateTime: _pickupDateTime!,
          isFoodSafe: _isFoodSafe,
          imagePath: _imagePath,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The donation could not be saved. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String? _requiredText(String? value, String fieldName) {
    // A validator returns an error message, or null when the value is valid.
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName.';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    final requiredError = _requiredText(value, 'a food description');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 10) {
      return 'Description must contain at least 10 characters.';
    }
    return null;
  }

  String? _validateServings(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the number of servings.';
    }
    final servings = int.tryParse(value.trim());
    if (servings == null || servings <= 0) {
      return 'Servings must be a number greater than 0.';
    }
    return null;
  }

  String? _validateExpiryDate(String? _) {
    if (_expiryDate == null) {
      return 'Please select the expiry date.';
    }
    if (_preparationDate != null &&
        _expiryDate!.isBefore(_preparationDate!)) {
      return 'Expiry date cannot be before preparation date.';
    }
    return null;
  }

  String? _validatePickupDateTime(String? _) {
    if (_pickupDateTime == null) {
      return 'Please select the pickup date and time.';
    }
    if (_expiryDate != null) {
      final endOfExpiryDay = DateTime(
        _expiryDate!.year,
        _expiryDate!.month,
        _expiryDate!.day,
        23,
        59,
      );
      if (_pickupDateTime!.isAfter(endOfExpiryDay)) {
        return 'Pickup must be on or before the expiry date.';
      }
    }
    return null;
  }

  Widget _buildImagePreview(String imageValue) {
    if (imageValue.startsWith('assets/')) {
      return Image.asset(
        imageValue,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _imagePlaceholder(),
      );
    }

    if (imageValue.startsWith('data:image/')) {
      try {
        final commaIndex = imageValue.indexOf(',');
        final encodedImage = imageValue.substring(commaIndex + 1);
        return Image.memory(
          base64Decode(encodedImage),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _imagePlaceholder(),
        );
      } catch (_) {
        return _imagePlaceholder();
      }
    }

    if (imageValue.startsWith('http://') ||
        imageValue.startsWith('https://')) {
      return Image.network(
        imageValue,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _imagePlaceholder(),
      );
    }

    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return const ColoredBox(
      color: AppTheme.softGreen,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: AppTheme.mediumGreen,
          size: 42,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The value may be an asset, a data URL, or a future network URL.
    final hasStoredImage =
        _imagePath != null && _imagePath!.trim().isNotEmpty;

    // ListView makes the long form scrollable on smaller screens.
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
        children: [
          // Food photo upload and preview area.
          InkWell(
            onTap: _showImageSourceSheet,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _showImageError
                      ? Theme.of(context).colorScheme.error
                      : AppTheme.mediumGreen,
                  width: 1.4,
                ),
              ),
              child: hasStoredImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(17),
                          child: _buildImagePreview(_imagePath!),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xB8000000),
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(17),
                              ),
                            ),
                            child: const Text(
                              'Tap to change photo',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 52,
                          color: AppTheme.mediumGreen,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap to upload or capture food photo',
                          style: TextStyle(
                            color: AppTheme.darkGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'JPG or PNG',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
            ),
          ),
          if (_showImageError)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 6),
              child: Text(
                'Please add a food photo.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 20),
          // Fields containing the food's main information.
          _SectionTitle(title: 'Food information'),
          _LabeledField(
            label: 'Food name',
            child: TextFormField(
              controller: _foodNameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Example: Fresh Fruits Box',
              ),
              validator: (value) => _requiredText(value, 'the food name'),
            ),
          ),
          _LabeledField(
            label: 'Food description',
            child: TextFormField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Describe the food and its condition',
              ),
              validator: _validateDescription,
            ),
          ),
          _LabeledField(
            label: 'Food category',
            child: DropdownButtonFormField<String>(
              initialValue: categories.contains(_category) ? _category : null,
              decoration: const InputDecoration(
                hintText: 'Select category',
              ),
              items: categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _category = value),
              validator: (value) =>
                  value == null ? 'Please select a food category.' : null,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LabeledField(
                  label: 'Quantity',
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      hintText: '2 boxes',
                    ),
                    validator: (value) =>
                        _requiredText(value, 'the quantity'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LabeledField(
                  label: 'Servings',
                  child: TextFormField(
                    controller: _servingsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '4',
                    ),
                    validator: _validateServings,
                  ),
                ),
              ),
            ],
          ),
          _LabeledField(
            label: 'Preparation date',
            child: TextFormField(
              controller: _preparationDateController,
              readOnly: true,
              onTap: _pickPreparationDate,
              decoration: const InputDecoration(
                hintText: 'Select date',
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
              validator: (_) => _preparationDate == null
                  ? 'Please select the preparation date.'
                  : null,
            ),
          ),
          _LabeledField(
            label: 'Expiry date',
            child: TextFormField(
              controller: _expiryDateController,
              readOnly: true,
              onTap: _pickExpiryDate,
              decoration: const InputDecoration(
                hintText: 'Select date',
                suffixIcon: Icon(Icons.event_busy_outlined),
              ),
              validator: _validateExpiryDate,
            ),
          ),
          _LabeledField(
            label: 'Allergy information',
            optional: true,
            child: TextFormField(
              controller: _allergyController,
              minLines: 2,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Example: Contains milk and nuts',
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Fields telling the receiver where and when to collect the food.
          _SectionTitle(title: 'Pickup information'),
          _LabeledField(
            label: 'Pickup address',
            child: TextFormField(
              controller: _addressController,
              minLines: 2,
              maxLines: 3,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Enter the full collection address',
                suffixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (value) =>
                  _requiredText(value, 'the pickup address'),
            ),
          ),
          _LabeledField(
            label: 'Pickup date and time',
            child: TextFormField(
              controller: _pickupDateTimeController,
              readOnly: true,
              onTap: _pickPickupDateTime,
              decoration: const InputDecoration(
                hintText: 'Select date and time',
                suffixIcon: Icon(Icons.schedule_outlined),
              ),
              validator: _validatePickupDateTime,
            ),
          ),
          const SizedBox(height: 6),
          // The donor must confirm that the food is safe before submission.
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _showSafetyError
                    ? Theme.of(context).colorScheme.error
                    : AppTheme.border,
              ),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: CheckboxListTile(
                value: _isFoodSafe,
                activeColor: AppTheme.darkGreen,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                title: const Text(
                  'I confirm that this food is safe to donate and the information is accurate.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _isFoodSafe = value ?? false;
                    _showSafetyError = !_isFoodSafe;
                  });
                },
              ),
            ),
          ),
          if (_showSafetyError)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 6),
              child: Text(
                'You must confirm the food safety statement.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 24),
          // Submit button shows a loading indicator while data is being saved.
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _submit,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.volunteer_activism_outlined),
              label: Text(
                _isSaving ? 'Saving...' : widget.submitButtonText,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.warmOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          if (widget.showCancelButton) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: _isSaving
                    ? null
                    : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Holds the validated values passed from this form to the add/edit screen.
class DonationFormData {
  const DonationFormData({
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
    required this.imagePath,
  });

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
  final String? imagePath;
}

// Reusable heading for each major section of the form.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.darkGreen,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// Displays a label above a form field and can mark it as optional.
class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
    this.optional = false,
  });

  final String label;
  final Widget child;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (optional)
                Text(
                  '  (optional)',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
