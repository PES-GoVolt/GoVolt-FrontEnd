import 'dart:convert';

List<ClienteModel> clientesFromJson(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed
      .map<ClienteModel>((json) => ClienteModel.fromJson(json))
      .toList();
}

class ClienteModel {
  late int? id;
  late String? nombre;
  late String? apellido;
  late String? foto;
  late String? email;

  ClienteModel({
    this.id,
    this.nombre,
    this.apellido,
    this.foto,
    this.email,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      id: json['id'] as int,
      nombre: json['nombre'],
      apellido: json['apellido'],
      foto: json['foto'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['nombre'] = nombre;
    data['apellido'] = apellido;
    data['foto'] = foto;
    data['email'] = email;
    return data;
  }
}
