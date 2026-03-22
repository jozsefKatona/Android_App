import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_colors.dart';

class PlayingScreen extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onEndSong;

  const PlayingScreen({
    super.key,
    required this.isPlaying,
    required this.onTogglePlayPause,
    required this.onEndSong,
  });

  @override
  State<PlayingScreen> createState() => _PlayingScreenState();
}

class _PlayingScreenState extends State<PlayingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _lottieController;
  late final AnimationController _rotationController;
  String _language = 'de';

  @override
  void initState() {
    super.initState();

    // Lottie Controller — für Shine-Effekt
    _lottieController = AnimationController(vsync: this);

    // Wackel Controller — vor und zurück
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _loadLanguage();

    if (widget.isPlaying) {
      _rotationController.repeat(reverse: true);
    }
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
  void didUpdateWidget(PlayingScreen old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying != old.isPlaying) {
      if (widget.isPlaying) {
        _rotationController.repeat(reverse: true);
      } else {
        _rotationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.colorBackground,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: widget.onTogglePlayPause,
            child: SizedBox(
              width: 300,
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      final angle = (_rotationController.value * 2 - 1) * 0.26;
                      return Transform.rotate(angle: angle, child: child);
                    },
                    child: Lottie.asset(
                      'assets/vinyl.json',
                      controller: _lottieController,
                      width: 300,
                      height: 300,
                      fit: BoxFit.contain,
                      onLoaded: (composition) {
                        _lottieController.duration = composition.duration;
                        _lottieController.repeat(min: 0, max: 90 / 361);
                      },
                    ),
                  ),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: widget.isPlaying
                          ? AppColors.colorAccent
                          : AppColors.colorPrimary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (widget.isPlaying
                                      ? AppColors.colorAccent
                                      : AppColors.colorPrimary)
                                  .withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 48),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: widget.onEndSong,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.colorAccent,
                  side: const BorderSide(
                    color: AppColors.colorAccent,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: Text(
                  _t('Nächsten Song abspielen', 'Play Next Song'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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
