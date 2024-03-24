import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'package:intl/intl.dart';

import 'package:numberpicker/numberpicker.dart';
import 'package:sprintf/sprintf.dart';


import '../TGlobal_inc.dart';


class TReaptRulesWnd extends StatefulWidget {


   // TReaptRulesWnd();

  @override
  _TReaptRulesWndState createState() => _TReaptRulesWndState();
}


class _TReaptRulesWndState extends State<TReaptRulesWnd> {


  List<Map> _ruleTypeObjLs = [];

  List<bool> _weekRulesDatLs = [];  //  sunday is 0 index.....

  List<Map> _oneMonthByWeekObjLs = [];
  bool _isMonthLastDay = false;

  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

    List<String> typeStrLs = ['每天','每周','每月', ];

    for(int i = 0 ; i < typeStrLs.length ; i ++){

      var tmpObj = {};
      tmpObj['title'] = typeStrLs[i];
      tmpObj['isChecked'] = i == 0 ? true: false ;

      _ruleTypeObjLs.add(tmpObj);

    }


    List.generate(7, (index) => _weekRulesDatLs.add(false));

    _oneMonthByWeekObjLs = TGlobalData().generateCalendar(DateTime.now());


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
      appBar: AppBar(title: Text(  '重复规则',
        style: TextStyle(color: Color(0xff222222), fontSize: 20, fontWeight: FontWeight.bold), ),
        elevation: 0.0,
        backgroundColor: Color(0xffeeeeee),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        color: TGlobalData().crMainBgColor,
          padding: EdgeInsets.symmetric(horizontal: 20.0 , vertical: 8.0),
          child: Column(
            children: [

              ... <int>[for(int i = 0 ; i < _ruleTypeObjLs.length ; i ++ ) i].map((idx) {
                bool oldV = _ruleTypeObjLs[idx]['isChecked'] as bool;
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: TGlobalData().crGreyDD)),
                  ),
                  child: InkWell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Text(_ruleTypeObjLs[idx]['title'] , style: TGlobalData().tsTxtFn20Grey22,),

                         oldV ?  Icon(Icons.check , size:  30, color:  TGlobalData().crMainThemeColor,)
                        : SizedBox(height: 30,),

                      ],
                    ),
                    onTap: (){


                      for(int i = 0 ; i < _ruleTypeObjLs.length; i ++)
                      _ruleTypeObjLs[i]['isChecked'] = false;

                      _ruleTypeObjLs[idx]['isChecked'] = !oldV;

                      setState(() {});

                    },
                  ),

                );

              }).toList(),

              if(_ruleTypeObjLs[1]['isChecked'] as bool)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 26.0),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: TGlobalData().crGreyDD)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        child: Text('选择自定义周期' , style: TGlobalData().tsTxtFn20GreyAA,),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [

                         // Text(TGlobalData().weekNameByNum(7).substring(2), style: TGlobalData().tsTxtFn20Grey22,),
                          ... <int>[for(int i = 0 ; i < 7 ; i ++) i].map((idx) {
                           final   List<String> _weekNameLs = ['日','一','二','三','四','五','六'];

                            return InkWell(
                              child: Container(
                                width: 40,
                                  height: 40,
                                  decoration: _weekRulesDatLs[idx  ] ?  BoxDecoration(
                                    borderRadius: BorderRadius.circular(50.0),
                                    color: TGlobalData().crMainThemeColor,
                                  ) : null,
                                  child: Center(child: Text(_weekNameLs[idx],
                                    style: _weekRulesDatLs[idx   ] ? TGlobalData().tsTxtFn20GreyFF : TGlobalData().tsTxtFn20Grey22,))),
                            onTap: (){
                              _weekRulesDatLs[idx  ]  = ! _weekRulesDatLs[idx   ] ;
                              setState(() {});

                            },
                            );

                          }).toList(),

                        ],
                      )

                    ],
                  ),
                ),









              if(  _ruleTypeObjLs[2]['isChecked'] as bool   )
                Container(
                  padding: EdgeInsets.only(top: 2.0),
                  // decoration: BoxDecoration(
                  //   border: Border(bottom: BorderSide(color: TGlobalData().crGreyDD)),
                  // ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(DateFormat('yyyy年M月').format(DateTime.now()) , style: TGlobalData().tsTxtFn20Grey22Bn,),
                      ),



                      Stack(
                        children : [
                          Container(
                          padding: EdgeInsets.only(bottom: 0.0),
                        //  margin: EdgeInsets.only(bottom: 6.0),
                          // color: Color(0x110000ff),
                          height: 340,
                          child: GridView.count(
                            controller: null,
                            crossAxisCount: 7,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [

                              ...<int>[for(int i = 0 ; i < _oneMonthByWeekObjLs.length ; i ++) i].map((idx) {

                                bool isCk = false;
                                if(_oneMonthByWeekObjLs[idx]['isChecked'] != null )
                                  isCk =  _oneMonthByWeekObjLs[idx]['isChecked'] as bool;

                                if(idx < 7){
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 0.0),
                                    child: Center(child: Text(_oneMonthByWeekObjLs[idx]['label'],
                                      style: TextStyle(color: Color(0xff888888),fontSize: 16),)),
                                  );
                                }

                                if( _oneMonthByWeekObjLs[idx]['isChecked'] == null)
                                  return SizedBox.shrink();


                                return InkWell(
                                  onTap: (){
                                    bool oriB = (_oneMonthByWeekObjLs[idx]['isChecked'] as bool);
                                    // for(int i = 7 ; i < _oneMonthByWeekObjLs.length ;  i ++)
                                    //   if( _oneMonthByWeekObjLs[i]['isChecked'] != null )
                                    //     _oneMonthByWeekObjLs[i]['isChecked'] = false;

                                    _oneMonthByWeekObjLs[idx]['isChecked'] = !oriB;
                                    setState(() {  });
                                  },
                                  child: Container(
                                    // color: Colors.green,
                                    margin: EdgeInsets.all(2.0),
                                    decoration: BoxDecoration(
                                      color: isCk ?  TGlobalData().crMainThemeColor : Colors.transparent,
                                      borderRadius: BorderRadius.circular(40.0),
                                    ),

                                    child: Center(child: Text(_oneMonthByWeekObjLs[idx]['label'] ,
                                        style: TextStyle(color: Color( isCk ? 0xffffffff : 0xff222222),fontSize: 18))),
                                  ),
                                );
                              }).toList(),

                            ],
                          ),
                        ),


                          Positioned(
                            bottom: 16.0,
                              right: 6.0,
                              child: InkWell(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4.0),
                                 // color: Colors.red,
                                    decoration: BoxDecoration(
                                      color: _isMonthLastDay ?  TGlobalData().crMainThemeColor : Colors.transparent,
                                      borderRadius: BorderRadius.circular(40.0),
                                    ),
                                    child: Text('月末最后一天' ,  style: TextStyle(color: Color( _isMonthLastDay ? 0xffffffff : 0xff222222),fontSize: 18) )),
                                onTap: (){
                                  _isMonthLastDay = !_isMonthLastDay;
                                  setState(() {  });
                                },
                              )),



                       ]
                      ),




                    ],
                  ),
                ),





               Expanded(  child: SizedBox()),

              ElevatedButton(
                child: Text(
                  '完  成',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),

                style: ElevatedButton.styleFrom(
                  primary: TGlobalData().crMainThemeColor,
                  onPrimary: TGlobalData().crMainThemeOnColor,
                  shadowColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 130,vertical: 6),
                  shape: StadiumBorder(),

                ),
                onPressed:   () {
                  int i = 0;
                  for( ; i < _ruleTypeObjLs.length; i ++)
                    if( _ruleTypeObjLs[i]['isChecked']  )
                      break;

                    if(i == 1) { // weeek
                      int flags = 0;
                      for(int j = 0 ; j < _weekRulesDatLs.length ; j ++)
                        if(_weekRulesDatLs[j])
                          flags |= 1 << j;

                      flags <<= 1;
                      Navigator.pop(context, [i,flags,0]);
                      return;
                    }else if(i == 2) { // month

                      int flags = 0;
                      int dIdx = 1;
                      for(int j = 0 ; j < _oneMonthByWeekObjLs.length ; j ++) {
                        if (_oneMonthByWeekObjLs[j]['isChecked'] == null)
                          continue;
                        if (_oneMonthByWeekObjLs[j]['isChecked']  )
                          flags |= 1 << dIdx;

                        dIdx++;
                      }

                      if(_isMonthLastDay)
                        flags |= 1;

                      Navigator.pop(context, [i,0,flags]);
                      return;
                    }

                  Navigator.pop(context, [0,1 , 0]); // default and day type

                },
              ),

            ],
          )),
    );

  }
}

















