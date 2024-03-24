import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_svg/flutter_svg.dart';



import '../TGlobal_inc.dart';
import 'TTabbarIndicator.dart';
import 'TAppendAlarmWay.dart';

class TAlarmSettingWnd extends StatefulWidget {

  final int wndTabIdx;




  TAlarmSettingWnd( { this.wndTabIdx = 0 } );

  @override
  _TAlarmSettingWndState createState() => _TAlarmSettingWndState();
}


class _TAlarmSettingWndState extends State<TAlarmSettingWnd> {


  int _tabIdx  =  0;

  List<Map> _pwdAlarmObjLs = [];
  List<Map> _fpAlarmObjLs = [];
  List<Map> _phoneAlarmObjLs = [];

  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

    _tabIdx = widget.wndTabIdx;

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

            SvgPicture.asset( 'images/svgs/alarmway.svg' ,height: TDevsSizeFit.safeBlockHorizontal  * 32, fit: BoxFit.contain, ),

              SizedBox(height: 16,),
          Text( '报警方式'  ,textAlign: TextAlign.center,
                style: TGlobalData().tsTxtFn26Grey22Bn ),
             SizedBox(height: 6,),
              Text( '关键时刻输入“报警密码”进行求救'  ,textAlign: TextAlign.center,
                  style: TGlobalData().tsTxtFn16GreyAA ),

              SizedBox(height: 20,),

              DefaultTabController(
                  length: 3,
                  initialIndex: widget.wndTabIdx,
                  child: Theme(
                    data: ThemeData(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,

                    ),
                    child: Container(
                     // color: Color(0xffeeeeee),
                      decoration: BoxDecoration(color: Color(0xffeeeeee),borderRadius: BorderRadius.circular(30)),
                      child: TabBar(
                        labelStyle: TGlobalData().tsTxtFn20GreyCC,
                        unselectedLabelStyle: TGlobalData().tsTxtFn20Grey22,
                        labelColor: Colors.white,
                         unselectedLabelColor: Colors.black,

                         //indicatorColor: Colors.transparent,
                         indicator:  TTabbarIndicator(  height: 24, cr:  TGlobalData().crMainThemeColor),
                        // //indicatorPadding: EdgeInsets.symmetric(horizontal: 132),
                          indicatorWeight: .1,


                        labelPadding: EdgeInsets.all(6),
                        tabs: [
                          Text('密 码'),
                          Text('指 纹'),
                          Text('手机号'),
                        ],
                        onTap: (idx){

                          // _currPwdType = LockPwdType.oneTimePwd;
                          // if(idx == 1) _currPwdType = LockPwdType.repeatPwd;
                          //
                          setState(() {
                            _tabIdx = idx;
                          });
                          //
                          // if(_currPwdType == LockPwdType.oneTimePwd)
                          //   _fetchOneTimePwdDatLs();
                          // else _fetchRepeatPwdDatLs();

                        },
                      ),
                    ),
                  ),

                ),

              Expanded(

                child: IndexedStack(
                  index: _tabIdx,
                  sizing: StackFit.expand,
                  children: [

                    //_oneTimePwdWnd(),

                    //_repeatPwdWnd(),

                    _pwdAlarmLsWid(),
                    _fpAlarmLsWid(),
                    _phoneAlarmLsWid(),

                  ],
                ),
              ),




