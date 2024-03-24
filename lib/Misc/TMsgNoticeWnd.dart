import 'dart:async';
import 'dart:convert';

import '../TRemoteSrv.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';

import '../TGlobal_inc.dart';

import '../LockDev/CustomSwitchRound.dart';





class TMsgNoticeWnd extends StatefulWidget {



  @override
  _TMsgNoticeWndState createState() => _TMsgNoticeWndState();
}


class _TMsgNoticeWndState extends State<TMsgNoticeWnd> {

    List<Map> _msgObjLs  = [] ;


  int _needUpdLs = 0;

  int _lazyLoadingPageSize = 10;

  int _totalMsgCount = 0;

  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();



    // TGlobalData().keepNotifyMsg({});
    // for(int j = 0 ; j < 20 ; j ++){
    //   Map tmpObj = {};
    //   tmpObj['iconType'] = j % 5 ;
    //   tmpObj['lockname'] = 'doorName';
    //   tmpObj['evtId'] =  2 ;
    //   tmpObj['dt'] =  DateTime.now().millisecondsSinceEpoch ;
    //
    //   TGlobalData().keepNotifyMsg(tmpObj);
    //
    // }


   // _msgObjLs = TGlobalData().fetchNotifyMsg();

  //  print(_msgObjLs);
  // TGlobalData().keepNotifyMsg({});

    _fetchMsgFromRemoteSrv();

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
      appBar: AppBar(title: Text('消息通知' , style: TGlobalData().tsHeaderTextStyle,),
      elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>_TMsgSettingWnd())),
              icon: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SvgPicture.asset( 'images/svgs/setting6poly.svg' ,    fit: BoxFit.contain, ),
              )  ),

        ],
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.all(20.0),

        child: NotificationListener(
          onNotification: (notify)   {

            if(notify is ScrollUpdateNotification){

              double diff = notify.metrics.viewportDimension - notify.metrics.extentInside;

              if(diff > 80) {
                _needUpdLs = 1;
                if(notify.metrics.pixels < 0)
                   _needUpdLs = -1;
              }

              if(notify.metrics.atEdge && _needUpdLs != 0){
               // print(' need update list  ........$_needUpdLs');

                if(_needUpdLs < 0){

                  _fetchMsgFromRemoteSrv();

                }else if(_needUpdLs > 0){
                 // _msgObjLs = TGlobalData().fetchNotifyMsg();
                  _fetchMsgFromRemoteSrv();
                }

                _needUpdLs = 0;

              }


            }

            return false;
          },
          child: ListView.separated(

              itemCount: _msgObjLs.isEmpty ? 1 :  _msgObjLs.length - 1  ,
              itemBuilder: (BuildContext itCtx ,int idx){

              if(_msgObjLs.isEmpty)
                return Container(child: Text('暂无数据!' , textAlign: TextAlign.center,));

                return ListTile(
                  leading: Container( height: double.infinity,
                      child: Icon(Icons.circle, size: 20, color: TGlobalData().crMainThemeColor,)),
                  title: Align(
                    alignment: Alignment(-1.24 , 0),
                    //child: Text( _msgObjLs[idx]['lockname'] + '- ${_msgObjLs[idx]['evtId']}' ,
                      child: Text( _msgObjLs[idx]['lockname'] + '- ${_msgObjLs[idx]['evtStr']}' ,
                    style: TGlobalData().tsListTitleTS1,),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Align(
                      alignment: Alignment(-1.4 , 0),
                     // child: Text(DateFormat('yyyy.MM.dd  hh:mm').format(DateTime.fromMillisecondsSinceEpoch((_msgObjLs[idx]['dt'] as int) * 1000 )),
                        child: Text(_msgObjLs[idx]['dtStr'] ,
                               style: TextStyle(color: Color(0xffaaaaaa), fontSize: 18, ),),
                    ),
                  ),
                );
              },
            separatorBuilder:(BuildContext itCtx ,int idx){

              if(_msgObjLs.isEmpty)
                return SizedBox();

              return Container(height: 1,color: Color(0xffdddddd),);
            }, ),
        ),
        
      ),
    );

  }

  Future _fetchMsgFromRemoteSrv() async {

    final rtnObj = await TRemoteSrv().pullNotifyMsg( (_msgObjLs.length ~/ _lazyLoadingPageSize ) +1 , _lazyLoadingPageSize);
    Map<String, dynamic> tmpDatObj = rtnObj['data'];
    _totalMsgCount= tmpDatObj['total'];

    // print('total: $_totalMsgCount');

     List< dynamic > tmpLs = tmpDatObj['list'];



    for(int j = 0 ; j < tmpLs.length ; j ++){
      Map<String, dynamic> tmpO = tmpLs[j] ;
      Map tmpObj = {};
      tmpObj['iconType'] = j % 5 ;
      tmpObj['lockname'] = 'doorName';
      tmpObj['evtId'] =  2 ;
      tmpObj['evtStr'] =  tmpO['info']  ;
      tmpObj['dt'] =  0 ;
      tmpObj['dtStr'] =  tmpO['addtime_text']  ;

      _msgObjLs.add(tmpObj);

    }

    setState(() { });

    if(_totalMsgCount < _lazyLoadingPageSize )
      TGlobalData().showToastInfo('已到最后一页');

  }



}




