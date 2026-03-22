import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BarcodeService {
  DateTime? _lastScan;
  Map<String, String>? _songMap;

  // Map einmalig laden und cachen
  Future<void> loadSongMap() async {
    final json = await rootBundle.loadString('assets/songs.json');
    _songMap = Map<String, String>.from(jsonDecode(json));
  }

  Future<String?> process(String rawValue) async {
    final now = DateTime.now();
    if (_lastScan != null &&
        now.difference(_lastScan!) < const Duration(seconds: 2)) {
      return null;
    }
    _lastScan = now;

    final direct = _extractSpotifyUri(rawValue);
    if (direct != null) return direct;

    if (rawValue.contains('qrsong.io')) {
      final cleanUrl = rawValue.split('?').first;
      final uri = _songMap?[cleanUrl];
      if (uri != null) return uri;
    }

    return null;
  }

  String? _extractSpotifyUri(String value) {
    if (value.startsWith('spotify:')) return value;

    final uri = Uri.tryParse(value);
    if (uri != null && uri.host.contains('open.spotify.com')) {
      final segments = uri.pathSegments.where((s) => s != 'intl-de').toList();
      if (segments.length >= 2 && segments[0] == 'track') {
        return 'spotify:track:${segments[1]}';
      }
    }
    return null;
  }

  Future<bool> isFullSong() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('full_song') ?? true;
  }
}
