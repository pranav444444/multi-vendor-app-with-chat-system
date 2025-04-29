class VendorUserModel {
  final bool approved;

  final String? buisnessName;
  final String cityValue;
  final String countryValue;
  final String emailAddress;
  final String stateValue;
  final String storeImage;
  final String vendorid;
  VendorUserModel({
    required this.approved,
    this.buisnessName,
    required this.cityValue,
    required this.countryValue,
    required this.emailAddress,
    required this.stateValue,
    required this.storeImage,
    required this.vendorid,
  });

  factory VendorUserModel.fromJson(Map<String, dynamic> json) {
    return VendorUserModel(
      approved: json['approved']! as bool,
      buisnessName: json['businessName'] as String? ?? json['buisnessName'] as String?,
      cityValue: json['cityValue']! as String,
      countryValue: json['countryValue']! as String,
      emailAddress: json['emailAddress']! as String,
      stateValue: json['stateValue']! as String,
      storeImage: json['storeImage']! as String,
      vendorid: json['vendorid']! as String,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'approved': approved,
      'buisnessName': buisnessName,
      'cityValue': cityValue,
      'countryValue': countryValue,
      'emailAddress': emailAddress,
      'stateValue': stateValue,
      'storeImage': storeImage,
      'vendorid': vendorid,
    };
  }
}