class TValidDateWnd extends StatefulWidget {

  final DateTime startDt;
  final DateTime endDt;

  TValidDateWnd(this.startDt, this.endDt);

  @override
  _TValidDateWndState createState() => _TValidDateWndState();
}


class _TValidDateWndState extends State<TValidDateWnd> {


  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

    _startDate = widget.startDt;
    _endDate = widget.endDt;

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
      appBar: AppBar(title: Text(  '有效日期',
        style: TextStyle(color: Color(0xff222222), fontSize: 20, fontWeight: FontWeight.bold), ),
        elevation: 0.0,
        backgroundColor: Color(0xffeeeeee),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(

        color: TGlobalData().crMainBgColor,
        padding: EdgeInsets.all(20.0),
          child: Column(
            children: [

              InkWell(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: TGlobalData().crGreyCC)),
                  ),
                  child: Row(
                    children: [

                      Text('开始日期' , style: TGlobalData().tsTxtFn20Grey22Bn,),
                      Expanded( child: SizedBox()),
                      Text(_startDate == DateTime(0) ? '未设置' : DateFormat('yyyy.MM.dd').format(_startDate) ,
                        style: TGlobalData().tsTxtFn18GreyBB,),

                      Icon(Icons.navigate_next , size: 32, color: TGlobalData().crGreyBB,),

                    ],
                  ),
                ),
                onTap: ()  async  {
                  final rtn =  await _doChooseDate( _startDate == DateTime(0) ? DateTime.now() : _startDate, 1);
                  print(rtn);
                  if(rtn != DateTime(0)){

                    setState(() {
                      _startDate = rtn;
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

                      Text('结束日期' , style: TGlobalData().tsTxtFn20Grey22Bn,),
                      Expanded( child: SizedBox()),
                      Text(_endDate == DateTime(0) ? '未设置' : DateFormat('yyyy.MM.dd').format(_endDate) ,
                        style: TGlobalData().tsTxtFn18GreyBB,),

                      Icon(Icons.navigate_next , size: 32, color: TGlobalData().crGreyBB,),

                    ],
                  ),
                ),
                onTap: ()   async  {
                  final rtn =  await _doChooseDate(_endDate == DateTime(0) ? DateTime.now() : _endDate, 2);
                  if(rtn != DateTime(0)){

                    setState(() {
                      _endDate = rtn;
                    });

                  }


                },
              ),



              Expanded(flex: 10, child: SizedBox()),
              ElevatedButton(
                child: Text(
                  '完  成',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),

                style: ElevatedButton.styleFrom(
                  primary: TGlobalData().crMainThemeColor,
                  onPrimary: TGlobalData().crMainThemeOnColor,
                  shadowColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 130,vertical: 12),
                  shape: StadiumBorder(),

                ),
                onPressed:   () {
                  Navigator.pop(context, [_startDate, _endDate]);
                },
              ),



            ],
          )
      
      ),
    );

  }

  Future<DateTime> _doChooseDate( DateTime oriDt,  int wndType) async
  {

    int _yearVal = oriDt.year;
    int _monthVal = oriDt.month;
    int _dayhVal = oriDt.day;

    int _monthMinVal = oriDt.month;


    var currMFD = DateTime(_yearVal, _monthVal);
    var nextMFD = DateTime(_yearVal, _monthVal + 1);

    int  _dayMaxVal = nextMFD.difference(currMFD).inDays;

    int  _dayMinVal = _dayhVal;


    final rtn =  await    showDialog(context: context,
        builder: (BuildContext bctx){
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

                                Center(child: Text(
                                 wndType == 1 ? '开始日期' : '结束日期', style: TGlobalData().tsTxtFn24Grey22Bn,)),


                                Center(child: Text( DateFormat('yyyy年M月d日').format(oriDt) +   '  (${TGlobalData().weekNameByNum(oriDt.weekday)})',
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
                                          minValue: oriDt.year, maxValue: 2050, value: _yearVal,
                                          textStyle: TGlobalData().tsTxtFn26GreyBB,
                                          selectedTextStyle: TGlobalData().tsTxtFn26Grey22Bn,
                                          onChanged: (val) {

                                              _yearVal = val ;
                                              if(_yearVal == oriDt.year ) {

                                                _monthMinVal = oriDt.month;
                                                if(_monthVal < oriDt.month){
                                                  _monthVal = oriDt.month;
                                                }

                                                _dayMinVal = oriDt.day;
                                                if(_dayhVal < oriDt.day){
                                                  _dayhVal = oriDt.day;
                                                }


                                              }else{

                                                _monthMinVal = 1;
                                                _dayMinVal = 1;


                                                var currMFD = DateTime(_yearVal, _monthVal);
                                                var nextMFD = DateTime(_yearVal, _monthVal + 1);

                                                _dayMaxVal = nextMFD.difference(currMFD).inDays;


                                              }

                                                 setState(() { } );

                                              // Future.delayed(Duration(milliseconds: 500)).then((value) {
                                              //   setState(() { _monthVal = oriMonth; } );
                                              // });


                                            },
                                        ),


                                       // Text('：', style: TGlobalData().tsTxtFn26Grey22Bw900Sp6,),

                                        NumberPicker(
                                          minValue: _monthMinVal,
                                          maxValue: 12,
                                          value: _monthVal,
                                          textStyle: TGlobalData().tsTxtFn26GreyBB,
                                          selectedTextStyle: TGlobalData().tsTxtFn26Grey22Bn,
                                          textMapper: (ori){return sprintf('%02i',[int.parse(ori)]) ;},
                                          onChanged: (val){
                                            _monthVal = val;

                                            if( _yearVal == oriDt.year  &&   _monthVal == oriDt.month){
                                              _dayMinVal = oriDt.day;
                                              if( _dayhVal < oriDt.day )
                                                  _dayhVal = oriDt.day;
                                            }

                                            var currMFD = DateTime(_yearVal, _monthVal);
                                            var nextMFD = DateTime(_yearVal, _monthVal + 1);

                                           _dayMaxVal = nextMFD.difference(currMFD).inDays;

                                            setState(() { } );
                                          },
                                        ),


                                        NumberPicker(
                                          minValue: _dayMinVal,
                                          maxValue: _dayMaxVal,
                                          value: _dayhVal,
                                          textStyle: TGlobalData().tsTxtFn26GreyBB,
                                          selectedTextStyle: TGlobalData().tsTxtFn26Grey22Bn,
                                          textMapper: (ori){return sprintf('%02i',[int.parse(ori)]) ;},
                                          onChanged: (val) => setState(() => _dayhVal = val ),
                                        ),


                                      ],
                                    ),


                                  ],
                                ),


                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [

                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(bctx  );
                                        },
                                        child: Text(
                                          '取  消', style: TGlobalData().tsTxtFn20Grey22,),
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.all(12.0),
                                          primary: Colors.white,
                                          onPrimary: TGlobalData().crMainThemeDownColor,
                                          shadowColor: Colors.transparent,
                                          elevation: 0,

                                          //shape: StadiumBorder(),
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(bctx , [ _yearVal, _monthVal  , _dayhVal]);
                                        },
                                        child: Text(
                                          '确  定', style: TGlobalData().tsTxtFn20Grey22,),
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.all(12.0),
                                          primary: Colors.white,
                                          onPrimary: TGlobalData().crMainThemeDownColor,
                                          shadowColor: Colors.transparent,
                                          elevation: 0,


                                          //shape: StadiumBorder(),
                                        ),
                                      ),
                                    ),

                                  ],
                                ),


                              ],
                            ),
                          )),
                    )
                );

              }
          );
        });

    if(rtn != null){
      List<int> tmpLs = rtn as List<int>;
      // print(' chooson result: ${tmpLs[0]} - ${tmpLs[1]} - ${tmpLs[2]}');
      return Future<DateTime>.value(DateTime(  tmpLs[0], tmpLs[1] ,tmpLs[2]));

    }

    return Future<DateTime>.value(DateTime(0));

  }




}





















