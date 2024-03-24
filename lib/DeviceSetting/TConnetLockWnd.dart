import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'dart:convert';
import '../TBleSingleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';



import '../TGlobal_inc.dart';
import '../TRemoteSrv.dart';



class TConnetLockWnd extends StatefulWidget {

  final String devIdStr;
  final String macStr;
  //final BluetoothDevice bleDev;

  TConnetLockWnd(this.devIdStr , this.macStr);

  @override
  _TConnetLockWndState createState() => _TConnetLockWndState();
}


class _TConnetLockWndState extends State<TConnetLockWnd> {

 // Future<int> test = Future.value(32);


  List<  Future<int> > _stepFIntLs = [];

  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

    for(int i = 0 ; i < 4 ; i ++){
      _stepFIntLs.add(Future.value(0));
    }


  //  WidgetsBinding.instance!.addPostFrameCallback((_) => _goThroughAllStep());


    Future.delayed(Duration(seconds: 1)).then((value) {
      // setState(() {
      // //  _stepFIntLs[0] = Future.value(100);
      //
      // });
     // _testAddVal();

      _goThroughAllStep();

    });

  }


  @override
  void deactivate() {
    print('${this.runtimeType.toString()} deactivate()......................');
  }

  @override
  void dispose() {
    print('${this.runtimeType.toString()} dispose()......................');

   // stepVal = 500;

  //  widget.bleDev.disconnect();


    super.dispose();
  }


  // int stepVal = 0;

  // void _testAddVal (){
  //
  //   if(stepVal > 400) return;
  //
  //   setState(() {
  //     if(stepVal > 300 ){
  //       _stepFIntLs[3] = Future.value(  stepVal - 300);
  //     }else if(stepVal > 200 ){
  //       _stepFIntLs[2] = Future.value(  stepVal - 200);
  //     }else if(stepVal > 100 ){
  //       _stepFIntLs[1] = Future.value(  stepVal - 100);
  //     }else{
  //       _stepFIntLs[0] = Future.value(  stepVal  );
  //     }
  //   });
  //
  //   stepVal += 20;
  //
  //   Future.delayed(Duration(milliseconds: 300)).then((value) {
  //     _testAddVal ();
  //   });
  // }

  Future<bool> _connToBleLock() async {

    TBleSingleton().doResetBle();
    TBleScanStatus currStat = await TBleSingleton().findAndConnBleById(widget.devIdStr) ;

    print('currStat : ${currStat}');

    if(currStat != TBleScanStatus.Found){
      TGlobalData().showToastInfo("连接锁具失败....");
      return false;
    }

    return true;
  }

  _goThroughAllStep() async
  {

    bool haveError = false;

    setState(() {
        _stepFIntLs[0] = Future.value(  50  );
     });


    bool isConnOk = await _connToBleLock();

    if(!isConnOk) {
      _stepFIntLs[0] = Future.value(   0  );
      return;
    }


    setState(() {
      _stepFIntLs[0] = Future.value(  100  );
      _stepFIntLs[1] = Future.value(  50  );
    });


        List<Completer> tmpCptLs = [];
       List.generate(3, (index) => tmpCptLs.add(Completer<void>()));

        //final initLockC = Completer<void>();
        StreamSubscription<String> jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) {

          print('got jsonstr: $jsonStr');

          var jsonObj = jsonDecode(jsonStr);

          String foctoryKey = jsonObj["InitLock"];
          print('initlock: ${foctoryKey}');
          if (foctoryKey.length > 16) {
            TBleSingleton().keepDfk = foctoryKey;
            TBleSingleton().Userid = int.parse( jsonObj["uid"].toString() );
           // TBleSingleton().doResetBle();
            tmpCptLs[0].complete();
          }



        });

        var jobj = {};
        jobj["InitLock"] =  DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000 ;

       await TBleSingleton().sendFramedJsonData(json.encode(jobj));

        await  tmpCptLs[0].future;
    print(' Cancel init steam sub scription 0.....');
    jsonSSub.cancel();
        await Future.delayed(Duration(milliseconds:500));


    //
    //   isConnOk = await _connToBleLock();
    //
    // if(!isConnOk) {
    //   _stepFIntLs[0] = Future.value(   0  );
    //   _stepFIntLs[2] = Future.value(   0  );
    //   TGlobalData().showToastInfo("初始化后重连锁具失败....");
    //   return;
    // }

    String safeCode =   await _showSafetyCodeWnd();

    print('safe code is : $safeCode');

    jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) {

      print('got 1 jsonstr: $jsonStr');

       var jsonObj = jsonDecode(jsonStr);
       if( int.parse(jsonObj['rsl'].toString()) == ResultCodeToApp_e.Rsl_Ok_Ok.index){
            print('Setup safe code for SmartLock ok.....');
       }

      tmpCptLs[1].complete();

    });

      jobj = {};
    jobj["sjaqm"] =  safeCode;
    TBleSingleton().sendFramedJsonData(json.encode(jobj));

    await  tmpCptLs[1].future;

    print(' Cancel init steam sub scription 1.....');
    jsonSSub.cancel();

    print('Enter pair code step.....');

    String pariCode = TGlobalData().generateRndNumberStr(6);

    bool isPairCodeDone = false;
   bool checkIfInputDone(){
     return isPairCodeDone;
    }

      _showPairCodeWnd(pariCode , checkIfInputDone);

    print('wait for pair code input done.. ...');
    jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) {

      print('got 2 jsonstr: $jsonStr');

       var jsonObj = jsonDecode(jsonStr);
      if( int.parse(jsonObj['rsl'].toString()) ==  ResultCodeToApp_e.Rsl_Ok_Pair_Code_Matched.index
      ){
        print('Setup pair code for SmartLock ok.....');

      }else{
        print('  pair code ERROR........');
        haveError = true;
      }

      isPairCodeDone = true;
      tmpCptLs[2].complete();

    });

    jobj = {};
    jobj["sjpdm"] = pariCode ;
    TBleSingleton().sendFramedJsonData(json.encode(jobj));

    await  tmpCptLs[2].future;
    await Future.delayed(Duration(milliseconds:1100));


    print(' Cancel init steam sub scription 2.....');
    jsonSSub.cancel();

    if(haveError){
      TGlobalData().showToastInfo("配对码错误，请重新添加设备....");
      TBleSingleton().doResetBle();
      setState(() {
        _stepFIntLs[0] = Future.value(  0  );
        _stepFIntLs[1] = Future.value(  0  );
      });
      return;
    }


    bool isSetupOk =  await _showRenameLockWnd();


    setState(() {
      _stepFIntLs[0] = Future.value(  100  );
      _stepFIntLs[1] = Future.value(  100  );
      _stepFIntLs[2] = Future.value(  100  );
      _stepFIntLs[3] = Future.value(  100  );
    });

    TGlobalData().keepInitLockData( widget.macStr  , [TBleSingleton().keepDfk, TBleSingleton().Userid.toString()]); //??????

    await Future.delayed(Duration(milliseconds: 500));

     if(isSetupOk) {
        Navigator.popUntil(context, (route) {
          (route.settings.arguments as Map)['rsl'] = 1;
          return  route.isFirst;
        });
     }

  }


  Future<String> _showSafetyCodeWnd () async {

   // FocusScope.of(context).previousFocus();

    final rtn = await showDialog(context: context,
        builder: (BuildContext ctx )=>  Platform.isAndroid ?  _TSetupSaftyCodeWnd2( ) :   _TSetupSaftyCodeWnd( )   );

    String safeCode = rtn.toString();
    return Future.value(safeCode);
  }


  Future<void> _showPairCodeWnd (String pn , Function func) async {


    final rtn = await showDialog(context: context,
        builder: (BuildContext ctx )=> _TSetupPairCodeWnd(pn , func ));

  }


  Future<bool>  _showRenameLockWnd () async {


    final rtn = await showDialog(context: context,
        builder: (BuildContext ctx )=> _TSetupLockNameWnd( widget.devIdStr , widget.macStr));


    if(rtn as int == 1){
      // Navigator.popUntil(context, (route) {
      //    (route.settings.arguments as Map)['rsl'] = 1;
      //  return  route.isFirst;
      // });

      return Future.value(true);

    }

    return Future.value(false);

  }


  void _showConnErrorWnd() async {
    final rtn = await showDialog(context: context,
        builder: (BuildContext dctx){

        final s = MediaQuery.of(context).size;
         double mH  = s.width / 10.0;
         double mV  = s.height / 4.0;


            return Material(
              color: Colors.transparent,
              child:
            Container(
              margin: EdgeInsets.fromLTRB(mH, mV, mH, mV),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  Icon(    Icons.folder , color: Colors.red, size: s.width / 5.0,),

                  Center(child: Text('连接设备失败' , style: TextStyle(fontSize: 20 , fontWeight: FontWeight.bold),)),
                  Center(child: Text('请重启手机蓝牙，并靠近设备后重试' , style: TextStyle(fontSize: 14 , color: Color(0xffaaaaaa),))),


                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
                    child: ElevatedButton(
                      onPressed: (){

                        Navigator.pop(dctx);

                        // Future.delayed(Duration(seconds: 3)).then((value) {
                        //
                        //
                        // });

                        // Navigator.push(context, MaterialPageRoute(builder: (context) => TScanLockWnd()));

                        //   Navigator.pushReplacement(
                        //     context,
                        //     MaterialPageRoute(builder: (context) => TLogingWnd()),
                        //     //MaterialPageRoute(builder: (context) => TDevMainWnd()),
                        //   );
                      },
                      child: Text('重新连接' , style: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
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
            );

        }

    );
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
      resizeToAvoidBottomInset: false,
      body:   Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [



            Image.asset('images/pngs/connLock.png' ,
              height: MediaQuery.of(context).size.height / 5.0 * 1.8,
              fit: BoxFit.scaleDown,),



            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('请将手机放置在设备附近', style: TextStyle(color: Colors.black ,fontSize: 20, fontWeight: FontWeight.normal)),
              ),
            ),

            Container(
              padding: EdgeInsets.fromLTRB(30, 20, 10, 20),
              margin: EdgeInsets.fromLTRB(40, 2, 40, 6),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xffbbbbbb)),
                borderRadius: BorderRadius.circular(32.0),

              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children : [

                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: FutureBuilder<int>(
                          future: _stepFIntLs[0],
                          builder: (fctx, ss){
                            int v = 0;

                            if(ss.connectionState == ConnectionState.done){
                              v = ss.data! ;
                            }

                            return  Wrap(
                              spacing: 14,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [

                               v == 100 ? Icon(Icons.check_circle , color: TGlobalData().crMainThemeColor, size: 26,)
                                        : SizedBox( height: 20, width: 20, child:CircularProgressIndicator(value: v > 0 ? null : v.toDouble(), color: TGlobalData().crMainThemeColor, backgroundColor: Color(0xffdddddd),)),
                               v == 100 ?  Text('连接设备成功' , style: TGlobalData().tsListTitleTS1,)
                                          : Text('正在连接设备...' , style: TGlobalData().tsListTitleTS1,)  ,
                              ],);
                          }),
                    ),


                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: FutureBuilder<int>(
                          future: _stepFIntLs[1],
                          builder: (fctx, ss){
                            int v = 0;

                            if(ss.connectionState == ConnectionState.done){
                              v = ss.data! ;
                            }

                            return  Wrap(
                              spacing: 14,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [

                                v == 100 ? Icon(Icons.check_circle , color: TGlobalData().crMainThemeColor, size: 26,)
                                    : SizedBox( height: 20, width: 20, child:CircularProgressIndicator(value: v > 0 ? null : v.toDouble(), color: TGlobalData().crMainThemeColor, backgroundColor: Color(0xffdddddd),)),
                                v == 100 ?  Text('安全认证成功' , style: TGlobalData().tsListTitleTS1,)
                                    : Text('安全认证中···' , style: TGlobalData().tsListTitleTS1,)  ,
                              ],);
                          }),
                    ),




                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: FutureBuilder<int>(
                          future: _stepFIntLs[2],
                          builder: (fctx, ss){
                            int v = 0;

                            if(ss.connectionState == ConnectionState.done){
                              v = ss.data! ;
                            }

                            return  Wrap(
                              spacing: 14,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [

                                v == 100 ? Icon(Icons.check_circle , color: TGlobalData().crMainThemeColor, size: 26,)
                                    : SizedBox( height: 20, width: 20, child:CircularProgressIndicator(value: v > 0 ? null : v.toDouble(), color: TGlobalData().crMainThemeColor, backgroundColor: Color(0xffdddddd),)),
                                v == 100 ?  Text('设备绑定账号成功' , style: TGlobalData().tsListTitleTS1,)
                                    : Text('设备绑定账号中···' , style: TGlobalData().tsListTitleTS1,)  ,
                              ],);
                          }),
                    ),




                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: FutureBuilder<int>(
                          future: _stepFIntLs[3],
                          builder: (fctx, ss){
                            int v = 0;

                            if(ss.connectionState == ConnectionState.done){
                              v = ss.data! ;
                            }

                            return  Wrap(
                              spacing: 14,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [

                                v == 100 ? Icon(Icons.check_circle , color: TGlobalData().crMainThemeColor, size: 26,)
                                    : SizedBox( height: 20, width: 20, child:CircularProgressIndicator(value: v > 0 ? null : v.toDouble(), color: TGlobalData().crMainThemeColor, backgroundColor: Color(0xffdddddd),)),
                                v == 100 ?  Text('扩展程序初始化成功' , style: TGlobalData().tsListTitleTS1,)
                                    : Text('扩展程序初始化中···' , style: TGlobalData().tsListTitleTS1,)  ,
                              ],);
                          }),
                    ),




          ],
        ),
      ),




            Padding(
              padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
              child: ElevatedButton(
                onPressed: _stepFIntLs[3] == Future.value(100) ? (){


                  Future.delayed(Duration(seconds: 0)).then((value) {
                   // _showConnErrorWnd();



                  });

                 //    Navigator.push(context, MaterialPageRoute(builder: (context) => EnglishPin('ThorAbcd')));
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => MyPinCode(6)));

                  //   Navigator.pushReplacement(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => TLogingWnd()),
                  //     //MaterialPageRoute(builder: (context) => TDevMainWnd()),
                  //   );
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


          ] )
    ));

  }
}








