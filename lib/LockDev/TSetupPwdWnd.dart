import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:collection/collection.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../TGlobal_inc.dart';
import '../TBleSingleton.dart';


import 'TOnetimePwdWnd.dart';
import 'TReaptPwdWnd.dart';


enum LockPwdType { oneTimePwd, repeatPwd }


class TSetupPwdWnd extends StatefulWidget {

  final LockPwdType pwdType;
  final Map lockInfoObj;

  TSetupPwdWnd({required this.pwdType , required this.lockInfoObj});

  @override
  _TSetupPwdWndState createState() => _TSetupPwdWndState();
}


class _TSetupPwdWndState extends State<TSetupPwdWnd> {



  static final List<String> _weekNameLs = ['','星期一','星期二','星期三','星期四','星期五','星期六','星期日'];

  int _tabIdx = 0;

  List<Map> _oneTimePwdObjLs = [];
  List<Map> _repeatPwdObjLs = [];

  LockPwdType _currPwdType = LockPwdType.oneTimePwd;

  late final StreamSubscription<String> _jsonSSub;


  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

    _currPwdType = widget.pwdType;


    _tabIdx = _currPwdType.index;


    _jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) => handleJsonStr(jsonStr));
    Future.delayed(Duration(milliseconds: 300)).then((_) {
      _currPwdType == LockPwdType.oneTimePwd ?
      _fetchOneTimePwdDatLs()
      :
      _fetchRepeatPwdDatLs();
    });


    }

  @override
  void deactivate() {
    print('${this.runtimeType.toString()} deactivate()......................');
  }

  @override
  void dispose() {
    print('${this.runtimeType.toString()} dispose()......................');

    _jsonSSub.cancel();

    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    DateTime currDt = DateTime.now();

    String subTitStr = DateFormat('yyyy年M月d日').format(currDt) + '（${_weekNameLs[currDt.weekday  ]}）';

    return Scaffold(
      appBar: AppBar(title: Text( _currPwdType == LockPwdType.oneTimePwd ? '一次性密码' : '周期密码',
        style: TextStyle(color: Color(0xff222222), fontSize: 20, fontWeight: FontWeight.bold), ),
      elevation: 0.0,
      backgroundColor: Color(0xffeeeeee),
      iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(

         padding: EdgeInsets.fromLTRB(20, 20, 20, 4),
          color: Color(0xffeeeeee),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Text( widget.lockInfoObj['lockname'], style: TGlobalData().tsHeader0TextStyle),
              Text( subTitStr, style: TGlobalData().tsListCntTS1),

              Padding(
                padding: const EdgeInsets.fromLTRB(0, 14, 0, 8),
                child: Divider(),
              ),



              DefaultTabController(
                  length: 2,
                  initialIndex: _currPwdType == LockPwdType.oneTimePwd ? 0 : 1,
                  child: Theme(
                    data: ThemeData(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,

                    ),
                    child: TabBar(
                      labelStyle: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                      unselectedLabelStyle: TextStyle(fontSize: 18,color: Colors.black),
                      labelColor: Colors.black,
                      //indicatorColor: TGlobalData().crMainThemeColor,
                      indicator:  UnderlineTabIndicator(
                        borderSide: BorderSide(color: TGlobalData().crMainThemeColor,width: 4.0),
                        insets: EdgeInsets.symmetric(horizontal: 56.0),
                      ),
                      //indicatorPadding: EdgeInsets.symmetric(horizontal: 132),
                      indicatorWeight: 3.0,

                      labelPadding: EdgeInsets.all(12),
                      tabs: [
                        Text('一次性密码'),
                        Text('周期密码'),
                      ],
                      onTap: (idx){

                        _currPwdType = LockPwdType.oneTimePwd;
                        if(idx == 1) _currPwdType = LockPwdType.repeatPwd;

                        setState(() {
                          _tabIdx = idx;
                        });

                        if(_currPwdType == LockPwdType.oneTimePwd)
                          _fetchOneTimePwdDatLs();
                        else _fetchRepeatPwdDatLs();

                      },
                    ),
                  ),

              ),


              SizedBox(height: 12.0,),

              Expanded(

                child: IndexedStack(
                  index: _tabIdx,
                  sizing: StackFit.expand,
                  children: [

                    _oneTimePwdWnd(),

                    _repeatPwdWnd(),

                  ],
                ),
              ),



            //  Expanded(child: Container(color: Colors.red,)),







            ],
          )),
    );

  }

  Widget _oneTimePwdWnd(){
    return RefreshIndicator(
      onRefresh: _fetchOneTimePwdDatLs,
      child: ListView.separated(
           itemCount: _oneTimePwdObjLs.length + 1,
          itemBuilder: (itCtx, idx){

             if(_oneTimePwdObjLs.isEmpty || idx == _oneTimePwdObjLs.length  )
               return InkWell(
                 child: Container(
                   height: 80,
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(10),
                     border: Border.all(color: TGlobalData().crWeakGrey,width: 4),
                   ),
                   child: Icon(Icons.add, color: TGlobalData().crMainThemeColor, size: 50,),
                 ),
                 onTap: () async {
                 final rtn = await  Navigator.push(context, MaterialPageRoute(builder: (ctx) => TOnetimePwdWnd()));
               //  print('rtn : $rtn');
                 if(rtn != null &&  rtn as bool)
                   _fetchOneTimePwdDatLs();
                 },
               );


             Color disabCr = Color(0xffaaaaaa);
             bool isEnab =  _oneTimePwdObjLs[idx]['isEnabled'] as bool;

             String titleStr =  _oneTimePwdObjLs[idx]['startDt'] == 0 ? '00:00  ~  00:00' : '${ DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch( _oneTimePwdObjLs[idx]['startDt']   ))  }'
                 '  ~  '
                 '${ DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch( _oneTimePwdObjLs[idx]['endDt'] ))  }'
             ;

             return ListTile(
               contentPadding: EdgeInsets.zero,
               horizontalTitleGap: 0,
               minLeadingWidth: 0,
               enabled: isEnab  ,
               leading: Container(
                 padding: EdgeInsets.all(12.0),
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(40.0),
                     border: Border.all(color: TGlobalData().crWeakGrey, width: 2),
                   ),

                   child: Icon(Icons.lock  , color: isEnab ? Colors.black : disabCr  ,)),
              // title: Container( height: 33,color: TGlobalData().crMainThemeColor,),
               title: Padding(
                 padding: const EdgeInsets.only(left: 14),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                       Text(titleStr
                         ,
                        style: TextStyle(fontSize: 20, color: isEnab ?  Color(  0xff333333)  : disabCr, fontWeight: FontWeight.w900),
                       ),
                         Text('当天有效', style: TextStyle(color: TGlobalData().crCommonGrey, fontSize: 16),),
                     ],),

                     InkWell(
                       child: SvgPicture.asset( 'images/svgs/shareArrow.svg' , width: 26, height: 26, fit: BoxFit.scaleDown,color: TGlobalData().crGreyBB, ),
                       onTap: () => _showShareWnd(titleStr ,'当天有效'),
                     ),

                   ],
                 ),
               ),

               trailing: IconButton(icon: Icon(Icons.delete),  onPressed: () => _deletePwdItem(idx , 1),),
               onTap: (){
                 _oneTimePwdObjLs[idx]['isEnabled'] = ! isEnab;
               //  print('delete idx = ${_oneTimePwdObjLs[idx]['idx']}');
                 setState(() {  });
               },
             );
          },
          separatorBuilder: (sctx, idx) => Divider(),
      ),
    );
  }


  Widget _repeatPwdWnd(){
    return RefreshIndicator(
      onRefresh: _fetchRepeatPwdDatLs,
      child: ListView.separated(
        itemCount: _repeatPwdObjLs.length + 1,
        itemBuilder: (itCtx, idx){

          if(_repeatPwdObjLs.isEmpty || idx == _repeatPwdObjLs.length  )
            return InkWell(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: TGlobalData().crWeakGrey,width: 4),
                ),
                child: Icon(Icons.add, color: TGlobalData().crMainThemeColor, size: 50,),
              ),
              onTap: () async {
              final rtn = await   Navigator.push(context, MaterialPageRoute(builder: (ctx) => TReaptPwdWnd()));
          if(rtn != null &&  rtn as bool)
          _fetchRepeatPwdDatLs();
          },

        );


          Color disabCr = Color(0xffaaaaaa);
          bool isEnab =  _repeatPwdObjLs[idx]['isEnabled'] as bool;

          // tmpObj['idx'] = tmpLs[0] as int;
          // tmpObj['uid'] = tmpLs[1] as int;
          // tmpObj['title'] = tmpLs[2].toString();
          // tmpObj['pwd'] = tmpLs[3].toString();
          // tmpObj['isEnabled'] =  (tmpLs[4] as int ) == 1;
          // tmpObj['flags'] = tmpLs[5] as int;
          // tmpObj['daysInMonth'] = tmpLs[6] as int;
          // tmpObj['startDt'] = DateTime.fromMillisecondsSinceEpoch( (tmpLs[7] as int) * 1000 );
          // tmpObj['endDt'] = DateTime.fromMillisecondsSinceEpoch( (tmpLs[8] as int) * 1000 );


          int rFlags = _repeatPwdObjLs[idx]['flags'];
          int mDays =  _repeatPwdObjLs[idx]['daysInMonth'];

          bool isPerDay = rFlags & 0x01  > 0;
          bool isPerMonth = mDays > 0;

          String repeatTypeStr = '';
         if(  mDays > 0) {
          int lastDay = mDays & 0x01;
          mDays >>=1;
           List<String> tmpStrLs = [];
           for(int p = 0 ; p < 31 ; p ++) {
             if (mDays & 0x01 == 1)
               // repeatTypeStr += '周' + weekNameLs[p] + ', ';
               tmpStrLs.add('${p+1}号'  );

             mDays >>= 1;
           }

           repeatTypeStr = '每月' + tmpStrLs.toString();
           if(lastDay == 1)
             repeatTypeStr += ', 月末一天';

         }else if( isPerDay) {
           repeatTypeStr = '每日';
         }else if( rFlags & 0xfe  > 0) {
           final   List<String> weekNameLs = ['日','一','二','三','四','五','六'];
           int f = rFlags & 0xfe;
           f >>= 1;
           repeatTypeStr = '';
           List<String> tmpStrLs = [];
           for(int p = 0 ; p < 7 ; p ++) {
             if (f & 0x01 == 1)
              // repeatTypeStr += '周' + weekNameLs[p] + ', ';
             tmpStrLs.add('周' + weekNameLs[p]);

             f >>= 1;
           }

           repeatTypeStr = tmpStrLs.toString();

         }
          repeatTypeStr = repeatTypeStr.replaceAll('[', '');
          repeatTypeStr = repeatTypeStr.replaceAll(']', '');

         String startDtStr = '';
          String endDtStr =   '';

          DateTime sdt =  _repeatPwdObjLs[idx]['startDt'];
          DateTime edt =  _repeatPwdObjLs[idx]['endDt'];

         // if(sdt != DateTime(0))
            if(isPerDay || isPerMonth )
              startDtStr = DateFormat('HH:mm').format(sdt);
              else
             startDtStr = DateFormat('yyyy.MM.dd').format(sdt);

         // if(edt != DateTime(0))
            if(isPerDay || isPerMonth)
              endDtStr = DateFormat('HH:mm').format(edt);
            else
            endDtStr   = DateFormat('yyyy.MM.dd').format( edt);


          return ListTile(
            contentPadding: EdgeInsets.zero,
            horizontalTitleGap: 0,
            minLeadingWidth: 0,
            enabled: isEnab  ,
            leading: Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40.0),
                  border: Border.all(color: TGlobalData().crWeakGrey, width: 2),
                ),

                child: Icon(Icons.lock  , color: isEnab ? Colors.black : disabCr  ,)),
            // title: Container( height: 33,color: TGlobalData().crMainThemeColor,),
            title: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Text('${ DateFormat('hh:mm').format(DateTime.fromMillisecondsSinceEpoch( (_repeatPwdObjLs[idx]['startDt'] as int) * 1000 ))  }  ~  '
                      //     '${ DateFormat('hh:mm').format(DateTime.fromMillisecondsSinceEpoch( (_repeatPwdObjLs[idx]['endDt'] as int) * 1000 ))  }',
                      //   style: TextStyle(fontSize: 20, color: isEnab ?  Color(  0xff333333)  : disabCr, fontWeight: FontWeight.w900),
                      // ),

                      Row(
                        children: [
                          Text( _repeatPwdObjLs[idx]['title'],
                            style: TextStyle(fontSize: 20, color: isEnab ?  Color(  0xff333333)  : disabCr, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 12,),
                          InkWell(
                            onTap: () async {
                               final rtnStr = await _chgNameWnd(_repeatPwdObjLs[idx]['title'].toString());
                               String str = rtnStr.toString();
                               if(str.isNotEmpty){
                                 setState(() {
                                   _repeatPwdObjLs[idx]['title'] = str;
                                 });
                               }

                            },
                            //  child: Icon( SvgPicture.asset( 'images/svgs/editIcon.svg' , width: 20, height: 20, fit: BoxFit.scaleDown,color: TGlobalData().crMainThemeColor, ) , color: isEnab ?  Color(  0xff333333)  : disabCr,)),
                  child:  SvgPicture.asset( 'images/svgs/editIcon.svg' , width: 20, height: 20, fit: BoxFit.scaleDown,color: TGlobalData().crGreyBB, )),

                      ],),




                      Text(repeatTypeStr, style: TextStyle(color: TGlobalData().crCommonGrey, fontSize: 16),),

                      Text(  '$startDtStr ～ $endDtStr', style: TextStyle(color: TGlobalData().crCommonGrey, fontSize: 14),),



                    ],),


                  InkWell(
                      child: SvgPicture.asset( 'images/svgs/shareArrow.svg' , width: 26, height: 26, fit: BoxFit.scaleDown,color: TGlobalData().crGreyBB, ),
                    onTap: () => _showShareWnd(    _repeatPwdObjLs[idx]['title'] , repeatTypeStr),
                  ),


                ],
              ),
            ),

            trailing: IconButton(icon: Icon(Icons.delete),  onPressed: () => _deletePwdItem(idx , 2),),
            onTap: (){
              _repeatPwdObjLs[idx]['isEnabled'] = ! isEnab;
              setState(() {  });
            },
          );
        },
        separatorBuilder: (sctx, idx) => Divider(),
      ),
    );
  }


  Future<void> _fetchOneTimePwdDatLs() async
  {

    var jobj = {};
    jobj["sjcxycxmm"] = int.parse(TGlobalData().currUid) ;
    jobj["skip"] =  _oneTimePwdObjLs.length ;

    TBleSingleton().sendFramedJsonData(json.encode(jobj));


  }

  Future<void> _fetchRepeatPwdDatLs() async
  {
    var jobj = {};
    jobj["sjcxzqxmm"] =  int.parse(TGlobalData().currUid) ;
    jobj["skip"] = _repeatPwdObjLs.length.toString();

    TBleSingleton().sendFramedJsonData(json.encode(jobj));

  }


  void handleJsonStr(String jsonStr) async {
    // print('Got jstr : $jsonStr');

    var jsonObj = jsonDecode(jsonStr);

    var ycxmm = jsonObj['sjcxycxmm'];
    if (ycxmm != null) {
      List<dynamic> oneTimePwdLs = ycxmm as List<dynamic>;
      _showOneTimePwdLs(oneTimePwdLs);

    }

    var zqxmm = jsonObj['sjcxzqxmm'];
    if (zqxmm != null) {
      List<dynamic> repeatPwdLs = zqxmm as List<dynamic>;
     _showRepeatPwdLs(repeatPwdLs);

    }

    var rslVal = jsonObj['rsl'];
    if (rslVal != null) {
      int rv = int.parse(rslVal.toString());


      if(rv == ResultCodeToApp_e.Rsl_OneTime_Pwd_Delete_Ok.index) {
        TGlobalData().showToastInfo('删除一次性密码成功');
        await  Future.delayed(Duration(milliseconds: 500));
        _fetchOneTimePwdDatLs();
      }else if(rv == ResultCodeToApp_e.Rsl_Repeat_Pwd_Delete_Ok.index) {
        TGlobalData().showToastInfo('删除周期性密码成功');
       await  Future.delayed(Duration(milliseconds: 500));
        _fetchRepeatPwdDatLs();
      }


    }




  }

  void _showOneTimePwdLs(List<dynamic> datLs)
  {
     if(datLs.isEmpty && _oneTimePwdObjLs.isNotEmpty)
        TGlobalData().showToastInfo('已到末页....');

   // _oneTimePwdObjLs.clear();
    for(int i = 0 ; i < datLs.length ; i ++){
      final List<dynamic> tmpLs = datLs[i];
      var tmpObj = {};
      tmpObj['idx'] = tmpLs[0] as int;
      tmpObj['uid'] = tmpLs[1] as int;
      tmpObj['pwd'] = tmpLs[2].toString();
      tmpObj['isEnabled'] = (tmpLs[3] as int) == 1 ;
      tmpObj['startDt'] =   (tmpLs[4] as int ) * 1000 ;
      tmpObj['endDt'] =   (tmpLs[5] as int ) * 1000 ;
     // tmpObj['validDt'] = currDt.millisecondsSinceEpoch ~/ 1000;

      _oneTimePwdObjLs.add(tmpObj);

    }

    setState(() {   });
  }

  void _showRepeatPwdLs(List<dynamic> datLs)
  {
    if(datLs.isEmpty && _repeatPwdObjLs.isNotEmpty)
      TGlobalData().showToastInfo('已到末页....');

     // _repeatPwdObjLs.clear();
    for(int i = 0 ; i < datLs.length ; i ++){
      final List<dynamic> tmpLs = datLs[i];

      // tmpObj['validDt'] = currDt.millisecondsSinceEpoch ~/ 1000;

      int sdt =  (tmpLs[7] as int) * 1000;
      int edt =  (tmpLs[8] as int) * 1000;

      var tmpObj = {};
      tmpObj['idx'] = tmpLs[0] as int;
      tmpObj['uid'] = tmpLs[1] as int;
      tmpObj['title'] = tmpLs[2].toString();
      tmpObj['pwd'] = tmpLs[3].toString();
      tmpObj['isEnabled'] =  (tmpLs[4] as int ) == 1;
      tmpObj['flags'] = tmpLs[5] as int;
      tmpObj['daysInMonth'] = tmpLs[6] as int;
      tmpObj['startDt'] = sdt == 0 ? DateTime(0) : DateTime.fromMillisecondsSinceEpoch(sdt );
      tmpObj['endDt'] = edt == 0 ? DateTime(0) :DateTime.fromMillisecondsSinceEpoch(edt  );


      _repeatPwdObjLs.add(tmpObj);

    }
    setState(() {  });

  }




  Future<String> _chgNameWnd(String currName) async
  {

    TextEditingController txtCtrlor = TextEditingController();

    txtCtrlor.text = currName;

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
                        .width / 11.0,
                        vertical: MediaQuery
                            .of(context)
                            .size
                            .height * .24),
                    padding: EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: (){FocusScope.of(dctx).unfocus();},
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                         // Icon(Icons.warning, color: Colors.yellow, size: 64.0,),

                          Text('重命名'  , style: TGlobalData().tsHeader0TextStyle,),

                          Text(
                            '原名称：$currName',
                            textAlign: TextAlign.center,
                            style: TGlobalData().tsListTitleTS1,),


                          TextField(
                            controller: txtCtrlor,
                 style: TGlobalData().tsHeaderTextStyle,
                            decoration: InputDecoration(
                              //focusColor: TGlobalData().crMainThemeColor,
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0),
                                  borderSide: BorderSide(color: TGlobalData().crMainThemeColor)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0),
                            borderSide: BorderSide(color: TGlobalData().crGreyDD),
                            ),
                              suffixIcon: IconButton(icon: Icon( Icons.clear ,color: TGlobalData().crMainThemeDownColor,),onPressed: ()=>txtCtrlor.clear() ,),
                            ),

                          ),


                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [


                              ElevatedButton(
                                onPressed: txtCtrlor.text.isEmpty ? null :   () {
                                  Navigator.pop(dctx, true);
                                },
                                child: Text('确  定', style: TextStyle(color: Colors
                                    .white, fontSize: 20, fontWeight: FontWeight
                                    .bold),),
                                style: ElevatedButton.styleFrom(
                                  primary: TGlobalData().crMainThemeColor,
                                  onPrimary: TGlobalData().crMainThemeOnColor,
                                  shadowColor: Colors.white,
                                  padding: EdgeInsets.fromLTRB(80, 10, 80, 10),
                                  shape: StadiumBorder(),
                                ),
                              ),


                              // ElevatedButton(
                              //   onPressed: () {
                              //     Navigator.pop(dctx);
                              //   },
                              //   child: Text('取  消', style: TextStyle(color: Colors
                              //       .white, fontSize: 20, fontWeight: FontWeight
                              //       .bold),),
                              //   style: ElevatedButton.styleFrom(
                              //     primary: TGlobalData().crMainThemeColor,
                              //     onPrimary: TGlobalData().crMainThemeOnColor,
                              //     shadowColor: Colors.white,
                              //     padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                              //     shape: StadiumBorder(),
                              //   ),
                              // ),

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
        //print('rtn true');
         return txtCtrlor.text;
      }

     // return false;




    return '';
  }


  Future<bool> _deletePwdItem(int idx, int wndType) async {

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
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: (){ },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Icon(Icons.warning, color: Colors.yellow, size: 64.0,),
                          Text(
                            wndType == 1 ? '确定删除该项码？'
                            : '确定删除 “${_repeatPwdObjLs[idx]['title']}” 的周期密码？',
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
                    ),
                  )

              ),
            ),
          );
        });

    if ((rtn != null) && (rtn as bool)) {
      if(wndType == 1){
        int pwdIdx = _oneTimePwdObjLs[idx]['idx'];


        var jobj = {};
        jobj["sjscycxmm"] =  pwdIdx;

        TBleSingleton().sendFramedJsonData(json.encode(jobj));


      }else if(wndType == 2){

        int pwdIdx = _repeatPwdObjLs[idx]['idx'];
        print('===========================  repeat idx : $idx    pwdIdx: $pwdIdx');
        var jobj = {};
        jobj["sjsczqxmm"] =  pwdIdx;

        print(jobj);

        TBleSingleton().sendFramedJsonData(json.encode(jobj));


      }
     // print('rtn true');
      return Future.value(true);
    }

    return Future.value(false);

  }


  void _showShareWnd(String dtStr, String subtitle) async {

    final rtn =  await    showDialog(context: context,
        //barrierColor: Colors.transparent,
        builder: (BuildContext bctx){

          return Material(
              color: Colors.transparent,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: (){Navigator.pop(bctx);},
                child: Container(
                  // color: Colors.purple,
                  // margin: Ed,
                    margin: EdgeInsets.only(top: TDevsSizeFit.blockSizeVertical *40),
                    // color: Colors.cyan,
                    //   decoration: ShapeDecoration(
                    //     color: Colors.cyan,
                    //      shape: RoundedRectangleBorder(
                    //        borderRadius: BorderRadius.vertical(top: Radius.circular(40.0))
                    //      )
                    //   ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(40.0)),
                          child:
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 22),
                            height: TDevsSizeFit.blockSizeVertical * 12,
                            width: TDevsSizeFit.blockSizeHorizontal * 100,
                            color: Colors.white,
                            child: Row(

                              children: [

                                Container(
                                    padding: EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40.0),
                                      border: Border.all(color: TGlobalData().crWeakGrey, width: 2),
                                    ),

                                    child: Icon(Icons.lock  ,  )
                                ),

                                SizedBox(width:20),

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(dtStr, style: TGlobalData().tsTxtFn18Grey22BW900,),
                                    Text(subtitle, style: TGlobalData().tsTxtFn14GreyAA,),
                                  ],
                                ),


                              ],
                            ),
                          ),

                        ),


                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(bctx);
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset( 'images/svgs/wechat.svg' , width: 50, height: 50, fit: BoxFit.fill,  ),
                              SizedBox(width:20),
                              Text('微 信', style: TGlobalData().tsListTitleTS1,),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                              primary: Colors.white,
                              onPrimary: Color(0xff119999),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              )
                          ),
                        ),

                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(bctx);
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset( 'images/svgs/telegram.svg' , width: 50, height: 50, fit: BoxFit.fill,  ),
                              SizedBox(width:20),
                              Text('Telegram', style: TGlobalData().tsListTitleTS1,),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                              padding:EdgeInsets.fromLTRB(20, 10, 20, 10),
                              primary: Colors.white,
                              onPrimary: Color(0xff119999),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              )
                          ),
                        ),


                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(bctx);
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset( 'images/svgs/contactIcon.svg' , width: 50, height: 50, fit: BoxFit.fill,  ),
                              SizedBox(width:20),
                              Text('通讯录', style: TGlobalData().tsListTitleTS1,),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                              padding:EdgeInsets.fromLTRB(20, 10, 20, 10),
                              primary: Colors.white,
                              onPrimary: Color(0xff119999),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              )
                          ),
                        ),

                        // SizedBox(height: 9,),
                        Expanded(child:


                        ElevatedButton(
                          onPressed: (){
                            Navigator.pop(bctx);
                          },
                          child: Text('取   消', style: TGlobalData().tsListTitleTS1,),
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(22.0),
                              primary: Colors.white,
                              onPrimary: Color(0xff119999),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              )
                          ),
                        ),
                        ),



                      ],
                    )),
              )
          );

        });

  }



}
