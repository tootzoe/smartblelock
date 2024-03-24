import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';

import 'package:numberpicker/numberpicker.dart';


import '../TGlobal_inc.dart';
import '../TBleSingleton.dart';

import 'CustomSwitchRound.dart';


class TOnetimePwdWnd extends StatefulWidget {


     // TOnetimePwdWnd();

  @override
  _TOnetimePwdWndState createState() => _TOnetimePwdWndState();
}


class _TOnetimePwdWndState extends State<TOnetimePwdWnd> {


  String _genPwdStr = '';

  bool _isNotRightNow = true;

  late DateTime _startTime ;// = DateTime.now();
  late DateTime _endTime ;//= DateTime(1970,1,1,23,59);

  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();
    DateTime nowT = DateTime.now();

    _startTime = DateTime(nowT.year,nowT.month, nowT.day);
    _endTime = DateTime(nowT.year,nowT.month, nowT.day , 23, 59);

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

   // context.f

    return Scaffold(
      appBar: AppBar(title: Text(  '一次性密码',
        style: TextStyle(color: Color(0xff222222), fontSize: 20, fontWeight: FontWeight.bold), ),
        elevation: 0.0,
        backgroundColor: Color(0xffeeeeee),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 12),
        color: TGlobalData().crMainBgColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Text('生成一次性密码', style: TGlobalData().tsHeader0TextStyle)),
              SizedBox(height: 10.0,),
              Center(child: Text('失效前仅可使用一次', style: TGlobalData().tsTxtFn18Grey88)),


              Container(
                margin: EdgeInsets.symmetric(vertical: 20.0),
                padding: EdgeInsets.fromLTRB(40, 10, 10, 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: TGlobalData().crGrey88),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Text(_genPwdStr,
                      textAlign: TextAlign.center,
                      style: TGlobalData().tsTxtFn26Grey22Bw900Sp6, )),

