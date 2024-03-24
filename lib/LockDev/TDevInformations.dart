import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';


import '../TGlobal_inc.dart';
import '../TBleSingleton.dart';


class TDevInformations extends StatefulWidget {


  @override
  _TDevInformationsState createState() => _TDevInformationsState();
}


class _TDevInformationsState extends State<TDevInformations> {


  final List<String> titleLs = [
    '门锁型号',
    '门锁序列号',
    '锁体序列号',
    '主板硬件版本号',
    '主板固件版本号',
    '副板硬件版本号',
    '副板固件版本号',
    '蓝牙模块信息',
    '指纹模块信息'
  ];


  List<String> titleValLs =  [];


  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

    for(var s in titleLs)
      titleValLs.add('');

    Future.delayed(Duration(milliseconds: 300)).then((_) => _fetchLockInfo());

  }

  @override
  void deactivate() {
    print('${this.runtimeType.toString()} deactivate().... ..............');
  }

  @override
  void dispose() {
    print('${this.runtimeType.toString()} dispose()......................');

    super.dispose();
  }

  void _fetchLockInfo() async
  {


    final Completer tmpC = Completer<void>();

    StreamSubscription<String> jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) {

     //  print('got jsonstr: $jsonStr');

      var jsonObj = jsonDecode(jsonStr);

      if(jsonObj != null){
        dynamic tmpObj = jsonObj['sjhqsbxx'];
        if(tmpObj != null){
           List<dynamic> tmpLs = tmpObj as List<dynamic>;
          // if(   titleLs.length == tmpLs.length)
           {
              for(int i = 0 ; i < tmpLs.length ;  i ++)
                 titleValLs[i] = tmpLs[i].toString();

           }
        }
      }

      if(!tmpC.isCompleted)
        tmpC.complete();

    });

    var jobj = {};
    jobj["sjhqsbxx"] =  '';
    TBleSingleton().sendFramedJsonData(json.encode(jobj));


    await tmpC.future;
    jsonSSub.cancel();

       setState(() {  });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('设备信息',style: TGlobalData().tsHeaderTextStyle,),
      elevation: 0,
        iconTheme: IconThemeData(color: Color(0xff333333)),
        backgroundColor: Color(0xfffafafa),
      ),
      body:
      Container(
        padding: EdgeInsets.all(24),
        child: ListView.separated(
              itemCount:titleLs.length,
              itemBuilder: (context,idx){

                if(idx  == titleLs.length - 2) // ble modula info
                  return   InkWell(
                    onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => TBleNameWnd()));},
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 0,vertical: 6),
                      //color: Colors.tealAccent,
                      // child: Text('${titleLs[idx]}' , style: TextStyle(fontSize: 16),),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('${titleLs[idx]}' , style: TextStyle(fontSize: 16),),
                          Expanded(child: SizedBox()),
                          Text('${titleValLs[idx]}' , style: TextStyle(fontSize: 16 , color: Colors.grey),),
                          Icon( CupertinoIcons.forward , color: Colors.grey),
                        ],),
                    ),
                  );

                if(idx  == titleLs.length -1) // fingerprint modula info
                  return   InkWell(
                    onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => TFingerprintInfo()));},
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 0,vertical: 6),
                      //color: Colors.tealAccent,
                      // child: Text('${titleLs[idx]}' , style: TextStyle(fontSize: 16),),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('${titleLs[idx]}' , style: TextStyle(fontSize: 16),),
                          Icon( CupertinoIcons.forward , color: Colors.grey),
                        ],),
                    ),
                  );

              return   Container(
                margin: const EdgeInsets.symmetric(horizontal: 0,vertical: 6),
                //color: Colors.tealAccent,
               // child: Text('${titleLs[idx]}' , style: TextStyle(fontSize: 16),),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('${titleLs[idx]}' , style: TextStyle(fontSize: 16),),
                    Text('${titleValLs[idx]}' , style: TextStyle(fontSize: 16 , color: Colors.grey),),
                ],),
              );

          },

          separatorBuilder: (context,idx){
                return Divider();
           },

          ),


      ),





    );

  }
}



class TBleNameWnd extends StatefulWidget {


  @override
  _TBleNameWndState createState() => _TBleNameWndState();
}


class _TBleNameWndState extends State<TBleNameWnd> {

  final _blenameTxtCtrlor = TextEditingController();
  String _oldBleName = '';