              InkWell(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius:     BorderRadius.circular(80),
                    border: Border.all(color: TGlobalData().crWeakGrey,width: 2),
                  ),
                  child: Icon(Icons.add, color: TGlobalData().crMainThemeColor, size: 50,),
                ),
                onTap: () async {

                  if(_tabIdx == 0){
                    final rtn = await  Navigator.push(context, MaterialPageRoute(builder: (ctx) => TAppendPwdAlarmWay()));

                    // //  print('rtn : $rtn');
                    // if(rtn != null &&  rtn as bool)
                    //   _fetchPwdAlarmDatLs();

                  }else if(_tabIdx == 1){
                    final rtn = await  Navigator.push(context, MaterialPageRoute(builder: (ctx) => TAppendFpAlarmWay()));

                    // //  print('rtn : $rtn');
                    // if(rtn != null &&  rtn as bool)
                    //   _fetchPwdAlarmDatLs();
                  }else if(_tabIdx == 2){
                    final rtn = await  Navigator.push(context, MaterialPageRoute(builder: (ctx) => TAppendPhoneAlarmWay()));

                    // //  print('rtn : $rtn');
                    // if(rtn != null &&  rtn as bool)
                    //   _fetchPwdAlarmDatLs();
                  }

                },
              )

            ],
          )),
    );

  }


  Widget _pwdAlarmLsWid(){
    return RefreshIndicator(
      onRefresh: _fetchPwdAlarmDatLs,
      child: ListView.separated(
        itemCount: _pwdAlarmObjLs.length + 1,
        itemBuilder: (itCtx, idx){

          if(_pwdAlarmObjLs.isEmpty || idx == _pwdAlarmObjLs.length  )
            return Container(
              height: TDevsSizeFit.safeBlockVertical *36,
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(10),
              //   border: Border.all(color: TGlobalData().crWeakGrey,width: 4),
              // ),
              child:  Center(
                  //
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset( 'images/svgs/noNumPwd.svg' ,
                        width: TDevsSizeFit.safeBlockHorizontal  *  26,
                        fit: BoxFit.contain, ),

                      SizedBox(height: 20,),
                      Text('暂无报警密码' , style: TGlobalData().tsTxtFn24GreyBB,),
                    ],
                  )),

            );


          Color disabCr = Color(0xffaaaaaa);
          bool isEnab =  _pwdAlarmObjLs[idx]['isEnabled'] as bool;

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text( _pwdAlarmObjLs[idx]['startDt'] == 0 ? '00:00  ~  00:00' : '${ DateFormat('HH:mm').
                  format(DateTime.fromMillisecondsSinceEpoch( _pwdAlarmObjLs[idx]['startDt']   ))  }'
                      '  ~  '
                      '${ DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch( _pwdAlarmObjLs[idx]['endDt'] ))  }'

                    ,
                    style: TextStyle(fontSize: 20, color: isEnab ?  Color(  0xff333333)  : disabCr, fontWeight: FontWeight.w900),
                  ),
                  Text('当天有效', style: TextStyle(color: TGlobalData().crCommonGrey, fontSize: 16),),
                ],),
            ),

            trailing: IconButton(icon: Icon(Icons.delete),  onPressed: null ),// () => _deletePwdItem(idx , 1),),
            onTap: (){
              _pwdAlarmObjLs[idx]['isEnabled'] = ! isEnab;
              //  print('delete idx = ${_oneTimePwdObjLs[idx]['idx']}');
              setState(() {  });
            },
          );
        },
        separatorBuilder: (sctx, idx) => Divider(),
      ),


    );
  }



  Widget _fpAlarmLsWid(){
    return RefreshIndicator(
      onRefresh: _fetchPwdAlarmDatLs,
      child: ListView.separated(
        itemCount: _pwdAlarmObjLs.length + 1,
        itemBuilder: (itCtx, idx){

          if(_pwdAlarmObjLs.isEmpty || idx == _pwdAlarmObjLs.length  )
            return Container(
              height: TDevsSizeFit.safeBlockVertical *36,
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(10),
              //   border: Border.all(color: TGlobalData().crWeakGrey,width: 4),
              // ),
              child:  Center(
                //
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset( 'images/svgs/noFingerprint.svg' ,
                        width: TDevsSizeFit.safeBlockHorizontal  *  26,
                        fit: BoxFit.contain, ),

                      SizedBox(height: 20,),
                      Text('暂无报警指纹' , style: TGlobalData().tsTxtFn24GreyBB,),
                    ],
                  )),

            );


          Color disabCr = Color(0xffaaaaaa);
          bool isEnab =  _pwdAlarmObjLs[idx]['isEnabled'] as bool;

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text( _pwdAlarmObjLs[idx]['startDt'] == 0 ? '00:00  ~  00:00' : '${ DateFormat('HH:mm').
                  format(DateTime.fromMillisecondsSinceEpoch( _pwdAlarmObjLs[idx]['startDt']   ))  }'
                      '  ~  '
                      '${ DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch( _pwdAlarmObjLs[idx]['endDt'] ))  }'

                    ,
                    style: TextStyle(fontSize: 20, color: isEnab ?  Color(  0xff333333)  : disabCr, fontWeight: FontWeight.w900),
                  ),
                  Text('当天有效', style: TextStyle(color: TGlobalData().crCommonGrey, fontSize: 16),),
                ],),
            ),

            trailing: IconButton(icon: Icon(Icons.delete),  onPressed: null ),// () => _deletePwdItem(idx , 1),),
            onTap: (){
              _pwdAlarmObjLs[idx]['isEnabled'] = ! isEnab;
              //  print('delete idx = ${_oneTimePwdObjLs[idx]['idx']}');
              setState(() {  });
            },
          );
        },
        separatorBuilder: (sctx, idx) => Divider(),
      ),


    );
  }


  Widget _phoneAlarmLsWid(){
    return RefreshIndicator(
      onRefresh: _fetchPwdAlarmDatLs,
      child: ListView.separated(
        itemCount: _pwdAlarmObjLs.length + 1,
        itemBuilder: (itCtx, idx){

          if(_pwdAlarmObjLs.isEmpty || idx == _pwdAlarmObjLs.length  )
            return Container(
              height: TDevsSizeFit.safeBlockVertical *36,
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(10),
              //   border: Border.all(color: TGlobalData().crWeakGrey,width: 4),
              // ),
              child:  Center(
                //
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset( 'images/svgs/noPhoneNum.svg' ,
                        width: TDevsSizeFit.safeBlockHorizontal  *  26,
                        fit: BoxFit.contain, ),

                      SizedBox(height: 20,),
                      Text('暂无报警手机号' , style: TGlobalData().tsTxtFn24GreyBB,),
                    ],
                  )),

            );


          Color disabCr = Color(0xffaaaaaa);
          bool isEnab =  _pwdAlarmObjLs[idx]['isEnabled'] as bool;

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text( _pwdAlarmObjLs[idx]['startDt'] == 0 ? '00:00  ~  00:00' : '${ DateFormat('HH:mm').
                  format(DateTime.fromMillisecondsSinceEpoch( _pwdAlarmObjLs[idx]['startDt']   ))  }'
                      '  ~  '
                      '${ DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch( _pwdAlarmObjLs[idx]['endDt'] ))  }'

                    ,
                    style: TextStyle(fontSize: 20, color: isEnab ?  Color(  0xff333333)  : disabCr, fontWeight: FontWeight.w900),
                  ),
                  Text('当天有效', style: TextStyle(color: TGlobalData().crCommonGrey, fontSize: 16),),
                ],),
            ),

            trailing: IconButton(icon: Icon(Icons.delete),  onPressed: null ),// () => _deletePwdItem(idx , 1),),
            onTap: (){
              _pwdAlarmObjLs[idx]['isEnabled'] = ! isEnab;
              //  print('delete idx = ${_oneTimePwdObjLs[idx]['idx']}');
              setState(() {  });
            },
          );
        },
        separatorBuilder: (sctx, idx) => Divider(),
      ),


    );
  }



  Future<void> _fetchPwdAlarmDatLs() async
  {

    // var jobj = {};
    // jobj["sjcxycxmm"] =  TGlobalData().currUid;
    // jobj["skip"] = _oneTimePwdObjLs.length.toString();
    //
    // TBleSingleton().sendFramedJsonData(json.encode(jobj));


  }

}

















