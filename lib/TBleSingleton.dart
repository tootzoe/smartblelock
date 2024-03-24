import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:dart_des/des_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:ffi/ffi.dart';

import 'package:flutter_blue/flutter_blue.dart';

import 'package:dart_des/dart_des.dart';

import 'TGlobal_inc.dart';



enum TBleScanStatus { Idle,  Scanning, Found,  Done }


//
// class BluetoothDevice {
//   final String name;
//   final String address;
//   final bool paired;
//   final bool nearby;
//
//   const BluetoothDevice(this.name, this.address, {this.nearby = false, this.paired = false});
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) || other is BluetoothDevice && runtimeType == other.runtimeType && name == other.name && address == other.address;
//
//   @override
//   int get hashCode => name.hashCode ^ address.hashCode;
//
//   Map<String, dynamic> toMap() {
//     return {'name': name, 'address': address};
//   }
//
//   @override
//   String toString() {
//     return 'BluetoothDevice{name: $name, address: $address, paired: $paired, nearby: $nearby}';
//   }
// }

class TBleSingleton {
  static final _singleton = TBleSingleton._();

  factory TBleSingleton() => _singleton;

  final DynamicLibrary nativeCppLib = Platform.isAndroid
      ? DynamicLibrary.open("libaweencrypt.so")
      : DynamicLibrary.process();
 // final DynamicLibrary nativeCppLib = DynamicLibrary.process();

 // int Function(int x, int y)?  _cppAdd ;

   late int Function(Pointer<Uint8> inBa,   int inLen, Pointer<Uint8> outBa)   _getTrueKey ;

   late int Function(Pointer<Uint8> outBa) _fetchAppBuildDt;

  void initData(){
       // _cppAdd = nativeCppLib.
       // lookup<NativeFunction<Int32 Function(Int32,Int32)>>("native_add2").asFunction();

       _getTrueKey = nativeCppLib.
       lookup<NativeFunction<Int32 Function(Pointer<Uint8>,Int32, Pointer<Uint8>)>>("decryptKeyForDart").asFunction();

       if(! Platform.isAndroid )
       _fetchAppBuildDt = nativeCppLib.lookup<NativeFunction< Int32 Function(Pointer<Uint8> ) > >('appBuildDt').asFunction();

  }

  final StreamController<BluetoothDevice> _controller =  StreamController.broadcast();

 // final StreamController<String> _evtNotifierCtllor = StreamController.broadcast();

  List< StreamController<List<int>> > thizStreamCtllorLs = [];


  int _selfIncresNum = 1;

  // String svrUuid = "0000aeac-0000-1000-8000-00805f9b34fb";
  // String charUuid = "0000ffe1-0000-1000-8000-00805f9b34fb";
  // String peerBleName = "";


  String _dfk =  '';//  '9474b8e8c73bca7d12bc3d917c29a1f684d99e2ac0f18d57';

  FlutterBlue fluBle = FlutterBlue.instance;
  StreamSubscription<ScanResult> ?  bleScanSubScri;
  Map<String , BluetoothDevice> foundBleDevMap = {};

  List<BluetoothDevice> _foundBleLs = [];

  Map<String , BluetoothCharacteristic> bleCharaMap = {};



  Stream<BluetoothDevice> get devices => _controller.stream;
  //Stream<String> get thorBleEvt => _evtNotifierCtllor.stream;

  BluetoothDevice ? _targetBleDev  ;
  List<BluetoothCharacteristic > _workingCharaLs = []  ;
  StreamSubscription< List<int> > ? _targetCharaSub  ;

  //set keepBleDev(BluetoothDevice d){;}
  final StreamController<String> _jsonStrCtrllor = StreamController.broadcast();
  Stream<String> get jsonStream => _jsonStrCtrllor.stream;

  set keepDfk(String k) => _dfk = k;
  // ignore: unnecessary_getters_setters
  String get keepDfk => _dfk;

  int userid= 0;
  set Userid(int uid) => userid = uid;
  int get Userid => userid;

  // set keepSvrUuid(String id) {
  //   svrUuid = id;
  // }
  //
  // set keepChrUuid(String id) {
  //   charUuid = id;
  // }
  //
  // set keepPeerBleName(String n) {
  //   peerBleName = n;
  // }
  //
  // String get fetPeerBleName => peerBleName;

  // List<int> _testBaLs = [] ;
  //
  //  List<int>  get getTestBaLs  => _testBaLs;

  String get currBleDevId => _targetBleDev == null ? '' : _targetBleDev!.id.toString();

  BluetoothState _btState = BluetoothState.unknown;

  TBleSingleton._() {
    // _channel.setMethodCallHandler((methodCall) {
    //   switch (methodCall.method) {
    //     case 'action_new_device':
    //       _newDevice(methodCall.arguments);
    //       break;
    //     case 'action_scan_stopped':
    //       _scanStopped.add(true);
    //       break;
    //   }
    // });
    //
    fluBle.state.listen((btState) {
      print('...............................curr bt stats: $btState');
      _btState = btState;
    });

    //
    // fluBle.isScanning.listen((event) {
    //   print('curr Ble is Scaning.................................: $event');
    // });

    // fluBle.scanResults.listen((resultLs) {
    //   resultLs.forEach((r) {
    //     print('.......scan result.....................${r.device.name}');
    //   });
    // });



  }