class TValidTimeWnd extends StatefulWidget {

  final DateTime startDt;
  final DateTime endDt;

   TValidTimeWnd(this.startDt, this.endDt);

  @override
  _TValidTimeWndState createState() => _TValidTimeWndState();
}


class _TValidTimeWndState extends State<TValidTimeWnd> {

  late DateTime _startTime  ;
  late DateTime _endTime  ;

  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

    _startTime = widget.startDt;
    _endTime = widget.endDt;

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
      appBar: AppBar(title: Text(  '有效时段',
        style: TextStyle(color: Color(0xff222222), fontSize: 20, fontWeight: FontWeight.bold), ),
        elevation: 0.0,
        backgroundColor: Color(0xffeeeeee),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body:  Container(

          color: TGlobalData().crMainBgColor,
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [


              InkWell(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: TGlobalData().crGreyCC)),
                  ),
                  child: Row(
                    children: [

                      Text('开始时间' , style: TGlobalData().tsTxtFn20Grey22Bn,),
                      Expanded( child: SizedBox()),
                      Text( _startTime == DateTime(0) ? '未设置' : DateFormat('HH:mm').format(_startTime) ,
                        style: TGlobalData().tsTxtFn18GreyBB,),

                      Icon(Icons.navigate_next , size: 32, color: TGlobalData().crGreyBB,),

                    ],
                  ),
                ),
                onTap: ()  async  {
                  final rtn = await _doChooseTime( _startTime == DateTime(0) ? DateTime.now() : _startTime, 1);

                    if(rtn != DateTime(0)){

                      setState(() {
                        _startTime = rtn;
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

                      Text('结束时间' , style: TGlobalData().tsTxtFn20Grey22Bn,),
                      Expanded( child: SizedBox()),
                      Text( _endTime == DateTime(0) ? '未设置' : DateFormat('HH:mm').format(_endTime) ,
                        style: TGlobalData().tsTxtFn18GreyBB,),

                      Icon(Icons.navigate_next , size: 32, color: TGlobalData().crGreyBB,),

                    ],
                  ),
                ),
                onTap: ()   async {
                  final rtn = await _doChooseTime( _endTime == DateTime(0) ? DateTime.now() : _endTime, 2);

                  if(rtn != DateTime(0)){

                    setState(() {
                      _endTime = rtn;
                    });

                  }

                },
              ),



