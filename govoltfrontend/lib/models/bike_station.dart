class BikeStation {
  final double latitude;
  final double longitude;
  final String stationId; 

  BikeStation(this.latitude, this.longitude, this.stationId);

  factory BikeStation.fromJson(Map<String, dynamic> json) {
    return BikeStation(
      json['latitude'] as double,
      json['longitude'] as double,
      json['station_id'] as String,
    );
  }
}
