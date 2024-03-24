import 'dart:async';
import 'dart:convert';

import 'dart:io';
import '../TRemoteSrv.dart';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sprintf/sprintf.dart';
import 'package:flutter_svg/flutter_svg.dart';
//import '../TLocalizations.dart';
//import 'package:flutter_gen/gen_l10n/TLocalizations.dart';

import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';


import 'package:http/http.dart' as http;


import '../TGlobal_inc.dart';
import '../TBleSingleton.dart';

import 'TPrivacyAgreement.dart';
import 'TUserServicesAgreement.dart';
import 'TSelectCountRegionCode.dart';
import 'TPushNotification.dart';

import '../flutter_info.dart';

import '../TMainWnd.dart';

import '../gbk2utf8/gbk2utf8.dart';

import '../main.dart';

//import '../DeviceSetting/TDevMainWnd.dart';
//
// class TLogingWnd extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return MaterialApp(
//       title: 'AwesomeBleLock',
//       debugShowCheckedModeBanner: false,
//       home: _TLogingWnd(),
//       //theme: ThemeData.dark(),
//
//       // theme: ThemeData(
//       //   // Define the default brightness and colors.
//       //   brightness: Brightness.light,
//       //   primaryColor: Colors.lightBlue[800],
//       //   accentColor: Colors.cyan[600],
//       //
//       //   // Define the default font family.
//       //   // fontFamily: 'Georgia',
//       //
//       //   // Define the default TextTheme. Use this to specify the default
//       //   // text styling for headlines, titles, bodies of text, and more.
//       //   textTheme: TextTheme(
//       //     headline1: TextStyle(
//       //         fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.black),
//       //     headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
//       //     bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
//       //   ),
//       // ),
//     );
//   }
// }

class TLogingWnd extends StatefulWidget {

  @override
  _TLogingWndState createState() => _TLogingWndState();
}



class _TLogingWndState extends State<TLogingWnd> {

  var _btnEnabled = false;

    Future<VerifiCode>? _vcode ;


  final _phoneNumTxtctller = TextEditingController();
  final _passCodeTxtctller = TextEditingController();

  bool _isClearBtn = false;
  bool _isPhoneNumClearBtn = false;
  bool _isAgree = false;


  String _diaiCode = '+855';

 // late String _vcodeMsgStr;
  String btnTxt = '获取验证码';
  int secs = 0;
  Timer? coundDownTmr;


  late OverlayEntry _myOverlayMsgWnd ;


  String buildDt = '2021-04-08 15:32:51';


  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {


    super.initState();

    _phoneNumTxtctller.text='967995233';


     // _vcode = fetchVCode();

      Future.delayed(Duration(milliseconds: 200)).then((_) async {
        setState(() {
          buildDt = TBleSingleton().appBuildDt();
        });
      }) ;

  // final aa =   SvgPicture.asset( 'images/svgs/AppLogo.svg' ,width: 90, fit: BoxFit.contain, );
  //    svg.fromSvgString('rawSvg', 'key'  ).then((value) {
  //      value.toPicture();
  //    });


  }

  @override
  void deactivate() {
    print('${this.runtimeType.toString()} deactivate()......................');
  }

  @override
  void dispose() {
    print('${this.runtimeType.toString()} dispose()......................');

    coundDownTmr?.cancel();

    _phoneNumTxtctller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('登 陆'),
      // ),

      resizeToAvoidBottomInset: false,
      body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child:  Container(
              padding: EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [

                  Expanded(flex: 30, child: SizedBox()),

                  UnconstrainedBox(

                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      //child: SvgPicture.asset(  'images/svgs/AppLogo.svg'  ),
                      child: SvgPicture.asset( 'images/svgs/AppLogo.svg' ,width: 90, fit: BoxFit.contain, ),
                     // Image.asset(  'images/AppLogo.png'  , fit: BoxFit.fill,),
                    ),
                  ),

                  Expanded(flex: 30, child: SizedBox()),

                  Text('手机号登录', style: TextStyle(color: Color(0xff222222) , fontSize: 26, fontWeight: FontWeight.bold),),

                  Expanded(flex: 30, child: SizedBox()),

              Container(
                padding:  EdgeInsets.fromLTRB(0, 20, 0, 0),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                          color: Color(0xffcccccc),
                          width: 1,
                        )
                    )
                ),
                child: Row(

                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () async {
                          final rtn = await  Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TSelectCountRegionCode( )),
                          );

