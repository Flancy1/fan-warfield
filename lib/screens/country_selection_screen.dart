import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_theme.dart';
import '../services/supabase_service.dart';

class CountrySelectionScreen extends StatefulWidget {
  const CountrySelectionScreen({super.key});

  @override
  State<CountrySelectionScreen> createState() => _CountrySelectionScreenState();
}

class _CountrySelectionScreenState extends State<CountrySelectionScreen>
    with SingleTickerProviderStateMixin {
  static const List<_Country> _allCountries = [
    _Country('🇹🇷', 'Türkiye'),
    _Country('🇧🇷', 'Brezilya'),
    _Country('🇩🇪', 'Almanya'),
    _Country('🇦🇷', 'Arjantin'),
    _Country('🇫🇷', 'Fransa'),
    _Country('🇪🇸', 'İspanya'),
    _Country('🇬🇧', 'İngiltere'),
    _Country('🇵🇹', 'Portekiz'),
    _Country('🇳🇱', 'Hollanda'),
    _Country('🇮🇹', 'İtalya'),
    _Country('🇯🇵', 'Japonya'),
    _Country('🇰🇷', 'Güney Kore'),
    _Country('🇲🇽', 'Meksika'),
    _Country('🇺🇸', 'ABD'),
    _Country('🇨🇴', 'Kolombiya'),
    _Country('🇺🇾', 'Uruguay'),
    _Country('🇧🇪', 'Belçika'),
    _Country('🇭🇷', 'Hırvatistan'),
    _Country('🇸🇳', 'Senegal'),
    _Country('🇲🇦', 'Fas'),
  ];

  String _searchQuery = '';
  String? _selectedCountry;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }


  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<_Country> get _filteredCountries {
    if (_searchQuery.isEmpty) return _allCountries;
    final q = _searchQuery.toLowerCase();
    return _allCountries
        .where((c) => c.name.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _confirm() async {
    if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.teamAAccent, size: 20),
              SizedBox(width: 12),
              Text('Lütfen bir ülke seç',
                  style: TextStyle(color: AppTheme.textPrimary)),
            ],
          ),
          backgroundColor: AppTheme.cardBackground,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Kullanıcı bulunamadı');

      // Generate a username from the email or a guest tag
      final email = user.email;
      final username = email != null && email.isNotEmpty
          ? email.split('@').first
          : 'Misafir_${user.id.substring(0, 6)}';

      await SupabaseService.instance.createProfile(
        userId: user.id,
        username: username,
        country: _selectedCountry!,
      );

      if (!mounted) return;

      // Navigate to main app
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline,
                  color: AppTheme.teamBAccent, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Hata: $e',
                    style: const TextStyle(color: AppTheme.textPrimary)),
              ),
            ],
          ),
          backgroundColor: AppTheme.cardBackground,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredCountries;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              const SizedBox(height: 32),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 20),
              Expanded(child: _buildCountryGrid(filtered)),
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          // Globe icon with glow
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF10B981)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.teamAAccent.withValues(alpha: 0.3),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.public, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ülkeni Seç',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Savaş meydanında hangi ülkeyi temsil edeceksin?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: TextField(
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Ülke ara…',
          hintStyle: const TextStyle(color: AppTheme.textSecondary),
          prefixIcon:
              const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
          filled: true,
          fillColor: AppTheme.cardBackground,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.teamAAccent),
          ),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  // ── Country grid ──────────────────────────────────────────────────────

  Widget _buildCountryGrid(List<_Country> countries) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: countries.length,
      itemBuilder: (context, index) {
        final country = countries[index];
        final isSelected = _selectedCountry == country.name;

        return GestureDetector(
          onTap: () => setState(() => _selectedCountry = country.name),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.teamAAccent.withValues(alpha: 0.12)
                  : AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppTheme.teamAAccent : AppTheme.cardBorder,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.teamAAccent.withValues(alpha: 0.2),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                // Checkmark badge
                if (isSelected)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: AppTheme.teamAAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          size: 14, color: Colors.white),
                    ),
                  ),
                // Flag + name
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        country.flag,
                        style: const TextStyle(fontSize: 36),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        country.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Confirm button ────────────────────────────────────────────────────

  Widget _buildConfirmButton() {
    final hasSelection = _selectedCountry != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: hasSelection ? AppTheme.primaryGradient : null,
            color: hasSelection ? null : AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(14),
            boxShadow: hasSelection
                ? [
                    BoxShadow(
                      color: AppTheme.teamAAccent.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _confirm,
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
                    hasSelection ? 'Onayla' : 'Bir ülke seç',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: hasSelection
                          ? Colors.white
                          : AppTheme.textSecondary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Country data class
// ═══════════════════════════════════════════════════════════════════════════

class _Country {
  final String flag;
  final String name;
  const _Country(this.flag, this.name);
}
