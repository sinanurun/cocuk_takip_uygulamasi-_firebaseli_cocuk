import 'dart:isolate';

import 'package:cocuktakipuygulamasi/models/ayarModel.dart';
import 'package:flutter/material.dart';
import 'package:cocuktakipuygulamasi/models/DbHelper.dart';

// günlük ilaç eklenmesi
import 'package:schedule_controller/schedule_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class Ayarsayfasi extends StatefulWidget {
  Ayarsayfasi({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() =>_AyarState();
}

class _AyarState extends State<Ayarsayfasi>{
  List _ayargunleri = ["Haftaiçi", "Haftasonu", "Tüm Hatfta"];
  List _ayarBaslangicSaati = ["7","8","9","10","11","12","13","14",
                              "15","16","17","18"]  ;
  List _ayarBitisSaati = ["8","9","10","11","12","13","14",
    "15","16","17","18","19"]  ;
  List _ayarZamanAraligi = ["30","60","90","120"]  ;

  var _ayarlistesi = new List(4);

  String _currentGunler;
  String _currentBaslangic;
  String _currentBitis;
  String _currentZaman;

  @override
  void initState() {
   getDropDownAyarlar();
   _currentGunler = _ayarlistesi[0][0].value;
   _currentBaslangic = _ayarlistesi[1][0].value;
   _currentBitis = _ayarlistesi[2][0].value;
   _currentZaman = _ayarlistesi[3][0].value;

   super.initState();
  }



  List<DropdownMenuItem<String>> getDropDownAyarlar() {

    List<DropdownMenuItem<String>> gunler = new List();
    for (String ayargunu in _ayargunleri) {
      gunler.add(new DropdownMenuItem(
          value: ayargunu,
          child: new Text(ayargunu)
      ));
    }
    _ayarlistesi[0] =gunler;

    List<DropdownMenuItem<String>> baslangicsaatleri = new List();
    for (String  baslangicsaati in _ayarBaslangicSaati) {
      baslangicsaatleri.add(new DropdownMenuItem(
          value: baslangicsaati,
          child: new Text(baslangicsaati)
      ));
    }
    _ayarlistesi[1] = baslangicsaatleri;

    List<DropdownMenuItem<String>> bitissaatleri = new List();
    for (String bitissaati in _ayarBitisSaati) {
      bitissaatleri.add(new DropdownMenuItem(
          value: bitissaati,
          child: new Text(bitissaati)
      ));
    }
    _ayarlistesi[2] = bitissaatleri;
    List<DropdownMenuItem<String>> zamanaraliklari = new List();
    for (String zamanaraligi in _ayarZamanAraligi) {
      zamanaraliklari.add(new DropdownMenuItem(
          value: zamanaraligi,
          child: new Text(zamanaraligi)
      ));
    }
    _ayarlistesi[3] = zamanaraliklari;
  }

  String ayar_gunleri = "";
  String ayar_baslangic_saati = "";
  String ayar_bitis_saat = "";
  String ayar_zaman_araligi = "";
  bool blocked = true;

  void changedDropDownGunler(String selectedayarlar) {
    setState(() {
      _currentGunler = selectedayarlar;
    });
  }
  void changedDropDownBaslangic(String selectedayarlar) {
    setState(() {
      _currentBaslangic = selectedayarlar;
    });
  }
  void changedDropDownBitis(String selectedayarlar) {
    setState(() {
      _currentBitis = selectedayarlar;
    });
  }
  void changedDropDownZaman(String selectedayarlar) {
    setState(() {
      _currentZaman = selectedayarlar;
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mesaj Gönderim Ayar Sayfası")),
//      resizeToAvoidBottomPadding: false,
      body: ListView(
        //mainAxisAlignment: MainAxisAlignment.center,

        children: <Widget>[
          Text("Aşağıdaki Forma Zaman Bilgilerini Yazınız", style: TextStyle(fontSize: 20),textAlign: TextAlign.center),
          SizedBox(height: 10),
          Text("Günleri Seçiniz", style: TextStyle(fontSize: 20),textAlign: TextAlign.center),
          Center(
            child:DropdownButton(
              value: _currentGunler,
              items: _ayarlistesi[0],
              onChanged: changedDropDownGunler,
            ),
          ),
          SizedBox(height: 10),
          Text("Başlangıç Saatini Seçiniz", style: TextStyle(fontSize: 20),textAlign: TextAlign.center),
          Center(
            child:DropdownButton(
              value: _currentBaslangic,
              items: _ayarlistesi[1],
              onChanged: changedDropDownBaslangic,
            ),
          ),

          SizedBox(height: 10),
          Text("Bitiş Saatini Seçiniz", style: TextStyle(fontSize: 20),textAlign: TextAlign.center),
          Center(
            child:DropdownButton(
              value: _currentBitis,
              items: _ayarlistesi[2],
              onChanged: changedDropDownBitis,
            ),
          ),

          SizedBox(height: 10),
          Center(
            child:DropdownButton(
              value: _currentZaman,
              items: _ayarlistesi[3],
              onChanged: changedDropDownZaman,
            ),
          ),
          SizedBox(height: 10),


          Center(
              child: RaisedButton(
                  child: Text("Ayarları Güncelle"),
                  // Navigator.pop ile bir önceki sayfaya dönücek
                  onPressed: ()   async {
                    Ayar yeniayarlar = Ayar(ayar_gunleri: _currentGunler, ayar_baslangic_saati: _currentBaslangic,
                        ayar_bitis_saati: _currentBitis, ayar_zaman_araligi: int.parse(_currentZaman));
                        await DBHelper().newAyar(yeniayarlar);
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                              title: Text("Ayar Güncelleme İşlemi"),
                              content: Text("Başarılı"),
                              actions :<Widget>[ FlatButton(
                                child: Text("Kapat"),
                                onPressed: (){
                                  Navigator.of(context).pop();
                                },
                              )
                              ]
                          );
                        }
                    );

                  }
                //onPressed: () => Navigator.pop(context),
              )),
        ],
      ),
    );
  }

}