class _TSetupSaftyCodeWnd extends StatefulWidget {

 // String uuidStr;
  //_TSetupSaftyCodeWnd( );

  @override
  _TSetupSaftyCodeWndState createState() => _TSetupSaftyCodeWndState();
}


class _TSetupSaftyCodeWndState extends State<_TSetupSaftyCodeWnd> {

  final dummyChar = '\u200B';

  List<TextEditingController> _pinCodeTxtCtrolorLs = [];
  List<FocusNode> _pinCodeTxtFNodeLs = [];

  int _maxPinCount = 6;

  String _firstCodeStr = '';

  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

    for(int i = 0 ; i < _maxPinCount ; i ++){
      _pinCodeTxtCtrolorLs.add(TextEditingController()..text = dummyChar);
      _pinCodeTxtFNodeLs.add(FocusNode());
    }

    print('is mounted : $mounted');

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


  void _restartPinInput(){
    setState(() {
      for(int i = 0 ; i < _pinCodeTxtCtrolorLs.length ;i ++){
        _pinCodeTxtCtrolorLs[i].value = TextEditingValue(text: dummyChar , selection: TextSelection.collapsed(offset: 2));
      }
    });

    FocusScope.of(context).requestFocus(_pinCodeTxtFNodeLs[0]);

  }