    bool get isBtReady => _btState == BluetoothState.on;

  // Future<void> startScan({pairedDevices = false}) async {
  //   final bondedDevices = await _channel.invokeMethod('action_start_scan', pairedDevices);
  //   for (var device in bondedDevices) {
  //     final d = BluetoothDevice(device['name'], device['address'], paired: true);
  //     _pairedDevices.add(d);
  //     _controller.add(d);
  //   }
  // }

  // Future<void> stopScan({pairedDevices = false}) async {
  //  await fluBle.stopScan();
  // }


    Future<TBleScanStatus> startScan({pairedDevices = false}) async {

   // fluBle.startScan(timeout: Duration(seconds: 10));

      final rslC = Completer<TBleScanStatus>();

      _foundBleLs.clear();

    bleScanSubScri = fluBle.scan(timeout: Duration(seconds: 6)).listen((sr)   {
      // print('name: ${sr.device.name}');
      // print('UUID: ${sr.device.id.toString()}');
      // print('1: ${sr.advertisementData.localName}');
       //print('2: ${sr.advertisementData.manufacturerData}');
      // print('3: ${sr.advertisementData.serviceData}');
      // print('4: ${sr.advertisementData.serviceUuids}');



      if (sr.device.type == BluetoothDeviceType.le   ) {

      //  for(String srUuid in sr.advertisementData.serviceUuids)

        sr.advertisementData.serviceUuids.forEach((srUuid) async {
          if( srUuid.toUpperCase().contains('AEAC')
               ||  srUuid.toUpperCase().contains('FFE0')
            ) {


              print('..............Awe smart lock Ble dev found..${sr.advertisementData.localName}');

            bool isInit =  await _checkLockIsInitialized(sr.device);

          if(!isInit){

            _foundBleLs.add(sr.device);


            if(!rslC.isCompleted) {
              rslC.complete(TBleScanStatus.Found);
              await Future.delayed(Duration(milliseconds: 500));
            }


            _controller.add(sr.device);

          }


             // foundBleDevMap.putIfAbsent(   sr.device.name    , () => sr.device);
              // foundBleDevMap.putIfAbsent(  'SmartLockBle'   , () => sr.device);



            }
        });

      }

      // rslC.complete(TBleScanStatus.Scanning);

    }, onDone: ()
    {
      print('scan ble done...............');  // thor, seems never run here
      stopScan();

     // Future.delayed(Duration(milliseconds: 0)).then((value) => _checkLockIsInitialized());

      if(!rslC.isCompleted)
          rslC.complete(TBleScanStatus.Done);
    });

    return rslC.future ;

  }

  // void directConnByDevId()
  // {
  //   BluetoothDevice dev ;
  // }


  Future<String> scanForLocalHwId (String fixIdFromMac) async
  {
    String localHwId = '';

    int awesomeManufTag  = 0xAEAC;

    print('fixIdFromMac : $fixIdFromMac');

    final rslC = Completer<void>();

    bleScanSubScri = fluBle.scan(timeout: Duration(seconds: 6)).listen((sr)   {
      // print('name: ${sr.device.name}');
      // print('UUID: ${sr.device.id.toString()}');
      // print('1: ${sr.advertisementData.localName}');
     // print('2: ${sr.advertisementData.manufacturerData}');
      // print('3: ${sr.advertisementData.serviceData}');
      // print('4: ${sr.advertisementData.serviceUuids}');


      if (sr.device.type == BluetoothDeviceType.le   ) {

        //print('2: ${sr.advertisementData.manufacturerData}');

        final manufData = sr.advertisementData.manufacturerData;

        if(manufData.containsKey(awesomeManufTag)){
          print('Found.............');
           print(manufData[awesomeManufTag]);

          // print('local hw id: ${sr.device.id}');

          localHwId = sr.device.id.toString();


          if(!rslC.isCompleted)
            rslC.complete();

        }

      }

    }, onDone: ()
    {
      print('...refresh scan ble done...............');  // thor, seems never run here

      if(!rslC.isCompleted)
          rslC.complete();

    });

    await rslC.future;
      stopScan();

    print('rtn : $localHwId');
    return Future.value(localHwId);

  }





