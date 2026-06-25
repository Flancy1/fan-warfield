import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_theme.dart';
import 'screens/auth_screen.dart';
import 'screens/country_selection_screen.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    // TODO: Replace with your actual Supabase credentials
    url: const String.fromEnvironment('SUPABASE_URL',
        defaultValue: 'https://YOUR_PROJECT.supabase.co'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY',
        defaultValue: 'YOUR_ANON_KEY'),
  );

  runApp(const FanWarfieldApp());
}

class FanWarfieldApp extends StatelessWidget {
  const FanWarfieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fan Warfield',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthGate(),
      routes: {
        '/auth': (_) => const AuthScreen(),
        '/country-selection': (_) => const CountrySelectionScreen(),
      },
    );
  }
}

/// Decides which screen to show based on auth state + profile existence.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;

        // ── Not logged in → Auth screen ────────────────────────────────
        if (session == null) {
          return const AuthScreen();
        }

        // ── Logged in → check if profile exists ────────────────────────
        return FutureBuilder<bool>(
          future:
              SupabaseService.instance.isReturningUser(session.user.id),
          builder: (context, profileSnapshot) {
            // Still loading
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const _SplashLoading();
            }

            final hasProfile = profileSnapshot.data ?? false;

            if (hasProfile) {
              return const _MainAppPlaceholder();
            } else {
              return const CountrySelectionScreen();
            }
          },
        );
      },
    );
  }
}

/// Shown while we check if the user has a profile.
class _SplashLoading extends StatelessWidget {
  const _SplashLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.primaryGradient.createShader(bounds),
              child: const Text(
                'FAN WARFIELD',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppTheme.teamAAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder for the main app — replace with your actual main content.
class _MainAppPlaceholder extends StatelessWidget {
  const _MainAppPlaceholder();

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.primaryGradient.createShader(bounds),
              child: const Text(
                'FAN WARFIELD',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Hoş Geldin! 🎉',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? 'Misafir Kullanıcı',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 40),
            // Sign-out button (for testing)
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                },
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Çıkış Yap'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cardBackground,
                  foregroundColor: AppTheme.textPrimary,
                  side: const BorderSide(color: AppTheme.cardBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
