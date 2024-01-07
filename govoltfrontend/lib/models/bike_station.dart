class BikeStation {
  final double latitude;
  final double longitude;
  final String stationId; 
  final String address;

  BikeStation(this.latitude, this.longitude, this.stationId, this.address);

  factory BikeStation.fromJson(Map<String, dynamic> json) {
    return BikeStation(
      json['latitude'] as double,
      json['longitude'] as double,
      json['station_id'] as String,
      json['address'] as String,
    );
  }
}
