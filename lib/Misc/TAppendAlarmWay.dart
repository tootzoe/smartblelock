import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_svg/flutter_svg.dart';



import '../TGlobal_inc.dart';
import 'TTabbarIndicator.dart';
import 'TAnimaPath.dart';

class TAppendPwdAlarmWay extends StatefulWidget {


  @override
  _TAppendPwdAlarmWayState createState() => _TAppendPwdAlarmWayState();
}


class _TAppendPwdAlarmWayState extends State<TAppendPwdAlarmWay> {

  final _pwdCodeTxtctller1 = TextEditingController();
  final _pwdCodeTxtctller2 = TextEditingController();

  bool _isPwdClearBtn1 = true;
  bool _isPwdClearBtn2 = true;

  bool   _btnEnabled = false;

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
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color(0xfff8f8f8),
        iconTheme: IconThemeData(color: Color(0xff222222)),

      ),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(

            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                Expanded(flex: 10,child: SizedBox()),

              SvgPicture.asset( 'images/svgs/numPwd.svg' ,height: TDevsSizeFit.safeBlockHorizontal  * 22, fit: BoxFit.contain, ),

                SizedBox(height: 12,),
                Text('添加报警密码' , textAlign: TextAlign.center, style: TGlobalData().tsTxtFn26Grey22Bn,),
                SizedBox(height: 12,),
                Text('请保持蓝牙开启状态,并将手机连接至WiFi或蜂窝数\n据系统将及时将报警信息发送给您的朋友' ,
                  textAlign: TextAlign.center, style: TGlobalData().tsTxtFn14GreyAA,),



                SizedBox(height: 20,),


                TextField(
                  keyboardType: TextInputType.number,
                  controller: _pwdCodeTxtctller1,
                  style: TGlobalData().tsListTitleTS1,
                  textAlignVertical: TextAlignVertical.center,
                  autofocus: true,
                  obscureText: _isPwdClearBtn1,
                  obscuringCharacter: '●',
                  decoration: InputDecoration(
                      fillColor: Colors.transparent,
                     // border: InputBorder.none,
                      border: UnderlineInputBorder(
                          borderRadius: BorderRadius.only(bottomRight: Radius.zero , bottomLeft: Radius.zero),
                          borderSide: BorderSide (color: TGlobalData().crGreyCC)),
                      focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.only(bottomRight: Radius.zero , bottomLeft: Radius.zero),
                          borderSide: BorderSide (color: TGlobalData().crMainThemeColor)),
                       // filled: true,
                         contentPadding: EdgeInsets.all(16),
                      // prefixText: '密  码      ',
                      //  prefixStyle: TGlobalData().tsTxtFn20Grey22,
                      hintText: '输入报警密码',
                     // alignLabelWithHint: true,
                      isDense: true,
                      prefixIcon: Padding(

                        padding: const EdgeInsets.only(right: 30),
                        child: Text('密  码', style:TGlobalData().tsTxtFn20Grey22 ,),
                      ),
                      prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                      // prefix: Padding(
                      //   padding: const EdgeInsets.only(right: 24),
                      //   child: Text('密  码', style:TGlobalData().tsTxtFn20Grey22 ,),
                      // ) ,
                      // suffixIcon:  _isPwdClearBtn1 ?
                      // IconButton(icon:  SvgPicture.asset( 'images/svgs/deleteIcon.svg' , width: 20, height: 20, fit: BoxFit.scaleDown,color: TGlobalData().crMainThemeColor, ),
                      //   onPressed: (){
                      //     _pwdCodeTxtctller1.clear();
                      //     setState(() {
                      //       _isPwdClearBtn1 = false;
                      //       _btnEnabled = false;
                      //     });
                      //   } , )   : null


                    suffixIcon:  InkWell(
                  child: _isPwdClearBtn1 ?
                  Icon(   Icons.visibility    ,    size: 26,color: Color(0xff666666),)
                      : Icon(   Icons.visibility_off   ,  size: 26,color: TGlobalData().crCommonGrey,) ,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,

          onTap: (){
            _isPwdClearBtn1 = !_isPwdClearBtn1;

            setState(() {});

          },
        ),





                  )  ,
                  onChanged: (str){
                    if(str.length > 0){
                      setState(() {
                       // _isPwdClearBtn1 = true;
                        if(_pwdCodeTxtctller1.text.length > 5 && _pwdCodeTxtctller2.text.length > 5)
                          _btnEnabled = true;
                        else _btnEnabled = false;
                      });
                    }else{
                      setState(() {
                       // _isPwdClearBtn1 = false;
                        _btnEnabled = false;
                      });
                    }
                  },
                ),


                TextField(
                  keyboardType: TextInputType.number,
                  controller: _pwdCodeTxtctller2,
                  style: TGlobalData().tsListTitleTS1,
                //  textAlignVertical: TextAlignVertical.center,
                  obscureText: _isPwdClearBtn2,
                  obscuringCharacter: '●',
                  decoration: InputDecoration(
                      fillColor: Colors.transparent,
                      // border: InputBorder.none,
                      border: UnderlineInputBorder(
                          borderRadius: BorderRadius.only(bottomRight: Radius.zero , bottomLeft: Radius.zero),
                          borderSide: BorderSide (color: TGlobalData().crGreyCC)),
                      focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.only(bottomRight: Radius.zero , bottomLeft: Radius.zero),
                          borderSide: BorderSide (color: TGlobalData().crMainThemeColor)),
                      // filled: true,
                      contentPadding: EdgeInsets.all(16),
                      hintText: '再次输入报警密码',
                      isDense: true,
                      prefixIcon: Padding(

                        padding: const EdgeInsets.only(right: 30),
                        child: Text('密  码', style:TGlobalData().tsTxtFn20Grey22 ,),
                      ),
                      prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),

                      // suffixIcon:  _isPwdClearBtn2 ?
                      // IconButton(icon:  SvgPicture.asset( 'images/svgs/deleteIcon.svg' , width: 20, height: 20, fit: BoxFit.scaleDown,color: TGlobalData().crMainThemeColor, ),
                      //   onPressed: (){
                      //     _pwdCodeTxtctller2.clear();
                      //     setState(() {
                      //       _isPwdClearBtn2 = false;
                      //       _btnEnabled = false;
                      //     });
                      //   } , )   : null




                    suffixIcon:  InkWell(
                  child: _isPwdClearBtn2 ?
                  Icon(   Icons.visibility    ,    size: 26,color: Color(0xff666666),)
                      : Icon(   Icons.visibility_off   ,  size: 26,color: TGlobalData().crCommonGrey,) ,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,

          onTap: (){
            _isPwdClearBtn2 = !_isPwdClearBtn2;

            setState(() {});

          },
        ),



                  )  ,
                  onChanged: (str){
                    if(str.length > 0){
                      setState(() {
                       // _isPwdClearBtn2 = true;
                        if(_pwdCodeTxtctller1.text.length > 5 && _pwdCodeTxtctller2.text.length > 5)
                          _btnEnabled = true;
                        else _btnEnabled = false;
                      });
                    }else{
                      setState(() {
                       // _isPwdClearBtn2 = false;
                        _btnEnabled = false;
                      });
                    }
                  },
                ),


                SizedBox(height: 32,),

                ElevatedButton(
                  child: Text(
                    '提  交',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),

                  style: ElevatedButton.styleFrom(
                    primary: TGlobalData().crMainThemeColor,
                    onPrimary: TGlobalData().crMainThemeOnColor,
                    shadowColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    shape: StadiumBorder(),

                  ),
                  onPressed:  _btnEnabled ?  () {

                    if(_pwdCodeTxtctller1.text  != _pwdCodeTxtctller2.text ){
                      TGlobalData().showToastInfo('密码不一致');
                      return;
                    }

                    print(_pwdCodeTxtctller1.text);

                  } : null ,
                ),


                Expanded(flex: 50,child: SizedBox()),

              ],
            )),
      ),
    );

  }


}



