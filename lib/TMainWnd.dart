

import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:convert/convert.dart';
import 'dart:typed_data';

import 'package:intl/intl.dart';

import 'TGlobal_inc.dart';
import '../TBleSingleton.dart';


import 'UserInfo/TUserChgeNickname.dart';
import 'UserInfo/TUserPhotoWnd.dart';

import 'DeviceSetting/TScanLockWnd.dart';
import 'Misc/TMsgNoticeWnd.dart';
import 'LockDev/TLockDevWnd.dart';
//
import 'Misc/TPushNotify.dart';
import 'Misc/TAlarmSettingWnd.dart';

//
import 'TRemoteSrv.dart';



class TMainWnd extends StatefulWidget {
  @override
  _TMainWndState createState() => _TMainWndState();
}

class _TMainWndState extends State<TMainWnd> {
  int _idxShowStack = 0;


  late StreamSubscription<String> _jsonSSub ;

    List<String> _commonDatLs = TGlobalData().fetchCommonLoginData();



  @override
  void reassemble() {
    // print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

    _jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) => handleJsonStr(jsonStr));

    // new Future.delayed(Duration(milliseconds: 200)).then((_) {
    //
    // });

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
    return   Material(
      color: Color(0xffeeeeee),
      child: SafeArea(
        child: Container(
             color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [


                Expanded(
                  flex:100 ,
                  child:  //Text('ssssss'),
                  IndexedStack(
                  index: _idxShowStack,
                  children: [
                    Center(child: _TMainWndHome(_commonDatLs)),
                    Center(child: _TMainWndUser(_commonDatLs)),
                  ],
                   ),
                ),

                Container(
                 // color: Color(0xffeeeeee),
                 // height: 100,
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Color(0xfff6f6f6),
                    border: Border.all(color: Color(0xffe8e8e8)),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.0),),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: DefaultTabController(
                      length: 2,
                      child: Theme(
                        data: ThemeData(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                        )  ,
                        child: TabBar(
                          // controller: _connTypeTabCtlr,
                          indicatorColor: Colors.transparent,
                         // indicator: BoxDecoration(),
                           // unselectedLabelColor: Colors.blue,
                           // labelColor: Colors.red,
                            onTap: (int idx) {
                              //FocusScope.of(context).unfocus();
                                //print('curr tab index.....$idx');

                              setState(() {
                                _idxShowStack = idx;
                              });
                            },
                            tabs: [
                              SizedBox(
                                  width:32,
                                  height: 32,
                                  child: CustomPaint(painter: THomeIcon(_idxShowStack))),

                              SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CustomPaint(painter: TUserIcon(_idxShowStack))),


                            ]),
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }


  void handleJsonStr(String jsonStr) async {

    final dummyChar = '\u200B';
    List<String> allLockDevLs = TGlobalData().fetAllLockDevLs();
    //  print('TMainWnd Got jstr : $jsonStr');

    final jsonObj = jsonDecode(jsonStr);

    final pushmsg = jsonObj['sjpushmsg'];
    if(pushmsg != null){
      List<dynamic> tmpLs = pushmsg as List<dynamic>;


      List< Map<String , dynamic> > sendObjLs = [];

      for(int j = 0 ; j < tmpLs.length ; j ++){

        Map<String , dynamic> tmpObj = {'type':'${tmpLs[j][0] as int}' , 'addtime':((tmpLs[j][0] as int) * 1000).toString() , 'nickname':'wudaquan'};

        sendObjLs.add(tmpObj);
    }

  //  TRemoteSrv().batchSubmitLockLog(sendObjLs, '2');

/*
      for(int i = 0 ; i < allLockDevLs.length; i ++) {
        if(allLockDevLs[i].contains(TBleSingleton().currBleDevId)){
          List<String> infoLs = allLockDevLs[i].split(dummyChar);
          String doorName = infoLs[0];
          for(int j = 0 ; j < tmpLs.length ; j ++){
            Map tmpObj = {};
            tmpObj['iconType'] = j % 5 ;
            tmpObj['lockname'] = doorName;
            tmpObj['evtId'] =  tmpLs[j][0] as int ;
            tmpObj['dt'] =  (tmpLs[j][0] as int) * 1000 ;

            TGlobalData().keepNotifyMsg(tmpObj);

            Map<String , dynamic> = {'type':'${tmpLs[j][0] as int}' , 'addtime':((tmpLs[j][0] as int) * 1000).toString() , 'nickname':'wudaquan'};



            TRemoteSrv().batchSubmitNotifyEvent(aaa, '2');

          }
          break;
        }
      }
*/
      // print(tmpLs);
      // print
    }

    }


   void reloadCommonDataLs () {
     setState(() {
       _commonDatLs = TGlobalData().fetchCommonLoginData();
     });
   }

}



class _TMainWndHome extends StatefulWidget {

  final List<String> _commonDatLs;

  _TMainWndHome(this._commonDatLs);

  @override
  _TMainWndHomeState createState() => _TMainWndHomeState();
}

class _TMainWndHomeState extends State<_TMainWndHome> {

  List<Map> _allLockDevObjLs = [];

  @override
  void reassemble() {
    // print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

   // context.findAncestorStateOfType()


   // _loadLockDevList();
    fetchDoorLocksListFromRemoteSrv();

    // new Future.delayed(Duration(milliseconds: 1200)).then((_) {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => TLogingWnd()),
    //     //MaterialPageRoute(builder: (context) => TDevMainWnd()),
    //   );
    // });
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


  Future  fetchDoorLocksListFromRemoteSrv() async
  {
    final rtnObj = await TRemoteSrv().allDoorLocksList();
    Map<String, dynamic> datObj = rtnObj['data']  ;

    _allLockDevObjLs.clear();

    int count = datObj['total']  ;
    if(count < 1) {
      TGlobalData().showToastInfo('无记录....');
      return;
    }

      List<  dynamic  > datObjLs = datObj['data'] as List<   dynamic  >;


      for(int i = 0 ; i < datObjLs.length; i ++){
        Map<String, dynamic> inObj = datObjLs[i] as Map<String, dynamic>;

        String devId = inObj['lock_id']; // mac addr
       // String devUid = inObj['device_id2'];

        List<String> lockInfoLs = TGlobalData().fetchLockByDevId(devId);

        print('LockInfoLs : ');
        print(lockInfoLs);

        String dseKey = '';
        String localHwId = '';
        if(lockInfoLs.length > 4) {
          dseKey = lockInfoLs[4];
          localHwId = lockInfoLs[1];
        }

        Map tmpObj = {};
        tmpObj['lockname'] = inObj['lock_name'];
        tmpObj['bleDevId'] =  devId;
        tmpObj['bleHwId'] = localHwId; // android OS is MAC, iOS is unique string
        tmpObj['bleUid'] =  '0';
        tmpObj['lockUid'] = inObj['lock_uid'];
        tmpObj['dse3key'] = dseKey ;
        tmpObj['borderCr'] = Colors.red;
        tmpObj['bleCr'] = Colors.blue;
        tmpObj['lockCr'] = Colors.blue;
        tmpObj['evtStr'] = inObj['type_text'];
        tmpObj['dt'] =  inObj['last_open_time'] ;//DateTime.now().toUtc().millisecondsSinceEpoch  /1000  ;

        _allLockDevObjLs.add(tmpObj);

      }

      setState(() { });


  }
  
  
  Widget _noLockDev(){
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 2),
            child: Image.asset('images/pngs/noLockDev.png' ,
              height: MediaQuery.of(context).size.height / 5.0 * 2.0,
              fit: BoxFit.scaleDown,),
          ),

          Center( child:
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text('暂无设备，去添加' , style: TGlobalData().tsListCntTS1,),
          )),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80.0),
            child: ElevatedButton(
                onPressed: () async {
                    _goScanNewBleLockDev();
                },
                child: Text('添加设备' , style: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
                style: ElevatedButton.styleFrom(
                  primary: TGlobalData().crMainThemeColor,
                onPrimary: TGlobalData().crMainThemeOnColor,
                shadowColor: Colors.white,
                padding: EdgeInsets.all(10.0),
                  shape: StadiumBorder(),

              ),
            ),
          ),

        ],
      ),
    );
  }

  void _goScanNewBleLockDev() {

    Navigator.push(context, MaterialPageRoute(
        settings: RouteSettings(name: '/tscanlockwnd', arguments: Map()),
        builder: (context) => TScanLockWnd())
    ).then((v) {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;

     // print(arguments.toString());

      final result = arguments['rsl'];


      if(result != null && result == 1){
        (ModalRoute.of(context)!.settings.arguments as Map)['rsl'] = 0;

           fetchDoorLocksListFromRemoteSrv();

       // setState(() {
        //  _loadLockDevList();
        //});

       // print(_allLockDevLs);


      }



    });
  }


  Widget _dispAllALockDev(){
    return Container(
     // height: 300,
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          Row(
            children: [
              Icon(Icons.location_pin),

              Text('太子中央广场' , style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),

              Expanded(child: SizedBox()),

              IconButton(
                onPressed: () async {


//////////////////////////////////////////////////////////////////////////





                  final lObj =  _allLockDevObjLs.first;
               final tmpObj = await   TRemoteSrv().pullLockLogs( lObj['bleDevId']  , 1 , -2 , '2021-12-09' );

                  print(tmpObj );



////////////////////////////////////////////////////////////////////////////////////////////
//                   List< Map<String , dynamic> > sendObjLs = [];
//
//                   for(int j = 1 ; j < 4 ; j ++){
//
//                     //  [[0, 1, 32, 1, 1632911195], [1, 1, 32, 1, 1632911220]]
//                     Map<String , dynamic> tmpObj = {
//                       'evttype':j +1 ,
//                       'evttime':DateTime.now().toUtc().millisecondsSinceEpoch ,
//                       'paratype' :2,
//                       'uid' :1,
//                       'nickname':'alibaba$j'
//                     };
//
//
//                     sendObjLs.add (tmpObj);
//                   }
//
//
//                   final lObj =  _allLockDevObjLs.first;
//                   TRemoteSrv().batchSubmitLockLog(sendObjLs,lObj['bleDevId']  );


////////////////////////////////////////////////////////////////////////////////////////////
                // final lObj =  _allLockDevObjLs.first;
                //
                // print('lObj: $lObj');
                //
                // final tmpObj = await TRemoteSrv().renameLock(lObj['bleDevId'], '新大门');

                  // print(TGlobalData().currUserAcceToken());
                  //
                  // final obj = await TRemoteSrv().refreshAccessToken();
                  // print(obj.toString());
                  // if(obj['code'] == 0){
                  //   print('save token....');
                  //  // TGlobalData().keepCurrUserAcceToken(obj['data']['access_token']);
                  // }
                  //
                  // print(TGlobalData().currUserAcceToken());

///////////////////////////////////////////Testing//////////////////////////////////////////////////////
//                   Map<String , dynamic> tmpOjb = {
//                    // 'token': TGlobalData().currUserToken(),
//                      'access_token':TGlobalData().currUserAcceToken()    ,
//                     'lock_id':'22aa22bb33cf',
//                     'lock_name': '小区正门4',
//                     'lock_uid': '1',
//                     'aeskey':'abcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdef',
//
//                   };
//
//                   print('auth new lock: ');
//                   print(tmpOjb.toString());
//                   // {token: gtuc37jb15ohf35ts9qfhdjhmg, device_id: 341a0db8e209, name: 大门, user_id: 1, device_id2: 8AB2505A-2233-C924-F8B5-A2FEB905B2EF}
//
//                   final rtnObj = await  TRemoteSrv(). authNewLock( tmpOjb);
//
//                   print(rtnObj);
//                   int code = rtnObj['code'];
//                   if(code == 0){
//                   //  print('keep new lock: $tmpStrLs');
//                    // TGlobalData().keepLockByDevId(tmpStrLs);
//                   }

                  ///////////////////////////////////////////Testing//////////////////////////////////////////////////////


                    // TGlobalData().keepLockByDevId([ ]);
                  // TGlobalData().showToastInfo('Clean lock dev info.....');

                  ///////////////////////////////////////////Testing//////////////////////////////////////////////////////



                },
                icon:  SvgPicture.asset( 'images/svgs/refresh.svg' ,height: TDevsSizeFit.safeBlockHorizontal  * 5, fit: BoxFit.contain, ),),

            ],
          ),

            Container(
               height: MediaQuery.of(context).size.height / 10.0 * 6.2,
              child: RefreshIndicator(
                onRefresh: _refreshAllDoorLs,
                child: SingleChildScrollView(
                  child:
                  Column(
                   mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,

                    children: [

                    ...<int>[for(int i = 0 ; i < _allLockDevObjLs.length; i ++) i].map((idx) {

                      return  InkWell(
                        onLongPress: () => _delLockContextMenu(_allLockDevObjLs[idx]['bleDevId']),
                        onTap: () async {
                         // print('go lock detail.....${_allLockDevObjLs[idx]}');
                          await Navigator.push(context, MaterialPageRoute(builder: (ctx)
                                    => TLockDevWnd(_allLockDevObjLs[idx])));

                          setState(() {  });

                        },
                        child: Container(
                            margin: EdgeInsets.symmetric(vertical:  6.0),
                            padding: EdgeInsets.all(14.0),
                            height: MediaQuery.of(context).size.height / 4.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: _allLockDevObjLs[idx]['borderCr'] as Color ),
                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                //  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [

                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(Icons.bluetooth,
                                      color: _allLockDevObjLs[idx]['bleCr'] as Color,
                                      size: 20,),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      // child: Icon(Icons.lock_open,
                                      // color: _allLockDevObjLs[idx]['lockCr'] as Color,
                                      // size: 26,),
                                      child:  SvgPicture.asset( 'images/svgs/lock_open.svg' ,height: TDevsSizeFit.safeBlockHorizontal  * 4, fit: BoxFit.contain, ),



                                    ),


                                ],),


                                Image.asset('images/pngs/noLockDev.png' ,
                                  height:  22 , // MediaQuery.of(context).size.height / 5.0 * 2.0,
                                  fit: BoxFit.scaleDown,),


                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                       crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                            padding:  EdgeInsets.fromLTRB(0  , 10, 10, 10),
                                            decoration: BoxDecoration(
                                              border: Border(bottom: BorderSide(width: 1.0, color: Color(0xffdddddd))),
                                            ),
                                            child: Text(_allLockDevObjLs[idx]['lockname'] , style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),)
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.only(top: 16.0),
                                          child: Wrap(
                                            spacing: 6.0,
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            children: [
                                              //Icon(Icons.timer  , color: Color(0xffbbbbbb),),
                                              SvgPicture.asset( 'images/svgs/timeIcon.svg' ,height: TDevsSizeFit.safeBlockHorizontal  * 5, fit: BoxFit.contain, ),

                                              Text(_allLockDevObjLs[idx]['evtStr']  , style: TextStyle(fontSize: 16 , color: Color(0xffbbbbbb))),
                                            ],
                                          ),
                                        ),

                                        SizedBox(height: 6.0,),

                                        Wrap(
                                          spacing: 6.0,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: [
                                            CustomPaint( painter:  TLineCorner() ,size: Size(20,20),),
                                            Text( _allLockDevObjLs[idx]['dt'] == 0 ? '暂无记录' : DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(
                                                                _allLockDevObjLs[idx]['dt']    )) .toString()  ,
                                                style: TextStyle(fontSize: 16 , color: Color(0xff666666) , fontWeight: FontWeight.bold)),
                                          ],
                                        ),


                                    ],),
                                  ),
                                ),




                              ],
                            )),
                      );


                    }).toList(),




                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ElevatedButton(
                        onPressed: (){
                           _goScanNewBleLockDev();

                        },
                        child: Icon(Icons.add , size: 50, color: Color(0xffaaaaaa),),
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xffeeeeee),
                          onPrimary: TGlobalData().crMainThemeOnColor,
                          shadowColor: Colors.transparent,

                          padding: EdgeInsets.all(10.0),
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20) ,
                              side: BorderSide(color: Color(0xffaaaaaa))),

                        ),
                      ),
                    ),

                      ElevatedButton(

                        child: Text('推送消息'),  //
                        onPressed: ()  {
                          Navigator.push(context, MaterialPageRoute(builder: (ctx)=>TPushNotify()));

                        },
                      ),
                      //
                      // ElevatedButton(
                      //
                      //   child: Text('test remote server'),
                      //   onPressed: ()  {
                      //
                      //    // TRemoteSrv().deleteOneLock('d');
                      //
                      //     Map<String , dynamic> tmpOjb = {
                      //       'token': TGlobalData().currUserToken(),
                      //       'device_id':'aaaa-3333-bbbb-4444-cccc-5555-eeee',
                      //       'name': 'doorName4',
                      //       'user_id':'1',
                      //       // 'id':'1',
                      //       // 'device_id2':'2',
                      //
                      //     };
                      //
                      //    //   TRemoteSrv(). authNewLock( tmpOjb);
                      //
                      //     TRemoteSrv().allDoorLocksList();
                      //
                      //
                      //      // List<String> commDatLs = TGlobalData().fetchCommonLoginData() ;
                      //      // print(commDatLs);
                      //    // TRemoteSrv().oneUserInfo(commDatLs[1], '3'  );
                      //    //  TRemoteSrv().allDoorLocksList();
                      //     // TRemoteSrv().allDoorLocksList();
                      //   },
                      // ),


                  ],)
                  ,),
              ),
            ),

        ],
      ),
    );
  }

  //
  // Future<RawImage> test() async {
  //
  //   final String svgStr = '';
  //   final DrawableRoot svgRoot = await svg.fromSvgString(svgStr, svgStr);
  //
  //   final Picture pic = svgRoot.toPicture() ;
  //
  //   final  Image img  = (await pic.toImage(32, 32)) as Image;
  //   //ImageProvider();
  //   return   RawImage(img, 1.0 );
  // }


  @override
  Widget build(BuildContext context) {

    return   Material(
      color: Colors.white,
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 20, 10, 2),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Row(
                 crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                // ClipRRect(
                //   borderRadius:BorderRadius.circular( 800.0),
                //   child:
                //  // Image( image: AssetImage('images/photos/beauty01.png'), width: 64,  fit: BoxFit.fill,),
                //   Image.file(File( TGlobalData().currUserPhotoUrl ), width: MediaQuery.of(context).size.width / 5.0 ,
                //     fit: BoxFit.scaleDown,),
                // ),

                  FutureBuilder<String> (
                      future: TGlobalData().checkAndFindUserPhotoUrl(),
                      builder: (ctx , ss) {
                        if(ss.connectionState == ConnectionState.done){
                          // return Text(ss.data.toString(), style: TGlobalData().tsTxtFn22Grey22,);
                          return CircleAvatar(
                            radius: 38.0,
                            backgroundImage: FileImage(File( ss.data.toString()), ),
                          );
                        }
                        return SizedBox( width:38*2, height:38*2,child: CircularProgressIndicator());
                      }),

                // CircleAvatar(
                //   radius: 38.0,
                //   backgroundImage:   FileImage(File(TGlobalData().currUserPhotoUrl)),
                // ),



                Padding(
                  padding: const EdgeInsets.fromLTRB(14.0, 0, 0, 4),
                  child: Wrap(direction: Axis.vertical,
                  spacing: 5,
                  children: [
                    Text(widget._commonDatLs[3], style: TGlobalData().tsTxtFn22Grey22Bn),
                    Text('ID：${widget._commonDatLs[1]}', style: TGlobalData().tsTxtFn18Grey88),

                  ],),
                ),

                Expanded(flex: 10,child: SizedBox(),),


                // Center(
                //
                //   child: IconButton(
                //     splashColor: Colors.transparent,
                //       onPressed: (){
                //
                //       Navigator.push(context, MaterialPageRoute(builder: (BuildContext) =>TMsgNoticeWnd()));
                //
                //   },
                //       padding: EdgeInsets.only(bottom: 40),
                //       icon: Icon(Icons.doorbell , size: 32,)),
                // ),


                  InkWell(
                    onTap: ()async{
                     await  Navigator.push(context, MaterialPageRoute(builder: (ctx) =>TMsgNoticeWnd()));
                     setState(() { });
                    },
                    child: Stack(
                      children: <Widget>[
                         // Icon(Icons.notifications ,   size: 32,),

                        SvgPicture.asset( 'images/svgs/msgIcon.svg' ,height: TDevsSizeFit.safeBlockHorizontal  * 8, fit: BoxFit.contain, ),



                     if(TGlobalData().notifyMsgCount > 0)
                          Positioned(
                          right: 0,
                          child:   Container(
                            padding: EdgeInsets.all(1),
                            decoration:   BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child:   Text(  TGlobalData().notifyMsgCount.toString(),
                              style:   TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),





              ],),


              _allLockDevObjLs.isEmpty ?
              _noLockDev()
              : _dispAllALockDev(),


         ]),
        ),
    );
  }

  Future<void> _refreshAllDoorLs()
  {

    return Future.value();
  }



  Future _delLockContextMenu(String lockDevId) async {

    final rtn = await showDialog(context: context,
        builder: (BuildContext dctx){
          return Container(
              margin: EdgeInsets.symmetric (horizontal:  MediaQuery.of(context).size.width / 11.0,
                  vertical:  MediaQuery.of(context).size.height / 4 ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular( 40.0),
              ),
              child:Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.warning, color: Colors.yellow, size: 64.0,),
                    Text('确认删除该设备？\n DeviceID: $lockDevId', style: TGlobalData().tsListTitleTS1,),

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
              )

          );
        }) ;

    if( (rtn != null )  &&   (rtn as bool) ){
     final rsl = await  TRemoteSrv().deleteOneLock(lockDevId);

     if(rsl['code']  == 0){
       TGlobalData().deleteLockByDevId(lockDevId);
       _allLockDevObjLs.clear();
        fetchDoorLocksListFromRemoteSrv();

     }

     setState(() { });

    }
    //print('Logout ......');

  }



}



