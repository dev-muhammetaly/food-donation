import 'package:flutter/material.dart';
import 'package:food_donation/screens/edit_profile_screen.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../providers/auth_provider.dart';
import '../services/profile_repository.dart';
import '../utils/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_stat_card.dart';
import 'help_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.profileRepository,
    required this.onLogout,
  });

  final ProfileRepository profileRepository;

  // Member 1's authentication module owns the real sign-out flow.
  // This callback is the integration point for that logic.
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: profileRepository,
      builder: (context, _) {
        final profile = profileRepository.profile;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                tooltip: 'About & Help',
                icon: const Icon(Icons.help_outline),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpScreen()),
                ),
              ),
            ],
          ),
          body: profile == null
              ? const Center(child: CircularProgressIndicator())
              : _ProfileBody(
                  profile: profile,
                  profileRepository: profileRepository,
                  onLogout: onLogout,
                ),
        );
      },
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.profile,
    required this.profileRepository,
    required this.onLogout,
  });

  final UserProfile profile;
  final ProfileRepository profileRepository;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(child: ProfileAvatar(imagePath: profile.profileImagePath)),
        const SizedBox(height: 12),
        Center(
          child: Text(
            profile.fullName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.softGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              profile.accountType.label,
              style: const TextStyle(
                color: AppTheme.darkGreen,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            ProfileStatCard(
              label: 'Donations',
              value: '${profile.donationsCount}',
              icon: Icons.volunteer_activism,
            ),
            const SizedBox(width: 10),
            ProfileStatCard(
              label: 'Requests',
              value: '${profile.requestsCount}',
              icon: Icons.shopping_basket,
            ),
            const SizedBox(width: 10),
            ProfileStatCard(
              label: 'Meals Shared',
              value: '${profile.mealsImpact}',
              icon: Icons.restaurant,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _InfoTile(
          icon: Icons.email_outlined,
          label: 'Email',
          value: profile.email,
        ),
        _InfoTile(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: profile.phone,
        ),
        _InfoTile(
          icon: Icons.location_on_outlined,
          label: 'Address',
          value: profile.address,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditProfileScreen(
                profile: profile,
                profileRepository: profileRepository,
              ),
            ),
          ),
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profile'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _showChangePasswordDialog(context),
          icon: const Icon(Icons.lock_outline),
          label: const Text('Change Password'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _confirmLogout(context),
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text('Logout', style: TextStyle(color: Colors.red)),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            side: const BorderSide(color: Colors.red),
          ),
        ),
      ],
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const _ChangePasswordDialog(),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.darkGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                Text(value, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final message = await context.read<AuthProvider>().changePassword(
          currentPassword: _currentPassword.text,
          newPassword: _newPassword.text,
        );

    if (!mounted) return;
    if (message != null) {
      setState(() {
        _error = message;
        _saving = false;
      });
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _currentPassword,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
              validator: (v) => Validators.required(v, 'Current password'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newPassword,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
              validator: Validators.password,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPassword,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Confirm new password'),
              validator: (v) =>
                  Validators.confirmPassword(v, _newPassword.text),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }
}
