import 'dart:async';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_sdk/models/player_state.dart';
import '../models/game_config.dart';

class SpotifyService {
  StreamSubscription<PlayerState>? _playerStateSubscription;
  Timer? _previewTimer;
  bool _isSeeking = false;

  /// Verbindet mit Spotify und gibt true zurück wenn erfolgreich.
  Future<bool> connect() async {
    try {
      final token = await SpotifySdk.getAccessToken(
        clientId: GameConfig.clientId,
        redirectUrl: GameConfig.redirectUrl,
        scope:
            'app-remote-control,user-read-playback-state,user-modify-playback-state',
      );
      print('✅ Token erhalten: $token');

      final connected = await SpotifySdk.connectToSpotifyRemote(
        clientId: GameConfig.clientId,
        redirectUrl: GameConfig.redirectUrl,
      );
      print('✅ Verbunden: $connected');
      return connected;
    } catch (e) {
      print('❌ Connect Fehler: $e');
      return false;
    }
  }

  /// Startet einen Song per URI.
  /// [fullSong] = false → stoppt automatisch nach 30 Sekunden.
  Future<void> play(String spotifyUri, {bool fullSong = true}) async {
    _previewTimer?.cancel(); // alten Timer stoppen

    print('▶️ Spiele: $spotifyUri (fullSong: $fullSong)');
    try {
      await SpotifySdk.play(spotifyUri: spotifyUri);
      print('✅ Play erfolgreich');

      // 30s Vorschau — automatisch pausieren
      if (!fullSong) {
        _previewTimer = Timer(const Duration(seconds: 30), () async {
          print('⏱ 30s Vorschau beendet');
          await pause();
        });
      }
    } catch (e) {
      print('❌ Play Fehler: $e');
      rethrow;
    }
  }

  Future<void> pause() async {
    try {
      await SpotifySdk.pause();
    } catch (_) {}
  }

  Future<void> resume() => SpotifySdk.resume();

  /// Hört auf Player-Events.
  void subscribePlayerState({
    required void Function(bool isPlaying) onStateChanged,
    required void Function() onConnectionLost,
  }) {
    _playerStateSubscription?.cancel();
    _playerStateSubscription = SpotifySdk.subscribePlayerState().listen((
      state,
    ) async {
      final track = state.track;
      if (track == null) return;

      onStateChanged(!state.isPaused);

      // Song-Loop (nur im fullSong Modus — bei 30s Vorschau läuft kein Loop)
      if (_previewTimer == null &&
          !_isSeeking &&
          state.playbackPosition >= track.duration - 800) {
        _isSeeking = true;
        try {
          await SpotifySdk.seekTo(positionedMilliseconds: 0);
          await SpotifySdk.resume();
        } finally {
          _isSeeking = false;
        }
      }
    }, onError: (_) => onConnectionLost());
  }

  void dispose() {
    _previewTimer?.cancel();
    _playerStateSubscription?.cancel();
    pause();
  }
}
