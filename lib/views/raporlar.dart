import 'package:cocuktakipuygulamasi/models/iletisimModel.dart';
import 'package:cocuktakipuygulamasi/models/raporModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cocuktakipuygulamasi/models/DbHelper.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';


class RaporlarSayfasi extends StatefulWidget {
  RaporlarSayfasi({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() =>_RaporlarState();
}

class _RaporlarState extends State<RaporlarSayfasi>{

  @override
  void initState() {
    super.initState();
  }



  Future<String> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Rapor Sayfası")),
//      resizeToAvoidBottomPadding: false,
        body:Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: FutureBuilder<List<Rapor>>(
                      // future olarak database sınıfımızdaki bütün kelimeleri getir
                      // adlı methodunu verdik
                      future: DBHelper().getAllRaporlar(),
                      builder: (BuildContext context, AsyncSnapshot<List<Rapor>> snapshot) {
                        // eğer verdiğimiz future içerisinde veri var ise bunları
                        if (snapshot.hasData) {
                          return ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              Rapor item = snapshot.data[index];
                              return Dismissible(
                                key: UniqueKey(),
                                background: Container(color: Colors.red),
                                onDismissed: (direction) {
                                  DBHelper().deleteRapor(item);
                                },
                                child: ListTile(
                                  title: Text(item.rapor_email),
                                  subtitle: Text(item.rapor_linki),
                                  leading: Text(item.rapor_zamani),
                                  onLongPress: ()async{await _launchURL(item.rapor_linki);}
                                  ),
                              );
                            },
                          );
                          // veri yok ise ekran ortasında dönen progressindicator göster
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    ),

    )
    );



            }


  }




