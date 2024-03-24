import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';



import '../TGlobal_inc.dart';
import '../TBleSingleton.dart';




class TPrivNfcWnd extends StatefulWidget {

  final int uid;

  TPrivNfcWnd({required this.uid});

  @override
  _TPrivNfcWndState createState() => _TPrivNfcWndState();
}


class _TPrivNfcWndState extends State<TPrivNfcWnd> {


  bool _isStart = false;

  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

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
      appBar: AppBar(title: Text(  '录入NFC',
        style: TextStyle(color: Color(0xff222222), fontSize: 20, fontWeight: FontWeight.bold), ),
        elevation: 0.0,
        backgroundColor: Color(0xffeeeeee),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [


           // Center(child: Text('NFC ${widget.uid}', style: TGlobalData().tsTxtFn20Grey22Bn)),

            Center(child: Icon(Icons.nfc , size: 128, color: TGlobalData().crMainThemeColor,)),


            ElevatedButton(
              onPressed:  _isStart ? null :  () {_scanNfcStuff();},
              child: Text( _isStart ? '请感应NFC介质' : '开始录入NFC' , style: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
              style: ElevatedButton.styleFrom(
                primary: TGlobalData().crMainThemeColor,
                onPrimary: TGlobalData().crMainThemeOnColor,
                shadowColor: Colors.white,
                padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                shape: StadiumBorder(),
              ),
            ),

          ],
        ),
      ),
    );

  }




  Future<void> _scanNfcStuff() async {

    bool isOk = false;

    Completer tmpC = Completer<void>();

    print('nfc scan.....');

    StreamSubscription<String> jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) {

       print('got nfc jsonstr: $jsonStr');

      var jsonObj = jsonDecode(jsonStr);
      var rsl = jsonObj['nfc'];

      if(rsl != null  && rsl == ResultCodeToApp_e.Rsl_Nfc_Append_One_Nfc_Ok.index){

        TGlobalData().showToastInfo('添加NFC成功!');
        isOk = true;
        tmpC.complete();
      }




    });

    var jobj = {};
    jobj["sjtjyhnfc"] =  widget.uid  ;


    TBleSingleton().sendFramedJsonData(json.encode(jobj));

    setState(() {
      _isStart = true;
    });

    await  tmpC.future;

    jsonSSub.cancel();

    Navigator.pop(context , isOk);


  }






















}