  bool _isBtnEnabled = true;


  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 100)).then((_) => _fetchBleName());
  }

  @override
  void deactivate() {
    print('${this.runtimeType.toString()} deactivate().... ..............');
  }

  @override
  void dispose() {
    print('${this.runtimeType.toString()} dispose()......................');

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('蓝牙名称',style: TGlobalData().tsHeaderTextStyle,),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xff333333)),
        backgroundColor: Color(0xfffafafa),
      ),
      body:
      GestureDetector(

        behavior: HitTestBehavior.opaque,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Container(

              padding: EdgeInsets.all(20.0),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  Expanded(
                    flex: 10,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        '支持中英文，数字（10个字符内）',
                        style: TGlobalData().tsListCntTS1,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 10,
                    child: TextField(
                      controller: _blenameTxtCtrlor,
                      decoration: InputDecoration(

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.black38),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.black38),
                        ),
                        suffixIcon:  _blenameTxtCtrlor.text.isEmpty  ? null :  IconButton(icon: Icon(Icons.clear,color: TGlobalData().crMainThemeColor,),
                          onPressed: (){
                            setState(() {
                              _blenameTxtCtrlor.clear();
                            });

                          } , )  ,

                      ),



                      onChanged: (str){
                        setState(() {
                          _isBtnEnabled =  str.isNotEmpty;
                        });


                      },
                    ),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: TGlobalData().crMainThemeColor,
                      onPrimary: Color(0xff119999),

                      shape: StadiumBorder(),
                      shadowColor: Color(0xff118888),
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 0),
                      // textStyle: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                    child: Text(
                      '确   定',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    onPressed: _blenameTxtCtrlor.text.isEmpty  ? null :   () async  {

                      if(_oldBleName == _blenameTxtCtrlor.text){

                      }else{
                        var jobj = {};
                        jobj["sjlymc"] =  _blenameTxtCtrlor.text;
                        TBleSingleton().sendFramedJsonData(json.encode(jobj));

                      }

                      Navigator.pop(context);

                     // TGlobalData().showToastInfo('修改昵称失败....');


                    }  ,
                  ),

                  Expanded(flex :30,child:SizedBox()),

                ],
              )),
        ),
      ),


    );

  }



  void _fetchBleName() async
  {

    final Completer tmpC = Completer<void>();

    StreamSubscription<String> jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) {

      //  print('got jsonstr: $jsonStr');

      var jsonObj = jsonDecode(jsonStr);

      if(jsonObj != null){
        dynamic tmpObj = jsonObj['sjlymc'];
        if(tmpObj != null){

          setState(() {
            _oldBleName = tmpObj.toString();
            _blenameTxtCtrlor.text = _oldBleName;
          });

        }
      }

      if(!tmpC.isCompleted)
        tmpC.complete();

    });

    var jobj = {};
    jobj["sjlymc"] =  '';
    TBleSingleton().sendFramedJsonData(json.encode(jobj));


    await tmpC.future;
    jsonSSub.cancel();

    setState(() {  });

  }


}






class TFingerprintInfo extends StatefulWidget {


  @override
  _TFingerprintInfoState createState() => _TFingerprintInfoState();
}


class _TFingerprintInfoState extends State<TFingerprintInfo> {


  final List<String> titleLs = [
    '唯一标识号',
    '产品序列号',
    '固件包版本号',
    '感应器代号',
    '制造商',
    '指纹容量'
  ];


  List<String> titleValLs =  [];


  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

    for(var s in titleLs)
      titleValLs.add('');

    Future.delayed(Duration(milliseconds: 100)).then((_) => _fetchFpInfo());

  }

  @override
  void deactivate() {
    print('${this.runtimeType.toString()} deactivate().... ..............');
  }

  @override
  void dispose() {
    print('${this.runtimeType.toString()} dispose()......................');

    super.dispose();
  }

  void _fetchFpInfo() async
  {

    final Completer tmpC = Completer<void>();

    StreamSubscription<String> jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) {

    //  print('got jsonstr: $jsonStr');

      var jsonObj = jsonDecode(jsonStr);

      if(jsonObj != null){
        dynamic tmpObj = jsonObj['sjhqzwxx'];
        if(tmpObj != null){
          List<dynamic> tmpLs = tmpObj as List<dynamic>;
          if(   titleLs.length == tmpLs.length){
            for(int i = 0 ; i < titleLs.length ;  i ++)
              titleValLs[i] = tmpLs[i].toString();

          }
        }
      }

      if(!tmpC.isCompleted)
        tmpC.complete();

    });

    var jobj = {};
    jobj["sjhqzwxx"] =  '';
    TBleSingleton().sendFramedJsonData(json.encode(jobj));


    await tmpC.future;
    jsonSSub.cancel();

    setState(() {  });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('指纹模块信息',style: TGlobalData().tsHeaderTextStyle,),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xff333333)),
        backgroundColor: Color(0xfffafafa),
      ),
      body:
      Container(
        padding: EdgeInsets.all(24),
        child: ListView.separated(
          itemCount:titleLs.length,
          itemBuilder: (context,idx){

            return   Container(
              margin: const EdgeInsets.symmetric(horizontal: 0,vertical: 6),
              //color: Colors.tealAccent,
              // child: Text('${titleLs[idx]}' , style: TextStyle(fontSize: 16),),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('${titleLs[idx]}' , style: TextStyle(fontSize: 16),),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 60),
                      child: InkWell(
                        onTap: idx == 0 ? ()=> _showFullTextWnd(titleValLs[idx]) : null,
                        child: Text('${titleValLs[idx]}' , style: TextStyle(fontSize: 16 , color: Colors.grey),
                        overflow: TextOverflow.ellipsis,),
                      ),
                    ),
                  ),
                ],),
            );

          },

          separatorBuilder: (context,idx){
            return Divider();
          },

        ),


      ),





    );

  }

  void _showFullTextWnd(String txt) async
  {

    await showDialog(context: context,
        builder: (BuildContext dctx){
          return Material(
            color: Colors.white,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: (){ Navigator.pop(dctx); },
              child: Container(
                padding: EdgeInsets.all(20),
                  child:Center(
                    child:  Text(txt) ,
                  )

              ),
            ),
          );
        }) ;

  }

}

