class TAppendFpAlarmWay extends StatefulWidget {


  @override
  _TAppendFpAlarmWayState createState() => _TAppendFpAlarmWayState();
}


class _TAppendFpAlarmWayState extends State<TAppendFpAlarmWay> {


  int _pathStep = 0;
  int _pathMaxStep = 4;


  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
   // WidgetsFlutterBinding.ensureInitialized();
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
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color(0xfff8f8f8),
        iconTheme: IconThemeData(color: Color(0xff222222)),

      ),
      body: Container(

          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Text('添加指纹报警',textAlign: TextAlign.center,
                style: TGlobalData().tsTxtFn26Grey22Bn,),

              SizedBox(height: 14,),

              Text('请将手指放置在指纹开锁处',textAlign: TextAlign.center,
                style: TGlobalData().tsTxtFn20Grey88,),


              Expanded(flex: 30,child: SizedBox()),

              Center(
                  child: TAnimaPath(_pathStep, _pathMaxStep , 82, 128)),

              Expanded(flex: 30,child: SizedBox()),

              Center(
                  child: Container(
                      padding: EdgeInsets.fromLTRB(46, 16, 46, 16),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: TGlobalData().crGreyCC),
                          bottom: BorderSide(color: TGlobalData().crGreyCC),
                        ),
                      ),
                      child: Text('0 / 4' , style: TGlobalData().tsTxtFn22Grey22,))  ),

              Expanded(flex: 20,child: SizedBox()),

              ElevatedButton(
                  child: Text('当前采集次数 $_pathStep'),
                  onPressed: () async {

                    setState(() {
                      _pathStep = (_pathStep + 1) % (_pathMaxStep + 1);
                    });

                  }
              ),


            ],
          )),
    );

  }


}