  Future<bool> _checkLockIsInitialized (BluetoothDevice dev) async
  {
     print('\n\n\n for each dev.....\n\n\n');

    bool isInit = true;

   // _foundBleLs.forEach((dev) async {
      // print(dev.id);

   //   await dev.connect(timeout:Duration(seconds: 4),autoConnect: false).then((_) async
          await dev.connect(timeout:Duration(seconds: 4),autoConnect: false);
     // {
        List<BluetoothService> srvsLs = await dev.discoverServices();

        for( BluetoothService srv in srvsLs )  {

          String srvuuid  = srv.uuid.toString() ;

           print('\n\n srv P1 : ${srvuuid.substring(0, srvuuid.indexOf('-'))}\n\n \n');

          String uuidP1 = srvuuid.substring(0, srvuuid.indexOf('-'));

          if(uuidP1.toUpperCase().contains('AEAC')){

             for( BluetoothCharacteristic chara in srv.characteristics){

               String charaP1 = chara.uuid.toString();
               charaP1 = charaP1.substring(0, charaP1.indexOf('-'));

               if(!charaP1.toUpperCase().contains('FFE1')) continue;

           //  print(chara.isNotifying) ;
              // print(' -  ---- char uuid: ${chara.uuid.toString()}');

             if(!chara.isNotifying  ) {
               try {
                 await chara.setNotifyValue(true);
               }on PlatformException catch(err){
                 print('thor: chara  *************  ${err.toString()}');
               }catch(err){
                 print('thor: chara  *************  ${err.toString()}');
               }
             }


              StreamSubscription< List<int> > tmpSub = chara.value.listen((inBa) {

                 print('thor11 inBa: len: ${inBa.length} : dat:  ${hex.encode(inBa)}');

                 if(inBa.length > 10) {
                   String jsonStr = decodeFramedData(inBa);
                 var jobj =  json.decode(jsonStr);
                   if(jobj['ok'].toString() == '1') {
                     print('already inited.......');
                   } else {
                     print('Not inited.......');
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

               print('after wait 1 second.........');

               tmpSub.cancel();


               break;
            }

          }

        }


    //  }

     // ); // then

     await  dev.disconnect();
     return Future.value(isInit);

  //  });
  }

  Future<void> disconnAllDevs() async
  {
    List<BluetoothDevice> devLs = await fluBle.connectedDevices;
    devLs.forEach((dev) async => await dev.disconnect());
  }

  Future<TBleScanStatus> findAndConnBleById(String devId) async
  {
    var rtnCpt = Completer<TBleScanStatus>();

    //await  fluBle.stopScan();
   // await disconnAllDevs();

   //   final devIdG = Guid('2374D50A-C5B2-38B4-3639-73063AC9B35F');
   // final devIdhaveFp = Guid('F80D1263-D057-CE65-034B-D0EB4EE7A1DA');


     // print('start ble startScan.......');

     BluetoothDevice ? foundBle;
      fluBle.scan(timeout: Duration(seconds: 5)).listen((sr) {
     //   print(sr.device.id.toString());
        if(sr.device.id.toString() == devId){
           foundBle = sr.device;
       //   print('  ble found.......');
          fluBle.stopScan();
          // if(!rtnCpt.isCompleted)
          //   rtnCpt.complete(TBleScanStatus.Found);
        }
      },onDone: () async{
        print('scan done.....');

        if(foundBle == null){
          if(!rtnCpt.isCompleted)
            rtnCpt.complete(TBleScanStatus.Done);

          print('ble Not found......');
        }else{
          _targetBleDev = foundBle;
          List<BluetoothCharacteristic>  targetCharaLs  = await findRWCharaByDev(_targetBleDev!);
          if(targetCharaLs.length == 2){
            print('Two chara found......***************** ');
            //_targetChara = targetChara;

            for(int ii = 0 ; ii < targetCharaLs.length ; ii ++)
              if(targetCharaLs[ii].isNotifying) {
                _targetCharaSub = targetCharaLs[ii].value.listen((dat) =>
                    _handleTagetCharaArrivedData(dat));
                break;
              }

            _workingCharaLs.clear();
            _workingCharaLs.addAll(targetCharaLs);

            if(!rtnCpt.isCompleted)
              rtnCpt.complete(TBleScanStatus.Found);
          }

       // await  foundBle!.disconnect();
        }


      });


    return rtnCpt.future;
  }

  Future< List<BluetoothCharacteristic>  >  findRWCharaByDev(BluetoothDevice dev) async
  {

    List<BluetoothCharacteristic> rtnLs = [];

    bool isConnected = false;
    StreamSubscription<BluetoothDeviceState> statSub = dev.state.listen((s) {
      isConnected = s == BluetoothDeviceState.connected;
    });

    await dev.connect(timeout: Duration(seconds: 5),autoConnect: false);


    int cc = 0;
    while(!isConnected){
      await Future.delayed(Duration(milliseconds: 1)) ;
       if( cc ++ > 100)
         break;
    }

    if( isConnected ){
      print('ble connected..........');
      List<BluetoothService> srvsLs =  await dev.discoverServices();
      print('srvsLs len: ${srvsLs.length}');
      for( BluetoothService srv in srvsLs ){
        String srvuuid  = srv.uuid.toString() ;
        String uuidP1 = srvuuid.substring(0, srvuuid.indexOf('-'));

     //   print('uuidP1 : $uuidP1');

        if(! uuidP1.toUpperCase().contains('AEAC')) {   continue;}
        for( BluetoothCharacteristic chara in srv.characteristics){
          String charaP1 = chara.uuid.toString();
          charaP1 = charaP1.substring(0, charaP1.indexOf('-'));

          print('charaP1 : $charaP1 , W? : ${chara.properties.write} , N? : ${chara.properties.notify}');


          // if( !charaP1.toUpperCase().contains('ACA2')  || !charaP1.toUpperCase().contains('ACA3') )  continue;

          if(  charaP1.toUpperCase().contains('ACA2')   ){
            // writeable chara found....
            if(chara.properties.write){
             // chara.properties.writeWithoutResponse = true;

              rtnLs.add(chara);
              print('Add writable chara....');

              // print('tryWrite: ....');
              // await  chara.write([0,0,2]);


            }
          }else if(  charaP1.toUpperCase().contains('ACA3')   ){
            // writeable chara found....
            if( chara.properties.notify   ) {

              try {
               bool isNotify =   await chara.setNotifyValue(true);
                await Future.delayed(Duration(milliseconds: 500));
                if(isNotify) {
                  rtnLs.add(chara);
                  print('Add notify chara22....');
                }else{
                  print('set notify chara Failed....');
                }
              }on PlatformException catch(err){
                print('thor: chara  *************  ${err.toString()}');
                continue;
              }catch(err){
                print('thor: chara  *************  ${err.toString()}');
                continue;
              }
            }

          }

        }
      }

    }

    statSub.cancel();
    print(' return  chara List count ${rtnLs.length}........');
    return Future.value(rtnLs);
  }

  List<int> _inDatBaLs = [];
  void _handleTagetCharaArrivedData(List<int> inDatLs)
  {
   // if(  inDatLs.isEmpty) return;
    // print('*******  arrived len: ${inDatLs.length} dat : ${hex.encode(inDatLs) }');  // **************data come in here*******************


    if( (inDatLs.length > 3) && ( (inDatLs[0] == 0) && (inDatLs[1] == 0) && (inDatLs[2] == 0x01) ) ){ // start new frame
      _inDatBaLs.clear();
    }

    _inDatBaLs += inDatLs;


    if(_inDatBaLs.length < 10) {
      print('no frame length info....');
      return;
    }


    int datLen = (_inDatBaLs[4] << 8) | _inDatBaLs[3];

    if(datLen > 1024  ){  // we limit max data not large than 1024 bytes
      print('data len more than 1024 bytes, clean all data....');
      _inDatBaLs.clear();
      return;
    }

    if(_inDatBaLs.length < (datLen + 5) ) {
      print('Need more data....');
      return;
    }


    String jsonStr =  decodeFramedData(   _inDatBaLs   );
    _inDatBaLs.clear();

    print('jsonStr Decoded:  $jsonStr');

    if(jsonStr.isEmpty) return;


    _jsonStrCtrllor.add(jsonStr);




  }




  Future<void>   doResetBle() async {
    print('${this.runtimeType.toString()} doResetBle.. .......');

   // if(_btState == BluetoothState.)
   // stopScan();

    _targetCharaSub?.cancel();
    _targetCharaSub = null;
   // _targetChara = null;
    _targetBleDev?.disconnect();
    _targetBleDev = null;

    disconnectFromPeerBleDev();

    // foundBleDevMap.forEach((key, dev) {
    //   dev = null;
    // });

   // foundBleDevMap.clear();

    // bleCharaMap.forEach((key, chr) {
    //   chr = null;
    // });

   // bleCharaMap.clear();

    // thizStreamCtllorLs.forEach((sc) async {
    //   await sc.close();
    //  // sc = null;
    // });

   // thizStreamCtllorLs.clear();


  }

  // Future<void>   reScanAgain() async {
  //   print('${this.runtimeType.toString()} reScanAgain.........');
  //
  //   await disconnectFromPeerBleDev();
  //
  //   stopScan();
  //   startScan();
  // }

  void stopScan() async  {
    await fluBle.stopScan();
    bleScanSubScri?.cancel();
    bleScanSubScri = null;
  }

  Future<void> disconnectFromPeerBleDev() async {
   List<BluetoothDevice> bleLs = await  fluBle.connectedDevices;
   bleLs.forEach((dev) =>  dev.disconnect() );
  }

  // Future<bool> checkConnetionByBleName(String n) async {
  //
  //   List<BluetoothDevice> bleLs = await  fluBle.connectedDevices;
  //
  //   for(var dev in bleLs)
  //     if(dev.name == n)
  //       return true;
  //
  //   return false;
  // }

  // Future<void> connToBleDev(String dname) async {
  //
  //   var blePeerDev =  foundBleDevMap[dname];
  //
  //   if (blePeerDev == null) return;
  //
  //   await blePeerDev.connect(timeout: Duration(seconds: 5), autoConnect: false);
  //
  //   discoverBleServices(dname);
  // }



  //
  // Future<void> discoverBleServices(String dname) async {
  //   var blePeerDev =  foundBleDevMap[dname];
  //
  //   if (blePeerDev == null) return;
  //
  //
  //   List<BluetoothService> srvsLs = await blePeerDev.discoverServices();
  //
  //   srvsLs.forEach((svr)  async {
  //     print('svr uuid: ${svr.uuid.toString()}');
  //     if (svr.uuid.toString() == svrUuid) {
  //         svr.characteristics.forEach((chr)  async {
  //         print('char uuid: ${chr.uuid.toString()}');
  //         if (chr.uuid.toString() == charUuid) {
  //
  //           print('........fill map with name :$dname');
  //
  //           bleCharaMap.putIfAbsent(dname, () => chr);
  //
  //           //   await chr.setNotifyValue(true);
  //           //
  //           //   print('send data to mcu......');
  //           //
  //           // List<int> testest = [10, 0, 196, 101, 117, 181, 4, 168, 186, 206, 135];
  //           // chr.write(testest);
  //
  //           _evtNotifierCtllor.add(dname);
  //
  //         }
  //       });
  //     }
  //   });
  //
  // }

  // Future<bool> connBleByDevUuid(String uuid){
  //   bool isConnOk = false;
  //
  //
  //
  //
  //   return Future.value(isConnOk);
  // }
  //
  // Future < Stream<List<int>> > listenBleDataByName(String dname ) async
  // {
  //
  //   Future < Stream<List<int>> >  ?  rtnStream   ;
  //
  //   print('listenBleDataByName....enter...$dname');
  //
  //   var tmpChr = bleCharaMap[dname];
  //
  //   if(tmpChr != null){
  //
  //
  //     if(!tmpChr.isNotifying) {
  //       try {
  //         await tmpChr.setNotifyValue(true);
  //       }on PlatformException catch(err){
  //          print('thor: *************  ${err.toString()}');
  //       }catch(err){
  //         print('thor: *************  ${err.toString()}');
  //       }
  //     }
  //
  //      StreamController<List<int>> tmpSc = StreamController.broadcast();
  //
  //      tmpSc.addStream(tmpChr.value);
  //
  //
  //     thizStreamCtllorLs .add(tmpSc);
  //
  //    // print('listenBleDataByName.....okkkkkkkkkkk...$dname');
  //
  //    // tmpSc.stream.listen((event) { })
  //
  //     return tmpSc.stream;
  //
  //     // if(!tmpChr.isNotifying)
  //     //   await tmpChr.setNotifyValue(true);
  //     //
  //     // await tmpChr.write(dat);
  //   }
  //
  //  return rtnStream!;
  // }

  //
  // void sendBinDataToAllDevs(List<int> dat)  {
  //
  //   print('sendBinData inLs map: $dat');
  //
  //   bleCharaMap.forEach((devName, tmpChr) async {
  //     if(tmpChr != null){
  //
  //       try {
  //         await tmpChr.write(dat);
  //       }on PlatformException catch(err){
  //         print('thor: ****  ${err.toString()}');
  //       }catch(err){
  //         print('thor: ****  ${err.toString()}');
  //       }
  //     }
  //   });
  //
  // }
  //
  // void sendBinDataByName(String dname, List<int> dat)  async {
  //
  //   print('sendBinDataByName in map: $dname -- len: ${dat.length} dat: ${hex.encode( dat )}');
  //
  //    var tmpChr = bleCharaMap[dname];
  //
  //    if(tmpChr != null){
  //      // print('ble real write data....$dat');
  //       try {
  //        await tmpChr.write(dat);
  //      }on PlatformException catch(err){
  //        print('thor: ****  ${err.toString()}');
  //      }catch(err){
  //        print('thor: ****  ${err.toString()}');
  //      }
  //
  //    }
  // }

  void sendBinDataByChara(BluetoothCharacteristic chara, List<int> dat)  async {

    try {
      await chara.write(dat , withoutResponse: Platform.isAndroid  );
    }on PlatformException catch(err){
      print('thor: write****  ${err.toString()}');
    }catch(err){
      print('thor: write****  ${err.toString()}');
    }
  }


  List<int> keyStrToKeyBaLs(String keyStr)
  {
    List<int> rtnLs = [];


    Uint8List keyBytesLs = Uint8List.fromList(   utf8.encode( keyStr    ) );
    // Uint8List outBytesLs = Uint8List(24);
    // outBytesLs.fillRange(0, outBytesLs.length, 0);


    final inBaPtr = malloc.allocate <Uint8> (keyBytesLs.length);
    final outBaPtr = malloc.allocate <Uint8> ( 24 );// outBytesLs.length

    inBaPtr.asTypedList(keyBytesLs.length).setAll(0, keyBytesLs);
    //  outBaPtr.asTypedList(outBytesLs.length).setAll(0, outBytesLs);

   // print('keyBytesLs: len ${keyBytesLs.length} --- ${hex.encode( keyBytesLs) }');

    int outLen = _getTrueKey(inBaPtr, keyBytesLs.length, outBaPtr);

    rtnLs = List<int>.from(  outBaPtr.asTypedList(outLen) );

   // print('keyForDes3: OutBa: len $outLen --- ${hex.encode( rtnLs )}');



    malloc.free(inBaPtr);
    malloc.free(outBaPtr);

    return rtnLs;
  }

  String   appBuildDt(){


    String rtnStr = '';
    if(Platform.isAndroid)
      return rtnStr;


    final Pointer<Uint8> baPtr = malloc.allocate<Uint8>(32);

    int len = _fetchAppBuildDt(baPtr);

    String dtStr = String.fromCharCodes(  baPtr.asTypedList(len) );
    malloc.free(baPtr);


    String dtFmtStr = 'MMM  D yyyy hh:mm:ss';
    if(dtStr[4] != ' ')
      dtFmtStr = 'MMM DD yyyy hh:mm:ss';

    DateTime dt =  DateFormat(dtFmtStr).parse(dtStr);  //// ???????????  D maybe have problem
    rtnStr = DateFormat('yyyyMMddTHHmmss').format(dt);

    return  rtnStr;
  }

  //
  // void sendFramedBaByName(String dname, String jsonStr)  async {
  //
  //  // print('sendBinDataByName in map: $dname -- len: ${dat.length} dat: ${hex.encode( dat )}');
  //
  // //  var tmpChr = bleCharaMap[dname];
  //
  //   List<int> sendDatLs  = utf8.encode(jsonStr)  ;
  //
  //  // print('str to utf8 len: ${sendDatLs.length}');
  //
  //
  //  // print('Run C add func , resutl: ${_cppAdd(10,11)}');
  //
  //
  //   String rndKey = TGlobalData().getRandKeyStr();
  // //
  //     Uint8List keyBytesLs = Uint8List.fromList(   utf8.encode( rndKey    ) );
  // //  // Uint8List outBytesLs = Uint8List(24);
  // //  // outBytesLs.fillRange(0, outBytesLs.length, 0);
  // //
  // //
  // //   final inBaPtr = malloc.allocate <Uint8> (keyBytesLs.length);
  // //   final outBaPtr = malloc.allocate <Uint8> ( 24 );// outBytesLs.length
  // //
  // //   inBaPtr.asTypedList(keyBytesLs.length).setAll(0, keyBytesLs);
  // // //  outBaPtr.asTypedList(outBytesLs.length).setAll(0, outBytesLs);
  // //
  // //   print('keyBytesLs: len ${keyBytesLs.length} --- ${hex.encode( keyBytesLs) }');
  // //
  // //  int outLen = _getTrueKey(inBaPtr, keyBytesLs.length, outBaPtr);
  // //
  // //  final keyForDes3 = List<int>.from(  outBaPtr.asTypedList(outLen) );
  // //
  // //   print('keyForDes3: OutBa: len $outLen --- ${hex.encode( keyForDes3 )}');
  // //
  // //
  // //
  // //  malloc.free(inBaPtr);
  // //   malloc.free(outBaPtr);
  //
  //  // keyBytesLs .insert(0, keyBytesLs.length);
  //
  //   var keyForDes3 = keyStrToKeyBaLs(rndKey);
  //
  //   if(_dfk.length >= 16){
  //     List<int> factoryKey = hex.decode(_dfk);
  //
  //     keyForDes3 = doDes3ecbEcrypt(   keyForDes3, factoryKey);
  //
  //   //  print('facotry key is: ${hex.encode(factoryKey)}');
  //   //  print('keyForDes3 is encrypted by facotyr key: len: ${keyForDes3.length} : ${hex.encode(keyForDes3)}');
  //   }
  //
  //
  //
  // //  print('++++++ ori data: len: ${ sendDatLs.length} ${hex.encode(sendDatLs)}');
  //   Uint8List tmpLenArr = myUint32ToIntLs(sendDatLs.length);
  //   sendDatLs = [tmpLenArr[0], tmpLenArr[1]] + sendDatLs;
  //
  //  // print('++++++ ori data: len: ${ sendDatLs.length} ${hex.encode(sendDatLs)}');
  //
  //   sendDatLs  = doDes3ecbEcrypt(   sendDatLs, keyForDes3);
  //
  // //  print('++++++after data: len: ${ sendDatLs.length} ${hex.encode(sendDatLs)}');
  //
  //
  //   sendDatLs = [keyBytesLs.length] + keyBytesLs + sendDatLs;  // add Max 16bytes
  //
  //
  //   Uint8List tmpU8Ls =  myUint32ToIntLs(_selfIncresNum);
  //   sendDatLs = [tmpU8Ls[0] , tmpU8Ls[1]   ] + sendDatLs;   // add 2bytes
  //   _selfIncresNum ++;
  //
  //   sendDatLs =  doChecksunData(sendDatLs); // (total len + checksum) + 3bytes
  //
  //   sendDatLs = [0,0,1] + sendDatLs; // insert frame header, (0x00,0x00,0x01)
  //
  //  //  print('*******  sendFramedBaByName ori : $dname -- len: ${sendDatLs.length} dat: ${hex.encode( sendDatLs )}');
  //
  //   int framedSize = 128;
  //
  //   while(sendDatLs.length > 0){
  //     // List<int> tmpDat = testLs.skip( k++ * takeLen).take(takeLen).toList();
  //     int takeLen = sendDatLs.length > framedSize ?  framedSize : sendDatLs.length;
  //     List<int> tmpDat = sendDatLs.sublist(0,takeLen);
  //     sendDatLs.removeRange(0, takeLen);
  //
  //     sendBinDataByName(dname, tmpDat);
  //
  //     sleep(const Duration(milliseconds: 100));
  //
  //   }
  //
  //
  // }


  Future<void> sendFramedJsonData( String jsonStr)  async {
    // if(_targetChara == null){
    //   print('Chara for writting is null, maybe ble not connected....');
    //   return;
    // }
    // await sendFramedBaByChara(_targetChara!, jsonStr);
    for(int i = 0 ; i < _workingCharaLs.length ; i ++)
      if(_workingCharaLs[i].properties.write){
        await sendFramedBaByChara(_workingCharaLs[i] , jsonStr);
        break;
      }

  }

  Future<void> sendFramedBaByChara(BluetoothCharacteristic chara, String jsonStr)  async {

    List<int> sendDatLs  = utf8.encode(jsonStr)  ;

   // print('str to utf8 len: ${sendDatLs.length}');

    String rndKey = TGlobalData().getRandKeyStr();
    //
    Uint8List keyBytesLs = Uint8List.fromList(   utf8.encode( rndKey    ) );


    var keyForDes3 = keyStrToKeyBaLs(rndKey);

    if(_dfk.length >= 16){
      List<int> factoryKey = hex.decode(_dfk);

      keyForDes3 = doDes3ecbEcrypt(   keyForDes3, factoryKey);

     // print('facotry key is: ${hex.encode(factoryKey)}');
     // print('keyForDes3 is encrypted by facotyr key: len: ${keyForDes3.length} : ${hex.encode(keyForDes3)}');
    }

    //  print('++++++ ori data: len: ${ sendDatLs.length} ${hex.encode(sendDatLs)}');
    Uint8List tmpLenArr = myUint32ToIntLs(sendDatLs.length);
    sendDatLs = [tmpLenArr[0], tmpLenArr[1]] + sendDatLs;

    // print('++++++ ori data: len: ${ sendDatLs.length} ${hex.encode(sendDatLs)}');

    sendDatLs  = doDes3ecbEcrypt(   sendDatLs, keyForDes3);

   // print('++++++after data: len: ${ sendDatLs.length} ${hex.encode(sendDatLs)}');

    sendDatLs = [keyBytesLs.length] + keyBytesLs + sendDatLs;  // add Max 16bytes

    Uint8List tmpU8Ls =  myUint32ToIntLs(_selfIncresNum);
    sendDatLs = [tmpU8Ls[0] , tmpU8Ls[1]   ] + sendDatLs;   // add 2bytes
    _selfIncresNum ++;

    sendDatLs =  doChecksunData(sendDatLs); // (total len + checksum) + 3bytes

    sendDatLs = [0,0,1] + sendDatLs; // insert frame header, (0x00,0x00,0x01)

   // print('****  -- len: ${sendDatLs.length} dat: ${hex.encode( sendDatLs )}');

    int framedSize = Platform.isAndroid ? 20 :128;

    while(sendDatLs.length > 0){
      int takeLen = sendDatLs.length > framedSize ?  framedSize : sendDatLs.length;
      List<int> tmpDat = sendDatLs.sublist(0,takeLen);
      sendDatLs.removeRange(0, takeLen);

      sendBinDataByChara(chara, tmpDat);

      sleep(const Duration(milliseconds: 100));

    }


  }


  String decodeFramedData(List<int> inBaLs)
  {
    String rtnStr = '';

   // print('parse data: len: ${inBaLs.length} ${hex.encode(inBaLs)}');
    
    
    if( (inBaLs[0] != 0) && (inBaLs[1] != 0) && (inBaLs[2] != 1))
      {
          print('InBaLs is NOT a correct framed data.....');
          return rtnStr;
      }

    int datLen = (inBaLs[4] << 8) | inBaLs[3];

   // print(' datLen : $datLen');

    if(datLen != inBaLs.length - 5){
      print('InBaLs data length NOT match.....');
      return rtnStr;
    }

    int checksum = inBaLs[5];
    inBaLs = inBaLs.sublist(6);

   // print('parse data22 : ${hex.encode(inBaLs)}');

    int tmpCs = 0;

    inBaLs.forEach((v) {
      tmpCs += v;
    });

    tmpCs = myUint32ToIntLs(tmpCs)[0];

    if(tmpCs != checksum){
      print('InBaLs Checksum Error.....wanted: $checksum , got: $tmpCs');
      return rtnStr;
    }

    int cmdNum = (inBaLs[1] << 8) | inBaLs[0];

   // print('cmdNum : $cmdNum');

    int keyLen = inBaLs[2];

   // print('keyLen : $keyLen');

    inBaLs = inBaLs.sublist(2 + 1);

    String keyStr = String.fromCharCodes(    inBaLs.sublist(0, keyLen) );


   // print('keyStr : $keyStr');

    inBaLs = inBaLs.sublist( keyLen);


    var keyForDes3 = keyStrToKeyBaLs(keyStr);
    
    //print('Got key for decrypt: ${hex.encode(keyForDes3)}');

    if(_dfk.length >= 16){
      List<int> factoryKey = hex.decode(_dfk);

      keyForDes3 = doDes3ecbEcrypt(   keyForDes3, factoryKey);

     // print('facotry key is: ${hex.encode(factoryKey)}');
     // print('Got True keyForDes3 is encrypted by facotyr key: len: ${keyForDes3.length} : ${hex.encode(keyForDes3)}');
    }


    if(keyForDes3.length < 16 ) {
      print('Error key for decryption.....');
      return rtnStr;
    }


   // print('data Still need decrypte : len: ${inBaLs.length}  ${hex.encode(inBaLs)}');

     inBaLs = des3ecbDecrypt( inBaLs , keyForDes3);

  //  print('111 inBaLs after decrypt : len: ${inBaLs.length}  ${hex.encode(inBaLs)}');


    if(inBaLs.length < 3) {
       print('Length Error after decrypt......');
       return rtnStr;
     }

     int trueDatLen =   ( inBaLs[1] << 8) | inBaLs[0]  ;
     inBaLs = inBaLs.sublist(2);

    // print('trueDatLen: $trueDatLen');

     if(trueDatLen > inBaLs.length ){
       print('Error trueDataLenght.....now len ${inBaLs.length}');
       return rtnStr;
     }

     inBaLs =  inBaLs.sublist(0,trueDatLen);
     

      rtnStr = utf8.decode(inBaLs);

    // print('inBaLs after decrypt : len: ${inBaLs.length}  ${hex.encode(inBaLs)}');


    return rtnStr;
  }


  List<int> doChecksunData(List<int> datLs)
  {
    int checksun = 0;

    datLs.forEach((v) {
      checksun += v;
    });

    // datLs.add(myUint32ToIntLs(checksun)[0]);
    datLs.insert(0, myUint32ToIntLs(checksun)[0]);

    Uint8List dLen =  myUint32ToIntLs(datLs.length);


   // print('dLen : $dLen');

    datLs = [ dLen[0] ,  dLen[1] ] + datLs;



    return datLs;

  }

  Uint8List myUint32ToIntLs(int vv ) =>  Uint8List(4)..buffer.asUint32List()[0] = vv;



  List<int> doDes3ecbEcrypt(List<int> datLs , List<int> privKey)
  {
    List<int> rtn = [];

    if(datLs.isEmpty)
      return rtn;

    int less;
    if( (less = datLs.length % 8) > 0){
      datLs += List.filled(8 - less, 0);
    }

   // print('Ori data for Encrypt: ${hex.encode(datLs)}');


    privKey =  privKey.sublist(0,8).reversed.toList()
        + privKey.sublist(8,16).reversed.toList()
        + privKey.sublist(16).reversed.toList();

   //  print('Do Encrypt using key: ${hex.encode(privKey )}');


    DES3 des3ECB = DES3(key: privKey, mode: DESMode.ECB , paddingType: DESPaddingType.None);


    for(int i = 0 ; i < datLs.length / 8 ; i ++){
      List<int > inLs = datLs.sublist(i * 8 , i * 8 + 8)  .reversed.toList();
     // print('inLs: len: ${inLs.length}  ${hex.encode(inLs)}');
      rtn  += des3ECB.encrypt(inLs).reversed.toList() ;

    //  print('rtn: len: ${rtn.length}  ${hex.encode(rtn)}');

    }


  // print('after des3 encrypt: len: ${rtn.length}  : ${hex.encode(rtn)}');

    return rtn;

  }

  List<int> des3ecbDecrypt(List<int> datLs , List<int> privKey)
  {
   // List<int> myKey = TGlobalData().defaultDes3EcbKeyLs;

    List<int> decryptedLs = [];

    privKey =  privKey.sublist(0,8).reversed.toList()
        + privKey.sublist(8,16).reversed.toList()
        + privKey.sublist(16).reversed.toList();

   // print('Do decrypt using key: ${hex.encode(privKey )}');

    DES3 des3ECB = DES3(key: privKey, mode: DESMode.ECB , paddingType: DESPaddingType.None);


    for(int i = 0 ; i < datLs.length / 8 ; i ++)
       decryptedLs += des3ECB.decrypt(datLs.sublist(i * 8, i * 8 + 8).reversed.toList() ).reversed.toList();
      // decryptedLs += des3ECB.decrypt(datLs.sublist(i * 8, i * 8 + 8) ).reversed.toList();

    return decryptedLs;

  }

  List<int> encryptOrDecryptDatBa(bool isEncrypt,  List<int> inBaLs , List<int> factoryKey){

    List<int> rtnLs = [];


    return rtnLs;

  }


  List<int> goChecksunAndDecrypt(List<int> datIntLs , String blename) {
    List<int> rtn = [];

    //  print('dat len: ${datIntLs.length}  [0] = ${datIntLs[0]}');

    if(  (datIntLs.length < 3) || ((  datIntLs.length - 1  ) !=  datIntLs[0])  ) {
      print('Data len Error....');
      return rtn;
    }


    int checksun = 0 ;

    for(int i = 1 ; i < datIntLs.length - 1 ; i ++)
      checksun += datIntLs[i];


    int cs = myUint32ToIntLs(checksun)[0];

    //print('2222222222 cs =  $cs');




    if(cs != datIntLs[datIntLs.length - 1]) {
      print('Checksum Error....');
      return rtn;
    }

    int userid = datIntLs[1];

    List<int> privKey =  TGlobalData().fetCryptKeyByBleUId(blename, userid);


    datIntLs =  des3ecbDecrypt(   datIntLs.sublist(2, datIntLs.length - 1) , privKey );
    datIntLs.insert(0, userid);

    return datIntLs;

  }


  List<int> goChecksunAndDecrypt2(List<int> datIntLs , String blename,List<int> privKey) {
    List<int> rtn = [];

    //  print('dat len: ${datIntLs.length}  [0] = ${datIntLs[0]}');

    if(  (datIntLs.length < 3) || ((  datIntLs.length - 1  ) !=  datIntLs[0])  ) {
      print('Data len Error....');
      return rtn;
    }


    int checksun = 0 ;

    for(int i = 1 ; i < datIntLs.length - 1 ; i ++)
      checksun += datIntLs[i];


    int cs = myUint32ToIntLs(checksun)[0];

    //print('2222222222 cs =  $cs');




    if(cs != datIntLs[datIntLs.length - 1]) {
      print('Checksum Error....');
      return rtn;
    }

    int userid = datIntLs[1];

    datIntLs =  des3ecbDecrypt(   datIntLs.sublist(2, datIntLs.length - 1) , privKey );
    datIntLs.insert(0, userid);

    return datIntLs;

  }





  int extraIntVal(List<int> datLs){
    return Uint8List.fromList(datLs).buffer.asByteData().getUint32(0, Endian.little);
  }

  Future<void> close() async {
    await _controller.close();
    thizStreamCtllorLs.forEach((sc) async {
      await sc.close();
    });
   // await _bleIntDataLs.close();
  }

}
