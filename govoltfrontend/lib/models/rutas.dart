class Ruta {
  final String id;
  final String beginning;
  final String destination;
  final String price;
  final int seats;
  final String date;
  final String creator;
  final List? participants;
  final List? participantsName;
  final String creatorUsername;

  Ruta({
    required this.id,
    required this.beginning,
    required this.destination,
    required this.price,
    required this.seats,
    required this.date,
    required this.creator,
    this.participants,
    this.participantsName,
    required this.creatorUsername
  });

  factory Ruta.fromJson(Map<String, dynamic> json) {
    return Ruta(
      id: json['id'] as String,
      beginning: json['ubicacion_inicial'] as String,
      destination: json['ubicacion_final'] as String,
      price: json['precio'] as String,
      seats: json['num_plazas'] as int,
      date: json['fecha'] as String,
      creator: json['creador'] as String,
      participants: json['participantes'] as List?,
      participantsName: json['nombreParticipantes'] as List?,
      creatorUsername: json['username'] as String
    );
  }

  String get description => '$beginning a $destination';
  String get title => 'Ruta $id';
}


  