              Expanded(flex: 10, child: SizedBox()),
              ElevatedButton(
                child: Text(
                  '完  成',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),

                style: ElevatedButton.styleFrom(
                  primary: TGlobalData().crMainThemeColor,
                  onPrimary: TGlobalData().crMainThemeOnColor,
                  shadowColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 130,vertical: 12),
                  shape: StadiumBorder(),

                ),
                onPressed:   () {
                  Navigator.pop(context, [_startTime, _endTime]);
                }
              ),



            ],
          )

      ),
    );

  }


  Future<DateTime> _doChooseTime( DateTime oriDt,  int wndType) async
  {

    int _hourVal = oriDt.hour;
    int _minuteVal = oriDt.minute;

    final rtn =  await    showDialog(context: context,
        builder: (BuildContext bctx){
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

                                Center(child: Text(
                                  wndType == 1 ? '开始时间' : '结束时间', style: TGlobalData().tsTxtFn24Grey22Bn,)),


                                Center(child: Text( DateFormat('HH:mm').format(oriDt) +   '  (${TGlobalData().weekNameByNum(oriDt.weekday)})',
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
                                          onChanged: (val) {

                                            setState(() { _hourVal = val; } );

                                          },
                                        ),


                                         Text('：', style: TGlobalData().tsTxtFn26Grey22Bw900Sp6,),

                                        NumberPicker(
                                          minValue: 0,
                                          maxValue: 59,
                                          value: _minuteVal,
                                          textStyle: TGlobalData().tsTxtFn26GreyBB,
                                          selectedTextStyle: TGlobalData().tsTxtFn26Grey22Bn,
                                          textMapper: (ori){return sprintf('%02i',[int.parse(ori)]) ;},
                                          onChanged: (val){

                                            setState(() { _minuteVal = val; } );
                                          },
                                        ),


                                      ],
                                    ),


                                  ],
                                ),


                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [

                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(bctx );
                                        },
                                        child: Text(
                                          '取  消', style: TGlobalData().tsTxtFn20Grey22,),
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.all(12.0),
                                          primary: Colors.white,
                                          onPrimary: TGlobalData().crMainThemeDownColor,
                                          shadowColor: Colors.transparent,
                                          elevation: 0,

                                          //shape: StadiumBorder(),
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(bctx , [_hourVal, _minuteVal   ]);
                                        },
                                        child: Text(
                                          '确  定', style: TGlobalData().tsTxtFn20Grey22,),
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.all(12.0),
                                          primary: Colors.white,
                                          onPrimary: TGlobalData().crMainThemeDownColor,
                                          shadowColor: Colors.transparent,
                                          elevation: 0,


                                          //shape: StadiumBorder(),
                                        ),
                                      ),
                                    ),

                                  ],
                                ),


                              ],
                            ),
                          )),
                    )
                );

              }
          );
        });

    if(rtn != null){

       List<int> tmpLs = rtn as List<int>;
      // print(' chooson result: ${tmpLs[0]} : ${tmpLs[1]}');
      return Future<DateTime>.value(DateTime(oriDt.year,oriDt.month, oriDt.day, tmpLs[0], tmpLs[1]));

    }




    return Future<DateTime>.value(DateTime(0));

  }


}








