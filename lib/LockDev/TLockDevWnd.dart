import 'dart:async';
import 'dart:convert';

import '../TBleSingleton.dart';
import '../TRemoteSrv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_phoenix/flutter_phoenix.dart';




import '../TGlobal_inc.dart';
import '../TBleSingleton.dart';

import 'CustomSwitch.dart';
import 'TDevInformations.dart';
import 'TDoorChecking.dart';
import '../Misc/TAlarmSettingWnd.dart';
import 'TDoorNfcWnd.dart';
import 'TDoorEventWnd.dart';
import 'TSetupPwdWnd.dart';
import 'TUserManagerWnd.dart';
import 'TPrivatePwdWnd.dart';



enum DoorLockStatus {Unknow, Open, Closed , Exception }


class TLockDevWnd extends StatefulWidget {

  final Map dataObj;

  TLockDevWnd(this.dataObj);


  @override
  _TLockDevWndState createState() => _TLockDevWndState();
}


class _TLockDevWndState extends State<TLockDevWnd> {

  DoorLockStatus _currDLStatus = DoorLockStatus.Unknow;

  bool _enableSwitch = false;
  bool _enSwitchClick = true;

  bool _quitMe = false;

  List<Map<String,dynamic>>   _popMenuItemLs = [];

  bool _havePrivPwd = false;

  String _connStatusTxt = '未连接';
  String _suStatusTxt = '请打开手机蓝牙贴近门锁';
  IconData _icdat  = Icons.bluetooth_searching;

  late StreamSubscription<String> _jsonSSub ;

  final _lockIconDatLs = [Icons.hourglass_empty, Icons.lock_open , Icons.lock , Icons.warning  ];

  int _batteryCap = 0;

  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

