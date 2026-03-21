import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_colors.dart';

class StartScreen extends StatefulWidget {
  final bool isConnected;
  final VoidCallback onPlay;
  final VoidCallback onSettings;

  const StartScreen({
    super.key,
    required this.isConnected,
    required this.onPlay,
    required this.onSettings,
  });

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  String _language = 'de';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _language = prefs.getString('language') ?? 'de';
    });
  }

  String _t(String de, String en) => _language == 'de' ? de : en;

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _loadLanguage();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: AppColors.colorBackground),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ─── Titel ───────────────────────────────────────────────
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.colorPrimary, AppColors.colorPrimaryDark],
                ).createShader(bounds),
                child: const Text(
                  'Tunez',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 6,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle Badge
              const Spacer(flex: 2),

              // ─── Pulsierendes Icon ────────────────────────────────────
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.colorPrimary.withOpacity(0.08),
                        border: Border.all(
                          color: AppColors.colorPrimary.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo_headphone.png',
                          width: 260,
                          height: 260,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // ─── Spotify Verbindungsstatus ────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isConnected
                          ? AppColors.colorPrimary
                          : AppColors.colorAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.isConnected
                        ? _t('Spotify verbunden', 'Spotify connected')
                        : _t(
                            'Spotify wird verbunden...',
                            'Connecting to Spotify...',
                          ),
                    style: TextStyle(
                      color: widget.isConnected
                          ? AppColors.colorPrimary
                          : Colors.white38,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 3),

              // ─── Buttons ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: widget.isConnected ? widget.onPlay : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.colorAccent,
                          disabledBackgroundColor: AppColors.colorNeutral
                              .withOpacity(0.3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _t('JETZT SPIELEN', 'PLAY NOW'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: widget.onSettings,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.colorLight,
                          side: BorderSide(
                            color: AppColors.colorNeutral.withOpacity(0.5),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          _t('EINSTELLUNGEN', 'SETTINGS'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
