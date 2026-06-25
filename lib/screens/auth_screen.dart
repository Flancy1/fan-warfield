import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_theme.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import 'country_selection_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _gradientController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Auth logic ────────────────────────────────────────────────────────

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final auth = AuthService.instance;
      AuthResponse response;

      if (_isLogin) {
        response = await auth.signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        response = await auth.signUpWithEmail(
          _emailController.text,
          _passwordController.text,
        );
      }

      if (!mounted) return;

      final user = response.user;
      if (user != null) {
        await _navigateAfterAuth(user.id);
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      _showError('Beklenmeyen bir hata oluştu.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await AuthService.instance.signInWithGoogle();
      // OAuth flow will redirect — the app will be re-opened via deep link.
    } on AuthException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      _showError('Google ile giriş başarısız oldu.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGuestSignIn() async {
    setState(() => _isLoading = true);
    try {
      final response = await AuthService.instance.signInAnonymously();
      if (!mounted) return;

      final user = response.user;
      if (user != null) {
        await _navigateAfterAuth(user.id);
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      _showError('Misafir girişi başarısız oldu.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateAfterAuth(String userId) async {
    final isReturning = await SupabaseService.instance.isReturningUser(userId);

    if (!mounted) return;

    if (isReturning) {
      // Returning user → main app
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
    } else {
      // New user → country selection
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const CountrySelectionScreen(),
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.teamBAccent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.cardBackground,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Animated background particles / glow
          _buildBackgroundEffects(),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    _buildLogo(),
                    const SizedBox(height: 12),
                    _buildSubtitle(),
                    const SizedBox(height: 48),
                    _buildForm(),
                    const SizedBox(height: 20),
                    _buildSubmitButton(),
                    const SizedBox(height: 16),
                    _buildToggleMode(),
                    const SizedBox(height: 32),
                    _buildDivider(),
                    const SizedBox(height: 24),
                    _buildGoogleButton(),
                    const SizedBox(height: 16),
                    _buildGuestButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Background effects ────────────────────────────────────────────────

  Widget _buildBackgroundEffects() {
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _BackgroundPainter(_gradientController.value),
        );
      },
    );
  }

  // ── Logo ──────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        return Column(
          children: [
            // Glowing icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.teamAAccent
                        .withValues(alpha: 0.3 + 0.2 * _gradientController.value),
                    AppTheme.betButtonActive
                        .withValues(alpha: 0.3 + 0.2 * _gradientController.value),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.teamAAccent.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.sports_soccer,
                size: 40,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            // Animated gradient title
            ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: const [
                    Color(0xFF3B82F6),
                    Color(0xFF8B5CF6),
                    Color(0xFF10B981),
                  ],
                  stops: [
                    0.0 + _gradientController.value * 0.3,
                    0.5,
                    1.0 - _gradientController.value * 0.3,
                  ],
                ).createShader(bounds);
              },
              child: const Text(
                'FAN WARFIELD',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubtitle() {
    return Text(
      _isLogin ? 'Hesabına giriş yap' : 'Yeni hesap oluştur',
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 16,
      ),
    );
  }

  // ── Form ──────────────────────────────────────────────────────────────

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'E-posta adresi',
              prefixIcon: const Icon(Icons.email_outlined,
                  color: AppTheme.textSecondary, size: 20),
              filled: true,
              fillColor: AppTheme.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.cardBorder),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'E-posta adresi gerekli';
              }
              if (!RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w]{2,}$').hasMatch(value.trim())) {
                return 'Geçerli bir e-posta girin';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Şifre',
              prefixIcon: const Icon(Icons.lock_outline,
                  color: AppTheme.textSecondary, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              filled: true,
              fillColor: AppTheme.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.cardBorder),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Şifre gerekli';
              }
              if (value.length < 6) {
                return 'Şifre en az 6 karakter olmalı';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // ── Submit button ─────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.teamAAccent.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleEmailAuth,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  _isLogin ? 'Giriş Yap' : 'Hesap Oluştur',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  // ── Toggle Login / Register ───────────────────────────────────────────

  Widget _buildToggleMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLogin ? 'Hesabın yok mu? ' : 'Zaten hesabın var mı? ',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        GestureDetector(
          onTap: () => setState(() => _isLogin = !_isLogin),
          child: Text(
            _isLogin ? 'Kayıt Ol' : 'Giriş Yap',
            style: const TextStyle(
              color: AppTheme.teamAAccent,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ── Divider ───────────────────────────────────────────────────────────

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppTheme.cardBorder)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'veya',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppTheme.cardBorder)),
      ],
    );
  }

  // ── Google button ─────────────────────────────────────────────────────

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        icon: const Text('G',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
        label: const Text(
          'Google ile Giriş',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.cardBorder, width: 1.2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: AppTheme.cardBackground,
        ),
      ),
    );
  }

  // ── Guest button ──────────────────────────────────────────────────────

  Widget _buildGuestButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: TextButton(
        onPressed: _isLoading ? null : _handleGuestSignIn,
        style: TextButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text(
          'Misafir Olarak Devam Et',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
            decorationColor: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Background painter — subtle animated gradient orbs
// ═══════════════════════════════════════════════════════════════════════════

class _BackgroundPainter extends CustomPainter {
  final double progress;
  _BackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // Top-right blue orb
    final blueOrb = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF3B82F6).withValues(alpha: 0.12 + progress * 0.06),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width * 0.85,
            size.height * (0.08 + progress * 0.04),
          ),
          radius: 180,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * (0.08 + progress * 0.04)),
      180,
      blueOrb,
    );

    // Bottom-left green orb
    final greenOrb = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF10B981).withValues(alpha: 0.08 + progress * 0.04),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width * 0.15,
            size.height * (0.75 + progress * 0.03),
          ),
          radius: 160,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * (0.75 + progress * 0.03)),
      160,
      greenOrb,
    );

    // Center purple orb (subtle)
    final purpleOrb = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF8B5CF6).withValues(alpha: 0.06 + progress * 0.03),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.5, size.height * 0.4),
          radius: 200,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.4),
      200,
      purpleOrb,
    );
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
