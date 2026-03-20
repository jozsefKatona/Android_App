class SongQuestion {
  final String spotifyUri;
  final String correctAnswer;
  final List<String> options;

  SongQuestion({
    required this.spotifyUri,
    required this.correctAnswer,
    required this.options,
  });
}
