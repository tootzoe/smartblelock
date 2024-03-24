import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';


import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';

import '../TGlobal_inc.dart';
import '../TBleSingleton.dart';
import '../TRemoteSrv.dart';

enum _EvtFilter{ evtType, evtDt }

class TDoorEventWnd extends StatefulWidget {

  final String lockId;

  TDoorEventWnd(this.lockId);

  @override
  _TDoorEventWndState createState() => _TDoorEventWndState();
}


class _TDoorEventWndState extends State<TDoorEventWnd> {


  List<Map> _evtObjLs = [];
  List<Map> _evtObjLsBackup = [];

  late StreamSubscription<String> _jsonSSub ;

  bool _canSubmit = true;

  // static final List<String> _allEvtItemName = [
  //   '未知事件',
  //   '解除反锁',
  //   '开锁成功',
  //   '已上锁',
  // ];


  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

    _jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) => handleJsonStr(jsonStr));

    Future.delayed(Duration(milliseconds: 200)).then((_) => _fetchMoreLogData( ));


  }

  @override
  void deactivate() {
    print('${this.runtimeType.toString()} deactivate()......................');
  }

  @override
  void dispose() {
    print('${this.runtimeType.toString()} dispose()......................');

    _canSubmit = false;

    _jsonSSub.cancel();
    super.dispose();
  }


  bool _handleScrollNotification(ScrollNotification notification) {
   // print(notification);
    if (notification is ScrollEndNotification) {
      if (notification.metrics.extentAfter == 0) {
        _fetchMoreLogData( );
      }
     // print('Is ScrollEndNotification , ${notification.metrics.extentAfter}');
    }
    return false;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('门锁动态',
        style: TextStyle(color: Color(0xff222222),
            fontSize: 20,
            fontWeight: FontWeight.bold),),
        elevation: 0.0,
        backgroundColor: Color(0xffeeeeee),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          TextButton(onPressed: (){_deleteAllLogsFromDevFlash();}, child: Text('清除所有日记',style: TGlobalData().tsTxtFn16GreyAA,)),
        ],
      ),
      body: Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 4),
          color: Color(0xffeeeeee),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(

                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  InkWell(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32.0),
                        border: Border.all(color: Color(0xffbbbbbb)),
                      ),
                      child: Wrap(
                          spacing: 40,
                          children: [
                            Text('事件',
                                style: TextStyle(fontSize: 18, color: Color(
                                    0xff222222))),
                            Icon(Icons.arrow_drop_down,
                                color: Color(0xff444444)),
                          ]),
                    ),
                    onTap: () async {
                      bool isUpdate = await  _showEvtFiltterWnd(_EvtFilter.evtType);
                      if(isUpdate) setState(() {  });
                    },
                  ),


                  InkWell(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32.0),
                        border: Border.all(color: Color(0xffbbbbbb)),
                      ),
                      child: Wrap(
                          spacing: 20,
                          children: [
                            Text('选择日期',
                                style: TextStyle(fontSize: 18, color: Color(
                                    0xff222222))),
                            Icon(
                              Icons.arrow_drop_down, color: Color(0xff444444),),
                          ]),
                    ),
                    onTap: () async {
                    bool isUpdate = await  _showEvtFiltterWnd(_EvtFilter.evtDt);
                    if(isUpdate) setState(() {  });
                    },
                  ),
                ],
              ),


              Divider(),

              SizedBox(
                height: MediaQuery
                    .of(context)
                    .size
                    .height * .74,
                child:
                RefreshIndicator(
                  onRefresh: (){return _fetchMoreLogData( );} ,
                  child:
                  NotificationListener(
                    onNotification: _handleScrollNotification,
                    child: ListView.builder(
                        itemCount: _evtObjLs.length,
                        itemBuilder: (itCtx, idx) {
                          //  if(idx == 0){
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            minVerticalPadding: 0.0,
                            title: Container(
                              //  color: Colors.red,
                              // height: 144,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    (_evtObjLs[idx]['group'] as String).isNotEmpty
                                        ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0),
                                      child: Text(_evtObjLs[idx]['group'],
                                        style: TextStyle(
                                            color: Color(0xff888888)),),
                                    )
                                        : SizedBox.shrink(),

                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [

                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 12.0),
                                          child: Icon(_evtObjLs[idx]['icon'] ,
                                            color: Color(0xffbbbbbb), size: 24,),
                                        ),

                                        Column(
                                          children: [
                                            Icon(Icons.circle_outlined, size: 22,),
                                            idx == _evtObjLs.length - 1 ? SizedBox
                                                .shrink()
                                                : Container(height: 70,
                                              width: 1,
                                              color: Color(0xffaaaaaa),),
                                          ],
                                        ),

                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.fromLTRB(
                                                  12, 0, 4, 4),
                                              child: Text(  _evtObjLs[idx]['evtStr']  ,//   _allEvtItemName[_evtObjLs[idx]['evtStr'] ],
                                                style: TextStyle(fontSize: 20,
                                                    color: Color(0xff222222)),),
                                            ),

                                            Wrap(
                                              alignment: WrapAlignment.start,
                                              crossAxisAlignment: WrapCrossAlignment  .center,
                                              spacing: 10.0,
                                              children: [

                                                SizedBox(width: 1,),
                                                Icon(Icons.timer,
                                                  color: Color(0xffbbbbbb),
                                                  size: 20,),
                                                Text(DateFormat('HH:mm').format(
                                                    DateTime
                                                        .fromMillisecondsSinceEpoch(  _evtObjLs[idx]['dt']  )),
                                                  style: TextStyle(
                                                      color: Color(0xff444444)),),
                                              ],)

                                          ],
                                        ),

                                        Expanded(flex:1,child: SizedBox()),

                                        idx == 1 ? Container(
                                           // margin: EdgeInsets.only(left: 32.0),
                                            padding: EdgeInsets.fromLTRB(
                                                14, 3, 14, 3),
                                            decoration: BoxDecoration(
                                              color: Color(0xffdddddd),
                                              borderRadius: BorderRadius.circular(
                                                  20),
                                            ),
                                            child: Text('祁同伟',
                                              style: TextStyle(fontSize: 14),)
                                        )
                                            :
                                        SizedBox.shrink(),


                                      ],)
                                  ],
                                )),
                          );
                          // }

                          // return ListTile(
                          //   contentPadding: EdgeInsets.zero,
                          //   title: Text('test.....2222..'),
                          // );
                        }
                    ),
                  ),
                 ),
              ),


            ],
          )),
    );

  }


  void _deleteAllLogsFromDevFlash() async
  {

    /*
    //   Warning.!!!!    25Q64jvs1q , Chip erase need 14 seconds,
     */

    var jobj = {};

    jobj["sjscrj"] =  0;

     TBleSingleton().sendFramedJsonData(json.encode(jobj));

      await showDialog(context: context,
        builder: (BuildContext dctx){

        Future.delayed(Duration(seconds: 8)).then((value) => Navigator.pop(dctx));

          return Material(
            color: Colors.transparent,
            child: Container(
                margin: EdgeInsets.symmetric (horizontal:  MediaQuery.of(context).size.width / 4.0,
                    vertical:  MediaQuery.of(context).size.height / 2.8 ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular( 40.0),
               ),
                child:Center(
                  child: CircularProgressIndicator()  ,
                )

            ),
          );
        }) ;

  }


  Future<void> _fetchMoreLogData(  ) async
  {

    int fixPageSizeByPhpServer = 10;

    final tmpObj = await   TRemoteSrv().pullLockLogs( widget.lockId , 1  , -1  , '');

    if(tmpObj.isEmpty  || tmpObj['code'] == null || tmpObj['code'] != 0)
       return;

    int itemCnt = tmpObj['data']['total'];

    if(itemCnt < 1){
      TGlobalData().showToastInfo('暂无数据！');
      return;
    }


    //
    // List< Map<String , dynamic> > sendObjLs = [];
    //
    // for(int j = 0 ; j < 3 ; j ++){
    //
    //   //  [[0, 1, 32, 1, 1632911195], [1, 1, 32, 1, 1632911220]]
    //  // Map<String , dynamic> tmpObj = {'type':'${logObjLs[j][2] as int}' , 'addtime':((logObjLs[j][4] as int) * 1000).toString() , 'nickname':'wudaquan'};
    //   Map<String , dynamic> tmpObj = {
    //     'evttype': j + 1 , //logObjLs[j][2] as int ,
    //     'evttime': 1632911220  , //(logObjLs[j][4] as int) * 1000 ,
    //     'paratype' :2,
    //     'uid' :1,
    //     'nickname':'wudaquan'
    //   };
    //
    //   sendObjLs.add(tmpObj);
    // }
    //
    // // print(logObjLs.toString());
    //
    // TRemoteSrv().batchSubmitLockLog(sendObjLs, widget.lockId);




    //
    //
    // var jobj = {};
    //
    // jobj["sjcxrj"] =  0;
    // jobj["skip"] =  0; //_evtObjLs.length;
    //
    // TBleSingleton().sendFramedJsonData(json.encode(jobj));

  }

 /*
  List<Map> _generateCalendar(DateTime targetDt)
  {
    List<Map> rtn = [];

    var currMFD = DateTime(targetDt.year, targetDt.month);
    var nextMFD = DateTime(targetDt.year, targetDt.month + 1);

    int daysInM = nextMFD.difference(currMFD).inDays;

    List<String> _weekNameLs = ['日','一','二','三','四','五','六'];

    for(int i = 0  ; i < daysInM + 7 ; i ++){
      var tmpObj  = {};
      if(i < _weekNameLs.length)
        tmpObj['label'] =  _weekNameLs[i];
      else {
        tmpObj['label'] = '${i - 6}';
        tmpObj['isChecked'] = false;
      }

      rtn.add(tmpObj);
    }

    targetDt.day;

    for(int i = 0 ; targetDt.weekday != 7 &&  i  < targetDt.weekday ; i ++)
      rtn.insert(7, {});


    return rtn;
  }
*/

  List<Map> _filteEvtType(List<Map> evtLs){
    List<Map> rtnLs = [];

    List<String> checkDunplateLs = [];
    for(int i = 0 ; i < evtLs.length ; i ++){
      String txt = evtLs[i]['evtStr'];
      if(checkDunplateLs.contains(txt))
        continue;

      checkDunplateLs.add(txt);
      var tmpObj  = {};
      tmpObj['evtStr'] =  txt;
      tmpObj['isChecked'] = false;

      rtnLs.add(tmpObj);
    }
    return rtnLs;
  }

  Future<bool> _showEvtFiltterWnd(_EvtFilter type) async
  {

    List<Map> _evtTypeObjLs = [];

    if( _evtObjLsBackup.isNotEmpty)
      _evtTypeObjLs = _filteEvtType(_evtObjLsBackup);
    else if(_evtObjLs.isNotEmpty)
      _evtTypeObjLs = _filteEvtType(_evtObjLs);



    int _year = DateTime.now().year;
    int _month = DateTime.now().month;
     List<Map> _oneMonthByWeekObjLs = TGlobalData().generateCalendar(DateTime.now());


    final rtn = await showDialog(
        barrierColor: Colors.transparent,
        context: context,
        builder: (dctx) {

         // double scrW = MediaQuery.of(context).size.width;
          double scrH = MediaQuery.of(context).size.height;

          double appH = AppBar().preferredSize.height ;
          return StatefulBuilder(builder: (dctx, StateSetter setState){
          return Material(

            color: Colors.transparent,
            elevation: 0,
             shadowColor: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(dctx);
              },
              behavior: HitTestBehavior.deferToChild,
              child: Container(
                margin: EdgeInsets.fromLTRB(0, appH + 20 , 0,  0),

                color: Color(0x88000000),
                child: Container(
                   margin: EdgeInsets.fromLTRB(0,  0 , 0, 100),

                  padding: EdgeInsets.symmetric(horizontal: 20.0),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(30)),
                    // border: Border(),
                    // color: Colors.red,
                    color: Color(0xffeeeeee),

                  ),

                  child: Column(
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [

                          InkWell(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32.0),
                                border: Border.all(color: Color(0xffbbbbbb)),
                              ),
                              child: Wrap(
                                  spacing: 40,
                                  children: [
                                    Text('事件',
                                        style: TextStyle(fontSize: 18, color: Color(
                                            0xff222222))),
                                    type == _EvtFilter.evtType ? Icon(Icons.arrow_drop_up,
                                        color: TGlobalData().crMainThemeColor)
                                     : Icon(Icons.arrow_drop_down,
                                        color: Color(0xff444444)),

                                  ]),
                            ),
                            onTap: () {
                              if( type == _EvtFilter.evtType ){

                                String rtnStr = '';
                                for(int i = 0 ; i < _evtTypeObjLs.length ; i ++){
                                  if(_evtTypeObjLs[i]['isChecked']){
                                    rtnStr = _evtTypeObjLs[i]['evtStr'];
                                    break;
                                  }
                                }

                                Navigator.pop(dctx , rtnStr);
                                return;
                              }

                              setState(() {
                                type = _EvtFilter.evtType;
                              });
                            },
                          ),


                          InkWell(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32.0),
                                border: Border.all(color: Color(0xffbbbbbb)),
                              ),
                              child: Wrap(
                                  spacing: 20,
                                  children: [
                                    Text('选择日期',
                                        style: TextStyle(fontSize: 18, color: Color(
                                            0xff222222))),
                                    type == _EvtFilter.evtDt ? Icon(Icons.arrow_drop_up,
                                        color: TGlobalData().crMainThemeColor)
                                        : Icon(Icons.arrow_drop_down,
                                        color: Color(0xff444444)),
                                  ]),
                            ),
                            onTap: () {
                              if( type == _EvtFilter.evtDt ){

                                for(int i = 0 ; i < _oneMonthByWeekObjLs.length ; i ++){
                                   final ck = _oneMonthByWeekObjLs[i]['isChecked'];
                                   if(ck != null){
                                     if(_oneMonthByWeekObjLs[i]['isChecked'] ){
                                       int day = int.parse(  _oneMonthByWeekObjLs[i]['label']);
                                            Navigator.pop(dctx , [_year , _month , day]);
                                           return;
                                     }
                                   }

                                }

                                Navigator.pop(dctx);
                              }

                              setState(() {
                                type = _EvtFilter.evtDt;

                              });
                            },
                          ),
                        ],
                      ),


                      Divider(),


                      IndexedStack(
                        sizing: StackFit.expand,
                        index:  type.index ,

                        children: [

                          Container(
                            //color: Colors.red,
                            height: 380,
                            padding: EdgeInsets.only(top: 16.0),
                            child:
                            ListView.builder(
                                itemCount:  _evtTypeObjLs.length,
                                itemBuilder: (itCtx, idx){
                              return Container(
                               //  color: Colors.cyan,
                                child: ListTile(
                                  minVerticalPadding: 0,
                                  contentPadding: EdgeInsets.only(right: 20.0),

                                    title: Text(_evtTypeObjLs[idx]['evtStr']  ,
                                      style:_evtTypeObjLs[idx]['isChecked'] ?TGlobalData().tsListTitleTS1MainCr
                                        :  TGlobalData().tsListTitleTS1 ,),

                                  trailing: (_evtTypeObjLs[idx]['isChecked'] as bool ) ?
                                  Icon(Icons.check , color: TGlobalData().crMainThemeColor,)
                                  : null,

                                  onTap: (){
                                    bool oriB = _evtTypeObjLs[idx]['isChecked'] as bool;
                                    for(int i = 0 ; i < _evtTypeObjLs.length ; i ++)
                                      _evtTypeObjLs[i]['isChecked'] = false;

                                    _evtTypeObjLs[idx]['isChecked']   = !oriB;

                                    setState(() {  });
                                  },

                              ),
                              );

                            }),
                            ),




                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                TextButton(
                                    style: TextButton.styleFrom(
                                      primary: Colors.transparent,
                                    ),
                                    onPressed: (){
                                      var tmpDt = DateTime(_year, _month - 1 , 1);
                                      _year = tmpDt.year ;
                                      _month = tmpDt.month;

                                      _oneMonthByWeekObjLs = TGlobalData().generateCalendar(tmpDt);

                                      setState(() {});
                                    },
                                    child: Text('《' ,style: TextStyle(color: Color(0xff979797),fontSize: 20),)),

                                  Text(sprintf('%04i年%02i月', [_year , _month])  ,style: TextStyle(color: Color(0xff222222),fontSize: 20, fontWeight: FontWeight.bold),),

                                  TextButton(
                                      style: TextButton.styleFrom(
                                        primary: Colors.transparent,
                                      ),
                                      onPressed: (){

                                        var tmpDt = DateTime(_year, _month + 1 , 1);
                                        _year = tmpDt.year ;
                                        _month = tmpDt.month;

                                        _oneMonthByWeekObjLs = TGlobalData().generateCalendar(tmpDt);

                                        setState(() {});

                                      },
                                      child: Text('》' ,style: TextStyle(color: Color(0xff979797),fontSize: 20),)),


                                ],),



                              Container(
                                padding: EdgeInsets.only(top: 12.0),
                               // color: Color(0x110000ff),
                                height: 350,
                                child: GridView.count(
                                  controller: null,
                                    crossAxisCount: 7,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [

                           // ... List.generate(8, (index) => Text('$index')).toList(),
                                    ...<int>[for(int i = 0 ; i < _oneMonthByWeekObjLs.length ; i ++) i].map((idx) {

                                      bool isCk = false;
                                      if(_oneMonthByWeekObjLs[idx]['isChecked'] != null )
                                        isCk =  _oneMonthByWeekObjLs[idx]['isChecked'] as bool;

                                      if(idx < 7){
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 6.0),
                                          child: Center(child: Text(_oneMonthByWeekObjLs[idx]['label'],
                                                        style: TextStyle(color: Color(0xff888888),fontSize: 16),)),
                                        );
                                      }

                                      if( _oneMonthByWeekObjLs[idx]['isChecked'] == null)
                                        return SizedBox.shrink();


                                      return InkWell(
                                        onTap: (){
                                          bool oriB = (_oneMonthByWeekObjLs[idx]['isChecked'] as bool);
                                          for(int i = 7 ; i < _oneMonthByWeekObjLs.length ;  i ++)
                                            if( _oneMonthByWeekObjLs[i]['isChecked'] != null )
                                               _oneMonthByWeekObjLs[i]['isChecked'] = false;

                                          _oneMonthByWeekObjLs[idx]['isChecked'] = !oriB;
                                          setState(() {  });
                                        },
                                        child: Container(
                                         // color: Colors.green,
                                          margin: EdgeInsets.all(4.0),
                                          decoration: BoxDecoration(
                                            color: isCk ?  TGlobalData().crMainThemeColor : Colors.transparent,
                                            borderRadius: BorderRadius.circular(40.0),
                                          ),

                                            child: Center(child: Text(_oneMonthByWeekObjLs[idx]['label'] ,
                                              style: TextStyle(color: Color( isCk ? 0xffffffff : 0xff222222),fontSize: 18))),
                                        ),
                                      );
                                    }).toList(),

                                  // ...  _oneMonthByWeekObjLs.map((obj) {
                                  //     return Container(color: Colors.green,child: Text(obj['label']));
                                  //   }).toList(),

                                  ],
                                ),
                              ),



                            ],
                          ),

                        ],
                      ),


                    ],
                  ),

                ),
              ),

            ),
          );

          });

        });

    bool needUpdate = true;
    if(rtn != null){
    //  print(rtn);

      if( type == _EvtFilter.evtType ){

        String txt = rtn.toString();

        if(_evtObjLsBackup.isEmpty)
          _evtObjLsBackup .addAll(  _evtObjLs);
        _evtObjLs.clear();

        for(int i = 0 ; i < _evtObjLsBackup.length ; i ++){
          if(_evtObjLsBackup[i]['evtStr'] == txt){
            _evtObjLs.add(_evtObjLsBackup[i]);
          }
        }

      }else{

      List<int> intLs = rtn as List<int>;
      if(_evtObjLsBackup.isEmpty)
           _evtObjLsBackup .addAll(  _evtObjLs);
      _evtObjLs.clear();
     // print('_evtObjLsBackup len: ${_evtObjLsBackup.length}');
      for(int i = 0 ; i < _evtObjLsBackup.length ; i ++){
        DateTime dt = DateTime.fromMillisecondsSinceEpoch(_evtObjLsBackup[i]['dt']);
        if(dt.year == intLs[0] && dt.month == intLs[1] && dt.day == intLs[2]){
          _evtObjLs.add(_evtObjLsBackup[i]);
        }
      }
      }


    }else{
      if(_evtObjLsBackup.isNotEmpty){
        _evtObjLs.clear();
        _evtObjLs .addAll(  _evtObjLsBackup);
        _evtObjLsBackup.clear();
      }
    }

    return Future.value(needUpdate);
  }


  // void handleJsonStr(String jsonStr) async {
  //
  //   final jsonObj = jsonDecode(jsonStr);
  //
  //   final rjObj = jsonObj['sjcxrj'];
  //   if(rjObj != null){
  //
  //     List<dynamic> logObjLs  = rjObj as List<dynamic>;
  //
  //     if(logObjLs.isEmpty && _evtObjLs.isEmpty){
  //      TGlobalData().showToastInfo('当前无数据....');
  //       return;
  //     }
  //
  //     if(logObjLs.isEmpty && _evtObjLs.isNotEmpty){
  //       TGlobalData().showToastInfo('已到末页....');
  //       return;
  //     }
  //
  //     DateTime oldDt = DateTime (0);
  //     DateTime td  = DateTime.now();
  //     bool addGp = true;
  //
  //
  //     if(_evtObjLsBackup.isNotEmpty)
  //       {
  //         _evtObjLs.clear();
  //         _evtObjLs .addAll( _evtObjLsBackup) ;
  //         _evtObjLsBackup.clear();
  //       }
  //
  //
  //     logObjLs = logObjLs.reversed.toList();
  //
  //     List<Map> tmpDatMapLs = [];
  //     for (int i = 0; i < logObjLs.length; i ++) {
  //       List<dynamic> tmpObjLs = logObjLs[i];
  //
  //       int dtVal = (tmpObjLs[4] as int) * 1000;
  //       DateTime tmpDt = DateTime.fromMillisecondsSinceEpoch(dtVal);
  //
  //       String gpStr = '';
  //
  //
  //       if(tmpDt.year != oldDt.year || tmpDt.month != oldDt.month || tmpDt.day != oldDt.day) {
  //         addGp = true;
  //         oldDt = tmpDt;
  //       }
  //
  //       if(addGp){
  //         addGp  = false;
  //
  //         if(tmpDt.year == td.year && tmpDt.month == td.month && tmpDt.day == td.day)
  //             gpStr = '今天';
  //         else
  //           gpStr = DateFormat('yyyy.MM.dd').format(tmpDt);
  //
  //       }
  //
  //      String evtTxt = '';
  //       int enumVal = tmpObjLs[2] as int;
  //       if(enumVal < ResultCodeToApp_e.Rsl_Max.index){
  //         evtTxt =TGlobalData().rslToTxt( ResultCodeToApp_e.values[enumVal].toString().split('.').last );
  //       }
  //
  //       var tmpObj = {};
  //       tmpObj['logId'] =  tmpObjLs[0] as int;
  //       tmpObj['uid'] = tmpObjLs[1] as int;
  //       tmpObj['icon'] =  i == 1 ? Icons.lock_open : Icons.lock;
  //
  //       tmpObj['evtStr'] =   evtTxt;
  //       tmpObj['evtPara'] =tmpObjLs[3] as int;
  //       tmpObj['dt'] =  dtVal;
  //
  //       // if (i == 0)
  //       //   tmpObj['group'] = '今天';
  //       // else if (i == 3) {
  //       //   tmpObj['group'] = '2021.03.9';
  //       // } else
  //
  //           tmpObj['group'] = gpStr;
  //
  //       tmpDatMapLs.add(tmpObj);
  //      // _evtObjLs.add(tmpObj);
  //     }
  //
  //     if(tmpDatMapLs.isNotEmpty){
  //       _evtObjLs += tmpDatMapLs ; //.reversed.toList();
  //       setState(() {  });
  //     }
  //
  //
  //
  //   }
  //
  // }
  //

  void handleJsonStr(String jsonStr) async {
    final jsonObj = jsonDecode(jsonStr);

    final rjObj = jsonObj['sjcxrj'];
    if (rjObj != null) {
      List<dynamic> logObjLs = rjObj as List<dynamic>;

      if (logObjLs.isEmpty && _evtObjLs.isEmpty) {
        TGlobalData().showToastInfo('当前无数据....');
        return;
      }

      if (logObjLs.isEmpty && _evtObjLs.isNotEmpty) {
        TGlobalData().showToastInfo('已到末页....');
        return;
      }

      List< Map<String , dynamic> > sendObjLs = [];

      for(int j = 0 ; j < logObjLs.length ; j ++){

        //  [[0, 1, 32, 1, 1632911195], [1, 1, 32, 1, 1632911220]]
        Map<String , dynamic> tmpObj = {
          'evttype':logObjLs[j][2] as int ,
          'evttime':(logObjLs[j][4] as int) * 1000 ,
          'paratype' :2,
          'uid' :1,
          'nickname':'wudaquan'
        };

        sendObjLs.add(tmpObj);
      }

     // print(logObjLs.toString());

      TRemoteSrv().batchSubmitLockLog(sendObjLs, widget.lockId);



    }
  }




}