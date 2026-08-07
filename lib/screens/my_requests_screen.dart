import 'package:flutter/material.dart';

import '../models/food_request.dart';
import '../services/profile_repository.dart';
import '../services/request_repository.dart';
import '../utils/app_theme.dart';
import '../widgets/request_card.dart';
import 'pickup_details_screen.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({
    super.key,
    required this.requestRepository,
    required this.profileRepository,
    required this.currentUserId,
    this.showDemoDonorActions = false,
  });

  final RequestRepository requestRepository;
  final ProfileRepository profileRepository;
  final String currentUserId;

  /// When true, shows extra "Approve / Reject / Mark Ready" buttons that
  /// simulate the donor's side of the workflow. This is only meant for
  /// demonstrating and testing this module on its own — in the merged app
  /// those actions live on the donor's side of Member 3's module.
  final bool showDemoDonorActions;

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  Future<void> _cancelRequest(FoodRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this request?'),
        content: Text(
          'Your request for "${request.foodName}" will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Request'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF9A2727),
            ),
            child: const Text('Cancel Request'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await widget.requestRepository.cancelRequest(request.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request cancelled.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  void _openPickupDetails(FoodRequest request) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PickupDetailsScreen(
          request: request,
          requestRepository: widget.requestRepository,
          profileRepository: widget.profileRepository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Requests')),
      body: AnimatedBuilder(
        animation: widget.requestRepository,
        builder: (context, _) {
          final requests =
              widget.requestRepository.requestsFor(widget.currentUserId);

          if (requests.isEmpty) {
            return _EmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RequestCard(
                    request: request,
                    onViewPickupDetails: () => _openPickupDetails(request),
                    onCancel: () => _cancelRequest(request),
                  ),
                  if (widget.showDemoDonorActions)
                    _DemoDonorActions(
                      request: request,
                      requestRepository: widget.requestRepository,
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Demo-only controls that stand in for the donor's side of the workflow
/// so this module can be exercised end-to-end without Member 3's app.
class _DemoDonorActions extends StatelessWidget {
  const _DemoDonorActions({
    required this.request,
    required this.requestRepository,
  });

  final FoodRequest request;
  final RequestRepository requestRepository;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    if (request.status == RequestStatus.pending) {
      actions.addAll([
        TextButton(
          onPressed: () =>
              requestRepository.respondToRequest(request.id, approve: true),
          child: const Text('Demo: Approve'),
        ),
        TextButton(
          onPressed: () =>
              requestRepository.respondToRequest(request.id, approve: false),
          child: const Text('Demo: Reject'),
        ),
      ]);
    } else if (request.status == RequestStatus.approved) {
      actions.add(
        TextButton(
          onPressed: () => requestRepository.markReadyForPickup(request.id),
          child: const Text('Demo: Mark Ready for Pickup'),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 0),
      child: Wrap(spacing: 4, children: actions),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_basket_outlined,
              size: 56,
              color: AppTheme.mediumGreen,
            ),
            const SizedBox(height: 12),
            const Text(
              'No requests yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Browse available donations and tap "Request Donation" to '
              'submit your first request.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
