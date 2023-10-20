class OpeningHours {
  final bool open;

  OpeningHours({required this.open});

  factory OpeningHours.fromJson(Map<String, dynamic> parsedJson) {
    return OpeningHours(open: parsedJson['open_now']);
  }
}
