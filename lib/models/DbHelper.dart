import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'iletisimModel.dart';
import 'raporModel.dart';
import 'ayarModel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:firebase_messaging/firebase_messaging.dart";
import 'package:flutter/services.dart';
import 'package:get_mac/get_mac.dart';
import 'dart:isolate';
import 'package:schedule_controller/schedule_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';


class DBHelper {

  final Location location = Location();

  LocationData _location;
  String _error;

  ScheduleController controller;
  ScheduleController controller2;
  ScheduleController controller3;


  Future get(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(12);
    return prefs.get(key);
  }

  Future save(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
    print(13);
  }


  String cihaz = "";
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;


  /// Dabase'imizi ilgili konuma oluşturup, oluşturduğu database'i istediğimizde dönen method
  static Future<Database> database() async {
    // işletim sistemine göre varsayılan database oluşturabileceğimiz konumu alacak
    final dbPath = await getDatabasesPath();

    // Client isminde database table oluşturacak rawSql komutumuzu tutan değişken
    // karışık görünmesin diye buraya yazdım, execute ederken kullanıcaz
    const iletimSQL = "CREATE TABLE Iletisim ("
        "iletisim_id INTEGER PRIMARY KEY,"
        "iletisim_kisisi TEXT,"
        "iletisim_email TEXT,"
        "blocked BIT"
        ")";
    const ayarlarSQL = "CREATE TABLE Ayar ("
        "ayar_id INTEGER PRIMARY KEY,"
        "ayar_gunleri TEXT,"
        "ayar_baslangic_saati TEXT,"
        "ayar_bitis_saati TEXT,"
        "ayar_zaman_araligi INTEGER"
        ")";
    const raporlarSQL = "CREATE TABLE Rapor ("
        "rapor_id TEXT,"
        "rapor_email TEXT,"
        "rapor_linki TEXT,"
        "rapor_zamani TEXT"
        ")";

    // ve SqlFlite ile gelen openDatabase methodu ile database'i oluşturup onu dönüyoruz.
    return openDatabase(
      // database'in oluşturulacağı konum; yukarıda aldığımız varsayalın database konumu ve
      // oluşturmak istediğimiz isimde dosyamızın adını verip, o konuma o isimde oluşturmasını istedik
      join(dbPath, "cocuk_takip_uygulamasi.db"),// -> 'varsayılanKonum/TestDb.db'
      // verdiğimiz SQL komutu ve version numarası ile database'imizi oluşturmasını istedik
      onCreate: (db, version) async { await db.execute(iletimSQL);
      db.execute(ayarlarSQL);
      db.execute(raporlarSQL);
      },
//      onCreate: (db, version) => db.execute(iletimSQL),
      version: 1,
    );
  }

//  _getToken() async {
//    var cihaz = await _firebaseMessaging.getToken();
//
//    print("cihaz bilgisi : $cihaz");
//    return cihaz;
//  }