  void _pinCodeTxtChged(String currStr, int idx ){

    int _focusPos = 0;
    //print('str: $currStr  len: ${currStr.length} , idx: $idx');


    if(currStr.length == 0){
      _focusPos = max(idx - 1 , 0);
      setState(() {
        _pinCodeTxtCtrolorLs[idx].value = TextEditingValue(text: dummyChar , selection: TextSelection.collapsed(offset: 2));
      });
     FocusScope.of(context).requestFocus(_pinCodeTxtFNodeLs[_focusPos]);
      return;
    }

    if(currStr.length == 2){
      _focusPos = min( idx + 1 , _maxPinCount - 1);
      setState(() {
        _pinCodeTxtCtrolorLs[idx].value = TextEditingValue(text: dummyChar + currStr[1], selection: TextSelection.collapsed(offset: 2));
      });
      FocusScope.of(context).requestFocus(_pinCodeTxtFNodeLs[_focusPos]);
      if(idx == _maxPinCount - 1){

        for(int i = 0 ; i < _pinCodeTxtCtrolorLs.length ;i ++)
          if( _pinCodeTxtCtrolorLs[i].text.length != 2 )
            return;

          String currCodeStr = '';

        for(int i = 0 ; i < _pinCodeTxtCtrolorLs.length ;i ++){
          currCodeStr += _pinCodeTxtCtrolorLs[i].text.replaceAll(dummyChar, '');
        }

        //print('currCodeStr is : $currCodeStr  _firstCodeStr: $_firstCodeStr');

        if(_firstCodeStr. isEmpty ){
          setState(() {
            _firstCodeStr = currCodeStr;
          });

          _restartPinInput();
          return;
        }

          if(_firstCodeStr  == currCodeStr ){

          //  print('Pin code is The same....................');

            Navigator.pop(context , _firstCodeStr);

            return;
          }


        TGlobalData().showToastInfo("两次输入不一致....");
        _firstCodeStr = '';
        _restartPinInput();
         return;
      }
      return ;
    }

    if(currStr.length > 2){
      _focusPos = min( idx + 1 , _maxPinCount - 1);
      setState(() {
        _pinCodeTxtCtrolorLs[idx].value = TextEditingValue(text: dummyChar + currStr[currStr.length - 1], selection: TextSelection.collapsed(offset: 2));
      });
     FocusScope.of(context).requestFocus(_pinCodeTxtFNodeLs[_focusPos]);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child:
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: (){FocusScope.of(context).unfocus();},
        child: Container(
          margin: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 5.0, 0, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40.0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Center(child: Text( _firstCodeStr.isEmpty ? '请设置安全密码' : '请再次输入密码' ,
                style: TextStyle(fontSize: 26 , fontWeight: FontWeight.bold),)),
              Center(child: Text('请输入安全密码，改密码将用于主账号管理设备\n查看设备时需要验证安全密码' ,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16 , color: Color(0xffaaaaaa),))),


              Center(
                child: Wrap(
                  spacing: 10,
                  children: [

                    ...<int>[for(int i =0 ; i < _pinCodeTxtCtrolorLs. length ; i ++) i].map((idx) {

                      return SizedBox(width: 46,height: 46,
                            child: TextField(
                              controller: _pinCodeTxtCtrolorLs[idx],
                              focusNode:  _pinCodeTxtFNodeLs[idx],
                              textAlign: TextAlign.right,
                              textAlignVertical: TextAlignVertical.top,
                              showCursor: false,
                              selectionControls: null,
                               autofocus: idx == 0 ?  true : false,
                              keyboardType: TextInputType.number,
                              onChanged: (str) => _pinCodeTxtChged(str,idx) ,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: TGlobalData().crMainThemeColor,width: 2.0),
                                    borderRadius: BorderRadius.circular(6.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6.0),
                                    borderSide: BorderSide(color: (_pinCodeTxtCtrolorLs[idx].text.length >= 2) ?
                                    TGlobalData().crMainThemeColor  : Color(0xffbbbbbb)) ,
                                ),
                              ),
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),

                            )
                      );

                     }).toList(),

                ],),
              ),


              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 2),
                child: Image.asset('images/pngs/noLockDev.png' ,
                  height: MediaQuery.of(context).size.height / 5.0 * 1.6,
                  fit: BoxFit.scaleDown,),
              ),


              // ElevatedButton(onPressed: (){
              //   FocusScope.of(context).nextFocus();
              // }, child: Text('next focusWid')),

              Padding(
                padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                child: ElevatedButton(
                  onPressed: (){

                    Navigator.pop(context);


                  },
                  child: Text('取  消' , style: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
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
    );
  }
}




