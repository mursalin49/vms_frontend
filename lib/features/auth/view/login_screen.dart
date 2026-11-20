import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../viewmodel/auth_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).login(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;

    return Scaffold(
      backgroundColor: AppColors.softGray,
      body: isDesktop ? _buildSplitLayout(auth) : _buildMobileLayout(auth),
    );
  }

  /// 2-Part Premium Split Layout (Left Hero, Right Form)
  Widget _buildSplitLayout(AuthState auth) {
    return Row(
      children: [
        // Left Side: Brand Hero Panel
        Expanded(
          flex: 12,
          child: Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.8, -0.9),
                end: Alignment(0.8, 0.9),
                colors: [
                  Color(0xFF0A1F36),
                  Color(0xFF14395F),
                  Color(0xFF1F4E79),
                ],
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Subtle radial gold glow in top right
                Positioned(
                  top: -100,
                  right: -100,
                  child: Container(
                    width: 700,
                    height: 500,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.goldAccent.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Concentric circles SVG simulation in bottom-right
                Positioned(
                  right: -140,
                  bottom: -140,
                  child: IgnorePointer(
                    child: CustomPaint(
                      size: const Size(560, 560),
                      painter: _ConcentricCirclesPainter(),
                    ),
                  ),
                ),
                // Hero Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 56),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Brand Header
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.goldAccent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                )
                              ],
                            ),
                            child: const Text(
                              'V',
                              style: TextStyle(
                                color: AppColors.brandNavy,
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'VMS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),

                      // Middle Statement
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'STARK GROUP',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.5,
                              color: AppColors.goldAccent,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Every vehicle.\nOne clear view.',
                            style: TextStyle(
                              fontSize: 52,
                              height: 1.08,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 480),
                            child: const Text(
                              'Register, track and manage the Stark Group fleet from one secure workspace.',
                              style: TextStyle(
                                fontSize: 17,
                                height: 1.6,
                                color: Color(0xCCFFFFFF),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Bottom Copyright Footer (Floating cards omitted per user request)
                      const Text(
                        '© Stark Group · Vehicle Management System',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xA6FFFFFF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right Side: Login Card
        Expanded(
          flex: 10,
          child: Container(
            height: double.infinity,
            color: AppColors.softGray,
            alignment: Alignment.center,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: _buildFormCard(auth),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Mobile & Tablet Stack Layout
  Widget _buildMobileLayout(AuthState auth) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            children: [
              // Brand Icon Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.goldAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'V',
                      style: TextStyle(
                        color: AppColors.brandNavy,
                        fontWeight: FontWeight.w800,
                        fontSize: 21,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'VMS',
                    style: TextStyle(
                      color: AppColors.brandNavy,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildFormCard(auth),
              const SizedBox(height: 24),
              const Text(
                '© Stark Group · Vehicle Management System',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// White Login Card
  Widget _buildFormCard(AuthState auth) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x260F1F33),
            blurRadius: 48,
            offset: Offset(0, 20),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Welcome back',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.charcoal,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in to manage Stark Group vehicles.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),

            // Email Field
            CustomTextField(
              label: 'Email',
              controller: _email,
              hint: 'admin@starkgroup.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofocus: true,
              validator: Validators.email,
            ),
            const SizedBox(height: 20),

            // Password Field
            CustomTextField(
              label: 'Password',
              controller: _password,
              hint: 'Enter password',
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: (v) => Validators.required(v, 'Password is required'),
              suffix: IconButton(
                tooltip: _obscure ? 'Show password' : 'Hide password',
                icon: Icon(
                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 20,
                  color: AppColors.muted,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),

            // Server / Auth Error Alert Banner
            if (auth.error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline, size: 18, color: AppColors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        auth.error!,
                        style: const TextStyle(
                          color: AppColors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            // Login Button (Height 50px with gradient & shadow)
            PrimaryButton(
              label: 'Login',
              height: 50,
              expand: true,
              isLoading: auth.isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for background concentric decorative circles
class _ConcentricCirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x14FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final center = Offset(size.width / 2, size.height / 2);
    final radii = [90.0, 150.0, 210.0, 270.0];

    for (final r in radii) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
