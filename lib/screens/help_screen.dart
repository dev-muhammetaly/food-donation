import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About & Help')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _SectionHeader(title: 'About FoodShare'),
          const Text(
            'FoodShare Community Care connects donors who have surplus '
            'food with recipients nearby, reducing waste and helping more '
            'people get fed. Donors publish available food, recipients '
            'browse and request it, and both sides coordinate a simple, '
            'safe pickup.',
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'How to Donate Food'),
          const _NumberedStep(number: 1, text: 'Open "Donate Food" from the Home page.'),
          const _NumberedStep(number: 2, text: 'Add a photo, description, quantity and dates.'),
          const _NumberedStep(number: 3, text: 'Confirm the food-safety checkbox and publish.'),
          const _NumberedStep(number: 4, text: 'Track status from "My Donations" until it is collected.'),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'How to Request Food'),
          const _NumberedStep(number: 1, text: 'Browse "Available Donations" and open one that suits you.'),
          const _NumberedStep(number: 2, text: 'Tap "Request Donation" and confirm pickup details.'),
          const _NumberedStep(number: 3, text: 'Wait for donor approval, then collect at the agreed time.'),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Food Safety Guidelines'),
          const _BulletPoint(text: 'Only collect food that is within its stated expiry window.'),
          const _BulletPoint(text: 'Check allergen information before collecting or sharing food.'),
          const _BulletPoint(text: 'Store perishable food cold and consume it promptly after pickup.'),
          const _BulletPoint(text: 'Do not donate food that has been left unrefrigerated for a long time.'),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Frequently Asked Questions'),
          const _FaqTile(
            question: 'Is there a cost to donate or request food?',
            answer: 'No. FoodShare is a free community service — no payment is exchanged on the platform.',
          ),
          const _FaqTile(
            question: 'What happens if a donation expires before pickup?',
            answer: 'The donation is automatically marked "Expired" and removed from the available list.',
          ),
          const _FaqTile(
            question: 'Can I cancel a request?',
            answer: 'Yes, pending requests can be cancelled from "My Requests" at any time before approval.',
          ),
          const _FaqTile(
            question: 'How do I change my account type?',
            answer: 'Contact support through the details below — account type changes are handled manually for safety review.',
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Contact & Support'),
          const _InfoLine(icon: Icons.email_outlined, text: 'support@foodshare.app'),
          const _InfoLine(icon: Icons.phone_outlined, text: '+60 3-1234 5678'),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'App Version $_appVersion',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppTheme.darkGreen,
        ),
      ),
    );
  }
}

class _NumberedStep extends StatelessWidget {
  const _NumberedStep({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: AppTheme.darkGreen,
            child: Text(
              '$number',
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  const _BulletPoint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(answer),
        ),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.darkGreen),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