class _TMainWndUser extends StatefulWidget {

  final List<String> _commonDatLs;

  _TMainWndUser(this._commonDatLs);

  @override
  _TMainWndUserState createState() => _TMainWndUserState();
}

class _TMainWndUserState extends State<_TMainWndUser> {


  String _backupPhotoUrl = '';

  // String _nickname = '' ;

 //  List<String> _commonDataLs = TGlobalData().fetchCommonLoginData();

   String _alarmPhnoeNumStr = '已开启';

  @override
  void reassemble() {
    // print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {


    super.initState();


   // _photoPathname = TGlobalData().fetchRemotPhotoUrl();
    //_nickname = TGlobalData().fetchNickname();

    // new Future.delayed(Duration(milliseconds: 1200)).then((_) {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => TLogingWnd()),
    //     //MaterialPageRoute(builder: (context) => TDevMainWnd()),
    //   );
    // });
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
    return   Scaffold(
      appBar: AppBar(title: Text(  '个人中心',
        style: TextStyle(color: Color(0xff222222), fontSize: 20, fontWeight: FontWeight.bold), ),
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),

      ),
      resizeToAvoidBottomInset: false,

      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.white,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

        Expanded(
          flex: 50,
          child: Center(
            child: Stack(
              fit: StackFit.loose,
              clipBehavior: Clip.none,
              children: [


                FutureBuilder<String> (
                  future: TGlobalData().checkAndFindUserPhotoUrl(),
                    builder: (ctx , ss) {

                    if(ss.connectionState == ConnectionState.done){
                     // return Text(ss.data.toString(), style: TGlobalData().tsTxtFn22Grey22,);

                      _backupPhotoUrl = ss.data.toString();
                     return CircleAvatar(
                        radius: 48.0,
                        backgroundImage: FileImage(File( _backupPhotoUrl), ),
                      );
                    }

                  return CircularProgressIndicator();
                }),

              // CircleAvatar(
              //   radius: 48.0,
              //   backgroundImage: FileImage(File(TGlobalData().currUserPhotoUrl), ),
              //
              // ),

              // LayoutBuilder(
              //   builder: (BuildContext ctx, BoxConstraints cts){
              //     double aa =1;// cts.maxWidth;
              //     return   Padding(
              //       padding:    EdgeInsets.fromLTRB(
              //           cts.maxWidth / 10.0 * 5.3  ,
              //           cts.maxHeight / 10.0 * 6.6,
              //           0.0,
              //           0.0
              //       ),
              //       child: InkWell(child: Icon(Icons.camera,size: cts.maxWidth / 10.0,color: TGlobalData().crMainThemeColor,),
              //       onTap: () async {
              //        // print('Change photo......');
              //         final rtn = await  Navigator.push(
              //           context,
              //           MaterialPageRoute(builder: (context) => TUserPhotoWnd(   )),
              //
              //         );
              //
              //        // if(rtn != null )
              //       }
              //       ,),
              //     );
              //   },
              //
              // ),



                Positioned(
                  right: -8,
                  bottom: -4,
                  child: Container(
                   // color: Colors.red,
                    child: InkWell(
                    //  child: Icon(Icons.camera,size: 32,color: TGlobalData().crMainThemeColor,),
                      child:   SvgPicture.asset( 'images/svgs/cameraIcon.svg' ,height: TDevsSizeFit.safeBlockHorizontal  * 8, fit: BoxFit.contain, ),

                      onTap: () async {
                        // print('Change photo......');

                        // String imgUrl = TGlobalData().currUserPhotoUrl;
                        // print(imgUrl);

                         // File imgF = File(imgUrl);
                         // if(imgF.existsSync())
                         //   // print('img exxist...............');
                         //   TRemoteSrv().uploadFileFromDio(imgF);
                         //
                         // return;

                    //  String fn = await  TGlobalData().checkAndFindUserPhotoUrl();



                        final rtn = await  Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TUserPhotoWnd(_backupPhotoUrl )),

                        );

                        setState(() { });
                      }
                      ,),
                  ),
                ),



            ],),
          ),
        ),

            //  Expanded(flex :16,child:SizedBox()),

              InkWell(
                onTap: () async {
                //   print('change nick name....');
                //
                //   String aaa= 'https://www.abc.com/test/zoe.jpg';
                //
                //  final bb =  Uri.parse(aaa);
                // print( bb.pathSegments.last );

                 //  final test = context.findAncestorStateOfType<_TMainWndState>();
                 //
                 //  print(test);
                 //
                 //   final test2 = context.f<_TMainWndHomeState>();
                 //
                 //   print(test2);
                 //
                 //
                 // return;


                  final rtn = await  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TUserChgeNickname(widget._commonDatLs[3] )),

                  );

                  if(rtn != null ) {
                   // TGlobalData().userNickname =

                    String nnn = rtn.toString();

                    final rtnObj = await TRemoteSrv().updateUsernamePhoto(nnn , null);


                    int code = rtnObj['code'];

                    if(code != 0){
                      TGlobalData().showToastInfo('修改昵称失败！');
                      return;
                    }

                    List<String> tmpCommonDatLs = TGlobalData().fetchCommonLoginData();
                    tmpCommonDatLs[3] = nnn;
                    TGlobalData().keepCommonLoginData(tmpCommonDatLs);

                    final parentWnd = context.findAncestorStateOfType<_TMainWndState>();
                    if(parentWnd != null)
                      setState(() {
                        parentWnd.reloadCommonDataLs();
                      });

                  }

                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0x22000000),width: 1.0),
                    )
                  ),
                  child:
                  Row(
                    children: [

                      Text('昵 称', style: TGlobalData().tsListTitleTS1,),
                      Expanded(flex: 10,child: SizedBox()),
                      Text(widget._commonDatLs[3], style: TGlobalData().tsListCntTS1,),
                      Icon(Icons.navigate_next,  size: 30,color: Color(0xffbbbbbb),),

                    ],
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0x22000000),width: 1.0),
                    )
                ),
                child:  Row(

                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text('ID', style: TGlobalData().tsListTitleTS1,),
                    Text(widget._commonDatLs[1], style: TGlobalData().tsListCntTS1,),

                  ],
                ),
              ),


              Container(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0x22000000),width: 1.0),
                    )
                ),
                child:  Row(

                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text('手机号', style: TGlobalData().tsListTitleTS1,),
                    Text(widget._commonDatLs[0], style: TGlobalData().tsListCntTS1,),

                  ],
                ),
              ),



              InkWell(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0x22000000),width: 1.0),
                      )
                  ),
                  child:  Row(

                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text('报警手机', style: TGlobalData().tsListTitleTS1,),

                      Expanded(flex: 10,child: SizedBox()),
                      Text(_alarmPhnoeNumStr, style: TGlobalData().tsListCntTS1,),
                      Icon(Icons.navigate_next,  size: 30,color: Color(0xffbbbbbb),),

                    ],
                  ),
                ),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (ctx)=>TAlarmSettingWnd(wndTabIdx: 2,)));

                },
              ),




              Container(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0x22000000),width: 1.0),
                    )
                ),
                child:  TextButton(
                  onPressed: () async {

                    final rtn = await showDialog(context: context,
                        builder: (BuildContext dctx){
                          return Container(
                              margin: EdgeInsets.symmetric (horizontal:  MediaQuery.of(context).size.width / 11.0,
                                  vertical:  MediaQuery.of(context).size.height / 4 ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular( 40.0),
                              ),
                              child:Center(
                                child: Column(
                                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(Icons.warning, color: Colors.yellow, size: 64.0,),
                                    Text('即将登出当前用户，是否继续？', style: TGlobalData().tsListTitleTS1,),

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
                              )

                          );
                        }) ;

                    if( (rtn != null )  &&   (rtn as bool) ){
                      TGlobalData().keepCurrUserToken('');
                      TGlobalData().keepCurrUserAcceToken('');
                      Phoenix.rebirth(context);
                    }
                    //print('Logout ......');

                  },
                  child: Text('退出登录', style: TextStyle(color: Color(0x99ff0000), fontSize: 20),),
                ),
                ),

            //  Expanded(flex: 20,child: SizedBox()),



             // Text(data)
            ]),
      ),
    );
  }



}




