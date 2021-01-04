import 'dart:convert';
/// AyarModel.dart
Ayar ayarFromJson(String str) {
  final jsonData = json.decode(str);
  return Ayar.fromMap(jsonData);
}

String ayarToJson(Ayar data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Ayar {
  int ayar_id;
  String ayar_gunleri;
  String ayar_baslangic_saati;
  String ayar_bitis_saati;
  int ayar_zaman_araligi;

  Ayar({
    this.ayar_id,
    this.ayar_gunleri,
    this.ayar_baslangic_saati,
    this.ayar_bitis_saati,
    this.ayar_zaman_araligi,

  });

  // gelen map verisini json'a dönüştürür
  factory Ayar.fromMap(Map<String, dynamic> json) => new Ayar(
    ayar_id: json["ayar_id"],
    ayar_gunleri: json["ayar_gunleri"],
    ayar_baslangic_saati: json["ayar_baslangic_saati"],
    ayar_bitis_saati: json["ayar_bitis_saati"],
    ayar_zaman_araligi: json["ayar_zaman_araligi"],

  );

  // gelen json' verisini Map'e dönüştürür
  Map<String, dynamic> toMap() => {
    "ayar_id": ayar_id,
    "ayar_gunleri": ayar_gunleri,
    "ayar_baslangic_saati": ayar_baslangic_saati,
    "ayar_bitis_saati":ayar_bitis_saati,
      "ayar_zaman_araligi":ayar_zaman_araligi,

  };
}