                        //  print('rtn from auth wnd.....$rtn');

                          if(rtn != null)
                          setState(() {
                            _diaiCode = rtn.toString();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Wrap(children: [
                            Text(_diaiCode, style: TGlobalData().tsListTitleTS1,),
                            SizedBox(
                              width: 18,
                               height: 20,
                              child: CustomPaint(painter: TExpendArrow(),),
                            ),
                          ],),
                        )
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: _phoneNumTxtctller,
                          style: TGlobalData().tsListTitleTS1,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            fillColor: Colors.transparent,
                            border: InputBorder.none,
                            // border: OutlineInputBorder(
                            //     borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            //     borderSide: BorderSide(color: Colors.blue)),
                            // focusedBorder: OutlineInputBorder(
                            //     borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            //     borderSide: BorderSide(color: Colors.blue)),
                           // filled: true,
                           // contentPadding: EdgeInsets.only(left: 20),
                            hintText: '请输入手机号',
                              suffixIcon:  _isPhoneNumClearBtn ?
                              IconButton(icon:  SvgPicture.asset( 'images/svgs/deleteIcon.svg' , width: 20, height: 20, fit: BoxFit.scaleDown,color: TGlobalData().crMainThemeColor, ),
                                onPressed: (){
                                  _phoneNumTxtctller.clear();
                                  setState(() {
                                    _isPhoneNumClearBtn = false;
                                    _btnEnabled = false;
                                  });
                                } , )   : null
                          )  ,
                          onChanged: (str){
                            if(str.length > 0){
                              setState(() {
                                _isPhoneNumClearBtn = true;
                                if(_passCodeTxtctller.text.length > 5 && _phoneNumTxtctller.text.length > 5)
                                    _btnEnabled = true;
                                else _btnEnabled = false;
                              });
                            }else{
                              setState(() {
                                _isPhoneNumClearBtn = false;
                                _btnEnabled = false;
                              });
                            }
                          },
                        ),
                      ),
                    ),

                  ],
                )


                  // InternationalPhoneNumberInput(
                  //   onInputChanged: (PhoneNumber number) {
                  //    // print('onInputChanged: ${number.phoneNumber}');
                  //
                  //   okNumber = number;
                  //   },
                  //   onInputValidated: (bool value) {
                  //    // print('onInputValidated: $value');
                  //
                  //     new Future.delayed(Duration(milliseconds: 100)).then((_) {
                  //       formKey?.currentState?.validate();
                  //     });
                  //
                  //     setState(() {
                  //       btnEnabled = value;
                  //     });
                  //
                  //   },
                  //   selectorConfig: SelectorConfig(
                  //     selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                  //   ),
                  //   ignoreBlank: false,
                  //   autoValidateMode: AutovalidateMode.disabled,
                  //   selectorTextStyle: TextStyle(color: Colors.black),
                  //   initialValue: number,
                  //   textFieldController: _phoneNumTxtctller,
                  //   formatInput: false,
                  //   keyboardType: TextInputType.numberWithOptions(
                  //       signed: false, decimal: true),
                  //   //  inputBorder: OutlineInputBorder(),
                  //   //   inputDecoration: InputDecoration(
                  //   //
                  //   //     labelText: '请输入手机号码',
                  //   //   ) ,
                  //
                  //   inputDecoration: InputDecoration.collapsed(
                  //     border: InputBorder.none,
                  //     hintText: '请输入手机号码',
                  //     hintStyle: TextStyle(color: Colors.grey),
                  //
                  //   ),
                  //
                  //   onSaved: (PhoneNumber number) {
                  //     print('On Saved: $number');
                  //   },
                  // ),
              ),




                  Expanded(flex: 40, child: SizedBox()),

                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1.0,color: Color(0xffcccccc)),
                      )
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                            controller: _passCodeTxtctller,
                            style: TGlobalData().tsListTitleTS1,
                            decoration: InputDecoration(

                              //fillColor: Colors.transparent,
                              border: InputBorder.none,
                              // border: OutlineInputBorder(
                              //     borderRadius: BorderRadius.all(Radius.circular(5.0)),
                              //     borderSide: BorderSide(color: Colors.blue)),
                              // focusedBorder: OutlineInputBorder(
                              //     borderRadius: BorderRadius.all(Radius.circular(5.0)),
                              //     borderSide: BorderSide(color: Colors.blue)),
                              // filled: true,
                             // contentPadding: EdgeInsets.only(
                             //     top: 2.0, bottom: 2.0, left: 20.0, right: 20.0),
                              hintText: '请输验证码',
                              suffixIcon:  _isClearBtn ?  IconButton(icon:
                              SvgPicture.asset( 'images/svgs/deleteIcon.svg' , width: 20, height: 20, fit: BoxFit.scaleDown, color: TGlobalData().crMainThemeColor,),
                                          onPressed: (){
                                _passCodeTxtctller.clear();
                                setState(() {
                                  _isClearBtn = false;
                                  _btnEnabled = false;
                                });
                                } , ) : null
                            ),
                            onChanged: (str){
                              if(str.length > 0){
                                setState(() {
                                  _isClearBtn = true;
                                  if(_passCodeTxtctller.text.length > 5 && _phoneNumTxtctller.text.length > 5)
                                    _btnEnabled = true;
                                  else _btnEnabled = false;

                                });
                              }else{
                                _isClearBtn = false;
                                _btnEnabled = false;
                              }
                            },
                          ),
                        ),

                        Container(
                          width: 1,
                         height: 20,
                          color: Colors.grey,

                        ),

                        TextButton( // get verication code
                            onPressed:  secs == 0 ?  () async {
                              secs = 60;

                              // setState(() {
                              //   _vcode = fetchVCode();
                              // });
                              startCoundDownTmr();

                              TGlobalData().showToastInfo("获取验证码请求已发送....");

                           final Map  rtnObj = await    TRemoteSrv().fetchVCode(_pnum());

                           if(rtnObj['code'] == 0){

                           }else{
                           //  TGlobalData().showToastInfo(AppLocalizations.of(context)!.vcodeErr1);
                           }


                        } : null, child:

                        Text('$btnTxt',style: TextStyle(fontSize: 20,color:Colors.black38 ),)),

                      ],

                    ),
                  ),

                  Row(
                    children: [
                      SizedBox(
                        width: 26,
                        child: Checkbox(
                          activeColor: TGlobalData().crMainThemeColor,

                          value: _isAgree, onChanged: (v){
                          setState(() {
                          _isAgree = v! ;
                        }); },),
                      ),

                       Text('我已阅读并同意“'),
                      // Text(AppLocalizations.of(context)!.helloWorld),
                      InkWell(onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TUserServicesAgreement( )),
                        );
                      }, child:
                      Text('用户协议', style: TextStyle( color:Colors.blue ) ),),

                      Text('”和“'),
                      InkWell(onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TPrivacyAgreement( )),
                        );
                      }, child:
                      Text('隐私政策' , style: TextStyle( color:Colors.blue ) ),),
                      Text('”'),

                    ],
                  ),

                  Expanded(flex: 100, child: SizedBox()),



                  ElevatedButton(

                   style: ElevatedButton.styleFrom(
                     primary: TGlobalData().crMainThemeColor,
                     onPrimary: Color(0xff119999),
                     shape: StadiumBorder(),
                     shadowColor: Color(0xff118888),
                     padding: EdgeInsets.symmetric(vertical: 14, horizontal: 0),
                    // textStyle: TextStyle(fontSize: 18, color: Colors.red),
                   ),

                    child: Text('登   录' , style: TextStyle(fontSize: 18, color: Colors.white),),
                    onPressed: _btnEnabled && _isAgree ?   () async {


                   //   print(_pnum());
                   //   print(_passCodeTxtctller.text);
                   //
                   // final rtnObj = await TRemoteSrv().loginForToken(_pnum(), _passCodeTxtctller.text);
                   //
                   //
                   // print('-----=++++= ====  rtnObj :  ');
                   // print(rtnObj.toString());

                   //  return;

                     await showDialog(context: context, builder: (BuildContext ctx){
                       // Future.delayed(Duration(seconds: 4)).then((value) {
                       //   Navigator.pop(ctx);
                       // });
                       return   Container(
                         color: Colors.transparent,
                         child: Center(child:
                         Container(
                           width: 120,
                             height: 80,
                             decoration: ShapeDecoration(
                                 color: Colors.white,
                               shape:  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))
                             ),
                             child: Padding(
                               padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
                               child: FutureBuilder< Map<String,dynamic> >(
                                // future: fetchAuthoriCode(_passCodeTxtctller.text),
                                 future:  TRemoteSrv().loginForToken(_pnum(), _passCodeTxtctller.text),
                                 builder: (ctx, ss){
                                   if(ss.hasData){
                                     Map<String , dynamic> rtnObj = ss.data!;
                                    // print('rsl code is : ${ss.data!.rslCode}');
                                     if(rtnObj.isNotEmpty &&  rtnObj['code'] == 0 ){
                                      // print('ok, login ok....');

                                       //  {code: 0, msg: successful, timestamp: 1626949114, data: {token: tj8pqojo89ev6dj5fkbj8d9jdt, phone: 855967995233, uid: e616282ba6bc94e8, username: cf3c24c6b0a4b5c2, avatar: https://teststatic.ultronlocker.com/avatar/5f29cf2570e43b9010cff4a8179bfdf3.jpg, nickname: , is_new: 0}}

                                       Map<String, dynamic> datObj = rtnObj['data']  ;

                                       bool isNew = false;
                                       if(datObj.isNotEmpty){
                                       TGlobalData().keepCurrUserToken( datObj['token']  );
                                       TGlobalData().keepCurrUserAcceToken( datObj['access_token']  );

                                       final nknObj = datObj['nickname'];
                                       String nkn = '';
                                       if(nknObj != null)
                                         nkn = nknObj.toString();

                                       List<String> strLs = [
                                       datObj['phone'],
                                         datObj['uid'],
                                       datObj['username'],
                                         nkn.isEmpty ? '新用户' : nkn,
                                         datObj['avatar']
                                       ];

                                     //  print(strLs);

                                       TGlobalData().keepCommonLoginData(strLs);

                                       // TGlobalData().userAccount =
                                       // TGlobalData().remotePhotoUrl = ;
                                       // TGlobalData().currUid = ;
                                       // TGlobalData().userNickname = ;
                                       // TGlobalData().phoneNum = ;
                                         isNew =   datObj['is_new'] == 1 ;
                                      }

                                       _getinNextWnd(isNew);
                                     }else {
                                       // secs = 60;
                                       // startCoundDownTmr();
                                       // _passCodeTxtctller.clear();
                                       // setState(() {
                                       //   _isClearBtn = false;
                                       //   _btnEnabled = false;
                                       // });

                                       TGlobalData().showToastInfo("验证码错误!!");
                                     }


                                     Navigator.pop(ctx);
                                    return SizedBox();
                                   }else if(ss.hasError){
                                     Navigator.pop(ctx);
                                     return Text('hasError....',style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),);
                                   }
                                   return   CircularProgressIndicator();


                                 },
                               ),
                             ))),
                       );
                     });



                     // print('Current Number : ${okNumber.phoneNumber}');

                     // TGlobalData().phoneNum = _phoneNumTxtctller.value.text;
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => TLogingPwdWnd( )),
                      //   // MaterialPageRoute(builder: (context) => TAccountManager()),
                      // );
                    } : null ,
                  ),

                  Expanded(flex: 100, child: SizedBox()),