//// for Android


class _TSetupSaftyCodeWnd2 extends StatefulWidget {

  // String uuidStr;
  //_TSetupSaftyCodeWnd2( );

  @override
  _TSetupSaftyCodeWnd2State createState() => _TSetupSaftyCodeWnd2State();
}


class _TSetupSaftyCodeWnd2State extends State<_TSetupSaftyCodeWnd2> {

  final dummyChar = '\u200B';

  List<TextEditingController> _pinCodeTxtCtrolorLs = [];
  List<FocusNode> _pinCodeTxtFNodeLs = [];

  int _maxPinCount = 6;

  String _firstCodeStr = '';

  final TextEditingController _pinCodeTxtCtrlor= TextEditingController();
  String _pinCodeTxt1 = '';
  String _pinCodeTxt2 = '';

  final  FocusNode _pinInputNode  = FocusNode();

  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

    for(int i = 0 ; i < _maxPinCount ; i ++){
      _pinCodeTxtCtrolorLs.add(TextEditingController()..text = dummyChar);
      _pinCodeTxtFNodeLs.add(FocusNode());
    }

    print('is mounted : $mounted');

  }

  @override
  void deactivate() {
    print('${this.runtimeType.toString()} deactivate()......................');
  }

  @override
  void dispose() {
    print('${this.runtimeType.toString()} dispose()......................');

    // _pinInputNode.dispose();
    super.dispose();
  }


  void _restartPinInput(){
    setState(() {
      for(int i = 0 ; i < _pinCodeTxtCtrolorLs.length ;i ++){
        _pinCodeTxtCtrolorLs[i].value = TextEditingValue(text: dummyChar , selection: TextSelection.collapsed(offset: 2));
      }
    });

    FocusScope.of(context).requestFocus(_pinCodeTxtFNodeLs[0]);

  }


  void _pinCodeTxtChged(String currStr, int idx ){

    int _focusPos = 0;
    //print('str: $currStr  len: ${currStr.length} , idx: $idx');


    if(currStr.length == 0){
      _focusPos = max(idx - 1 , 0);
      setState(() {
        _pinCodeTxtCtrolorLs[idx].value = TextEditingValue(text: dummyChar , selection: TextSelection.collapsed(offset: 2));
      });
      FocusScope.of(context).requestFocus(_pinCodeTxtFNodeLs[_focusPos]);
      return;
    }

    if(currStr.length == 2){
      _focusPos = min( idx + 1 , _maxPinCount - 1);
      setState(() {
        _pinCodeTxtCtrolorLs[idx].value = TextEditingValue(text: dummyChar + currStr[1], selection: TextSelection.collapsed(offset: 2));
      });
      FocusScope.of(context).requestFocus(_pinCodeTxtFNodeLs[_focusPos]);
      if(idx == _maxPinCount - 1){

        for(int i = 0 ; i < _pinCodeTxtCtrolorLs.length ;i ++)
          if( _pinCodeTxtCtrolorLs[i].text.length != 2 )
            return;

        String currCodeStr = '';

        for(int i = 0 ; i < _pinCodeTxtCtrolorLs.length ;i ++){
          currCodeStr += _pinCodeTxtCtrolorLs[i].text.replaceAll(dummyChar, '');
        }

        //print('currCodeStr is : $currCodeStr  _firstCodeStr: $_firstCodeStr');

        if(_firstCodeStr. isEmpty ){
          setState(() {
            _firstCodeStr = currCodeStr;
          });

          _restartPinInput();
          return;
        }

        if(_firstCodeStr  == currCodeStr ){

          //  print('Pin code is The same....................');

          FocusScope.of(context).unfocus();

          Future.delayed(Duration(seconds: 1));

          Navigator.pop(context , _firstCodeStr);

          return;
        }


        TGlobalData().showToastInfo("两次输入不一致....");
        _firstCodeStr = '';
        _restartPinInput();
        return;
      }
      return ;
    }

    if(currStr.length > 2){
      _focusPos = min( idx + 1 , _maxPinCount - 1);
      setState(() {
        _pinCodeTxtCtrolorLs[idx].value = TextEditingValue(text: dummyChar + currStr[currStr.length - 1], selection: TextSelection.collapsed(offset: 2));
      });
      FocusScope.of(context).requestFocus(_pinCodeTxtFNodeLs[_focusPos]);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child:
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: (){FocusScope.of(context).unfocus();},
        child: Container(
          margin: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 5.0, 0, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40.0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Center(child: Text( _pinCodeTxt1.length == 6 ?  '请再次输入密码' :   '请设置安全密码' ,
                style: TextStyle(fontSize: 26 , fontWeight: FontWeight.bold),)),
              Center(child: Text('请输入安全密码，改密码将用于主账号管理设备\n查看设备时需要验证安全密码' ,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16 , color: Color(0xffaaaaaa),))),

/*
              Center(
                child: Wrap(
                  spacing: 10,
                  children: [

                    ...<int>[for(int i =0 ; i < _pinCodeTxtCtrolorLs. length ; i ++) i].map((idx) {

                      return SizedBox(width: 46,height: 46,
                            child: TextField(
                              controller: _pinCodeTxtCtrolorLs[idx],
                              focusNode:  _pinCodeTxtFNodeLs[idx],
                              textAlign: TextAlign.right,
                              textAlignVertical: TextAlignVertical.top,
                              showCursor: false,
                              selectionControls: null,
                               autofocus: idx == 0 ?  true : false,
                              keyboardType: TextInputType.number,
                              onChanged: (str) => _pinCodeTxtChged(str,idx) ,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: TGlobalData().crMainThemeColor,width: 2.0),
                                    borderRadius: BorderRadius.circular(6.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6.0),
                                    borderSide: BorderSide(color: (_pinCodeTxtCtrolorLs[idx].text.length >= 2) ?
                                    TGlobalData().crMainThemeColor  : Color(0xffbbbbbb)) ,
                                ),
                              ),
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),

                            )
                      );

                     }).toList(),

                ],),
              ),

 */

              PinCodeTextField(
                // key: UniqueKey(),
                appContext: context,
                pastedTextStyle: TextStyle(
                  color: Colors.green.shade600,
                  fontWeight: FontWeight.bold,
                  // fontSize: 50,
                ),
                textStyle: TextStyle(fontSize: 30),
                length: 6,
                autoFocus: true,
                focusNode: _pinInputNode,
                // obscureText: false,
                //  obscuringCharacter: '*',
                // obscuringWidget: FlutterLogo(  size: 24, ),
                // blinkWhenObscuring: true,
                animationType: AnimationType.fade,
                // validator: (str) {
                //   print(str);
                //   if (str!.length == 6) {
                //   //  textEditingController.text = '';
                //     return null;
                //   } else {
                //     return null;
                //   }
                // },
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldWidth: 46,
                  fieldHeight: 50,
                  selectedColor: TGlobalData().crMainThemeColor,
                  selectedFillColor: Colors.transparent,
                  activeColor: TGlobalData().crMainThemeColor,
                  activeFillColor: Colors.white,
                  inactiveColor: TGlobalData().crGreyBB,
                  inactiveFillColor: Colors.transparent,
                ),
                // cursorColor: Colors.transparent,
                showCursor: false,
                animationDuration: Duration(milliseconds: 300),
                // enableActiveFill: true,
                //errorAnimationController: errorController,
                controller: _pinCodeTxtCtrlor,
                keyboardType: TextInputType.number,
                // boxShadows: [
                //   BoxShadow(
                //     offset: Offset(0, 1),
                //     color: Colors.black12,
                //     blurRadius: 10,
                //   )
                // ],
                onCompleted: (str) async {
                  //  print("  Completed....................");

                  if(_pinCodeTxt2.isEmpty)
                    Future.delayed(Duration(milliseconds:  500)).then((value) {
                      _pinCodeTxtCtrlor.text = '';
                      FocusScope.of(context).requestFocus(_pinInputNode);
                    });

                  if(_pinCodeTxt1.length == 6 && _pinCodeTxt2.length == 6){

                    if(_pinCodeTxt1 == _pinCodeTxt2){
                      // print('is the same......');

                      FocusScope.of(context).unfocus();

                      await Future.delayed(Duration(seconds: 1));


                      Navigator.pop(context , _pinCodeTxt1);
                      return;
                    }else{
                      TGlobalData().showToastInfo("两次输入不一致....");

                      Future.delayed(Duration(milliseconds:  500)).then((value) {
                        _pinCodeTxtCtrlor.text = '';
                        setState(() {
                          _pinCodeTxt1 = '';
                          _pinCodeTxt2 = '';
                        });
                        FocusScope.of(context).requestFocus(_pinInputNode);

                      });

                    }
                  }

                },
                // onTap: () {
                //   print("Pressed");
                // },
                onChanged: (str) {
                  print(str);
                  setState(() {
                    if(_pinCodeTxt1.length != 6) {
                      // print('!!!===== 6');
                      _pinCodeTxt1 = str;
                      _pinCodeTxt2 = '';
                      return;
                    }

                    if(_pinCodeTxt1.length == 6) {
                      //  print('======== 6');
                      _pinCodeTxt2 = str;
                    }
                  });


                },
                beforeTextPaste: (text) {
                  //print("Allowing to paste $text");
                  //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                  //but you can show anything you want here, like your pop up saying wrong paste format or etc
                  return true;
                },
              ),


              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 2),
                child: Image.asset('images/pngs/lockDev.png' ,
                  height: MediaQuery.of(context).size.height / 5.0 * 1.6,
                  fit: BoxFit.scaleDown,),
              ),


              // ElevatedButton(onPressed: (){
              //   FocusScope.of(context).nextFocus();
              // }, child: Text('next focusWid')),

              Padding(
                padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                child: ElevatedButton(
                  onPressed: (){

                    Navigator.pop(context);


                  },
                  child: Text('取  消' , style: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
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
    );
  }
}











