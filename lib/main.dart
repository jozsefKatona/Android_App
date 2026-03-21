import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'models/game_config.dart';
import 'services/spotify_service.dart';
import 'services/barcode_service.dart';
import 'screens/start_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/scanner_screen.dart';
import 'screens/playing_screen.dart';

void main() => runApp(const BarcodeScannerApp());

class BarcodeScannerApp extends StatelessWidget {
  const BarcodeScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.colorBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.colorBackground,
          foregroundColor: AppColors.colorLight,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.colorAccent,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const BarcodeScannerScreen(),
    );
  }
}

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with WidgetsBindingObserver {
  final _spotify = SpotifyService();
  final _barcodeService = BarcodeService();
  static const _channel = MethodChannel('app/lifecycle');

  bool _isPlaying = false;
  bool _isConnected = false;
  GameScreen _screen = GameScreen.start;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _barcodeService.loadSongMap();
    _connect();

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onStop') {
        await _spotify.pause();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _spotify.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isConnected) {
      _connect();
    }
  }

  Future<void> _connect() async {
    try {
      final ok = await _spotify.connect();
      if (!mounted) return;
      setState(() => _isConnected = ok);
      if (ok) {
        _spotify.subscribePlayerState(
          onStateChanged: (playing) {
            if (mounted) setState(() => _isPlaying = playing);
          },
          onConnectionLost: () {
            if (mounted) setState(() => _isConnected = false);
          },
        );
      }
    } catch (_) {}
  }

  Future<void> _onBarcodeDetected(String raw) async {
    final uri = await _barcodeService.process(raw);

    if (uri == null || !_isConnected) return;

    final fullSong = await _barcodeService.isFullSong();
    await _spotify.play(uri, fullSong: fullSong);

    if (!mounted) return;
    setState(() => _screen = GameScreen.playing);
  }

  Future<void> _goToStart() async {
    await _spotify.pause();
    if (mounted) setState(() => _screen = GameScreen.start);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_screen) {
      GameScreen.start => StartScreen(
        isConnected: _isConnected,
        onPlay: () => setState(() => _screen = GameScreen.scanner),
        onSettings: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const SettingsScreen()))
            .then((_) {
              if (mounted) setState(() {});
            }),
      ),

      GameScreen.scanner => Scaffold(
        backgroundColor: AppColors.colorBackground,
        body: ScannerScreen(
          onBarcodeDetected: _onBarcodeDetected,
          onBack: _goToStart,
        ),
      ),

      GameScreen.playing => Scaffold(
        backgroundColor: AppColors.colorBackground,
        appBar: AppBar(
          backgroundColor: AppColors.colorBackground,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.colorLight),
            onPressed: _goToStart,
          ),
        ),
        body: Center(
          child: PlayingScreen(
            isPlaying: _isPlaying,
            onTogglePlayPause: () async {
              _isPlaying ? await _spotify.pause() : await _spotify.resume();
            },
            onEndSong: () async {
              await _spotify.pause();
              if (mounted) setState(() => _screen = GameScreen.scanner);
            },
          ),
        ),
      ),

      _ => const SizedBox(),
    };
  }
}
