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

          const SizedBox(height: 32),

          // ─── Spielregeln ──────────────────────────────────────────
          _sectionLabel(_t('Spielregeln', 'Game Rules')),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: AppColors.colorCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                title: Text(
                  _t('Spielregeln anzeigen', 'Show Game Rules'),
                  style: const TextStyle(
                    color: AppColors.colorLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(
                  Icons.expand_more,
                  color: AppColors.colorPrimary,
                ),
                children: [
                  _ruleItem(
                    icon: Icons.group,
                    title: _t('Spieler', 'Players'),
                    text: _t(
                      '2–10 Spieler. Alle spielen gegeneinander.',
                      '2–10 players. Everyone plays against each other.',
                    ),
                  ),
                  _divider(),
                  _ruleItem(
                    icon: Icons.qr_code_scanner,
                    title: _t('QR-Code scannen', 'Scan QR Code'),
                    text: _t(
                      'Scanne die Rückseite einer Karte um den Song abzuspielen. Niemand außer dem Scanner darf die Karte sehen.',
                      'Scan the back of a card to play the song. Nobody except the scanner may see the card.',
                    ),
                  ),
                  _divider(),
                  _ruleItem(
                    icon: Icons.music_note,
                    title: _t('Song erraten', 'Guess the Song'),
                    text: _t(
                      'Alle Mitspieler versuchen das Erscheinungsjahr des Songs zu erraten und in ihrer persönlichen Zeitlinie einzuordnen.',
                      'All players try to guess the release year of the song and place it in their personal timeline.',
                    ),
                  ),
                  _divider(),
                  _ruleItem(
                    icon: Icons.timeline,
                    title: _t('Zeitlinie', 'Timeline'),
                    text: _t(
                      'Jeder Spieler baut seine eigene Zeitlinie aus Karten auf. Die Karten müssen in der richtigen chronologischen Reihenfolge platziert werden.',
                      'Each player builds their own timeline of cards. Cards must be placed in the correct chronological order.',
                    ),
                  ),
                  _divider(),
                  _ruleItem(
                    icon: Icons.check_circle_outline,
                    title: _t('Richtig geraten', 'Correct Guess'),
                    text: _t(
                      'Wer das Jahr richtig einordnet, behält die Karte in seiner Zeitlinie.',
                      'Whoever places the year correctly keeps the card in their timeline.',
                    ),
                  ),
                  _divider(),
                  _ruleItem(
                    icon: Icons.cancel_outlined,
                    title: _t('Falsch geraten', 'Wrong Guess'),
                    text: _t(
                      'Wer falsch liegt, muss die Karte abgeben. Die Karte kommt aus dem Spiel.',
                      'Whoever guesses wrong must discard the card. The card is removed from the game.',
                    ),
                  ),
                  _divider(),
                  _ruleItem(
                    icon: Icons.emoji_events,
                    title: _t('Gewinner', 'Winner'),
                    text: _t(
                      'Wer zuerst 10 Karten korrekt in seiner Zeitlinie platziert hat, gewinnt das Spiel!',
                      'The first player to correctly place 10 cards in their timeline wins the game!',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _ruleItem({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.colorPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.colorPrimary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.colorLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    color: AppColors.colorLight.withOpacity(0.5),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Divider(color: AppColors.colorNeutral.withOpacity(0.15), height: 1);

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