class _TSetupPairCodeWnd extends StatefulWidget {

   final Function func;
  String pairNum ;
  _TSetupPairCodeWnd(this.pairNum , this.func);

  @override
  _TSetupPairCodeWndState createState() => _TSetupPairCodeWndState();
}

class _TSetupPairCodeWndState extends State<_TSetupPairCodeWnd> {


  //String _pairNum = TGlobalData().generateRndNumberStr(6);


  int _seconds = 120;




  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 1)).then((value) {
     // widget.func(_pairNum);
      _secondTmr();
    });
  }

  @override
  void deactivate() {
    print('${this.runtimeType.toString()} deactivate()......................');
  }

  @override
  void dispose() {
    print('${this.runtimeType.toString()} dispose()......................');

    _seconds = -1;
    super.dispose();
  }


  void _secondTmr() {

    bool isDone  = widget.func();
    if(isDone){
      _seconds = 0;
       Navigator.pop(context , 1);
        return;
    }

    if(_seconds < 0 ) return;

    setState(() {
      _seconds --;
    });

    if(_seconds > 0){

      Future.delayed(Duration(seconds: 1)).then((value) {
        _secondTmr();
      });

      return;
    }

    Navigator.pop(context);

  }


  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric (horizontal:  MediaQuery.of(context).size.width / 11.0,
                                      vertical:  MediaQuery.of(context).size.height / 4.6 ),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular( 40.0),
    ),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [

      Center(child: Text('配对验证码' , style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),)),

      Center(child: Text('请在锁上输入以下配对码，以完成验证' , style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16 , color: Color(0xff888888)),)),

      Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Color(0xffbbbbbb)),
        ),
          child: Text( widget.pairNum,
            textAlign: TextAlign.center,
            style: TextStyle(letterSpacing: 3.0 ,fontSize: 40,fontWeight: FontWeight.w800),)
      ),


      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //  crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('6位数字配对码',style: TextStyle( fontSize: 16, color: Color(0xffaaaaaa),   )),
            Text('${_seconds}S' , style: TextStyle( fontSize: 18, color: Color(0xffFFAB2A), fontWeight:FontWeight.bold ),),
          ],
        ),
      ),


      Padding(
        padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
        child: ElevatedButton(
          onPressed: (){

            Navigator.pop(context);

            // Future.delayed(Duration(seconds: 3)).then((value) {
            //
            //
            // });

            // Navigator.push(context, MaterialPageRoute(builder: (context) => TScanLockWnd()));

            //   Navigator.pushReplacement(
            //     context,
            //     MaterialPageRoute(builder: (context) => TLogingWnd()),
            //     //MaterialPageRoute(builder: (context) => TDevMainWnd()),
            //   );
          },
          child: Text('输入完成' , style: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
          style: ElevatedButton.styleFrom(
            primary: TGlobalData().crMainThemeColor,
            onPrimary: TGlobalData().crMainThemeOnColor,
            shadowColor: Colors.white,
            padding: EdgeInsets.all(10.0),
            shape: StadiumBorder(),

          ),
        ),
      ),


      ] ),

      )
    );
  }
}




















