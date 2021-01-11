class FindAddressData {
  String unrestricted_value;
  String value;
  String country;
  String region;
  String region_type;
  String type;
  String city;
  String city_type;
  String street;
  String street_type;
  String street_with_type;
  String house;
  bool out_of_town;
  String house_type;
  int accuracy_level;
  int radius;
  int lat;
  int lon;

  FindAddressData( {
    this.unrestricted_value,
    this.value,
    this.country,
    this.region,
    this.region_type,
    this.type,
    this.city,
    this.city_type,
    this.street,
    this.street_type,
    this.street_with_type,
    this.house,
    this.out_of_town,
    this.house_type,
    this.accuracy_level,
    this.radius,
    this.lat,
    this.lon,
  });

  factory FindAddressData.fromJson(Map<String, dynamic> parsedJson){

    return FindAddressData(
      unrestricted_value:parsedJson['unrestricted_value'],
      value:parsedJson['value'],
      country:parsedJson['country'],
      region:parsedJson['region'],
      region_type:parsedJson['region_type'],
      type:parsedJson['type'],
      city:parsedJson['city'],
      city_type:parsedJson['city_type'],
      street:parsedJson['street'],
      street_type:parsedJson['street_type'],
      street_with_type:parsedJson['street_with_type'],
      house:parsedJson['house'],
      out_of_town:parsedJson['out_of_town'],
      house_type:parsedJson['house_type'],
      accuracy_level:parsedJson['accuracy_level'],
      radius:parsedJson['radius'],
      lat:parsedJson['lat'],
      lon:parsedJson['lon'],
    );
  }
}