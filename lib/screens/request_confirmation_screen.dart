import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/donation.dart';
import '../services/request_repository.dart';
import '../utils/app_theme.dart';
import '../widgets/donation_image.dart';

class RequestConfirmationScreen extends StatefulWidget {
  const RequestConfirmationScreen({
    super.key,
    required this.donation,
    required this.requestRepository,
    required this.currentUserId,
  });

  final DonationSummary donation;
  final RequestRepository requestRepository;
  final String currentUserId;

  @override
  State<RequestConfirmationScreen> createState() =>
      _RequestConfirmationScreenState();
}

class _RequestConfirmationScreenState
    extends State<RequestConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _messageController = TextEditingController();

  int _peopleCount = 1;
  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;
  bool _agreedToCollect = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _quantityController.text = '1 portion';
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _pickupDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (selected != null) {
      setState(() => _pickupDate = selected);
    }
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _pickupTime ?? TimeOfDay.now(),
    );
    if (selected != null) {
      setState(() => _pickupTime = selected);
    }
  }

  Future<void> _submit() async {
    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (_pickupDate == null || _pickupTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose a preferred pickup date and time.'),
        ),
      );
      return;
    }

    if (!_agreedToCollect) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please confirm you agree to collect this donation on time.',
          ),
        ),
      );
      return;
    }

    if (!isFormValid) return;

    setState(() => _submitting = true);

    final pickupDateTime = DateTime(
      _pickupDate!.year,
      _pickupDate!.month,
      _pickupDate!.day,
      _pickupTime!.hour,
      _pickupTime!.minute,
    );

    try {
      await widget.requestRepository.createRequest(
        donationId: widget.donation.id,
        donorId: widget.donation.donorId,
        donorName: widget.donation.donorName,
        foodName: widget.donation.foodName,
        imagePath: widget.donation.imagePath,
        requesterId: widget.currentUserId,
        requestedQuantity: _quantityController.text.trim(),
        peopleCount: _peopleCount,
        preferredPickupDateTime: pickupDateTime,
        messageToDonor: _messageController.text.trim(),
        pickupAddress: widget.donation.pickupAddress,
        donationIsAvailable: widget.donation.isAvailable,
      );

      if (!mounted) return;
      await _showSuccessDialog();
    } on StateError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _showSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: AppTheme.mediumGreen,
          size: 40,
        ),
        title: const Text('Request Submitted'),
        content: Text(
          'Your request for "${widget.donation.foodName}" has been sent to '
          '${widget.donation.donorName}. You can track its status from '
          'My Requests.',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(); // close the dialog
              Navigator.of(context).pop(); // close the confirmation screen
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final donation = widget.donation;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Request')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SelectedDonationSummary(donation: donation),
            const SizedBox(height: 20),
            const _SectionLabel('Requested Quantity'),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                hintText: 'e.g. 2 containers',
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Please enter how much you are requesting'
                  : null,
            ),
            const SizedBox(height: 18),
            const _SectionLabel('Number of People Receiving the Food'),
            Row(
              children: [
                IconButton.outlined(
                  onPressed: _peopleCount > 1
                      ? () => setState(() => _peopleCount--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16),
                Text(
                  '$_peopleCount',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton.outlined(
                  onPressed: () => setState(() => _peopleCount++),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const _SectionLabel('Preferred Pickup Date & Time'),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: Text(
                      _pickupDate == null
                          ? 'Choose date'
                          : DateFormat('d MMM yyyy').format(_pickupDate!),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time, size: 16),
                    label: Text(
                      _pickupTime == null
                          ? 'Choose time'
                          : _pickupTime!.format(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const _SectionLabel('Message to Donor (optional)'),
            TextFormField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Anything the donor should know before pickup?',
              ),
            ),
            const SizedBox(height: 18),
            CheckboxListTile(
              value: _agreedToCollect,
              onChanged: (value) =>
                  setState(() => _agreedToCollect = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'I agree to collect this donation at the confirmed pickup '
                'time and understand it may be given to another recipient '
                'if I do not show up.',
                style: TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit Request',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedDonationSummary extends StatelessWidget {
  const _SelectedDonationSummary({required this.donation});

  final DonationSummary donation;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: DonationImage(
              imagePath: donation.imagePath,
              borderRadius: 10,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donation.foodName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${donation.category} • ${donation.quantity}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  'From ${donation.donorName}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppTheme.textDark,
        ),
      ),
    );
  }
}