  String _platformVersion = 'Unknown';

  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      _platformVersion = await GetMac.macAddress;
    } on PlatformException {
      _platformVersion = 'Failed to get Device MAC Address.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

  }

  /// Yeni Kayıt
  newIletisim(Iletisim newIletisim) async {
    final db = await database();
    // Client isimli tabloya parametre olarak verdiğimiz yeni müşteriyi
    // map'e çevir ve database()'imize ekle
    var sonuc = await db.insert("Iletisim", newIletisim.toMap());

    var cihaz = await _firebaseMessaging.getToken();

    await initPlatformState();

    print(_platformVersion);

    String _document = _platformVersion+newIletisim.iletisim_email;

    print(_document);



    Firestore.instance.collection('DeviceTokens').document(_document);
    Firestore.instance.collection('DeviceTokens').document(_document)
        .setData({"device_verici": _platformVersion,"device_email": newIletisim.iletisim_email});
//

    // geri dönüş değerini dönder, ekleme olumlu olursa, eklendi "id"'yi dönecek
    return sonuc;
  }

  /// Yeni Ayar Kayıt
  newAyar(Ayar newAyar) async {
    final db = await database();
    var sonuc = await db.insert("Ayar", newAyar.toMap());
//    ayarlara bağlı günlük konum dönderiminin tetiklenmesi
    _konumgonder(newAyar);
    var controller = await ScheduleController([
      Schedule(

        timeOutRunOnce: true,

        timing: [5],//gece saat 05 de yeni kullanımlar oluşturacak
        readFn: () async => await get('gunler'),
        writeFn: (String data) async {
          debugPrint(data);
          print(45);
          _konumgonder(newAyar);
          await save('gunler', data);
        },
        callback: () async{
          _konumgonder(newAyar);
          debugPrint('gunler');
        },
      ),
    ]);
    controller.run();

    return sonuc;
  }




  void _konumgonder(Ayar newAyar) async {
    await konumgonder(newAyar);
  }


  konumgonder(Ayar newAyar) async{
    final db = await database();
    _konumukaydet(newAyar);
    var haftaningunu = DateTime.now().weekday;
    var ayarGunleri;

    var controller2 = await ScheduleController([
      Schedule(

        timeOutRunOnce: true,

        timing: [double.parse(newAyar.ayar_baslangic_saati)],//gece saat 05 de yeni kullanımlar oluşturacak
        readFn: () async => await get('baslatma_zamani'),
        writeFn: (String data) async {
          debugPrint(data);
          _konumukaydet(newAyar);
          await save('baslatma_zamani', data);
        },
        callback: () async{
          _konumukaydet(newAyar);
          debugPrint('baslatma_zamani');
        },
      ),
    ]);


    switch (newAyar.ayar_gunleri){
      case "Haftaiçi":{
        if (haftaningunu <= 5){
          controller2.run();
        }
      } break;
      case "Haftasonu":{ if (haftaningunu > 5){
        controller2.run();
      }} break;
      case "Tüm Hafta":{controller2.run();} break;
    }


  }

  void _konumukaydet(Ayar newAyar) async {
    await konumukaydet(newAyar);
  }

  konumukaydet(Ayar newAyar)async{
    _konumkaydetme();
    if (int.parse(newAyar.ayar_baslangic_saati) == DateTime.now().hour ) {
     _konumkaydetme();
    }

    Timer.periodic(Duration(minutes: newAyar.ayar_zaman_araligi), (timer) async{
      if (int.parse(newAyar.ayar_baslangic_saati) > DateTime.now().hour ) {
        timer.cancel();
      }
      _konumkaydetme();
    });
  }

   _konumkaydetme() async{
      final LocationData _locationResult = await location.getLocation();
      var lat = _locationResult.latitude;
      var long = _locationResult.longitude;
      var konum_linki = "https://www.google.com.tr/maps/@$lat,$long";
//      https://www.google.com.tr/maps/place/@37.4219983,-122.084"

      var cihaz = await _firebaseMessaging.getToken();

      await initPlatformState();

      print(_platformVersion);

      String _document = _platformVersion+DateTime.now().toString();

      print(_document);

      List<Iletisim> iletisim_bilgileri = await getAllIletisim();

      for(Iletisim iletisim in iletisim_bilgileri)
      {
        String zaman = DateTime.now().toString();
        String _document = _platformVersion+zaman;

        await Firestore.instance.collection('Konum').document(_document);
        await Firestore.instance.collection('Konum').document(_document)
            .setData({"konum_verici": _platformVersion,"konum_email": iletisim.iletisim_email,
          "konum_zamani":zaman,"konum_linki":konum_linki});
        Rapor rapor = Rapor(rapor_id: _document,rapor_email: iletisim.iletisim_email,
        rapor_linki: konum_linki,rapor_zamani: zaman);
        await newRapor(rapor);
      }


    }


  newRapor(Rapor newRapor) async {
    final db = await database();
    // Client isimli tabloya parametre olarak verdiğimiz yeni müşteriyi
    // map'e çevir ve database()'imize ekle
    var sonuc = await db.insert("Rapor", newRapor.toMap());

    // geri dönüş değerini dönder, ekleme olumlu olursa, eklendi "id"'yi dönecek
    return sonuc;
  }


  getIletisim() async {
    final db = await database();
    // parametre olarak verdiğimiz "id" ye göre database()'den ilgili elemanı getircek
    var sonuc = await db.query("Iletisim", where: "iletisim_id = 1");
    return sonuc.isNotEmpty ? Iletisim.fromMap(sonuc.first) : Null;
  }



  /// bütün elemanları getir
  Future<List<Iletisim>> getAllIletisim() async {
    final db = await database();
    var sonuc = await db.query("Iletisim");
    List<Iletisim> list =
    sonuc.isNotEmpty ? sonuc.map((c) => Iletisim.fromMap(c)).toList() : [];
    return list;
  }

  /// bütün raporları elemanları getir
  Future<List<Rapor>> getAllRaporlar() async {
    final db = await database();
    var sonuc = await db.query("Rapor");
    List<Rapor> list =
    sonuc.isNotEmpty ? sonuc.map((c) => Rapor.fromMap(c)).toList() : [];
    return list;
  }

