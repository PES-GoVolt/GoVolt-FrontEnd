class Ruta {
  final String id;
  final String inicio;
  final String destino;
  final int tiempoAproximado;
  final double precio;
  final DateTime fecha;
  final String creador;

  Ruta({
    required this.id,
    required this.inicio,
    required this.destino,
    required this.tiempoAproximado,
    required this.precio,
    required this.fecha,
    required this.creador,
  });

  factory Ruta.fromJson(Map<String, dynamic> json) {
    return Ruta(
      id: json['id'] as String,
      inicio: json['inicio'] as String,
      destino: json['destino'] as String,
      tiempoAproximado: json['tiempo_aproximado'] as int,
      precio: json['precio'] as double,
      fecha: DateTime.parse(json['fecha']), 
      creador: json['creador'] as String,
    );
  }

  String get description => '$inicio a $destino';

  String get title => 'Ruta $id';
}
