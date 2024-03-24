import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'TReaptRulesWnd.dart';

import '../TGlobal_inc.dart';
import '../TBleSingleton.dart';

class TReaptPwdWnd extends StatefulWidget {
  // TReaptPwdWnd();

  @override
  _TReaptPwdWndState createState() => _TReaptPwdWndState();
}

class _TReaptPwdWndState extends State<TReaptPwdWnd> {

  final _nameTxtCtrlor = TextEditingController();
  final _pwdTxtCtrlor = TextEditingController();

  DateTime _startTime = DateTime(0);
   DateTime _endTime  = DateTime(0);

  DateTime _startDate = DateTime(0);
  DateTime _endDate   = DateTime(0);

   String _validDateStr = '未设置';
  String _validTimeStr = '未设置';

  List<String> _typeStrLs = ['每天','每周','每月'  ];

  int _currRepeatType = 0;
  int _repeatFlags = 0;
  int _monthRepeatFlags = 0;


  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

   // _endDTime = _startDTime.add(Duration(days: 1));

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
    double widW = MediaQuery.of(context).size.width;
    double widH = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop:   _askIfLeave,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '添加周期密码',
            style: TextStyle(
                color: Color(0xff222222),
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          elevation: 0.0,
          backgroundColor: Color(0xffeeeeee),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: (){FocusScope.of(context).unfocus();},
          child: Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 12),
              color: TGlobalData().crMainBgColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [



                  TextField(
                    controller: _nameTxtCtrlor,
                    cursorColor: TGlobalData().crMainThemeColor,

                    style: TGlobalData().tsTxtFn20Grey22Bn,

                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 20.0),
                      hintText: '输入名称',
                      hintStyle: TGlobalData().tsTxtFn20GreyAA,
                      //border: ,
                        enabledBorder:  UnderlineInputBorder(borderSide: BorderSide(color: TGlobalData().crGreyDD)),
                       focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: TGlobalData().crMainThemeColor)),
                      suffixIcon: _nameTxtCtrlor.text.isEmpty ? null : IconButton(
                        icon: Icon(Icons.clear, color: TGlobalData().crGreyBB,),
                        onPressed: ()  => setState(() => _nameTxtCtrlor.clear()) ,
                      ),
                    ),
                    onChanged: (val)=> setState(() {}) ,
                  ),


                  SizedBox(  height: 16.0,    ),



                        TextField(
                          controller: _pwdTxtCtrlor,
                          keyboardType: TextInputType.number,

                          cursorColor: TGlobalData().crMainThemeColor,
                          maxLength: 10,


                          style: TGlobalData().tsTxtFn26Grey22Bw900Sp6,

                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                            hintText: '请输入6～10位密码',
                            hintStyle: TGlobalData().tsTxtFn20GreyCC,

                            enabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(14.0) ,
                              borderSide: BorderSide(color: TGlobalData().crGreyAA)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0) ,
                                borderSide: BorderSide(color: TGlobalData().crMainThemeColor)),
                            suffixIcon: _pwdTxtCtrlor.text.isEmpty ? null : IconButton(
                              icon: Icon(Icons.clear, color: TGlobalData().crGreyBB,),
                              onPressed: ()  => setState(() => _pwdTxtCtrlor.clear()) ,
                            ),
                          ),
                          onChanged: (val)=> setState(() {}) ,
                        ),


                  SizedBox(  height: 14.0,    ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: widW * .22),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          String str = TGlobalData().generateRndNumberStr(7);
                          _pwdTxtCtrlor.value = TextEditingValue(text: str,
                          selection: TextSelection.collapsed(offset: str.length));
                        //  _pwdTxtCtrlor.text = '${TGlobalData().generateRndNumberStr(7)}';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(10.0),
                        primary: TGlobalData().crMainBgColor,
                        shape: StadiumBorder(),
                        side: BorderSide(color: TGlobalData().crGreyBB, width: 1),
                        shadowColor: Colors.transparent,
                        elevation: 0,
                      ),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12.0,
                        children: [
                          Icon(
                            Icons.refresh,
                            color: TGlobalData().crGrey22,
                            size: 26,
                          ),
                          Text(
                            '点击生成',
                            style: TGlobalData().tsTxtFn18Grey22,
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(flex: 10, child: SizedBox()),

                  InkWell(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: TGlobalData().crGreyCC)),
                      ),
                      child: Row(
                        children: [

                          Text('重复规则' , style: TGlobalData().tsTxtFn20Grey22,),
                          Expanded( child: SizedBox()),
                          Text(_typeStrLs[_currRepeatType], style: TGlobalData().tsTxtFn18GreyBB,),

                          Icon(Icons.navigate_next , size: 32, color: TGlobalData().crGreyBB,),

                        ],
                      ),
                    ),
                    onTap: () async {
                      final rtn =  await  Navigator.push(context, MaterialPageRoute(builder: (ctx) => TReaptRulesWnd())) ;
                      if(rtn != null){

                        _repeatFlags = rtn[1];
                        _monthRepeatFlags = rtn[2];

                        setState(() {
                          _currRepeatType = rtn[0]   ;
                        });


                      }


                      },
                  ),



                  InkWell(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: TGlobalData().crGreyCC)),
                      ),
                      child: Row(
                        children: [

                          Text('有效日期' , style: TGlobalData().tsTxtFn20Grey22,),
                          Expanded( child: SizedBox()),
                          Text(_validDateStr , style: TGlobalData().tsTxtFn18GreyBB,),

                          Icon(Icons.navigate_next , size: 32, color: TGlobalData().crGreyBB,),

                        ],
                      ),
                    ),

                    onTap: () async {
                      final rtnLs = await  Navigator.push(context, MaterialPageRoute(builder: (ctx) => TValidDateWnd(_startDate,_endDate)));
                      if(rtnLs != null){
                        DateTime dt1 = rtnLs[0];
                        DateTime dt2 = rtnLs[1];
                        if(dt1 != DateTime(0) && dt2 != DateTime(0)){

                          _startDate = dt1;
                          _endDate = dt2;
                          _validDateStr = DateFormat('yyyy.MM.dd').format(dt1) + '～' + DateFormat('yyyy.MM.dd').format(dt2);

                          setState(() {  });
                        }
                      }

                    },
                  ),



                  InkWell(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: TGlobalData().crGreyCC)),
                      ),
                      child: Row(
                        children: [

                          Text('有效时段' , style: TGlobalData().tsTxtFn20Grey22,),
                          Expanded( child: SizedBox()),
                          Text(_validTimeStr , style: TGlobalData().tsTxtFn18GreyBB,),

                          Icon(Icons.navigate_next , size: 32, color: TGlobalData().crGreyBB,),

                        ],
                      ),
                    ),
                    onTap: () async {
                    final rtnLs = await  Navigator.push(context, MaterialPageRoute(builder: (ctx) => TValidTimeWnd(_startTime,_endTime)));
                    if(rtnLs != null){
                      DateTime dt1 = rtnLs[0];
                      DateTime dt2 = rtnLs[1];
                     if(dt1 != DateTime(0) && dt2 != DateTime(0)){

                       _startTime = dt1;
                       _endTime = dt2;
                       _validTimeStr = DateFormat('HH:mm').format(dt1) + ' ～ ' + DateFormat('HH:mm').format(dt2);

                       setState(() {  });
                     }
                    }

                      },
                  ),


                  Expanded(flex: 10, child: SizedBox()),
                  ElevatedButton(
                    child: Text(
                      '保  存',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: TGlobalData().crMainThemeColor,
                      onPrimary: TGlobalData().crMainThemeOnColor,
                      shadowColor: Colors.white,
                      padding: EdgeInsets.all(10.0),
                      shape: StadiumBorder(),
                    ),
                    onPressed: (_pwdTxtCtrlor.text.isEmpty || _nameTxtCtrlor.text.isEmpty) ? null : () async {

                      if( _pwdTxtCtrlor.text.length < 6)  {
                        TGlobalData().showToastInfo("请生成密码....");
                        return;
                      }

                      bool isOk = false;
                      if(await _saveRepeatPwdToLock()) {
                        TGlobalData().showToastInfo("保存成功!!");
                        isOk = true;
                      }else  TGlobalData().showToastInfo("保存失败!!");

                      Navigator.pop(context , isOk);

                    },
                  ),
                ],
              )),
        ),
      ),
    );
  }


  Future<bool> _saveRepeatPwdToLock() async {
    bool rtn = false;

    Completer tmpC = Completer<void>();
    StreamSubscription<String> jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) {

      //  print('got jsonstr: $jsonStr');

      var jsonObj = jsonDecode(jsonStr);
      var val = jsonObj['rsl'];
      rtn = int.parse(val.toString()) == ResultCodeToApp_e.Rsl_Ok_Ok.index ;
      tmpC.complete();

    });

    int sy = _startDate.year;
    int ey = _endDate.year;
    if( sy == 0) sy = DateTime.now().year;
    if( ey == 0) ey = DateTime.now().year;

    DateTime  sdt = DateTime(sy , _startDate.month, _startDate.day, _startTime.hour, _startTime.minute);
    DateTime  edt = DateTime(ey , _endDate.month, _endDate.day, _endTime.hour, _endTime.minute);

    int ksrq = 0;
    int jsrq = 0;
    //if(sdt != DateTime(0))
      ksrq =  sdt.millisecondsSinceEpoch ~/ 1000;
    //if(edt != DateTime(0))
      jsrq =  edt.millisecondsSinceEpoch ~/ 1000;

    var jobj = {};
    jobj["sjtjzqxmm"] =  _pwdTxtCtrlor.text;
    jobj["uid"] = int.parse(  TGlobalData().currUid );
    jobj["mmmc"] =  _nameTxtCtrlor.text;
    jobj["cfgz"] =  _repeatFlags ;
    jobj["mycfr"] =  _monthRepeatFlags ;
    jobj["ksrq"] =  ksrq ;
    jobj["jsrq"] =  jsrq ;


    TBleSingleton().sendFramedJsonData(json.encode(jobj));

    await  tmpC.future;
    jsonSSub.cancel();

    return Future.value(rtn);

  }


  Future<bool> _askIfLeave( ) async {

    final rtn = await showDialog(context: context,
        builder: (BuildContext dctx) {
          return Material(
            color: Colors.transparent,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: (){Navigator.pop(dctx);},
              child: Container(
                  margin: EdgeInsets.symmetric(horizontal: MediaQuery
                      .of(context)
                      .size
                      .width * .08,
                      vertical: MediaQuery
                          .of(context)
                          .size
                          .height * .32),
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Icon(Icons.warning, color: Colors.yellow, size: 64.0,),
                        Text(
                          '确定放弃添加？' ,
                          textAlign: TextAlign.center,
                          style: TGlobalData().tsListTitleTS1,),



                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [


                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(dctx, true);
                              },
                              child: Text('确  定', style: TextStyle(color: Colors
                                  .white, fontSize: 20, fontWeight: FontWeight
                                  .bold),),
                              style: ElevatedButton.styleFrom(
                                primary: TGlobalData().crMainThemeColor,
                                onPrimary: TGlobalData().crMainThemeOnColor,
                                shadowColor: Colors.white,
                                padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                                shape: StadiumBorder(),
                              ),
                            ),


                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(dctx);
                              },
                              child: Text('取  消', style: TGlobalData().tsTxtFn20Grey88),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: TGlobalData().crMainThemeOnColor,
                                shadowColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                                shape: StadiumBorder(),
                                side: BorderSide(color: TGlobalData().crGreyBB),
                              ),
                            ),

                          ],
                        ),
                      ],
                    ),
                  )

              ),
            ),
          );
        });

    if ((rtn != null) && (rtn as bool)) {
     // print('rtn true');
      return true;
    }

    return false;

  }


}