//  /// sadece bloklanmış elemanları liste şeklinde dönecek
//  Future<List<Client>> getBlockedClients() async {
//    final db = await database();
//    var sonuc = await db.query("Client", where: "blocked = ? ", whereArgs: [1]);
//    List<Client> list =
//    sonuc.isNotEmpty ? sonuc.map((c) => Client.fromMap(c)).toList() : [];
//    return list;
//  }

  /// Karışık Kelimeleri Getirecek
//  Future<List<Client>> getRandomClients() async {
//    final db = await database();
//    Random random = Random();
//    var sonuc = await db.query("Client",orderBy: "random()", limit: 5);
//
//    List<Client> list =
//    sonuc.isNotEmpty ? sonuc.map((c) => Client.fromMap(c)).toList() : [];
//    return list;
//  }


  /// var olan müşteriyi günceller
//  updateClient(Client newClient) async {
//    final db = await database();
//    var sonuc = await db.update("Client", newClient.toMap(),
//        where: "id = ?", whereArgs: [newClient.id]);
//    return sonuc;
//  }

  /// Verilen iletişim bilgisini bloklar veya açar
  blockOrUnblock(Iletisim iletisim) async {
    final db = await database();
    Iletisim blocked = Iletisim(
        iletisim_id: iletisim.iletisim_id,
        iletisim_kisisi: iletisim.iletisim_kisisi,
        iletisim_email: iletisim.iletisim_email,
        blocked: !iletisim.blocked);
    var sonuc = await db.update("Iletisim", blocked.toMap(),
        where: "iletisim_id = ?", whereArgs: [iletisim.iletisim_id]);
    return sonuc;
  }

  /// verilen id değerine göre iletişim kişisini siler
  deleteIletisim(Iletisim delIletisim) async {
    final db = await database();

    await initPlatformState();

    print(_platformVersion);

    String _document = _platformVersion+delIletisim.iletisim_email;

    print(_document);


    db.delete("Iletisim", where: "iletisim_id = ?", whereArgs: [delIletisim.iletisim_id]);
    Firestore.instance.collection('DeviceTokens').document(_document).delete();

  }

  deleteRapor(Rapor delRapor) async {
    final db = await database();
    db.delete("Rapor", where: "rapor_id = ?", whereArgs: [delRapor.rapor_id]);
    Firestore.instance.collection('Konum').document(delRapor.rapor_id).delete();

  }


  /// bütün iletisim siler
  deleteIletisimAll() async {
    final db = await database();
    db.rawDelete("Delete from Iletisim");
  }
}