/*
                  _vcode == null ? SizedBox(height:40, width: 40,) :
                  FutureBuilder<VerifiCode>(
                      future: _vcode,
                      builder: (context, snapshot ){
                        if(snapshot.hasData){

                         // Locale appLocale =  Localizations.localeOf(context);
                         //
                         // print(appLocale);

                          String vcodeMsgStr =  '您的验证码是： ${snapshot.data!.vcode} ';

                          Future.delayed(Duration(milliseconds: 0)).then((value) => showTPushNotifWnd(vcodeMsgStr));

                          _vcode = null;

                          startCoundDownTmr();

                          return SizedBox(height:40, width: 40,);
                        }else if(snapshot.hasError){
                          TGlobalData().showToastInfo('接受验证码的时候产生错误....');
                          return SizedBox(height:40, width: 40,);
                        }
                        return Center(child: SizedBox(height: 40,width: 40, child: CircularProgressIndicator()));
                      }
                  ),

*/

//                   ElevatedButton(
//
//                     child:  Text( AppLocalizations.of(context)!.language),
//                     onPressed: () async {
//
//                       bool isChged = await _doChooseLanguage();
//
//                       if(isChged)
//                         Phoenix.rebirth(context);
//
//                     },
//                   ),

/*
                  ElevatedButton(

                    child: Text('清除所有参数'),
                    onPressed: () async {
                      //print(MediaQuery.of(context).padding);
                      // SystemChannels.textInput.invokeMethod('TextInput.hide');


                     // final test = context.findAncestorStateOfType<_TLogingWndState>();

                     // print(test);

                        TGlobalData().resetAllPreference();

                        TGlobalData().showToastInfo("清除所有参数成功!!");

                      // Navigator.push(
                      //   context,
                      //   // MaterialPageRoute(builder: (context) => TLogingPwdWnd(okNumber)),
                      //   MaterialPageRoute(builder: (context) => TDevInformations()),
                      // );

                     // double hh = MediaQuery.of(context).size.height  ;
                     // print('h: $hh');

                    },
                  ),

 */



                 // Expanded(flex: 200, child: SizedBox()),

                  Text('Flutter Ver: $tFlutterFrameworkVersion   App Ver: $buildDt', textAlign: TextAlign.center, style: TGlobalData().tsTxtFn14GreyAA,),

                ],
              ),
            ),
          ),
    );



  }


  String _pnum () {
    String phoneNum = '$_diaiCode${_phoneNumTxtctller.text}';
    phoneNum = phoneNum.replaceAll('+', '');

    return phoneNum;
  }




  Future<bool> _doChooseLanguage(  ) async
  {

    List<Map>   allLocasLs =TGlobalData().allLanguages()  ;// AppLocalizations.supportedLocales;

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
                              children:  [

                                Container(
                                  height: MediaQuery
                                      .of(context)
                                      .size
                                      .height * .3,
                                  child: ListView.separated(
                                      itemCount: allLocasLs.length,
                                      itemBuilder: (itCtx , idx) {
                                        return ListTile(title:  Text(allLocasLs[idx]['title']),
                                          onTap: (){

                                          Map tmpObj =  allLocasLs[idx];
                                         final String langStr = tmpObj['langCode'];
                                          final String countryStr = tmpObj['countryCode'];
                                          final String scriptStr =   tmpObj['scriptCode'];
                                          List<String> localInfoLs =[langStr , countryStr ,scriptStr ];
                                           // final l1 = const Locale.fromSubtags(languageCode: 'zh');
                                          // final l2 = const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'hant');
                                          //
                                          // print(l1 == l2);

                                          // final appLocal =   Locale.fromSubtags( languageCode: langStr,
                                          //     countryCode: countryStr.isEmpty ? null : countryStr ,
                                          //     scriptCode: scriptStr.isEmpty ? null : scriptStr);
                                          //
                                          //  Provider.of<TLocalChgedNotifyer>(context).chgeLocale(appLocal);

                                          TGlobalData().keepCurrLanguage(localInfoLs);

                                          Navigator.pop(bctx , true);

                                          },

                                        );
                          },
                                      separatorBuilder: (sctx, idx) => Divider(),

                                  ),
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
                                          Navigator.pop(bctx , true);
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

    if(rtn != null && rtn as bool ){
      return Future<bool>.value(true);
    }

    return Future<bool>.value(false);

  }



  void startCoundDownTmr(){
    //new Future.delayed(Duration(milliseconds: 2000)).then((_) {

    coundDownTmr = Timer(Duration(seconds:1),
            (){
          retryCoundDownSecs();
        }
    );

    // });
  }


  void retryCoundDownSecs()
  {
    secs --;
    if(secs > 0){

      // new Future.delayed(Duration(milliseconds: 1000)).then((_) {
      //   retryCoundDownSecs();
      // });

      coundDownTmr?.cancel();
      coundDownTmr = null;

      coundDownTmr = Timer(Duration(seconds:1),
              (){
            retryCoundDownSecs();
          }
      );

      setState(() {
        btnTxt =  sprintf('重新发送(%02i)' , [secs])   ;


      });
    }else{
      setState(() {
        btnTxt = '获取验证码';
        if(_passCodeTxtctller.text.length > 0)
          _btnEnabled = true;
      });

    }

  }

  void showTPushNotifWnd(String msgStr){
    _myOverlayMsgWnd = OverlayEntry(
        builder:(BuildContext ctx){
      return TPushNotification(msgStr: msgStr );
    } );

    Navigator.of(context).overlay!.insert(_myOverlayMsgWnd);

    Future.delayed(Duration(seconds: 6)).then((_) {
      _myOverlayMsgWnd.remove();
    });
  }

  void getPhoneNumber(String phoneNumber) async {
    // PhoneNumber number =
    //     await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber, 'US');

    // setState(() {
    //   this.number = number;
    // });
  }

  void _getinNextWnd(bool isNewUser){

    if(isNewUser){

      // setup nickname and user photo

    }


    Future.delayed(Duration(milliseconds: 200)).then((value) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            settings: RouteSettings(name: '/tmainwnd', arguments: Map()),
            builder: (context) => TMainWnd()),
      );
    });
  }

