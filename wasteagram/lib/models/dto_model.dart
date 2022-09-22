class DTOModel {
  String? date;
  int? waste;
  String? url;
  double? latitude;
  double? longitude;

  DTOModel({this.date, this.waste, this.url, this.latitude, this.longitude});

  DTOModel fromMap(Map<String, dynamic> inputMap) {
    return DTOModel(
        date: inputMap['date'],
        waste: inputMap['waste'],
        url: inputMap['url'],
        latitude: inputMap['latitude'],
        longitude: inputMap['longitude']);
  }

  String objectToString() {
    return 'Date: $date, Waste: $waste, URL: $url, Latitude: $latitude, Longitude: $longitude';
  }

  void updateWaste(int newWaste) {
    waste = newWaste;
  }
}
