import 'package:flutter/material.dart';
import "package:firebase_messaging/firebase_messaging.dart";

class FirebaseMesajDemo extends StatefulWidget{

  FirebaseMesajDemo(): super();
  final String title = "firebase mesajı demosu";

  @override
  State<StatefulWidget> createState() => FirebaseMesajDemoState();
}

class FirebaseMesajDemoState extends State<FirebaseMesajDemo> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  _getToken() {
    _firebaseMessaging.getToken().then((deviceToken) {
      print("cihaz token: $deviceToken");
    });
  }
  List<Message> messagesList;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    messagesList = List<Message>();
    _getToken();
    _configureFirebaseListeners();
  }



  _configureFirebaseListeners() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
        _setMessage(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
        _setMessage(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
        _setMessage(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true),
    );
  }

  _setMessage(Map<String, dynamic> message) {
    final notification = message['notification'];
    final data = message['data'];
    final String title = notification['title'];
    final String body = notification['body'];
    String mMessage = data['message'];
    print("Title: $title, body: $body, message: $mMessage");
    setState(() {
      Message msg = Message(title, body, mMessage);
      messagesList.add(msg);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: null == messagesList ? 0 : messagesList.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                messagesList[index].message,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
  class Message {
  String title;
  String body;
  String message;
  Message(title, body, message) {
  this.title = title;
  this.body = body;
  this.message = message;
  }
  }