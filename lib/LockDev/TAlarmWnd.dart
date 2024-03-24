import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:collection/collection.dart';

import 'package:fluttertoast/fluttertoast.dart';

import '../TGlobal_inc.dart';


class TAlarmWnd extends StatefulWidget {


  @override
  _TAlarmWndState createState() => _TAlarmWndState();
}


class _TAlarmWndState extends State<TAlarmWnd> {


  bool _isDoorOpen = false;

  List<Map> _allStepInfoObjLs = [];

  int _currStep = 0;

  String _titleTxtStr = '';
  String _subtitleTxtStr = '';

  int _countDownSecs = 30;

  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

    List<String> titleLs = [
      '请按一下步骤从室内开门，然后点击“开始”按钮',
      '请在室内关门',
      '请长按反锁按键1.5秒，并看到指示灯亮起',
      '关门后，请在室内握住门把手内侧的触摸区域，再按下把手上的按键推/拉开门',
    ];

    List<String> subTitleLs = [
      '1.用手握住（保持皮肤接触）门内把手\n'
          '   内侧触摸区域，不要松开\n'
          '2.按下门把手上的按键\n'
          '3.推/拉把手开门',

      '1.用手握住（保持皮肤接触）门内把手\n    内侧触摸区域，不要松开'
      '2.按下门把手上的按键'
    '3.推/拉把手开门',

      '',
      '',

    ];




    for(int i = 0 ; i < titleLs.length ; i ++){
      var tmpObj = {};
      tmpObj['title'] = titleLs[i];
      tmpObj['subtit'] = subTitleLs[i];
      tmpObj['imgUrl'] = '';


      _allStepInfoObjLs.add(tmpObj);
    }

    _titleTxtStr = _allStepInfoObjLs[0]['title'];
    _subtitleTxtStr = _allStepInfoObjLs[0]['subtit'];



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
      appBar: AppBar(title: Text( '报警方式'  ,
        style: TextStyle(color: Color(0xff222222), fontSize: 20, fontWeight: FontWeight.bold), ),
        elevation: 0.0,
        backgroundColor: Color(0xfff8f8f8),
        iconTheme: IconThemeData(color: Color(0xff222222)),

      ),
      body: Container(

          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Expanded( flex: 5, child: SizedBox()),

              Container(
                height: MediaQuery.of(context).size.height * .34,
                padding: EdgeInsets.all(40.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20,),
                  color: Color(0xffeeeeee),
                ),
              ),


              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text(_titleTxtStr, style: TextStyle(fontSize: 20 , fontWeight: FontWeight.bold)),
              ),


              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(_subtitleTxtStr, style: TextStyle(fontSize: 18 , color: Color(0xffbbbbbb))),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Checkbox(
                    //  // shape: Out(),
                    //     value: _isDoorOpen,
                    //     onChanged: (b){
                    //
                    //       setState(() {
                    //         _isDoorOpen = b!;
                    //       });
                    //
                    //     }
                    // ),

                  if(_currStep == 0 || _currStep == 2)
                    InkWell(
                    onTap: (){
                    setState(() {
                   _isDoorOpen = !_isDoorOpen;
                       });
                     },
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                child:  Container(
                      width: 22,
                      height: 22,
                      margin: EdgeInsets.only(right: 10.0),
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: _isDoorOpen ? TGlobalData().crMainThemeColor : Color( 0xff888888)),
                      ),

                      child:  Container(
                         // color: Colors.red,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                          //  border: Border.all(color: Color(0xff888888)),
                            color: _isDoorOpen ?  TGlobalData().crMainThemeColor : null,
                          ),
                        ),
                      ),

                    ),

                    if(_currStep == 0 || _currStep == 2)
                    Text( _currStep == 0 ?  '已打开门' : '已看到指示灯亮起' , style: TGlobalData().tsListCntTS1,),
                  ],
                ),
              ),

              Expanded( flex: 10, child: SizedBox()),

            if(_currStep == 0 || _currStep == 2)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(12.0),
                  primary: TGlobalData().crMainThemeColor,
                  onPrimary: TGlobalData().crMainThemeColor,
                  shape: StadiumBorder(),
                ),
                  child: Text('开  始' , style: TextStyle(color: Colors.white ,fontSize: 20.0),),
                onPressed: (){
                  _currStep ++;
                 _titleTxtStr =  _allStepInfoObjLs[_currStep]['title'];
                  _subtitleTxtStr =  _allStepInfoObjLs[_currStep]['subtit'];
                  setState(() {});

                  if(_currStep == 1 || _currStep == 3) {
                    _countDownSecs = 30;
                    Future.delayed(Duration(seconds: 1)).then((value) =>
                        _exeSecCountDown());
                  }

                },
              ),


              if( (_currStep == 1 || _currStep == 3)  )
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(12.0),
                      primary: Colors.transparent,
                      onPrimary: Colors.transparent,
                      elevation: 0,
                      shape: StadiumBorder(),
                      side: BorderSide(color: Color(0xffbbbbbb)),
                    ),
                    child: Text('${_countDownSecs}S' , style: TextStyle(color: Color(0xff222222) ,fontSize: 20.0),),
                    onPressed: (){
                      _countDownSecs = 0;
                      _currStep ++;

                      int tmpStep = _currStep;
                      if(tmpStep >= _allStepInfoObjLs.length)
                        tmpStep = _allStepInfoObjLs.length -1;

                      _titleTxtStr =  _allStepInfoObjLs[tmpStep]['title'];
                      _subtitleTxtStr =  _allStepInfoObjLs[tmpStep]['subtit'];


                      setState(() {});
                    },
                  ),
                ),

              if(_currStep == 4)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.fromLTRB(60, 12, 60, 12),
                        primary: Colors.transparent,
                        onPrimary: TGlobalData().crMainThemeDownColor,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: StadiumBorder(),
                        side: BorderSide(color: Color(0xffbbbbbb)),
                      ),
                      child: Text('否' , style: TextStyle(color: Color(0xff222222) ,fontSize: 20.0),),
                      onPressed: (){
                        // _countDownSecs = 0;
                        // _currStep ++;
                        // _titleTxtStr =  _allStepInfoObjLs[_currStep]['title'];
                        // _subtitleTxtStr =  _allStepInfoObjLs[_currStep]['subtit'];
                        // setState(() {});
                      },
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.fromLTRB(60, 12, 60, 12),
                        primary: TGlobalData().crMainThemeColor,
                        onPrimary: TGlobalData().crMainThemeDownColor,
                        shadowColor: Colors.transparent,

                        elevation: 0,
                        shape: StadiumBorder(),
                        side: BorderSide(color: TGlobalData().crMainThemeColor,),
                      ),
                      child: Text('是' , style: TextStyle(color: Colors.white ,fontSize: 20.0),),
                      onPressed: (){

                        Navigator.pop(context);
                      },
                    ),

                  ],
                ),


              Expanded( flex: 10, child: SizedBox()),

            ],
          )),
    );

  }

  void _exeSecCountDown()
  {

    _countDownSecs -- ;

    setState(() {});

    if(_countDownSecs > 0 ){
      Future.delayed(Duration(seconds: 1)) .then((value) => _exeSecCountDown());
    }

  }

}

