/*
  void _fetchVCode () async {

    String csrf = hex.encode(     TGlobalData().generateRndBytes(16) );

    //  print('csrf = $csrf');

    var queryParameters = {
      'ac':'send_code',
      'ct':'common',
      'ts': '${DateTime.now().millisecondsSinceEpoch}'
    };


    // api1.smartlock.com 内网
// testapi.ultronlocker.com 外网测试
// api.ultronlocker.com 正式

   // Uri tmpUri = Uri.parse('https://testapi.ultronlocker.com/');
    Uri tmpUri = Uri.parse('https://api.ultronlocker.com/');



    //http.MultipartRequest();
   // http.MultipartFile()

    Map tmpOjb = {
      'type': '1',
      'account' : '85593618123',
    };

    final httpResp = await  http.post(

      Uri.https(tmpUri.host, tmpUri.path, queryParameters),

      headers:   <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json; charset=UTF-8',
        'csrf' : csrf,
        'ENCRYPT':'1',
        //'debug':'1',
        'os':'ios',
      },
      body: 'post_data=${TGlobalData().encryptHttpPost(tmpOjb,  TGlobalData.aesFixKey ,  csrf)}',
    );

    //print(  httpResp.request );

    // print('\nGot http respon:\n\n');
    // print( utf8.decode(  httpResp.bodyBytes   ) );
    //print(   httpResp.body  );

    final String bodyStr =  httpResp.body;

    if(bodyStr.startsWith('<html>')){
      print(bodyStr);
      TGlobalData().showToastInfo(bodyStr);
      return;
    }

    final String jsonStr = TGlobalData().decrytpHttpRespon( bodyStr  , TGlobalData.aesFixKey  , csrf);

    //  print('Got json: ' );
    //  print(jsonStr );
    // return;


    var jsonCtn = jsonDecode(jsonStr);

     print('httpResp: ${ jsonCtn.toString()}');


  }
*/

}



