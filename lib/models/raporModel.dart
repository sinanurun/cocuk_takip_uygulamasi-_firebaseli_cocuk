import 'dart:convert';
/// RaporModel.dart
Rapor raporFromJson(String str) {
  final jsonData = json.decode(str);
  return Rapor.fromMap(jsonData);
}

String raporToJson(Rapor data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Rapor {
  String rapor_id;
  String rapor_email;
  String rapor_linki;
  String rapor_zamani;

  Rapor({
    this.rapor_id,
    this.rapor_email,
    this.rapor_linki,
    this.rapor_zamani,
  });

  // gelen map verisini json'a dönüştürür
  factory Rapor.fromMap(Map<String, dynamic> json) => new Rapor(
    rapor_id: json["rapor_id"],
    rapor_email: json["rapor_email"],
    rapor_linki: json["rapor_linki"],
    rapor_zamani: json["rapor_zamani"],
  );

  // gelen json' verisini Map'e dönüştürür
  Map<String, dynamic> toMap() => {
    "rapor_id": rapor_id,
    "rapor_email": rapor_email,
    "rapor_linki": rapor_linki,
    "rapor_zamani":rapor_zamani
  };
}