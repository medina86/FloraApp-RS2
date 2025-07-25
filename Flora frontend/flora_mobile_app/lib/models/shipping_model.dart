class ShippingAddressModel {
  final int? id;
  final String firstName;
  final String lastName;
  final String city;
  final String street;
  final String houseNumber;
  final String postalCode;

  ShippingAddressModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.city,
    required this.street,
    required this.houseNumber,
    required this.postalCode,
  });

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return ShippingAddressModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      city: json['city'],
      street: json['street'],
      houseNumber: json['houseNumber'],
      postalCode: json['postalCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'city': city,
      'street': street,
      'houseNumber': houseNumber,
      'postalCode': postalCode,
      
    };
  }
}