Future<VerifiCode> fetchVCode() async {
  //String url = "https://www.extraone.com.au/thor/verificationcode.php";


  //var http;
  // final response = await http.post(Uri.https('jsonplaceholder.typicode.com', 'albums/1'),
  //     headers: {HttpHeaders.contentTypeHeader: 'application/json'},
  //     body: jsonEncode({"id": "1"}));

  final response =
  await http.get(Uri.https('www.extraone.com.au', 'thor/verificationcode.php'));


  if (response.statusCode == 200) {
    print('Http get rtn: ' + response.body);
    return VerifiCode.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load post');
  }
}

class VerifiCode {
  final String vcode;

  VerifiCode({ required  this.vcode});

  factory VerifiCode.fromJson(Map<String, dynamic> json) {
    return VerifiCode(vcode: json['verificationcode']);
  }
}


Future<AuthorizationCode> fetchAuthoriCode(String acode) async {

  var queryParameters = {
    'authCode': acode,

    'timestamp': '${DateTime.now().millisecondsSinceEpoch}'
  };

  Uri tmpUri = Uri.parse('https://www.extraone.com.au/thor/authorizatecheck.php');
  // print('host: ${tmpUri.host} , path: ${tmpUri.path}');


  final response = await http.post(

    Uri.https(tmpUri.host, tmpUri.path, queryParameters),

    // headers:   <String, String>{
    //   'Content-Type': 'application/json; charset=UTF-8',
    //   'accept': 'application/json; charset=UTF-8',
    //   // 'authorization': 'Basic ' + base64Encode(utf8.encode('${_usernameTxtCtrl.text}:${_passwdTxtCtrl.text}')),
    //   // 'logintype' : 'app',
    //   // 'timestamp' : '${DateTime.now().millisecondsSinceEpoch}',
    // },
    // body: jsonEncode(<String, String>{
    //   'title': 'This is tootzoe\'s title....',
    // }),
  );


  if (response.statusCode == 200) {
    print('Http post rtn: ' + response.body);
    return AuthorizationCode.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to Authorizate code....');
  }
}

class AuthorizationCode {
  final String rslCode;

  AuthorizationCode({ required  this.rslCode});

  factory AuthorizationCode.fromJson(Map<String, dynamic> json) {
    return AuthorizationCode(rslCode: json['authorizationRsl']);
  }
}




class TExpendArrow extends CustomPainter{
  late Paint _myPaint;

  TExpendArrow() {
    _myPaint = Paint()
        ..color = Color(0xff666666)
        ..strokeWidth = 2.0
        ..style =PaintingStyle.stroke;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint

    //canvas.drawCircle(Offset(size.width /2, size.height / 2), size.width / 2  , _myPaint);
    // canvas.drawRect(Offset(0.0, 0.0) & size , _myPaint);

    double vertiaclOffset = size.height /8.0;

    var path = Path();
    path.moveTo(size.width / 6 , size.height / 4 + vertiaclOffset );
    path.lineTo(size.width / 2, size.height / 5 * 3+ vertiaclOffset);
    path.lineTo(size.width - size.width / 6, size.height / 4 + vertiaclOffset );
    canvas.drawPath(path,    _myPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
   // throw UnimplementedError();
    return false;
  }

}