class THomeIcon extends CustomPainter{
  late Paint _myPaint;

  int _currIdx  ;

  THomeIcon(  this._currIdx ) {
    _myPaint = Paint()
      ..color = _currIdx == 0 ?  Color(0xff666666) : Color(0xffdddddd)
      ..strokeWidth = 2.0
      ..style =PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint

    //canvas.drawCircle(Offset(size.width /2, size.height / 2), size.width / 2  , _myPaint);
    // canvas.drawRect(Offset(0.0, 0.0) & size , _myPaint);

   // double vertiaclOffset = size.height /8.0;

    double padding = 3.0;

    _myPaint.color = _currIdx == 0 ?  Color(0xff666666) : Color(0xffdddddd);

    var path = Path();
    path.moveTo(size.width / 2 , 0 );
    path.lineTo(0 + padding, size.height / 4);
    path.lineTo(0+ padding, size.height - padding  );
    path.lineTo(size.width - padding, size.height -padding  );
    path.lineTo(size.width - padding, size.height  / 4  );
   // path.moveTo(size.width / 2 , 0 );
    canvas.drawPath(path,    _myPaint);

    _myPaint.color = _currIdx == 0 ?  Color(0xff22cccc) : Color(0xffcccccc);


    double doorW = size.width / 5;

    canvas.drawRect(Offset(size.width / 2 - doorW / 2, size.height /2 ) & Size(doorW, size.height / 3 + padding) , _myPaint);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    // throw UnimplementedError();
    return false;
  }

}


