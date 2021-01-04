import 'dart:isolate';

import 'package:cocuktakipuygulamasi/models/iletisimModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cocuktakipuygulamasi/models/DbHelper.dart';
import 'package:flutter/services.dart';
import 'dart:convert';



class Iletisimsayfasi extends StatefulWidget {
  Iletisimsayfasi({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() =>_IletisimState();
}

class _IletisimState extends State<Iletisimsayfasi>{


  var _formKey = GlobalKey<FormState>();
  String _title;
  String _body;
  String _message;
  String _cihaz;


  @override
  void initState() {
    super.initState();





  }
  String iletisim_kisisi = "";
  String iletisim_email = "";
  bool blocked = true;





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("iletişim Ayar Sayfası")),
//      resizeToAvoidBottomPadding: false,
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: new Builder(builder: (BuildContext context)
          {
            return  Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Text("Aşağıdaki Forma İletişim Bilgilerini Yazınız", style: TextStyle(fontSize: 20),textAlign: TextAlign.center),
                      SizedBox(height: 10),
                      TextField(
                        decoration:InputDecoration(labelText: "Kişi Adı",
                            border: OutlineInputBorder()
                        ),textAlign: TextAlign.center,
                        // Her yeni veri girildiğinde çalışır
                        onChanged: (veri) {
                          iletisim_kisisi = veri;
                        },
                        // Klavyedeki Gönder(Bitti) tuşuna basınca çalışır
                        onSubmitted: (veri) {
                          iletisim_kisisi = veri;
                        },
                      ),
                      SizedBox(height: 10),
                      TextField(
                        inputFormatters: <TextInputFormatter>[
                          BlacklistingTextInputFormatter.singleLineFormatter,
                        ],
                        decoration:InputDecoration(labelText: "Kişi Email",
                            border: OutlineInputBorder()
                        ),textAlign: TextAlign.center,

                        // Her yeni veri girildiğinde çalışır
                        onChanged: (veri) {
                          iletisim_email = veri;
                        },
                        // Klavyedeki Gönder(Bitti) tuşuna basınca çalışır
                        onSubmitted: (veri) {
                          iletisim_email = veri;
                        },
                      ),
                      SizedBox(height: 10),
                      Center(
                          child: RaisedButton(
                              child: Text("İletişim Bilgilerini Ekle"),
                              // Navigator.pop ile bir önceki sayfaya dönücek
                              onPressed: ()   async {

                                Iletisim yeniiletisim = Iletisim(iletisim_kisisi:iletisim_kisisi, iletisim_email: iletisim_email,blocked: true);
                                await DBHelper().newIletisim(yeniiletisim);
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                          title: Text("İletişim Bilgilerini Ekleme İşlemi"),
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
                ),
                Expanded(
                  flex: 5,
                  child: FutureBuilder<List<Iletisim>>(
                    // future olarak database sınıfımızdaki bütün kelimeleri getir
                    // adlı methodunu verdik
                    future: DBHelper().getAllIletisim(),
                    builder: (BuildContext context, AsyncSnapshot<List<Iletisim>> snapshot) {
                      // eğer verdiğimiz future içerisinde veri var ise bunları
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            Iletisim item = snapshot.data[index];
                            return Dismissible(
                              key: UniqueKey(),
                              background: Container(color: Colors.red),
                              onDismissed: (direction) {
                                DBHelper().deleteIletisim(item);
                              },
                              child: ListTile(
                                title: Text(item.iletisim_kisisi),
                                subtitle: Text(item.iletisim_email),
                                leading: Text(item.iletisim_id.toString()),
                                trailing: Checkbox(
                                  onChanged: (bool value) {
                                    DBHelper().blockOrUnblock(item);
                                    setState(() {});
                                  },
                                  value: item.blocked,
                                ),
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
                ),

              ],
            );
          })
      )
    );
  }

}


