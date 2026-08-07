import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  AccountType _accountType = AccountType.donor;
  bool _agreedToTerms = false;
  bool _showTermsError = false;

  @override
  void dispose() {
    for (final c in [
      _fullName,
      _email,
      _phone,
      _address,
      _password,
      _confirmPassword,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _showTermsError = !_agreedToTerms);

    final formIsValid = _formKey.currentState!.validate();
    if (!formIsValid || !_agreedToTerms) return;

    final message = await context.read<AuthProvider>().register(
          fullName: _fullName.text,
          email: _email.text,
          phone: _phone.text,
          address: _address.text,
          password: _password.text,
          accountType: _accountType,
        );

    if (!mounted) return;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthProvider>().busy;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _CurvedHeader(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                            color: AppColors.textPrimary,
                            tooltip: 'Back',
                          ),
                          const Icon(Icons.eco, color: AppColors.primary, size: 26),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const _BrandLogo(),
                      const SizedBox(height: 40),
                      const Text(
                        'Create your account',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Join our community today',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        label: 'Full name',
                        controller: _fullName,
                        icon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                        validator: Validators.fullName,
                      ),
                      CustomTextField(
                        label: 'Email',
                        controller: _email,
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                      ),
                      CustomTextField(
                        label: 'Phone number',
                        controller: _phone,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator: Validators.phone,
                      ),
                      CustomTextField(
                        label: 'Address',
                        controller: _address,
                        icon: Icons.location_on_outlined,
                        textInputAction: TextInputAction.next,
                        validator: (v) => Validators.required(v, 'Address'),
                      ),
                      CustomTextField(
                        label: 'Password',
                        controller: _password,
                        icon: Icons.lock_outline,
                        obscure: true,
                        textInputAction: TextInputAction.next,
                        validator: Validators.password,
                      ),
                      CustomTextField(
                        label: 'Confirm password',
                        controller: _confirmPassword,
                        icon: Icons.lock_outline,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        validator: (v) =>
                            Validators.confirmPassword(v, _password.text),
                      ),
                      const Text(
                        'I am a',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (final type in AccountType.values) ...[
                            Expanded(
                              child: _AccountTypeCard(
                                type: type,
                                selected: _accountType == type,
                                onTap: () => setState(() => _accountType = type),
                              ),
                            ),
                            if (type != AccountType.values.last)
                              const SizedBox(width: 12),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        value: _agreedToTerms,
                        onChanged: (value) => setState(() {
                          _agreedToTerms = value ?? false;
                          _showTermsError = false;
                        }),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: const Text(
                          'I agree to the Terms and Conditions and Privacy Policy',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      if (_showTermsError)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Please accept the Terms and Conditions to continue.',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      CustomButton(
                        label: 'Create Account',
                        loading: busy,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pale green band with a wave along its lower edge, behind the top of
/// the page.
class _CurvedHeader extends StatelessWidget {
  const _CurvedHeader();

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(height: 190, color: AppColors.primaryLight),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final h = size.height;
    return Path()
      ..lineTo(0, h - 40)
      ..quadraticBezierTo(size.width * 0.30, h, size.width * 0.62, h - 28)
      ..quadraticBezierTo(size.width * 0.85, h - 48, size.width, h - 20)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Heart-and-basket mark with the two-tone wordmark beside it.
class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 58,
          width: 58,
          child: Stack(
            alignment: Alignment.center,
            children: const [
              Icon(Icons.favorite_border, size: 58, color: AppColors.primary),
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.shopping_basket,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'CommunityCare',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                height: 1.15,
              ),
            ),
            Text.rich(
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Food',
                    style: TextStyle(color: AppColors.accent),
                  ),
                  TextSpan(
                    text: 'Share',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                height: 1.15,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  const _AccountTypeCard({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final AccountType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surface,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Icon(
              type == AccountType.donor
                  ? Icons.volunteer_activism_outlined
                  : Icons.favorite_border,
              size: 20,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                type.label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
