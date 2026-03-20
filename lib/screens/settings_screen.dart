import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _fullSong = true;
  String _language = 'de';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullSong = prefs.getBool('full_song') ?? true;
      _language = prefs.getString('language') ?? 'de';
    });
  }

  Future<void> _saveSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('full_song', value);
    setState(() => _fullSong = value);
  }

  Future<void> _saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    setState(() => _language = lang);
  }

  String _t(String de, String en) => _language == 'de' ? de : en;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      appBar: AppBar(
        backgroundColor: AppColors.colorBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.colorLight),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _t('Einstellungen', 'Settings'),
          style: const TextStyle(
            color: AppColors.colorLight,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ─── Spotify ──────────────────────────────────────────────
          _sectionLabel(_t('Spotify-Einstellungen', 'Spotify Settings')),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.colorCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.colorPrimary.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Spotify',
                  style: TextStyle(
                    color: AppColors.colorPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.colorPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Premium',
                    style: TextStyle(
                      color: AppColors.colorPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ─── Spielmodus ───────────────────────────────────────────
          _sectionLabel(_t('Spielmodus', 'Game Mode')),
          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                _modeCard(
                  title: _t('Ganze Titel', 'Full Tracks'),
                  subtitle: _t(
                    'Spiele komplette Titel. Erfordert Spotify Premium.',
                    'Play complete tracks. Requires Spotify Premium.',
                  ),
                  selected: _fullSong,
                  onTap: () => _saveSetting(true),
                ),
                const Divider(color: AppColors.colorNeutralDark, height: 1),
                _modeCard(
                  title: _t('30-Sekunden-Vorschau', '30-Second Preview'),
                  subtitle: _t(
                    'Kein Premium-Abo erforderlich.',
                    'No Premium subscription required.',
                  ),
                  selected: !_fullSong,
                  onTap: () => _saveSetting(false),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ─── Sprache ──────────────────────────────────────────────
          _sectionLabel(_t('Sprache', 'Language')),
          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                _modeCard(
                  title: '🇩🇪  Deutsch',
                  subtitle: _t(
                    'App-Sprache auf Deutsch',
                    'Set app language to German',
                  ),
                  selected: _language == 'de',
                  onTap: () => _saveLanguage('de'),
                ),
                const Divider(color: AppColors.colorNeutralDark, height: 1),
                _modeCard(
                  title: '🇬🇧  English',
                  subtitle: _t(
                    'App-Sprache auf Englisch',
                    'Set app language to English',
                  ),
                  selected: _language == 'en',
                  onTap: () => _saveLanguage('en'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.colorNeutral.withOpacity(0.8),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }

  Widget _modeCard({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: const BoxDecoration(color: AppColors.colorCard),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.colorLight,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.colorLight.withOpacity(0.5),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Radio Button
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColors.colorPrimary
                      : AppColors.colorNeutral,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.colorPrimary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
