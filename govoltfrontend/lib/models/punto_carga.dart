import 'dart:convert';

List<PuntoCarga> puntosCargaFromJson(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed
      .map<PuntoCarga>((json) => PuntoCarga.fromJson(json))
      .toList();
}

class PuntoCarga {
  final double latitud;
  final double longitud;
  final String tipusConnexio;
  final String promotorGestor;
  final String designacioDescriptiva;
  final int kw;
  final String id;
  final String acDc;
  final String tipusVelocitat;
  final String nplacesEstaci;
  final String municipi;
  final String provincia;
  final String codiMun;
  final String acces;
  final String codiProv;
  final String adreca;
  final String tipusVehicle;

  PuntoCarga({
    required this.latitud,
    required this.longitud,
    required this.tipusConnexio,
    required this.promotorGestor,
    required this.designacioDescriptiva,
    required this.kw,
    required this.id,
    required this.acDc,
    required this.tipusVelocitat,
    required this.nplacesEstaci,
    required this.municipi,
    required this.provincia,
    required this.codiMun,
    required this.acces,
    required this.codiProv,
    required this.adreca,
    required this.tipusVehicle,
  });

  factory PuntoCarga.fromJson(Map<String, dynamic> json) {
    return PuntoCarga(
      latitud: json['geometry']['coordinates'][1],
      longitud: json['geometry']['coordinates'][0],
      tipusConnexio: json['properties']['tipus_connexi'],
      promotorGestor: json['properties']['promotor_gestor'],
      designacioDescriptiva: json['properties']['designacio_descriptiva'],
      kw: json['properties']['kw'],
      id: json['properties']['id'],
      acDc: json['properties']['ac_dc'],
      tipusVelocitat: json['properties']['tipus_velocitat'],
      nplacesEstaci: json['properties']['nplaces_estaci'],
      municipi: json['properties']['municipi'],
      provincia: json['properties']['provincia'],
      codiMun: json['properties']['codimun'],
      acces: json['properties']['acces'],
      codiProv: json['properties']['codiprov'],
      adreca: json['properties']['adre_a'],
      tipusVehicle: json['properties']['tipus_vehicle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitud': latitud,
      'longitud': longitud,
      'tipus_connexio': tipusConnexio,
      'promotor_gestor': promotorGestor,
      'designacio_descriptiva': designacioDescriptiva,
      'kw': kw,
      'id': id,
      'ac_dc': acDc,
      'tipus_velocitat': tipusVelocitat,
      'nplaces_estaci': nplacesEstaci,
      'municipi': municipi,
      'provincia': provincia,
      'codimun': codiMun,
      'acces': acces,
      'codiprov': codiProv,
      'adreca': adreca,
      'tipus_vehicle': tipusVehicle,
    };
  }
}
