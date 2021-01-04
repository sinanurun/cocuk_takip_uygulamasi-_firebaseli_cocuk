import 'package:flutter/material.dart';
import 'views/iletisim.dart';
import 'views/anaekran.dart';
import 'views/ayarlar.dart';
import 'views/raporlar.dart';
import 'widgets/main_localion.dart' as Lokasyon;
import 'package:url_launcher/url_launcher.dart';


//import 'package:cocuktakipuygulamasi/widgets/main_sms.dart' as Sms;


// Uygulamanın Başladığı yer
// runApp diyip açılışta çalıştırmasını istediğimiz Widgetimizi Belirtiyoruz
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // MaterialApp = Google'nın material standartlarında bileşenleri kullanmamızı sağlayan yapı
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // title = işletim sistemi uygulamamızı hangi isimde tanıyacak
      title: 'Çocuk Takip Uygulaması',
      // Uygualama ilk açıldığında görünecek widgetimiz
      home: StatelesUygulama(),
    );
  }
}

class StatelesUygulama extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    // Uygulama içerisinde kolaylık sağlaması için bir kaç sabit ekleyelim
    // böylece her seferinde tek tek girmemiz gerekmez
    final double myTextSize = 30.0;
    final double myIconSize = 40.0;
    final TextStyle myTextStyle =
    TextStyle(color: Colors.grey, fontSize: myTextSize);

    sendsms(){
      String sms1 = "sms:05553766570";
      launch(sms1);
    }



    return Scaffold(
      appBar: AppBar(
        title: Text("Çocuk Takip Uygulaması"),
      ),
      backgroundColor: Colors.amberAccent,
      body: Container(
        child: Center(
          // SingleChildScrollView = Eğer ekrana içerisine verdiğimiz widgetler
          // ekrana sığmaz ise aşşağı kaydırma özelliği ekleyecek
          child: SingleChildScrollView(
              child: Column(
                // Column içerisindeki OzelCardlarımız yatay olarak
                // genişleyebildiği kadar genişlemesini belirttik
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Ve Özel olarak oluşturduğumuz widgeti kullanarak elemanlarımızı ekliyoruz
                  OzelCard(
                    raisedButton: RaisedButton(
                      child: Icon(Icons.phone,
                          size: myIconSize, color: Colors.red),
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context)=>Iletisimsayfasi(),
                          ),
                        );},),

                    title: Text("İletişim Bölümü", style: myTextStyle),
                  ),
                  OzelCard(
                    title: Text("Ayarlar Bölümü", style: myTextStyle),
                    raisedButton: RaisedButton(
                      child: Icon(Icons.settings,
                          size: myIconSize, color: Colors.red),
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context)=>Ayarsayfasi(),
                          ),
                        );},),
                  ),
                  OzelCard(
                    title: Text("Konum Ayarları", style: myTextStyle),
                    raisedButton: RaisedButton(
                      child: Icon(Icons.location_on,
                          size: myIconSize, color: Colors.red),
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context)=>Lokasyon.MyApp(),
                          ),
                        );},),
                  ),
//                  OzelCard(
//                    title: Text("Konum Yolla", style: myTextStyle),
//
//                    raisedButton: RaisedButton(
//                      child: Icon(Icons.message,
//                          size: myIconSize,
//                          color: Colors.red),
//                      onPressed: (){ sendsms();},
//
////                      onPressed: () => Navigator.push(context, MaterialPageRoute(
////                        builder: (context) => RaporlarSayfasi(),
//
//                    ),
//                  ),
                  OzelCard(
                    title: Text("Rapor Listesi", style: myTextStyle),

                    raisedButton: RaisedButton(
                      child: Icon(Icons.rate_review,
                          size: myIconSize,
                          color: Colors.red),


                      onPressed: () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => RaporlarSayfasi(),
                      ),),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }


}

// Uygulamamızın başka yerlerinde kullanabileceğimiz bir widget oluşturduk
class OzelCard extends StatelessWidget {

  final Widget title;
  final Widget raisedButton;


  // Constructor.
  OzelCard({this.title,  this.raisedButton});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 1.0),
      child: Card(
        child: Container(
          margin: const EdgeInsets.all(10.0),
          width: 250,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              this.title,
              this.raisedButton,
            ],
          ),
        ),
      ),
    );
  }
}