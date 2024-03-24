import 'dart:async';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_blue/flutter_blue.dart';


import '../TGlobal_inc.dart';
import '../TBleSingleton.dart';
import 'TConnetLockWnd.dart';


class TScanLockWnd extends StatefulWidget {


  @override
  _TScanLockWndState createState() => _TScanLockWndState();
}


class _TScanLockWndState extends State<TScanLockWnd> {

  final StreamController<BluetoothDevice> _bleSC =  StreamController.broadcast();
  final Map<String,List<String> > _devIdToMacMap = {};

  bool _canGo = false;

  Future<TBleScanStatus> ?  _bleScanStatus ;

  bool _enScanBtn = true;

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

    TBleSingleton().doResetBle();

    super.dispose();
  }


  void  _showScanBleRslWnnd() async {

    List<dynamic> _bleDevObjLs = [];

    List<String> bleDevIdLs = [];

    final rtn = await showDialog(
        context: context,
        builder:(BuildContext dctx) {
           return StatefulBuilder(builder: (dctx, StateSetter setState){

             return GestureDetector(
               behavior: HitTestBehavior.opaque,
               onTap: (){Navigator.pop(dctx);},
               child: Material(
                 color: Colors.transparent,
                 child: Padding(
                   padding:   EdgeInsets.only(top: MediaQuery.of(context).size.height / 2.0 * .9),
                   child: ClipRRect(
                     borderRadius: BorderRadius.vertical(top: Radius.circular(40.0)),
                     child: GestureDetector(
                       behavior: HitTestBehavior.opaque,
                       onTap: (){    },
                       child: Container(
                       //  margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2.0),
                         padding: EdgeInsets.fromLTRB(40, 16, 40, 10),
                         color: Colors.white,
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.start,
                           crossAxisAlignment: CrossAxisAlignment.stretch,
                           children: [

                             Center(child: Text('已查找到' , style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),)),
                             Center(child: Text('请选择要添加的设备' , style: TextStyle(fontSize: 16  , color: Color(0xffaaaaaa)),)),

                             SizedBox(height: 16,),

                             Expanded(
                               child: Center(
                                 child:
                                 StreamBuilder<BluetoothDevice> (
                                   stream: _bleSC.stream,
                                   builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                     if(snapshot.hasData){

                                       BluetoothDevice tmpBle = snapshot.data;
                                     //  print(' snapshot.data  new ble arrived..............................');


                                       if(!bleDevIdLs.contains(tmpBle.id.toString())){
                                         bleDevIdLs.add(tmpBle.id.toString());
                                         Map tmpObj = {};
                                         tmpObj['dev'] = snapshot.data;
                                         tmpObj['ischecked'] = false;

                                         _bleDevObjLs.add(tmpObj);
                                       }

                                        return  ListView.separated(
                                       itemCount: _bleDevObjLs.length,
                                       itemBuilder: (BuildContext ictx , int idx){
                                         BluetoothDevice ble =  _bleDevObjLs[idx]['dev'] as BluetoothDevice ;
String bleLocalName = _devIdToMacMap[ble.id.toString()]![0];
                                         return ListTile(
                                           title:   Text( bleLocalName  , style: TextStyle(fontSize: 18,
                                             color: _bleDevObjLs[idx]['ischecked']  ? TGlobalData().crMainThemeColor : Colors.black,
                                           ), ),
                                           trailing:  _bleDevObjLs[idx]['ischecked']  ?
                                           Icon(Icons.check  , color: TGlobalData().crMainThemeColor,)
                                               : null,
                                           onTap: (){
                                             // print('this is idx $idx');

                                             for(int i = 0 ; i < _bleDevObjLs.length ; i ++ ){
                                               _bleDevObjLs[i]['ischecked'] = false;
                                             }

                                             setState(() {
                                               _bleDevObjLs[idx]['ischecked'] = true;
                                               _canGo = true;
                                             });


                                           },
                                         );

                                       },
                                       separatorBuilder: (BuildContext sctx, int idx){
                                         return Container(height: 1,color: Color(0x11000000),);
                                       },
                                     );
                                   }else{
                                      return CircularProgressIndicator();
                                  }
                                  },

                                  ),
                               ),
                             ),



                             Padding(
                               padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                               child: ElevatedButton(

                                 onPressed:  _canGo ?       (){

                                //   String bleUuid = '';
                                   BluetoothDevice ? tmpBle ;

                                   for(int i = 0 ; i < _bleDevObjLs.length ; i ++ ){
                                     if(_bleDevObjLs[i]['ischecked']){
                                       //bleUuid =  _bleDevObjLs[i]['uuid'];
                                       tmpBle = _bleDevObjLs[i]['dev'] as BluetoothDevice;
                                       break;
                                     }
                                   }




                                   if(tmpBle != null){
                                    List< String > bleSrStrLs = _devIdToMacMap[tmpBle.id.toString()]!;
                                     Future.delayed(Duration(milliseconds: 100)).then((value) {
                                       Navigator.push(context, MaterialPageRoute(
                                           settings: RouteSettings(name: '/tconnlockwnd', arguments: Map()),
                                           builder: (context) => TConnetLockWnd(tmpBle!.id.toString() , bleSrStrLs[1])));
                                     });
                                   }

                                  // _isBleFound = null;


                                   Navigator.pop(dctx);
                                 } : null,
                                 child: Text('下 一 步' , style: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
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
                       ),
                     ),
                   ),
                 ),
               ),
             );},
           );
        });


    if(rtn == null){
      TBleSingleton().doResetBle();
      setState(() {
        _enScanBtn = true;
      });
    }

  }

  StreamSubscription<ScanResult> ?   bleScanSubScri ;
/*
 // Thor , Old Stm32 Version
  Future<TBleScanStatus> _scanUninitLock()   {

   // late
    final fluBt = FlutterBlue.instance;
    final rslC = Completer<TBleScanStatus>();


    List<String> alreadyCheckedDevIdLs = [];

   // final svrUuid = Guid('0000aeac-0000-1000-8000-00805f9b34fb');
   // final devId = Guid('2374D50A-C5B2-38B4-3639-73063AC9B35F');
   // print('Start ble scan.....');

    fluBt.stopScan();

    bleScanSubScri =
   fluBt.scan(
     //  withServices: [svrUuid],
    // withDevices: [devId],
       timeout: Duration(seconds: 10)).listen((sr) async  {

   //  print('===================================================');
    // print('${sr.device.name}');
    // print(sr.device.id);

     if (sr.device.type == BluetoothDeviceType.le   ){
     //  print('thor got ble........................');
      print(sr.device.name);
    //  print(sr.device.id);

       for( String srUuid in sr.advertisementData.serviceUuids)    {

         print('svrUUid: $srUuid');
       //  print('advertisementData.serviceData : ');
       // print( sr.advertisementData.serviceData);
       //  print( sr.advertisementData.manufacturerData);
       //  print( hex.encode( sr.advertisementData.manufacturerData.values.first) );

         if( !( srUuid.toUpperCase().contains('AEAC')
             ||  srUuid.toUpperCase().contains('FFE0') )
            || alreadyCheckedDevIdLs.contains(sr.device.id.toString())
           )  continue;

         List<int> macBa = sr.advertisementData.manufacturerData.values.first;

        // print(macBa);
         bool isInitialized = macBa[6] > 0;

            print('..............Awe smart lock Ble dev found..${sr.advertisementData.localName}');

         print(sr.device.id.toString());

           alreadyCheckedDevIdLs.add(sr.device.id.toString());
           bool isConnected = false;
           StreamSubscription<BluetoothDeviceState> statSub = sr.device.state.listen((s) {
             isConnected = s == BluetoothDeviceState.connected;
           });

           await sr.device.connect(timeout: Duration(seconds: 5),autoConnect: false);

           await Future.delayed(Duration(milliseconds: 100)) ;

          if( isConnected ){
           print('ble connected **************************************sss.');
            List<BluetoothService> srvsLs =  await sr.device.discoverServices();
            for( BluetoothService srv in srvsLs ){
              String srvuuid  = srv.uuid.toString() ;
              String uuidP1 = srvuuid.substring(0, srvuuid.indexOf('-'));

              if(! uuidP1.toUpperCase().contains('AEAC'))  continue;
              for( BluetoothCharacteristic chara in srv.characteristics){
                String charaP1 = chara.uuid.toString();
                charaP1 = charaP1.substring(0, charaP1.indexOf('-'));

                if(!charaP1.toUpperCase().contains('FFE1')) continue;

                 print(' - ----------------------- char uuid: ${chara.uuid.toString()}');
                if(!chara.isNotifying  ) {
                  try {
                    await chara.setNotifyValue(true);
                  }on PlatformException catch(err){
                    print('thor: chara  *************  ${err.toString()}');
                    continue;
                  }catch(err){
                    print('thor: chara  *************  ${err.toString()}');
                    continue;
                  }
                }

                bool isInit = true;
                StreamSubscription< List<int> > tmpSub = chara.value.listen((inBa)     {

                  print('thor11 inBa: len: ${inBa.length} : dat:  ${hex.encode(inBa)}');

                  if(inBa.length > 10) {
                    String jsonStr =TBleSingleton(). decodeFramedData(inBa);
                    var jobj =  json.decode(jsonStr);
                    if(jobj['ok'].toString() == '1') {
                    //  print('already inited.......');
                    } else {

                    //  print('Not inited.......');
                      isInit = false;

                    }
                  }

                });

                try {
                  await chara.write([0,0,2]);
                }on PlatformException catch(err){
                  print('thor22: ****  ${err.toString()}');
                }catch(err){
                  print('thor22: ****  ${err.toString()}');
                }

                await Future.delayed(Duration(seconds: 1)) ;  // wait lock return data....

                if(!isInit){
                  if(!rslC.isCompleted) {
                    rslC.complete(TBleScanStatus.Found);
                    await Future.delayed(Duration(milliseconds: 500));
                  }

                  _bleSC.add(sr.device);
                }

                tmpSub.cancel();


                }
               }

          }


           statSub.cancel();
          await sr.device.disconnect();

       }

     }
   },
   onDone: () async {
     print('ble scan done.....');

     await bleScanSubScri?.cancel();
     bleScanSubScri = null;
    await fluBt.stopScan();
    List<BluetoothDevice> devLs = await fluBt.connectedDevices;
     devLs.forEach((dev) async => await dev.disconnect());
     if(!rslC.isCompleted)
       rslC.complete(TBleScanStatus.Done);
   },
     onError: (err) async {
     print('ble error: ' + err.toString());
     await bleScanSubScri?.cancel();
     bleScanSubScri = null;
     await fluBt.stopScan();
     if(!rslC.isCompleted)
       rslC.complete(TBleScanStatus.Done);
     }
   );

    return rslC.future ;

  }

 */

  // New nRf52840 Version
  Future<TBleScanStatus> _scanUninitLock()   {

    // late
    final fluBt = FlutterBlue.instance;
    final rslC = Completer<TBleScanStatus>();


    List<String> alreadyCheckedDevIdLs = [];

    // final svrUuid = Guid('0000aeac-0000-1000-8000-00805f9b34fb');
    // final devId = Guid('2374D50A-C5B2-38B4-3639-73063AC9B35F');
    // print('Start ble scan.....');

    fluBt.stopScan();

    bleScanSubScri =
        fluBt.scan(
          //  withServices: [svrUuid],
          // withDevices: [devId],
            timeout: Duration(seconds: 10)).listen((sr) async  {

           //  print('===================================================');
           // print('${sr.device.name}');
           // print(sr.advertisementData.manufacturerData.toString());
          // print(sr.device.id);

          List<int> ? companyDatLs = sr.advertisementData.manufacturerData[TGlobalData().companyFlagVal];

          if (sr.device.type == BluetoothDeviceType.le  && companyDatLs != null
              && companyDatLs.length == 8 && companyDatLs[6] == 0xAC
              && !alreadyCheckedDevIdLs.contains(sr.device.id.toString())
          ){

            for( String srUuid in sr.advertisementData.serviceUuids)    {

             // print('svrUUid: $srUuid');
              //  print('advertisementData.serviceData : ');
              // print( sr.advertisementData.serviceData);
              //  print( sr.advertisementData.manufacturerData);
              //  print( hex.encode( sr.advertisementData.manufacturerData.values.first) );

              // if( !( srUuid.toUpperCase().contains('AEAC')
              //     ||  srUuid.toUpperCase().contains('FFE0') )
              //     || alreadyCheckedDevIdLs.contains(sr.device.id.toString())
              // )  continue;

              List<int> macBa = companyDatLs.sublist(0,6);

              print( hex.encode( macBa) );

              bool isInitialized = (companyDatLs[7] & 0x01) > 0;
              bool needReadEvt = (companyDatLs[7] & 0x02) > 0;

             //  print('..............Awe smart lock Ble dev found..${sr.advertisementData.localName} , name ${sr.device.name}');

            //  print(sr.device.id.toString());

              alreadyCheckedDevIdLs.add(sr.device.id.toString());

              if(!isInitialized){
                if(!rslC.isCompleted) {
                  rslC.complete(TBleScanStatus.Found);
                  await Future.delayed(Duration(milliseconds: 500));
                }

                _bleSC.add(sr.device);
                _devIdToMacMap[sr.device.id.toString()] = [ sr.advertisementData.localName,   hex.encode(macBa)];

              }

            }

          }
        },
            onDone: () async {
              print('ble scan done.....');

              await bleScanSubScri?.cancel();
              bleScanSubScri = null;
              await fluBt.stopScan();
              List<BluetoothDevice> devLs = await fluBt.connectedDevices;
              devLs.forEach((dev) async => await dev.disconnect());
              if(!rslC.isCompleted)
                rslC.complete(TBleScanStatus.Done);
            },
            onError: (err) async {
              print('ble error: ' + err.toString());
              await bleScanSubScri?.cancel();
              bleScanSubScri = null;
              await fluBt.stopScan();
              if(!rslC.isCompleted)
                rslC.complete(TBleScanStatus.Done);
            }
        );

    return rslC.future ;

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        iconTheme: IconThemeData(color:   Colors.black) ,
        title: Text('添加设备', style: TextStyle(color: Colors.black ,fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body:   Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('打开手机蓝牙', style: TextStyle(color: Colors.black ,fontSize: 20, fontWeight: FontWeight.normal)),
              ),
            ),

            Container(
              padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
              margin: EdgeInsets.fromLTRB(40, 10, 40, 20),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xffbbbbbb)),
                borderRadius: BorderRadius.circular(32.0),

              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children : [

                  Image.asset('images/pngs/pairLock.png' ,
                  height: MediaQuery.of(context).size.height / 5.0 * 1.8,
                  fit: BoxFit.scaleDown,),

              Center( child:
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text('请将手机靠近门锁，打开锁\n具电池盖，安装好电池后长\n按“设置”键 3 秒进行配对。',
                style: TextStyle(fontSize: 16.0, color: Color(0xff444444)),),
              )),

             ]
              ),
            ),

            //  /?ct=common&ac=send_code

            FutureBuilder<TBleScanStatus>(
                future: _bleScanStatus,
                builder: (  fctx , ss){

                  if(ss.connectionState == ConnectionState.done){

                    if(ss.data ==  TBleScanStatus.Found){
                     // _showScanBleRslWnnd();
                     // return SizedBox.shrink();

                      Future.delayed(Duration(milliseconds: 0)).then((value) {
                        _showScanBleRslWnnd();
                      });

                    }  else  if(ss.data ==  TBleScanStatus.Done){

                      Future.delayed(Duration(milliseconds: 0)).then((value) {
                        Fluttertoast.showToast(
                          msg: "扫描10秒后未发现未注册的设备....",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: TGlobalData().crToastBgColor,
                          textColor: Colors.white,
                          fontSize: 18.0,
                        );

                        setState(() {
                          _enScanBtn = true;
                        });
                      });
                     // return SizedBox(height: 10,width: 40,);
                    }
                    _bleScanStatus = null;
                  }else if(ss.connectionState == ConnectionState.waiting){

                    Future.delayed(Duration(milliseconds: 50)).then((value) {
                      setState(() {
                        _enScanBtn = false;
                      });
                    });

                    return Center(child: SizedBox(child: CircularProgressIndicator(),height: 40,width: 40,));

                  }

                  return SizedBox(height: 40,width: 40,);

                }),


            Padding(
              padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
              child: ElevatedButton(

                child: Text('查找设备' , style: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
                style: ElevatedButton.styleFrom(
                  primary: TGlobalData().crMainThemeColor,
                  onPrimary: TGlobalData().crMainThemeOnColor,
                  shadowColor: Colors.white,
                  padding: EdgeInsets.all(10.0),
                  shape: StadiumBorder(),
                ),
                onPressed:  _enScanBtn ? (){

                  if(!TBleSingleton().isBtReady){
                    Fluttertoast.showToast(
                      msg: "蓝牙未打开... .",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.CENTER,
                      backgroundColor: TGlobalData().crToastBgColor,
                      textColor: Colors.white,
                      fontSize: 18.0,
                    );
                    return;
                  }

                  TBleSingleton().keepDfk = '';
                  TBleSingleton().Userid = 0;
                 setState(() {
                  _bleScanStatus =  _scanUninitLock();
                });


                 // TBleSingleton().findAndConnBleById('2374D50A-C5B2-38B4-3639-73063AC9B35F');

                // Future.delayed(Duration(seconds: 3)).then((value) {
                //   setState(() {
                   // _isBleFound = Future.value(true);
                //   });
                // });



                // Navigator.push(context, MaterialPageRoute(builder: (context) => TScanLockWnd()));

                //   Navigator.pushReplacement(
                //     context,
                //     MaterialPageRoute(builder: (context) => TLogingWnd()),
                //     //MaterialPageRoute(builder: (context) => TDevMainWnd()),
                //   );
              }  : null  ,
              ),
            ),



          ],
        ),
      ),
    );

  }
}
