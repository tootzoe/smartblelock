import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import "package:googleapis_auth/auth_io.dart";

import '../TGlobal_inc.dart';




class TPushNotify extends StatefulWidget {

  @override
  _TPushNotifyState createState() => _TPushNotifyState();
}


class _TPushNotifyState extends State<TPushNotify> {

  late String _token;
  late Stream<String> _tokenStream;

  final TextEditingController _titleTxtCtrlor = TextEditingController();
  final TextEditingController _contentTxtCtrlor = TextEditingController();

  int _pathStep = 0;
  int _pathMaxStep = 4;

  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

    _titleTxtCtrlor.text = '这是标题....';
    _contentTxtCtrlor.text = '这是内容…..';

    FirebaseMessaging.instance
        .getToken(
        vapidKey:
        'your key here')
        .then((tk) {
          if(tk != null)
            _setToken(tk);
    });
    _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    _tokenStream.listen(_setToken);


  }

  @override
  void deactivate() {
    print('${this.runtimeType.toString()} deactivate()......................');
  }

  @override
  void dispose() {
    print('${this.runtimeType.toString()} dispose()......................');

    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(  '推送消息',
        style: TextStyle(color: Color(0xff222222), fontSize: 20, fontWeight: FontWeight.bold), ),
        elevation: 0.0,
        backgroundColor: Color(0xffeeeeee),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {FocusScope.of(context).unfocus();},
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('标题：'),
                  Container(
                    width: 300,
                    child: TextField(

                      controller: _titleTxtCtrlor,
                    ),
                  ),
                ],
              ),


              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('内容：'),
                  Container(
                    width: 300,
                    child: TextField(
                      controller: _contentTxtCtrlor,
                    ),
                  ),
                ],
              ),



            ElevatedButton(
                child: Text('测试推送消息'),
                onPressed: () async {

                  FocusScope.of(context).unfocus();

                  _sendPushMessage();

                }
            ),

             // Center(child: TAnimaPath(_pathStep, _pathMaxStep , 82, 128)),


              Row(children: [
                Expanded( flex: 16, child: SizedBox()),

                Text('采集次数：'),

                DropdownButton<String>(
                  value: '$_pathMaxStep',
                  items: <int>[for(int i =1; i < 9 ; i ++ ) i] .map((int value) {
                    return   DropdownMenuItem<String>(
                      value: '$value',
                      child:   Text('$value'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    //print('combox selected value.....$val');
                    setState(() {
                      _pathMaxStep = int.parse(val!)  ;
                    });
                  },
                ),

                Expanded( flex: 50, child: SizedBox()),



              ],),

              ElevatedButton(
                  child: Text('当前采集次数 $_pathStep'),
                  onPressed: () async {

                    setState(() {
                      _pathStep = (_pathStep + 1) % (_pathMaxStep + 1);
                    });

                  }
              ),

            ],
          ),
        ),
      ),
    );

  }



  Future<void> _sendPushMessage() async {

   // print('do sendPushMessage()....');

    if (_token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    final accountCredentials = ServiceAccountCredentials.fromJson({   }
    );

    var scopes = ['https://www.googleapis.com/auth/firebase.messaging'];


    clientViaServiceAccount(accountCredentials, scopes).then((AuthClient client) async {
      // [client] is an authenticated HTTP client.
      // ...
     // print('[client] is an authenticated HTTP client....................................................');

      // print(client.credentials.scopes);
      // print(client.credentials.accessToken);


      try {
        final resp = await client.post(
          Uri.parse('https://fcm.googleapis.com/v1/projects/awesmartblelock/messages:send'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            // 'Authorization': 'key=AIzaSyBk2PeWn4E2EcrcQr-7ni9BvfSuj23U1D4'
          },
          body: _constructFCMPayload(_token),
        );

        print(resp.body);

        print('FCM request for device sent!');
      } catch (e) {
        print(e);
      }


      client.close();
    });

  }

  String _constructFCMPayload(String token) {

    return jsonEncode({

      "message":{
         "token":token,
      //  'topic':'thortopic',
        //'condition':"'foo' in topics && 'bar' in topics",
//
        "notification":{
          "title":_titleTxtCtrlor.text,
          "body": _contentTxtCtrlor.text,
        },
        "android":{
          "ttl":"86400s",
          "notification":{
            "click_action":"OPEN_ACTIVITY_1",
          }
        },
        "apns": {
          "headers":{
            "apns-priority": "5",
          },
          "payload": {
            "aps": {
              "category": "NEW_MESSAGE_CATEGORY",
            }
          }
        },
      }
    });
  }


  Future<void> _setToken(String token) async {
    print('FCM Token: $token');
    setState(() {
      _token = token;
    });
  }

}