    _thizInit();

  }

  @override
  void deactivate() {
    print('${this.runtimeType.toString()} deactivate()......................');
  }

  @override
  void dispose() {
    print('${this.runtimeType.toString()} dispose()......................');

    _quitMe = true;

    _jsonSSub.cancel();
    TBleSingleton().doResetBle();
    super.dispose();
  }


  void _thizInit() async {


    print(widget.dataObj);

    if(_quitMe) return;

    String devId = widget.dataObj['bleDevId']; // macAddr without ':'


    String hwId = widget.dataObj['bleHwId']; // android OS is MAC, iOS is unique string

    if(hwId.isEmpty) {
      hwId =  await TBleSingleton().scanForLocalHwId(devId);

      print('Got hw id: $hwId');

      if(hwId.isNotEmpty){
        final tmpObj = await TRemoteSrv().oneLockAseKey( devId );

        print('tmpObj : $tmpObj');
        if(tmpObj['code'] == 0){
          String aesKey = tmpObj['data']['aeskey'];

          TBleSingleton().Userid = int.parse(widget.dataObj['lockUid']) ;
          TBleSingleton().keepDfk  = aesKey;

          List<String> tmpStrLs = [
            devId,
            hwId,  // iOs and android is different
            widget.dataObj['lockname'],
            TBleSingleton().Userid.toString(),
            TBleSingleton().keepDfk,
          ];

          print('Finnally tmpStrLs for storage $tmpStrLs');

           TGlobalData().keepLockByDevId(tmpStrLs);

          Phoenix.rebirth(context);


        }

      }else{
        // Future.delayed(Duration(milliseconds: 1000)).then((_) => _thizInit());

        Navigator.pop(context);

        return;

      }
    }




    TGlobalData().currUid = widget.dataObj['lockUid'].toString();
    TBleSingleton().keepDfk =widget.dataObj['dse3key'].toString();

    List<dynamic> wndClsLs = [
      TSetupPwdWnd(pwdType: LockPwdType.oneTimePwd , lockInfoObj: widget.dataObj,) ,
      TSetupPwdWnd(pwdType: LockPwdType.repeatPwd, lockInfoObj: widget.dataObj,) ,
      TDoorChecking(),
      TAlarmSettingWnd(),
      TDevInformations() ,

    ];

    //final ics = [Icons.update_disabled , Icons.flip_camera_android , Icons.quiz,   Icons.alarm , Icons.assignment];
    final svgIcLs = ['onetimePwdCtx', 'repeatPwdCtx', 'chkDoorCtx'  , 'alarmCtx', 'deviceInfoCtx'];

    ['一次性密码', '周期密码', '检验门锁' , '报警方式' , '设备信息'].forEachIndexed((  idx , str ) {
      Map<String , dynamic> tmpObj = {};
      tmpObj..['title'] = str
        ..['icon'] = svgIcLs[idx]
        ..['wndcls'] = wndClsLs[idx];

      _popMenuItemLs.add(tmpObj);
    });

    _jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) => handleJsonStr(jsonStr));


    Future.delayed(Duration(milliseconds: 300)).then((_) => _tryConnectToBle());

  }



  @override
  Widget build(BuildContext context) {

    double scrW = MediaQuery.of(context).size.width;
    double scrH = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text(widget.dataObj['lockname'] ,
        style: TextStyle(color: Color(0xffeeeeee), fontSize: 20, fontWeight: FontWeight.bold), ),
      elevation: 0.0,
        backgroundColor: Color(0xff3D3D3D),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed:   _showPopupMenu,
           icon:  SvgPicture.asset( 'images/svgs/setting6poly.svg' ,height: TDevsSizeFit.safeBlockHorizontal  * 8, color: Colors.white, fit: BoxFit.contain, ))

        //Icon(Icons.policy , size: 32,))   //
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [

        Container(

          margin:  EdgeInsets.only(bottom:  scrH / 10.0 * 6.2 ) ,

          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
           // border: Border(),
            color:  Color(0xff3D3D3D),

          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Color(0xff888888)),
                      //  color: Color(0xffaaaaaa),
                    ),
                    child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TUserManagerWnd()));
                        },
                        icon: SvgPicture.asset( 'images/svgs/usericon.svg' ,height: TDevsSizeFit.safeBlockHorizontal  * 10, fit: BoxFit.contain, ),
                        //Icon(Icons.perm_identity, color: Colors.white, size: 44,)

                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('人员' , style: TGlobalData().tsListCntTS1,),
                  ),
                ],
              ),



              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Color(0xff888888)),
                      //  color: Color(0xffaaaaaa),
                    ),
                    child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TDoorEventWnd(widget.dataObj['bleDevId'].toString())));
                        },
                        icon: SvgPicture.asset( 'images/svgs/eventIcon.svg' ,height: TDevsSizeFit.safeBlockHorizontal  * 10, fit: BoxFit.contain, ),

                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('动态' ,textAlign: TextAlign.center , style: TGlobalData().tsListCntTS1,),
                  ),
                ],
              ),


              Wrap(
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                direction: Axis.vertical,
                children: [
                  Container(
                   padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Color(0xff888888)),
                     //  color: Color(0xffaaaaaa),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                        onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => TDoorNfcWnd()));
                        },
                        icon: SvgPicture.asset( 'images/svgs/nfc.svg' ,height: TDevsSizeFit.safeBlockHorizontal  * 10, fit: BoxFit.contain, ),

                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('NFC' ,textAlign: TextAlign.right ,   style: TGlobalData().tsListCntTS1,),
                  ),

              ],),


            ],
          ),

        ),





          Positioned(
            top: scrH / 6.0 ,
            left: scrW / 4.6,

            child: Column(
              children: [
                Container(
                  height: scrH / 4.0 * 1.2 ,
                  width: scrH / 4.0  * 1.2 ,
                  padding: EdgeInsets.all(18.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(scrH / 4.0   ),

                    color: Colors.white,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(18.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(scrH / 4.0   ),

                      color: Color(0xffeeeeee),
                    ),
                    child:
            _currDLStatus == DoorLockStatus.Unknow ?
                    Container(
                      // color: Colors.red,
                      padding: EdgeInsets.all(18.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(scrH / 4.0   ),

                        color:  _icdat == Icons.bluetooth_searching ? Color(0xffbbbbbb) : Color(0xff222222),
                      ),
                      child:  _icdat == Icons.bluetooth_searching ?  Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(scrH / 4.0   ),
                          color:   Color(0xff222222),
                        ),
                        child: Icon(_icdat, size:  scrW / 6.0, color: TGlobalData().crMainThemeColor,),
                      )
                      : Icon(_icdat, size:  scrW / 6.0, color: TGlobalData().crMainThemeColor,),
                    )
                    :
            Container(
              // color: Colors.red,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(scrH / 4.0   ),
                color: _currDLStatus == DoorLockStatus.Closed ? Color(0xffFF634E) : TGlobalData().crMainThemeColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_lockIconDatLs[_currDLStatus.index], size:  scrW / 6.0, color: Colors.white,),
                  RotatedBox(quarterTurns: 1,
                  child: Icon(Icons.battery_charging_full, size:  20, color: Colors.white,)),
                  Text('$_batteryCap%',  textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.white),),
                ],
              ),
            ),

                  ),

                ),


                Text(_connStatusTxt , style: TextStyle(fontSize: 30 , fontWeight: FontWeight.bold),),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_suStatusTxt , style: TextStyle(fontSize: 18 , color: Color(0xffaaaaaa)),),
                ),



                _havePrivPwd ?
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: _enSwitchClick ?   (){
                        setState(() {
                          _enableSwitch = !_enableSwitch;
                          _enSwitchClick = false;
                        });
                        _doOpenCloseDoorNow();

                        Future.delayed(Duration(milliseconds: 3600)).then((_) {setState(() {
                          _enSwitchClick = true;
                        });});

                      } : null,
                      child: CustomSwitch(switched: _enableSwitch, widW: 100, widH: 160,)),
                )
                :
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: ElevatedButton(
                  child: Text(
                  '添加用户密码',
                  style: TGlobalData().tsTxtFn20Grey22,
                  ),

                  style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: TGlobalData().crMainThemeOnColor,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 40,vertical: 12),
                  shape: StadiumBorder(),
                    side: BorderSide(color: TGlobalData().crGrey88),

                  ),
                  onPressed:   () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) => TPrivatePwdWnd(uid: int.parse(TGlobalData().currUid))));
                  },
                     ),
                ),



              ],
            ),

          ),


         ],
      ),
    );

  }





  void _showPopupMenu() async {

    double widW =  MediaQuery.of(context).size.width;
    double widH =  MediaQuery.of(context).size.height;

    final rtn = await showDialog(
        context: context,
        builder: (BuildContext dctx){
          return Material(
            color: Colors.transparent,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: (){Navigator.pop(dctx);},
              child: Container(
                // margin: EdgeInsets.fromLTRB (left:  / 11.0,
                //     top:  MediaQuery.of(context).size.height / 4 ),
                  margin: EdgeInsets.fromLTRB(widW * .38, widH * .08, widW * .08, widH * .4),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(32),
                        bottomLeft: Radius.circular(32),bottomRight: Radius.circular(32)),
                    //border: Border(top: BorderSide()),
                  ),
                  child:Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children:  [

                        ...<int>[ for(int i = 0 ; i < _popMenuItemLs.length ;i ++) i].map((idx) {
                          return InkWell(
                            onTap: (){
                               Navigator.pop(dctx);
                              Future.delayed(Duration(milliseconds: 100)).then((value) =>
                                  Navigator.push(context, MaterialPageRoute(builder: (ctx)=> _popMenuItemLs[idx]['wndcls'] ))
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              //  color: Colors.red,
                              decoration: BoxDecoration(
                                border: idx == _popMenuItemLs.length -1 ? null : Border(bottom: BorderSide(color: Color(0xffdddddd))),
                              ),
                              child: Wrap(
                                spacing: 16.0,
                                children: [
                                 // Icon(    _popMenuItemLs[idx]['icon'] ),
                                  SvgPicture.asset( 'images/svgs/${_popMenuItemLs[idx]['icon']}.svg' ,height: TDevsSizeFit.safeBlockHorizontal  * 7,   fit: BoxFit.contain, ),
                                  Text(_popMenuItemLs[idx]['title'] , style: TGlobalData().tsListTitleTS1,),
                                ],),

                            ),
                          );
                        }).toList(),

                        // ...<List>[_popMenuItemLs].mapIndexed((idx, obj) {
                        //   return Container(
                        //     padding: EdgeInsets.all(20),
                        //     child: Wrap(children: [
                        //       Icon( obj[idx]['icon'] ),
                        //       Text(obj[idx]['title']),
                        //     ],),
                        //
                        //   );
                        // }).toList(),


                      ],
                    ),
                  )

              ),
            ),
          );
        }

    );

  }

  void _doOpenCloseDoorNow() {
    var jobj = {};
    jobj["sjkgms"] = _enableSwitch ?  1 : 0;
    TBleSingleton().sendFramedJsonData(json.encode(jobj));

    }

  void _fetchDoorLockStatus() async
  {
    var jobj = {};
    jobj["sjkgzt"] =  '';
    TBleSingleton().sendFramedJsonData(json.encode(jobj));

  }


  void _fetchLockBattery() async
  {
    var jobj = {};
    jobj["sjdcrl"] =  0;
    TBleSingleton().sendFramedJsonData(json.encode(jobj));

  }

  void _updateLockTime() async
  {
    var jobj = {};
    jobj["sjrqsj"] =   DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

    TBleSingleton().sendFramedJsonData(json.encode(jobj));

  }

  void _tryConnectToBle() async
  {
    if(!TBleSingleton().isBtReady){
      TGlobalData().showToastInfo("蓝牙未打开... .");
      return;
    }

    setState(() {
      _icdat = Icons.bluetooth_searching;
      _connStatusTxt = '连接中···';
    });

    bool isConnOk = await _connToBleLock();
    if(!isConnOk) {
      TGlobalData().showToastInfo("连接锁具失败....");
      setState(() {
        _icdat = Icons.bluetooth_disabled;
        _connStatusTxt = '未连接';
      });
      return;
    }

    setState(() {
      _icdat = Icons.bluetooth_connected;
      _connStatusTxt = '已连接';
    });

    await Future.delayed(Duration(milliseconds: 100));
    _updateLockTime();
    await Future.delayed(Duration(milliseconds: 200));
    _fetchDoorLockStatus();
    await Future.delayed(Duration(milliseconds: 200));
    _fetchLockBattery();
  }



  Future<bool> _connToBleLock() async {

    TBleSingleton().doResetBle();
    TBleScanStatus currStat = await TBleSingleton().findAndConnBleById(widget.dataObj['bleHwId'].toString()) ;

  //  print('currStat : ${currStat}');

    if(currStat != TBleScanStatus.Found){
      //TGlobalData().showToastInfo("连接锁具失败....");
     return  Future.value(false);
    }

    return Future.value(true);
  }

  void handleJsonStr(String jsonStr) async {

   // print('Got jstr : $jsonStr');

    var jsonObj = jsonDecode(jsonStr);

    var kgzt = jsonObj['sjkgzt'];
    if(kgzt != null){
      int st = int.parse(kgzt.toString());
      switch(st){
        case 0:
          _currDLStatus = DoorLockStatus.Open;
          _connStatusTxt = '已开锁';
          _suStatusTxt = '点击下方关闭门锁';
          _enableSwitch = true;
          break;
        case 1:
          _currDLStatus = DoorLockStatus.Closed;
          _connStatusTxt = '已上锁';
          _suStatusTxt = '点击下方打开门锁';
          _enableSwitch = false;
        break;
        default:break;
      }

      _havePrivPwd = true;

        setState(() { });
    }

    var dcrl = jsonObj['sjdcrl'];
    if(dcrl != null){
      int st = int.parse(dcrl.toString());
      _batteryCap = st.clamp(1, 100);
      setState(() { });
    }

    var kgztsb = jsonObj['sjkgztsb'];
    if(kgztsb != null){
      int st = int.parse(kgztsb.toString());
      if(st == 1){
        _currDLStatus = DoorLockStatus.Closed;
        _connStatusTxt = '已上锁';
        _suStatusTxt = '点击下方打开门锁';

      }else {
        _currDLStatus = DoorLockStatus.Open;
        _connStatusTxt = '已开锁';
        _suStatusTxt = '点击下方关闭门锁';
      }
        setState(() { });

    }




  }


}
