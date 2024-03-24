import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sprintf/sprintf.dart';
import 'package:convert/convert.dart';


import '../TGlobal_inc.dart';
import '../TBleSingleton.dart';

import '../UserInfo/TUserChgeNickname.dart';
import '../UserInfo/TUserPhotoWnd.dart';
import 'TPrivatePwdWnd.dart';
import 'TPrivateFpWnd.dart';
import 'TPrivNfcWnd.dart';

class TUserDetailWnd extends StatefulWidget {

  final Map userObj;

  TUserDetailWnd(this.userObj);

  @override
  _TUserDetailWndState createState() => _TUserDetailWndState();
}


class _TUserDetailWndState extends State<TUserDetailWnd> {


  static final double _eachListHeight = 180;

  List<Map>  _unlockNumberObjLs = [];
  List<Map> _unlockFingerprintObjLs = [];
  List<Map> _unlockNfcObjLs = [];

  List<String> _fingerNameLs = [ '',
   '左手小指',  '左手无名指','左手中指','左手食指','左手大拇指',
    '右手大拇指', '右手食指','右手中指','右手无名指','右手小指'
  ];


  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

    new Future.delayed(Duration(milliseconds: 80)).then((_)  => _fetchPwdList() );

    new Future.delayed(Duration(milliseconds: 400)).then((_)  => _fetchFpList());

