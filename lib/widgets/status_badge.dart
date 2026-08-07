import 'package:flutter/material.dart';

import '../models/donation.dart';


class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
  });

  // The current status that should be displayed by the badge.
 
  final DonationStatus status;

  @override
  Widget build(BuildContext context) {
    // Gets the correct background and text colours
    
    final colours = _coloursFor(status);

    return Container(
      // Adds space around the status text.
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),

      // Controls the badge's background colour and rounded shape.
      decoration: BoxDecoration(
        color: colours.background,

        
        borderRadius: BorderRadius.circular(20),
      ),

      // status.label converts the enum value into readable text.
      // DonationStatus.available becomes "Available".
      child: Text(
        status.label,
        style: TextStyle(
          color: colours.foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // Selects the background and foreground colours for each status.
  //
  
  ({Color background, Color foreground}) _coloursFor(
    DonationStatus status,
  ) {
    switch (status) {
      // Green shows that the donation can still be requested.
      case DonationStatus.available:
        return (
          background: const Color(0xFFDDECC9),
          foreground: const Color(0xFF2C651E),
        );

      // Blue shows that someone has submitted a request.
      case DonationStatus.requested:
        return (
          background: const Color(0xFFE4EEFA),
          foreground: const Color(0xFF285D92),
        );

      // Orange shows that the food has been reserved
      
      case DonationStatus.reserved:
        return (
          background: const Color(0xFFFFE2B8),
          foreground: const Color(0xFF95520A),
        );

      // Grey shows that the donation process has been completed.
      case DonationStatus.collected:
        return (
          background: const Color(0xFFE7E7E7),
          foreground: const Color(0xFF5D5D5D),
        );

      // Red warns that the food is no longer available
      // because its expiry date has passed.
      case DonationStatus.expired:
        return (
          background: const Color(0xFFFFDADA),
          foreground: const Color(0xFF9A2727),
        );
    }
  }
}