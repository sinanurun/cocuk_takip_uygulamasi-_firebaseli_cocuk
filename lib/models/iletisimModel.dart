import 'dart:convert';
/// IletisimModel.dart
Iletisim iletisimFromJson(String str) {
  final jsonData = json.decode(str);
  return Iletisim.fromMap(jsonData);
}

String iletisimToJson(Iletisim data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Iletisim {
  int iletisim_id;
  String iletisim_kisisi;
  String iletisim_email;
  bool blocked;

  Iletisim({
    this.iletisim_id,
    this.iletisim_kisisi,
    this.iletisim_email,
    this.blocked,
  });

  // gelen map verisini json'a dönüştürür
  factory Iletisim.fromMap(Map<String, dynamic> json) => new Iletisim(
    iletisim_id: json["iletisim_id"],
    iletisim_kisisi: json["iletisim_kisisi"],
    iletisim_email: json["iletisim_email"],
    blocked: json["blocked"] == 1,
  );

  // gelen json' verisini Map'e dönüştürür
  Map<String, dynamic> toMap() => {
    "iletisim_id": iletisim_id,
    "iletisim_kisisi": iletisim_kisisi,
    "iletisim_email": iletisim_email,
    "blocked": blocked,
  };
}