class TAppendPhoneAlarmWay extends StatefulWidget {


  @override
  _TAppendPhoneAlarmWayState createState() => _TAppendPhoneAlarmWayState();
}


class _TAppendPhoneAlarmWayState extends State<TAppendPhoneAlarmWay> {

  final _phoneNumTxtctller1 = TextEditingController();
  final _phoneNumTxtctller2 = TextEditingController();

  bool _isPwdClearBtn1 = false;
  bool _isPwdClearBtn2 = false;

  bool   _btnEnabled = false;

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
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color(0xfff8f8f8),
        iconTheme: IconThemeData(color: Color(0xff222222)),

      ),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(

            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                Expanded(flex: 10,child: SizedBox()),

                SvgPicture.asset( 'images/svgs/phoneNum.svg' ,height: TDevsSizeFit.safeBlockHorizontal  * 22, fit: BoxFit.contain, ),

                SizedBox(height: 12,),
                Text('录入手机号报警' , textAlign: TextAlign.center, style: TGlobalData().tsTxtFn26Grey22Bn,),
                SizedBox(height: 12,),
                Text('仅支持“中国手机号”和“柬埔寨手机号”' ,
                  textAlign: TextAlign.center, style: TGlobalData().tsTxtFn16GreyAA,),



                SizedBox(height: 20,),


                TextField(
                 // keyboardType: TextInputType.number,
                  controller: _phoneNumTxtctller1,
                  style: TGlobalData().tsListTitleTS1,
                  textAlignVertical: TextAlignVertical.center,
                  autofocus: true,
                  // obscureText: _isPwdClearBtn1,
                  // obscuringCharacter: '●',
                  decoration: InputDecoration(
                    fillColor: Colors.transparent,
                    // border: InputBorder.none,
                    border: UnderlineInputBorder(
                        borderRadius: BorderRadius.only(bottomRight: Radius.zero , bottomLeft: Radius.zero),
                        borderSide: BorderSide (color: TGlobalData().crGreyCC)),
                    focusedBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.only(bottomRight: Radius.zero , bottomLeft: Radius.zero),
                        borderSide: BorderSide (color: TGlobalData().crMainThemeColor)),
                    // filled: true,
                    contentPadding: EdgeInsets.all(16),
                    // prefixText: '密  码      ',
                    //  prefixStyle: TGlobalData().tsTxtFn20Grey22,
                    hintText: '输入手机号报警姓名',
                    // alignLabelWithHint: true,
                    isDense: true,
                    prefixIcon: Padding(

                      padding: const EdgeInsets.only(right: 30),
                      child: Text('姓       名', style:TGlobalData().tsTxtFn20Grey22 ,),
                    ),
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    // prefix: Padding(
                    //   padding: const EdgeInsets.only(right: 24),
                    //   child: Text('密  码', style:TGlobalData().tsTxtFn20Grey22 ,),
                    // ) ,
                    suffixIcon:  _isPwdClearBtn1 ?
                    IconButton(icon:  SvgPicture.asset( 'images/svgs/deleteIcon.svg' , width: 20, height: 20, fit: BoxFit.scaleDown,color: TGlobalData().crMainThemeColor, ),
                      onPressed: (){
                        _phoneNumTxtctller1.clear();
                        setState(() {
                          _isPwdClearBtn1 = false;
                          _btnEnabled = false;
                        });
                      } , )   : null


                    // suffixIcon:  InkWell(
                    //   child: _isPwdClearBtn1 ?
                    //   Icon(   Icons.visibility    ,    size: 26,color: Color(0xff666666),)
                    //       : Icon(   Icons.visibility_off   ,  size: 26,color: TGlobalData().crCommonGrey,) ,
                    //   highlightColor: Colors.transparent,
                    //   splashColor: Colors.transparent,
                    //
                    //   onTap: (){
                    //     _isPwdClearBtn1 = !_isPwdClearBtn1;
                    //
                    //     setState(() {});
                    //
                    //   },
                    // ),





                  )  ,
                  onChanged: (str){
                    if(str.length > 0){
                      setState(() {
                         _isPwdClearBtn1 = true;
                        if(_phoneNumTxtctller1.text.length > 1 && _phoneNumTxtctller2.text.length > 5)
                          _btnEnabled = true;
                        else _btnEnabled = false;
                      });
                    }else{
                      setState(() {
                          _isPwdClearBtn1 = false;
                        _btnEnabled = false;
                      });
                    }
                  },
                ),


                TextField(
                  keyboardType: TextInputType.number,
                  controller: _phoneNumTxtctller2,
                  style: TGlobalData().tsListTitleTS1,
                  //  textAlignVertical: TextAlignVertical.center,
                  // obscureText: _isPwdClearBtn2,
                  // obscuringCharacter: '●',
                  decoration: InputDecoration(
                    fillColor: Colors.transparent,
                    // border: InputBorder.none,
                    border: UnderlineInputBorder(
                        borderRadius: BorderRadius.only(bottomRight: Radius.zero , bottomLeft: Radius.zero),
                        borderSide: BorderSide (color: TGlobalData().crGreyCC)),
                    focusedBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.only(bottomRight: Radius.zero , bottomLeft: Radius.zero),
                        borderSide: BorderSide (color: TGlobalData().crMainThemeColor)),
                    // filled: true,
                    contentPadding: EdgeInsets.all(16),
                    hintText: '输入手机号报警号码',
                    isDense: true,
                    prefixIcon: Padding(

                      padding: const EdgeInsets.only(right: 30),
                      child: Text('手机号码', style:TGlobalData().tsTxtFn20Grey22 ,),
                    ),
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),

                    suffixIcon:  _isPwdClearBtn2 ?
                    IconButton(icon:  SvgPicture.asset( 'images/svgs/deleteIcon.svg' , width: 20, height: 20, fit: BoxFit.scaleDown,color: TGlobalData().crMainThemeColor, ),
                      onPressed: (){
                        _phoneNumTxtctller2.clear();
                        setState(() {
                          _isPwdClearBtn2 = false;
                          _btnEnabled = false;
                        });
                      } , )   : null




                    // suffixIcon:  InkWell(
                    //   child: _isPwdClearBtn2 ?
                    //   Icon(   Icons.visibility    ,    size: 26,color: Color(0xff666666),)
                    //       : Icon(   Icons.visibility_off   ,  size: 26,color: TGlobalData().crCommonGrey,) ,
                    //   highlightColor: Colors.transparent,
                    //   splashColor: Colors.transparent,
                    //
                    //   onTap: (){
                    //     _isPwdClearBtn2 = !_isPwdClearBtn2;
                    //
                    //     setState(() {});
                    //
                    //   },
                    // ),



                  )  ,
                  onChanged: (str){
                    if(str.length > 0){
                      setState(() {
                          _isPwdClearBtn2 = true;
                        if(_phoneNumTxtctller1.text.length > 1 && _phoneNumTxtctller2.text.length > 5)
                          _btnEnabled = true;
                        else _btnEnabled = false;
                      });
                    }else{
                      setState(() {
                          _isPwdClearBtn2 = false;
                        _btnEnabled = false;
                      });
                    }
                  },
                ),


                SizedBox(height: 32,),

                ElevatedButton(
                  child: Text(
                    '提  交',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),

                  style: ElevatedButton.styleFrom(
                    primary: TGlobalData().crMainThemeColor,
                    onPrimary: TGlobalData().crMainThemeOnColor,
                    shadowColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    shape: StadiumBorder(),

                  ),
                  onPressed:  _btnEnabled ?  () {

                    // if(_phoneNumTxtctller1.text  != _phoneNumTxtctller2.text ){
                    //   TGlobalData().showToastInfo('密码不一致');
                    //   return;
                    // }

                    print(_phoneNumTxtctller1.text);
                    print(_phoneNumTxtctller2.text);

                  } : null ,
                ),


                Expanded(flex: 50,child: SizedBox()),

              ],
            )),
      ),
    );

  }


}