class _TMsgSettingWnd extends StatefulWidget {


  @override
  _TMsgSettingWndState createState() => _TMsgSettingWndState();
}


class _TMsgSettingWndState extends State<_TMsgSettingWnd> {

  bool _isAlarmOn = false;


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
      appBar: AppBar(title: Text(  '消息设置',
        style: TextStyle(color: Color(0xff222222), fontSize: 20, fontWeight: FontWeight.bold), ),
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('接受系统通知', style: TGlobalData().tsTxtFn18Grey88),

              Container(
                margin: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border.symmetric(horizontal: BorderSide(color: TGlobalData().crGreyDD)),
                ),

                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: SvgPicture.asset( 'images/svgs/alarmNotice.svg' , width: 50,  fit: BoxFit.contain, ),
                      ),

                      Expanded(flex: 10,child: SizedBox()),

                      Text('报警通知' , style: TGlobalData().tsTxtFn24Grey22Bn,),

                      Expanded(flex: 100,child: SizedBox()),

                      InkWell(child: CustomSwitchRound(switched: _isAlarmOn,widW: 46, widH: 24,),
                      onTap: () =>  setState(() => _isAlarmOn = !_isAlarmOn ),
                      ),


                    ],
                  )),


              // ElevatedButton(
              //     onPressed: () async {
              //
              //       Map<String , dynamic> tmpOjb = {
              //         'token': TGlobalData().currUserToken(),
              //         'device_id':'aaaa-3333-bbbb-4444-cccc-5555-eeef',
              //         'name': 'doorName8',
              //         'user_id':'1',
              //         // 'id':'1',
              //         // 'device_id2':'2',
              //
              //       };
              //
              //        TRemoteSrv(). authNewLock( tmpOjb);
              //
              //      List< Map<String , dynamic> > aaa = [];
              //      for(int i = 1 ; i < 6 ; i ++)
              //        aaa.add({'type':'$i' ,
              //          'addtime':(DateTime.now().millisecondsSinceEpoch ~/ 1000 ).toString() ,
              //          'nickname':'wudaquan'}
              //          );
              //
              //    //  TRemoteSrv().batchSubmitNotifyEvent(aaa, '2');
              //
              //     //  TRemoteSrv().pullLockLogs(1, 10);
              //       // TRemoteSrv().pushOneLockLog('2', 3);
              //
              //    // TRemoteSrv(). submitLockOperationEvent(3,'3');
              //
              //
              //       //  TRemoteSrv().renameLock('rn锁4');
              //
              //      //   TRemoteSrv().refreshNewToken();
              //
              //          //  TRemoteSrv().allDoorLocksList();
              //
              //
              //     // TRemoteSrv().oneLockInfo('2');
              //
              //     //   TRemoteSrv().deleteOneLock('d');
              //
              //    //  List<String> commDatLs = TGlobalData().fetchCommonLoginData() ;
              //     // TRemoteSrv().oneUserInfo(commDatLs[1], '2'  );
              //
              //       //  TRemoteSrv().pullNotifyMsg(1, 10);
              //
              //       //   TRemoteSrv().updateUsername('myNewName');
              //
              //
              //   //  TRemoteSrv().deleteOneUser('1' ,'1');
              //
              // }
              //     , child: Text('Push test notification msg data')),

            ],
          )),
    );

  }
}




















