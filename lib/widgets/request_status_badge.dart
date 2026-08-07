import 'package:flutter/material.dart';

import '../models/food_request.dart';

class RequestStatusBadge extends StatelessWidget {
  const RequestStatusBadge({super.key, required this.status});

  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final colours = _coloursFor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colours.background,
        borderRadius: BorderRadius.circular(20),
      ),
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

  ({Color background, Color foreground}) _coloursFor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return (
          background: const Color(0xFFFFE2B8),
          foreground: const Color(0xFF95520A),
        );
      case RequestStatus.approved:
        return (
          background: const Color(0xFFE4EEFA),
          foreground: const Color(0xFF285D92),
        );
      case RequestStatus.rejected:
        return (
          background: const Color(0xFFFFDADA),
          foreground: const Color(0xFF9A2727),
        );
      case RequestStatus.readyForPickup:
        return (
          background: const Color(0xFFDDECC9),
          foreground: const Color(0xFF2C651E),
        );
      case RequestStatus.completed:
        return (
          background: const Color(0xFFE7E7E7),
          foreground: const Color(0xFF5D5D5D),
        );
    }
  }
}