                    IconButton(icon: Icon(Icons.copy , color: TGlobalData().crGreyBB,),
                    onPressed: (){
                      TGlobalData().showToastInfo("复制成功!");
                    },
                    ),

                  ],
                ),
              ),


              Padding(
                padding:   EdgeInsets.symmetric(horizontal: widW * .22 ),
                child: ElevatedButton(
                    onPressed: (){
                      setState(() {
                        _genPwdStr = '${TGlobalData().generateRndNumberStr(7)}';
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
                      Icon(Icons.refresh, color: TGlobalData().crGrey22, size: 26,),
                      Text('点击生成', style: TGlobalData().tsTxtFn18Grey22,),
                    ],),
                ),
              ),

             // Expanded( flex: 6 ,child: SizedBox()),

              SizedBox(height: 30,),


              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.timer , size: 48, color: TGlobalData().crGrey44,),
                title: Text('定时生效' , style: TGlobalData().tsTxtFn20Grey22Bn,),
                subtitle: Text('未设定时间，则默认为立即生效', style: TGlobalData().tsTxtFn14GreyAA,),

                trailing:
                // Switch(
                //   value: _isNotRightNow,
                //   onChanged: (bool b) {
                //     setState(() {
                //       _isNotRightNow = !_isNotRightNow;
                //     });
                //   },
                // ),

                CustomSwitchRound(switched: _isNotRightNow,widW: 46, widH: 24,),


                onTap: (){
                  setState(() {
                    _isNotRightNow = !_isNotRightNow;
                  });
                },

              ),

              Expanded( flex: 4 ,child: SizedBox()),

              if(_isNotRightNow)
              Container(
                padding: EdgeInsets.fromLTRB(12, 24, 4, 24),
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(12.0),
                   border: Border.all(color: TGlobalData().crGreyBB),
                 ),
                   child: Row(
                     crossAxisAlignment: CrossAxisAlignment.center,
                     children: [

                       Text('当天有效：' , style: TGlobalData().tsTxtFn20Grey88,),

                       InkWell(child: Text(DateFormat('HH:mm').format(_startTime) , style: TGlobalData().tsTxtFn24Grey22Bn,),
                       onTap: () async {

                         DateTime tmpDt = await  _chooseTimeWnd( '开始时间' , _startTime);
                         if(tmpDt != DateTime(0)){
                           _startTime = tmpDt;
                           setState(()   {   });
                         }


                         }, ),
                       Text(' ～ ' , style: TGlobalData().tsTxtFn24Grey22Bn,),
                       InkWell(child: Text(DateFormat('HH:mm').format(_endTime) , style: TGlobalData().tsTxtFn24Grey22Bn,),
                         onTap: () async {
                           DateTime tmpDt  = await  _chooseTimeWnd( '结束时间' , _endTime);
                           if(tmpDt != DateTime(0)){
                             _endTime = tmpDt;
                             setState(()   {   });
                           }

                         }, ),
                       Expanded( child: SizedBox()),


                       Icon(Icons.navigate_next, size: 26 , color: TGlobalData().crGreyAA,),


                     ],
                   )
              ),



              Expanded( flex: 10 ,child: SizedBox()),


              ElevatedButton(
                child: Text('保  存' , style: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
                style: ElevatedButton.styleFrom(
                  primary: TGlobalData().crMainThemeColor,
                  onPrimary: TGlobalData().crMainThemeOnColor,
                  shadowColor: Colors.white,
                  padding: EdgeInsets.all(10.0),
                  shape: StadiumBorder(),

                ),
                onPressed: () async {

                  if(_genPwdStr.isEmpty)  {
                      TGlobalData().showToastInfo("请生成密码....");
                      return;
                    }

                  bool isOk = false;
                  if(await _saveOneTimePwdToLock()) {
                    TGlobalData().showToastInfo("保存成功!!");
                    isOk = true;
                  }else  TGlobalData().showToastInfo("保存失败!!");

                  Navigator.pop(context , isOk);

                },

              ),

            ],
          )),
    );

  }

  Future<bool> _saveOneTimePwdToLock() async {
    bool rtn = false;

    Completer tmpC = Completer<void>();
    StreamSubscription<String> jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) {

      //  print('got jsonstr: $jsonStr');

      var jsonObj = jsonDecode(jsonStr);
      var val = jsonObj['rsl'];
      rtn = int.parse(val.toString()) == ResultCodeToApp_e.Rsl_Ok_Ok.index ;
      tmpC.complete();

    });
  //  $(PROJECT_DIR)/build/ios/Debug-iphoneos/Toast/libToast.a
    var jobj = {};
    jobj["sjtjycxmm"] =  _genPwdStr;
    jobj["uid"] =  int.parse( TGlobalData().currUid) ;
    jobj["qymm"] = 1 ;//  _isNotRightNow ? '1' : '0';
    jobj["ksrq"] = _isNotRightNow ?  _startTime.millisecondsSinceEpoch ~/ 1000  : 0;
    jobj["jsrq"] = _isNotRightNow ?  _endTime.millisecondsSinceEpoch ~/ 1000  : 0;

    TBleSingleton().sendFramedJsonData(json.encode(jobj));

    await  tmpC.future;
    jsonSSub.cancel();

    return Future.value(rtn);

  }


  Future<DateTime>  _chooseTimeWnd(String titleTxt , DateTime oriDt) async
  {

   // print(DateTime(1970,1,1,0,0,0).toUtc().millisecondsSinceEpoch  );
   // print(DateTime.now().timeZoneOffset.inSeconds  );

    final rtn =  await    showDialog(context: context,
        builder: (BuildContext bctx){

          int _hourVal = oriDt.hour;
          int _minuteVal = oriDt.minute;

      return StatefulBuilder(
        builder: (BuildContext sfbctx, void Function(void Function()) setState) {
          return  Material(
                color: Colors.transparent,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.pop(bctx);
                  },
                  child: Container(
                      padding: EdgeInsets.all(22.0),
                      margin: EdgeInsets.only(top: MediaQuery
                          .of(context)
                          .size
                          .height * .4),
                      // color: Colors.cyan,
                      decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius
                                  .circular(40.0))
                          )
                      ),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () { },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [

                            Center(child: Text(titleTxt , style: TGlobalData().tsTxtFn24Grey22Bn,)),


                            Center(child: Text('一次性密码为当天有效',
                              style: TGlobalData().tsTxtFn16Grey66,)),


                            Stack(
                             // fit: StackFit.expand,
                              children: [


                                  Container(
                                    margin: EdgeInsets.only(top: 44.0),
                                    height: 64.0,
                                    width: double.infinity,
                                    color: TGlobalData().crWWeakGrey,),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    NumberPicker(
                                      minValue: 0, maxValue: 23, value: _hourVal,
                                      textStyle: TGlobalData().tsTxtFn26GreyBB,
                                      selectedTextStyle: TGlobalData().tsTxtFn26Grey22Bn,
                                      textMapper: (ori){return sprintf('%02i',[int.parse(ori)]) ;},
                                      onChanged: (val) => setState(() => _hourVal = val ),
                                    ),


                                    Text('：', style: TGlobalData().tsTxtFn26Grey22Bw900Sp6,),

                                    NumberPicker(
                                      minValue: 0, maxValue: 59, value: _minuteVal,
                                      textStyle: TGlobalData().tsTxtFn26GreyBB,
                                      selectedTextStyle: TGlobalData().tsTxtFn26Grey22Bn,
                                      textMapper: (ori){return sprintf('%02i',[int.parse(ori)]) ;},
                                      onChanged: (val) => setState(() => _minuteVal = val ),
                                    ),


                                  ],
                                ),


                              ],
                            ),


                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(bctx , [_hourVal, _minuteVal]);
                                },
                                child: Text(
                                  '保  存', style: TGlobalData().tsTxtFn20GreyFF,),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.all(12.0),
                                  primary: TGlobalData().crMainThemeColor,
                                  onPrimary: TGlobalData().crMainThemeDownColor,


                                  shape: StadiumBorder(),
                                ),
                              ),
                            ),


                          ],
                        ),
                      )),
                )
            );

        }
      );
        });

    DateTime rtnDt = DateTime(0);
    if(rtn != null) {
      List<int> tmpLs = rtn as List<int>;
    //  print(' chooson result: ${tmpLs[0]} : ${tmpLs[1]}');
      DateTime nowT = DateTime.now();
      rtnDt = DateTime(nowT.year,nowT.month, nowT.day , tmpLs[0], tmpLs[1]);
      }

    return Future.value(rtnDt);

  }




}
