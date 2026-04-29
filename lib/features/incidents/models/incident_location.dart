class IncidentLocation {
  final double latitude;
  final double longitude;
  final String? address;

  IncidentLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  factory IncidentLocation.fromJson(Map<String, dynamic> json) {
    return IncidentLocation(
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}