class _TSetupLockNameWnd extends StatefulWidget {

  final String devId;
  final String macStr;
  _TSetupLockNameWnd(this.devId , this.macStr);

  @override
  _TSetupLockNameWndState createState() => _TSetupLockNameWndState();
}


class _TSetupLockNameWndState extends State<_TSetupLockNameWnd> {


    final TextEditingController  _lockNameTxtCtrlor  = TextEditingController();


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
    return Material(
      color: Colors.transparent,
      child:
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: (){FocusScope.of(context).unfocus();},
        child: Container(
          margin: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 5.0, 0, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40.0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Center(child: Text(  '请给设备命名'  ,
                style: TextStyle(fontSize: 26 , fontWeight: FontWeight.bold),)),
              Center(child: Text('给您的设备命名吧，查找设备更方便' ,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16 , color: Color(0xffaaaaaa),))),

             // SizedBox(height: 20,),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: TextField(
                  controller:  _lockNameTxtCtrlor,
                  autofocus: true,
                  onChanged: (str) {},
                  decoration: InputDecoration(
                    hintText: '请设置设备名，限8字',
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: TGlobalData().crMainThemeColor,width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: TGlobalData().crCommonGrey     ) ,
                    ),
                  ),
                  style: TextStyle(fontSize: 18, ),

                ),
              ),


              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 2),
                child: Image.asset('images/pngs/noLockDev.png' ,
                  height: MediaQuery.of(context).size.height / 5.0 * 1.6,
                  fit: BoxFit.scaleDown,),
              ),


              Padding(
                padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                child: ElevatedButton(
                  onPressed: _lockNameTxtCtrlor.text.trim().isEmpty ? null : () async {

                    List<String> tmpStrLs = [
                                            widget.macStr,
                                            widget.devId,  // iOs and android is different
                                            _lockNameTxtCtrlor.text.trim(),
                                            TBleSingleton().Userid.toString(),
                                            TBleSingleton().keepDfk,
                                            ];

                    print(tmpStrLs);



                    Map<String , dynamic> tmpOjb = {
                      // 'token': TGlobalData().currUserToken(),
                      'access_token':TGlobalData().currUserAcceToken()   ,
                      'lock_id':tmpStrLs[0],
                      'lock_name': tmpStrLs[2],
                      'lock_uid': tmpStrLs[3],
                      'aeskey':tmpStrLs[4],
                    };

                    print('auth new lock: $tmpOjb');


                     final rtnObj = await  TRemoteSrv(). authNewLock( tmpOjb);
                     int code = rtnObj['code'];
                     if(code == 0){
                       print('keep new lock: $tmpStrLs');
                       TGlobalData().keepLockByDevId(tmpStrLs);
                     }

                    Navigator.pop(context , 1);

                  },
                  child: Text('确  定' , style: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
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
    );
  }

  //
  // Future _authNewLockDev(String lockId, String doorName , String userId) async {
  //
  //
  //   Map<String , dynamic> tmpOjb = {
  //     'token': TGlobalData().currUserToken(),
  //     'device_id':lockId,
  //     'name': doorName,
  //     'user_id':userId,
  //     // 'id':'1',
  //     // 'device_id2':'2',
  //
  //   };
  //
  //   //  TRemoteSrv(). authNewLock( tmpOjb);
  //
  //
  //
  // }



}