class TUserIcon extends CustomPainter{
  late Paint _myPaint;

  int _currIdx  ;

  TUserIcon(  this._currIdx ) {
    _myPaint = Paint()
      ..color = _currIdx == 1 ?  Color(0xff666666) : Color(0xffdddddd)
      ..strokeWidth = 2.0
      ..style =PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint

    canvas.drawCircle(Offset(size.width /2, size.height / 4), size.width / 10.0 * 4.0  , _myPaint);
     canvas.drawRect(Offset(0.0, size.height / 10.0 * 7.5) & Size(size.width  , size.height / 8.0) , _myPaint);

    // double vertiaclOffset = size.height /8.0;
    //
    // print(' idx = $_currIdx');
    //
    // var path = Path();
    // path.moveTo(size.width / 6 , size.height / 4 + vertiaclOffset );
    // path.lineTo(size.width / 2, size.height / 5 * 3+ vertiaclOffset);
    // path.lineTo(size.width - size.width / 6, size.height / 4 + vertiaclOffset );
    // canvas.drawPath(path,    _myPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    // throw UnimplementedError();
    return false;
  }

}




class TLineCorner extends CustomPainter{
  late Paint _myPaint;



  TLineCorner(   ) {
    _myPaint = Paint()
      ..color =   Color(0xffaaaaaa)
      ..strokeWidth = 2.0
      ..style =PaintingStyle.stroke;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint

    // canvas.drawCircle(Offset(size.width /2, size.height / 4), size.width / 10.0 * 4.0  , _myPaint);
    // canvas.drawRect(Offset(0.0, size.height / 10.0 * 7.5) & Size(size.width  , size.height / 8.0) , _myPaint);

    // double vertiaclOffset = size.height /8.0;
    //
    var path = Path();
    path.moveTo(size.width / 2 ,0 );
    path.lineTo(size.width / 2, size.height / 2);
    path.lineTo(size.width  , size.height / 2 );
    canvas.drawPath(path,    _myPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    // throw UnimplementedError();
    return false;
  }

}