    new Future.delayed(Duration(milliseconds: 700)).then((_)  => _fetchNfcList());

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
      appBar: AppBar(title: Text(  '人员管理',
        style: TextStyle(color: Color(0xff222222), fontSize: 20, fontWeight: FontWeight.bold), ),
        elevation: 0.0,
        backgroundColor: Color(0xfffafafa),
        iconTheme: IconThemeData(color: Colors.black),),
      body: Container(
         padding: EdgeInsets.fromLTRB(22.0, 2.0, 22.0, 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Stack(
                  fit: StackFit.loose,
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 32.0,
                      backgroundImage: FileImage(File(TGlobalData().userPhotoUrlById(0))),
                    ),

                    Positioned(
                      right: -14,
                        bottom: -10,
                        child: IconButton(
                          splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              icon: Icon(Icons.camera , size: 26.0, color: TGlobalData().crMainThemeColor,),
                              onPressed: ()async{
                                final rtn = await  Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => TUserPhotoWnd(  '' )),

                                );
                                setState(() { });
                              },
                              )),
                  ],
                ),
              ),


              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12.0,
                children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(widget.userObj['username'],
                      style: TextStyle(fontSize: 26,fontWeight: FontWeight.bold,color: Color(0xff222222))),
                ),
                InkWell(child: Icon(Icons.copy , size: 20,  color: Color(0xffaaaaaa),),
                onTap: () async {
                  final rtn = await  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TUserChgeNickname(widget.userObj['username'] )),
                  );

                  if(rtn != null ) {
                    String newName = rtn.toString();

                   bool isOk = await _chgeNickName(widget.userObj['userid'], newName);

                   if(isOk)
                    setState(() {
                      widget.userObj['username'] = newName;
                    });
                  }

                },
                ),
              ],),




              Expanded(
                child: SingleChildScrollView(
                  child : Container(
                   // height: 400,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 16.0),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xffe8e8e8))),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Text('密码开锁', style: TGlobalData().tsListTitleTS1,),
                              InkWell(child: Icon(Icons.add , size: 32,  color: TGlobalData().crMainThemeColor,),
                              onTap: () async {

                                bool isOk = await _appendPrivPwd(widget.userObj['userid']);
                                if(isOk) _fetchPwdList();

                              },
                              ),
                          ],),
                        ),


                        Container(
                          height: _eachListHeight,
                          child: RefreshIndicator(
                            onRefresh: _fetchPwdList,
                            child: ListView.builder(
                              itemCount: _unlockNumberObjLs.isEmpty ? 1 : _unlockNumberObjLs.length,
                              itemBuilder: (itCtx , idx){

                                double widW = MediaQuery.of(itCtx).size.width;

                                // print('w $widW');

                                return _unlockNumberObjLs.isEmpty ?
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  child: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 20,
                                    children: [
                                      Icon(Icons.touch_app , size: 40 , color: Color(0xff498FF1),),
                                      Text('未添加' ,style: TGlobalData().tsListCntTS1,),
                                    ],),
                                )
                                    :
                                ListTile(

                                  contentPadding: EdgeInsets.symmetric(vertical: 2.0),

                                  leading: Icon(Icons.lock , size: 40 , color: Color(0xff498FF1),),

                                  title:  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: widW * .6,
                                        child: TextField(
                                          style: TGlobalData().tsListTitleTS1,
                                          controller: _unlockNumberObjLs[idx]['txtCtrlor'],
                                          obscureText:  !  (_unlockNumberObjLs[idx]['showPwd'] as bool),
                                          readOnly: true,
                                          obscuringCharacter: '●',

                                          decoration: InputDecoration(
                                            border: OutlineInputBorder( borderSide: BorderSide.none,  gapPadding: 0),
                                            contentPadding: EdgeInsets.zero,
                                            // focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.zero, gapPadding: 0),
                                            suffixIcon:  InkWell(
                                              child: _unlockNumberObjLs[idx]['showPwd'] as bool ?
                                              Icon(   Icons.visibility    ,    size: 26,color: Color(0xff666666),)
                                                  : Icon(   Icons.visibility_off   ,  size: 26,color: TGlobalData().crCommonGrey,) ,
                                              highlightColor: Colors.transparent,
                                              splashColor: Colors.transparent,

                                              onTap: (){

                                                _unlockNumberObjLs[idx]['showPwd'] = !(_unlockNumberObjLs[idx]['showPwd'] as bool);

                                                setState(() {});

                                              },
                                            ),

                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  trailing: InkWell(
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      onTap: () async {
                                        final rtn = await showDialog(context: context,
                                            builder: (BuildContext dctx){
                                              return Material(
                                                color: Colors.transparent,
                                                child: GestureDetector(
                                                  behavior: HitTestBehavior.opaque,
                                                  onTap: (){ Navigator.pop(dctx); },
                                                  child: Container(
                                                      margin: EdgeInsets.symmetric (horizontal:  MediaQuery.of(context).size.width / 11.0,
                                                          vertical:  MediaQuery.of(context).size.height / 4 ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular( 40.0),
                                                      ),
                                                      child:Center(
                                                        child: GestureDetector(
                                                          behavior: HitTestBehavior.opaque,
                                                          onTap: (){ },
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              Icon(Icons.warning, color: Colors.yellow, size: 64.0,),
                                                              Text('确认删除此密码 ？', style: TGlobalData().tsListTitleTS1,),

                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                children: [
                                                                  ElevatedButton(
                                                                    onPressed:   ()async {
                                                                      bool isOk = await _deletePrivPwdByIndex(_unlockNumberObjLs[idx]['idx']);
                                                                      Navigator.pop(dctx , isOk);
                                                                    },
                                                                    child: Text('确  定' , style: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
                                                                    style: ElevatedButton.styleFrom(
                                                                      primary: TGlobalData().crMainThemeColor,
                                                                      onPrimary: TGlobalData().crMainThemeOnColor,
                                                                      shadowColor: Colors.white,
                                                                      padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                                                                      shape: StadiumBorder(),
                                                                    ),
                                                                  ),


                                                                  ElevatedButton(
                                                                    onPressed:   (){
                                                                      Navigator.pop(dctx);
                                                                    },
                                                                    child: Text('取  消' , style: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
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
                                                            ],
                                                          ),
                                                        ),
                                                      )

                                                  ),
                                                ),
                                              );
                                            }) ;

                                        if( (rtn != null )  &&   (rtn as bool) ){
                                          _fetchPwdList();
                                        }

                                      },
                                      child: Icon(Icons.delete, size: 26, color: Color(0xffbbbbbb),)),
                                );
                              },
                            ),
                          ),
                        ),


                        Container(
                          margin: EdgeInsets.only(top: 16.0),
                          padding: EdgeInsets.only(bottom: 10.0),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xffe8e8e8))),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Text('指纹开锁', style: TGlobalData().tsListTitleTS1,),
                              InkWell(child: Icon(Icons.add , size: 32,  color: TGlobalData().crMainThemeColor,),
                                onTap: () async {

                                  bool isOk = await _appendPrivFp(widget.userObj['userid']);

                                  if(isOk)
                                    _fetchFpList();


                                },
                              ),
                            ],),
                        ),



                        Container(
                          height: _eachListHeight,
                          child: RefreshIndicator(
                            onRefresh: _fetchFpList,
                            child: ListView.builder(
                              itemCount: _unlockFingerprintObjLs.isEmpty ? 1 : _unlockFingerprintObjLs.length,
                              itemBuilder: (itCtx , idx){
                                return _unlockFingerprintObjLs.isEmpty ?
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                                  child: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 20,
                                    children: [
                                      Icon(Icons.fingerprint , size: 40 , color: Color(0xff498FF1),),
                                      Text('未添加' ,style: TGlobalData().tsListCntTS1,),
                                    ],),
                                )
                                    :
                                ListTile(

                                  contentPadding: EdgeInsets.symmetric(vertical: 2.0),

                                  leading: Icon(Icons.fingerprint , size: 40 , color: Color(0xff498FF1),),

                                  title:  Text(_fingerNameLs[_unlockFingerprintObjLs[idx]['fgNum']] , style:  TGlobalData().tsListTitleTS1,)  ,

                                  trailing: InkWell(
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      onTap: () async {
                                        final rtn = await showDialog(context: context,
                                            builder: (BuildContext dctx){
                                              return Material(
                                                color: Colors.transparent,
                                                child: GestureDetector(
                                                  behavior: HitTestBehavior.opaque,
                                                  onTap: (){ Navigator.pop(dctx); },
                                                  child: Container(
                                                      margin: EdgeInsets.symmetric (horizontal:  MediaQuery.of(context).size.width / 11.0,
                                                          vertical:  MediaQuery.of(context).size.height / 4 ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular( 40.0),
                                                      ),
                                                      child:Center(
                                                        child: GestureDetector(
                                                          behavior: HitTestBehavior.opaque,
                                                          onTap: (){  },
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              Icon(Icons.warning, color: Colors.yellow, size: 64.0,),
                                                              Text('确认删除指纹 ？', style: TGlobalData().tsListTitleTS1,),

                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                children: [
                                                                  ElevatedButton(
                                                                    onPressed:   (){
                                                                      Navigator.pop(dctx , true);
                                                                    },
                                                                    child: Text('确  定' , style: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
                                                                    style: ElevatedButton.styleFrom(
                                                                      primary: TGlobalData().crMainThemeColor,
                                                                      onPrimary: TGlobalData().crMainThemeOnColor,
                                                                      shadowColor: Colors.white,
                                                                      padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                                                                      shape: StadiumBorder(),
                                                                    ),
                                                                  ),


                                                                  ElevatedButton(
                                                                    onPressed:   (){
                                                                      Navigator.pop(dctx);
                                                                    },
                                                                    child: Text('取  消' , style: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
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
                                                            ],
                                                          ),
                                                        ),
                                                      )

                                                  ),
                                                ),
                                              );
                                            }) ;

                                        if( (rtn != null )  &&   (rtn as bool) ){

                                          int fpIdx = _unlockFingerprintObjLs[idx]['fpIdx'];
                                          //  print(fpIdx);
                                          // Navigator.pop(context);
                                          bool isOk = await  _deletePrivFpByIndex(fpIdx);
                                          if(isOk) _fetchFpList();
                                        }

                                      },
                                      child: Icon(Icons.delete, size: 26, color: Color(0xffbbbbbb),)),
                                );
                              },
                            ),
                          ),
                        ),


                        Container(
                          margin: EdgeInsets.only(top: 16.0),
                          padding: EdgeInsets.only(bottom: 10.0),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xffe8e8e8))),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Text('NFC开锁', style: TGlobalData().tsListTitleTS1,),
                              InkWell(child: Icon(Icons.add , size: 32,  color: TGlobalData().crMainThemeColor,),
                                onTap: () async {

                                  bool isOk = await _appendPrivNfc(widget.userObj['userid']);

                                  if(isOk)
                                    _fetchNfcList();


                                },
                              ),
                            ],),
                        ),



                        Container(
                          height: _eachListHeight,
                          child: RefreshIndicator(
                            onRefresh: _fetchNfcList,
                            child: ListView.builder(
                              itemCount: _unlockNfcObjLs.isEmpty ? 1 : _unlockNfcObjLs.length,
                              itemBuilder: (itCtx , idx){
                                return _unlockNfcObjLs.isEmpty ?
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                                  child: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 20,
                                    children: [
                                      Icon(Icons.nfc , size: 40 , color: Color(0xff498FF1),),
                                      Text('未添加' ,style: TGlobalData().tsListCntTS1,),
                                    ],),
                                )
                                    :
                                ListTile(

                                  contentPadding: EdgeInsets.symmetric(vertical: 2.0),

                                  leading: Icon(Icons.nfc , size: 40 , color: Color(0xff498FF1),),

                                  title:  Text('NFC码：${sprintf("%02X●●●%02X%02X" , _unlockNfcObjLs[idx]['nfcCode'])}' , style:  TGlobalData().tsListTitleTS1,)  ,

                                  trailing: InkWell(
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      onTap: () async {
                                        final rtn = await showDialog(context: context,
                                            builder: (BuildContext dctx){
                                              return Material(
                                                color: Colors.transparent,
                                                child: GestureDetector(
                                                  behavior: HitTestBehavior.opaque,
                                                  onTap: (){ Navigator.pop(dctx); },
                                                  child: Container(
                                                      margin: EdgeInsets.symmetric (horizontal:  MediaQuery.of(context).size.width / 11.0,
                                                          vertical:  MediaQuery.of(context).size.height / 4 ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular( 40.0),
                                                      ),
                                                      child:Center(
                                                        child: GestureDetector(
                                                          behavior: HitTestBehavior.opaque,
                                                          onTap: (){  },
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              Icon(Icons.warning, color: Colors.yellow, size: 64.0,),
                                                              Text('确认删除NFC ？', style: TGlobalData().tsListTitleTS1,),

                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                children: [
                                                                  ElevatedButton(
                                                                    onPressed:   (){
                                                                      Navigator.pop(dctx , true);
                                                                    },
                                                                    child: Text('确  定' , style: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
                                                                    style: ElevatedButton.styleFrom(
                                                                      primary: TGlobalData().crMainThemeColor,
                                                                      onPrimary: TGlobalData().crMainThemeOnColor,
                                                                      shadowColor: Colors.white,
                                                                      padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                                                                      shape: StadiumBorder(),
                                                                    ),
                                                                  ),


                                                                  ElevatedButton(
                                                                    onPressed:   (){
                                                                      Navigator.pop(dctx);
                                                                    },
                                                                    child: Text('取  消' , style: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
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
                                                            ],
                                                          ),
                                                        ),
                                                      )

                                                  ),
                                                ),
                                              );
                                            }) ;

                                        if( (rtn != null )  &&   (rtn as bool) ){

                                          int nfcIdx = _unlockNfcObjLs[idx]['idx'];
                                          //  print(fpIdx);
                                          // Navigator.pop(context);
                                          bool isOk = await  _deleteNfcByIndex(nfcIdx);
                                          if(isOk) _fetchNfcList();
                                        }

                                      },
                                      child: Icon(Icons.delete, size: 26, color: Color(0xffbbbbbb),)),
                                );
                              },
                            ),
                          ),
                        ),


                      ],
                    ),
                  ),
                ),
              ),



              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.transparent,
                    onPrimary: TGlobalData().crMainThemeColor,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    shape: StadiumBorder(),
                    side: BorderSide(color: Color(0xffaaaaaa)),

                  ),
                  child: Text('删除人员' , style: TGlobalData().tsListTitleTS1,),
                   onPressed: ()  async {

                     final rtn = await showDialog(context: context,
                         builder: (BuildContext dctx){
                           return Material(
                             color: Colors.transparent,
                             child: GestureDetector(
                               behavior: HitTestBehavior.opaque,
                               onTap: (){ Navigator.pop(dctx); },
                               child: Container(
                                   margin: EdgeInsets.symmetric (horizontal:  MediaQuery.of(context).size.width / 11.0,
                                       vertical:  MediaQuery.of(context).size.height / 4 ),
                                   decoration: BoxDecoration(
                                     color: Colors.white,
                                     borderRadius: BorderRadius.circular( 40.0),
                                   ),
                                   child:GestureDetector(
                                     behavior: HitTestBehavior.opaque,
                                     onTap: (){ },
                                     child: Center(
                                       child: Column(
                                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                         children: [
                                           Icon(Icons.warning, color: Colors.yellow, size: 64.0,),
                                           Text('确认删除该用户 ？', style: TGlobalData().tsListTitleTS1,),

                                           Row(
                                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                             children: [


                                               ElevatedButton(
                                                 onPressed:   (){
                                                   Navigator.pop(dctx , true);
                                                 },
                                                 child: Text('确  定' , style: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
                                                 style: ElevatedButton.styleFrom(
                                                   primary: TGlobalData().crMainThemeColor,
                                                   onPrimary: TGlobalData().crMainThemeOnColor,
                                                   shadowColor: Colors.white,
                                                   padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                                                   shape: StadiumBorder(),
                                                 ),
                                               ),


                                               ElevatedButton(
                                                 onPressed:   (){
                                                   Navigator.pop(dctx);
                                                 },
                                                 child: Text('取  消' , style: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
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
                                         ],
                                       ),
                                     ),
                                   )

                               ),
                             ),
                           );
                         }) ;

                     if( (rtn != null )  &&   (rtn as bool) ){

                       String uid = widget.userObj['userid'] .toString();
                       print('delete user id = $uid');
                      bool isOk = await  _deleteUserById(uid);
                       Navigator.pop(context , isOk);
                     }

                   },
              ),


            ],
          )),
    );

  }


  Future<void> _fetchPwdList() async {

    List<dynamic> allPwdLs = [];
    Completer tmpC = Completer<void>();
    StreamSubscription<String> jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) {

      //  print('got jsonstr: $jsonStr');

      var jsonObj = jsonDecode(jsonStr);
      var pwdLs = jsonObj['sjcxyhmm'];

      if(pwdLs != null){
        allPwdLs = pwdLs as List<dynamic>;
        tmpC.complete();
      }




    });

    var jobj = {};
    jobj["sjcxyhmm"] =    widget.userObj['userid']  ;
    jobj["skip"] =    0 ;

    TBleSingleton().sendFramedJsonData(json.encode(jobj));

    await  tmpC.future;

    jsonSSub.cancel();

    _showUserPwdList(allPwdLs);


  }


  void _showUserPwdList(List<dynamic> datLs){

    _unlockNumberObjLs.clear();
    for(int i = 0 ; i < datLs.length; i ++){
      List<dynamic> tmpLs = datLs[i];
      var tmpObj = {};
      tmpObj['idx'] = tmpLs[0] as int;
      tmpObj['uid'] = tmpLs[1] as int;
      var tc = TextEditingController();
      tc.text = tmpLs[2].toString();
      tmpObj['txtCtrlor'] = tc;
      tmpObj['isAlarm'] = tmpLs[3] as int;
      tmpObj['showPwd'] = false;

      _unlockNumberObjLs.add(tmpObj);
    }

    setState(() {  });
  }


  Future<void> _fetchFpList() async {

    List<dynamic> allFpLs = [];
    Completer tmpC = Completer<void>();
    StreamSubscription<String> jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) {

     //  print('got fp jsonstr: $jsonStr');

      var jsonObj = jsonDecode(jsonStr);
      var fpLs = jsonObj['sjcxyhzw'];

      if(fpLs != null){
        allFpLs = fpLs as List<dynamic>;
        tmpC.complete();

      }



    });

    var jobj = {};
    jobj["sjcxyhzw"] =  (  widget.userObj['userid'] );
    jobj["skip"] = 0;

    TBleSingleton().sendFramedJsonData(json.encode(jobj));

    await  tmpC.future;
    jsonSSub.cancel();

    _showUserFpList(allFpLs);

  }




  void _showUserFpList(List<dynamic> datLs){

    // if(datLs.isEmpty)
    //   TGlobalData().showToastInfo('未录入指纹....');

    _unlockFingerprintObjLs.clear();
    for(int i = 0 ; i < datLs.length; i ++){
      List<dynamic> tmpLs = datLs[i];
      var tmpObj = {};
      tmpObj['fpIdx'] = tmpLs[0] as int;
      tmpObj['uid'] = tmpLs[1] as int;
      tmpObj['fgNum'] = tmpLs[2] as int;
      tmpObj['dt'] = tmpLs[3] as int;

      _unlockFingerprintObjLs.add(tmpObj);
    }



    setState(() {  });

  }


  Future<void> _fetchNfcList() async {

    List<dynamic> allNfcLs = [];
    Completer tmpC = Completer<void>();
    StreamSubscription<String> jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) {

      // print('got nfc jsonstr: $jsonStr');

      var jsonObj = jsonDecode(jsonStr);
      var fpLs = jsonObj['sjcxyhnfc'];

      if(fpLs != null){
        allNfcLs = fpLs as List<dynamic>;

        tmpC.complete();
      }



    });

    var jobj = {};
    jobj["sjcxyhnfc"] =  (  widget.userObj['userid'] );
    jobj["skip"] = 0;

    TBleSingleton().sendFramedJsonData(json.encode(jobj));

    await  tmpC.future;
    jsonSSub.cancel();

    _showUserNfcList(allNfcLs);

  }


  void _showUserNfcList(List<dynamic> datLs){

    // if(datLs.isEmpty)
    //   TGlobalData().showToastInfo('未录入NFC....');

    _unlockNfcObjLs.clear();
    for(int i = 0 ; i < datLs.length; i ++){
      List<dynamic> tmpLs = datLs[i];
      var tmpObj = {};
      tmpObj['idx'] = tmpLs[0] as int;
      tmpObj['uid'] = tmpLs[1] as int;
      tmpObj['flags'] = tmpLs[2] as int;

      tmpObj['nfcCode'] = hex.decode(tmpLs[3].toString() )    ;  // NFC code has 6 bytes, we hide 3 bytes

      _unlockNfcObjLs.add(tmpObj);
    }

    setState(() {  });

  }


  Future<bool> _appendPrivPwd(int userid) async {
    bool rtn = false;

   final wndRtn = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TPrivatePwdWnd(uid: userid, isIndicator: false,)),
    );


    if( wndRtn != null && wndRtn as bool)
      rtn = true;

    return Future.value(rtn);
  }

  Future<bool> _appendPrivFp(int userid) async {
    bool rtn = false;

    final wndRtn = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TPrivateFpWnd(
        uid:  userid,
          isIndicator: false,
          stepIndicatorImgLs : [],
          stepIndicatorGreyImgLs :[],
          stepIndicatorBlackImgLs: []
      )),
    );

    if(wndRtn != null && wndRtn as bool)
      rtn = true;


    return Future.value(rtn);
  }


  Future<bool> _appendPrivNfc(int userid) async {
    bool rtn = false;

    final wndRtn = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TPrivNfcWnd(  uid:  userid  )),
    );

    if(wndRtn != null && wndRtn as bool)
      rtn = true;


    return Future.value(rtn);
  }

  Future<bool> _deletePrivPwdByIndex(int idx) async {

    bool isDeleOk = false;

    Completer tmpC = Completer<void>();
    StreamSubscription<String> jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) {

      //  print('got jsonstr: $jsonStr');

      var jsonObj = jsonDecode(jsonStr);
      var rslObj = jsonObj['rsl'];

      if(rslObj != null){
        int rsl = int.parse(rslObj.toString());

        if(rsl == ResultCodeToApp_e.Rsl_Pri_Pwd_Delete_Ok.index) {
          TGlobalData().showToastInfo('删除用户密码成功!!');
          isDeleOk = true;
        }else TGlobalData().showToastInfo('删除用户密码失败!!');

        tmpC.complete();
      }



    });

    var jobj = {};
    jobj["sjscyhmm"] = idx  ;

    TBleSingleton().sendFramedJsonData(json.encode(jobj));

    await  tmpC.future;
    jsonSSub.cancel();

    return Future.value(isDeleOk);

  }

  Future<bool> _deletePrivFpByIndex(int idx) async {

    bool isDeleOk = false;

    Completer tmpC = Completer<void>();
    StreamSubscription<String> jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) {

      //  print('got jsonstr: $jsonStr');

      var jsonObj = jsonDecode(jsonStr);
      var rslObj = jsonObj['rsl'];

      if(rslObj != null){
        int rsl = int.parse(rslObj.toString());

        if(rsl == ResultCodeToApp_e.Rsl_Fp_Delete_One_Fp_Ok.index) {
          TGlobalData().showToastInfo('删除指纹成功!!');
          isDeleOk = true;
        }else TGlobalData().showToastInfo('删除指纹失败!!');

        tmpC.complete();
      }



    });

    var jobj = {};
    jobj["sjsczw"] = idx ;

    TBleSingleton().sendFramedJsonData(json.encode(jobj));

    await  tmpC.future;
    jsonSSub.cancel();

    return Future.value(isDeleOk);

  }


  Future<bool> _deleteUserById(String uid) async {

    bool isDeleOk = false;

    Completer tmpC = Completer<void>();
    StreamSubscription<String> jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) {

      //  print('got jsonstr: $jsonStr');

      var jsonObj = jsonDecode(jsonStr);
      var rslObj = jsonObj['rsl'];

      if(rslObj != null){
        int rsl = int.parse(rslObj.toString());

        if(rsl == ResultCodeToApp_e.Rsl_Ok_Del_User_Ok.index) {
          TGlobalData().showToastInfo('删除用户成功!!');
          isDeleOk = true;
        }else TGlobalData().showToastInfo('删除用户失败!!');

        tmpC.complete();
      }



    });

    var jobj = {};
    jobj["sjscyh"] = int.parse( uid );

    TBleSingleton().sendFramedJsonData(json.encode(jobj));

    await  tmpC.future;
    jsonSSub.cancel();

    return Future.value(isDeleOk);

  }



  Future<bool> _deleteNfcByIndex(int idx) async {

    bool isDeleOk = false;

    Completer tmpC = Completer<void>();
    StreamSubscription<String> jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) {

      //  print('got jsonstr: $jsonStr');

      var jsonObj = jsonDecode(jsonStr);
      var rslObj = jsonObj['nfc'];

      if(rslObj != null){
        int rsl = int.parse(rslObj.toString());

        if(rsl == ResultCodeToApp_e.Rsl_Nfc_Delete_One_Nfc_Ok.index) {
          TGlobalData().showToastInfo('删除NFC成功!!');
          isDeleOk = true;
        }else TGlobalData().showToastInfo('删除NFC失败!!');

        tmpC.complete();
      }



    });

    var jobj = {};
    jobj["sjscyhnfc"] = idx ;

    TBleSingleton().sendFramedJsonData(json.encode(jobj));

    await  tmpC.future;
    jsonSSub.cancel();

    return Future.value(isDeleOk);

  }


  Future<bool> _chgeNickName(int uid , String nickname) async {

    bool isOk = false;

    Completer tmpC = Completer<void>();
    StreamSubscription<String> jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) {

      var jsonObj = jsonDecode(jsonStr);
      var rslObj = jsonObj['rsl'];

      if(rslObj != null){
        int rsl = int.parse(rslObj.toString());

        if(rsl == ResultCodeToApp_e.Rsl_Ok_Set_Nickname_Ok.index) {
          isOk = true;
        }

        tmpC.complete();
      }



    });

    var jobj = {};
    jobj["sjcxxgyhm"] =  nickname;
    jobj["uid"] =  uid ;

    TBleSingleton().sendFramedJsonData(json.encode(jobj));

    await  tmpC.future;
    jsonSSub.cancel();

    return Future.value(isOk);

  }


}






























