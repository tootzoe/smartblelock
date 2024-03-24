import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/painting.dart';
import 'package:collection/collection.dart';




import '../TGlobal_inc.dart';
import '../TBleSingleton.dart';
import 'TUserDetailWnd.dart';


enum _TSyncUserStatus {Syncing , SyncOk , SyncFailed }

class TUserManagerWnd extends StatefulWidget {

 // TUserManagerWnd( );

  @override
  _TUserManagerWndState createState() => _TUserManagerWndState();
}


class _TUserManagerWndState extends State<TUserManagerWnd> {


  List<Map> _allUserObjLs = [];


  List<String > _syncTipStrLs = ['同步中，请稍后····' , '' , '同步失败，刷新重新同步'];


  _TSyncUserStatus _currSyncStatus = _TSyncUserStatus.Syncing;

  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

    _doSyncUserList();

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

  void _doSyncUserList(){

    Future.delayed(Duration(milliseconds: 500)).then((_) => _fetchUserList(false));

    Future.delayed(Duration(milliseconds: 5000)).then((_) {
      if(mounted){
        if(_currSyncStatus != _TSyncUserStatus.SyncOk)
          setState(() {
            _currSyncStatus = _TSyncUserStatus.SyncFailed;
          });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(  '人员资料',
        style: TextStyle(color: Color(0xff222222), fontSize: 20, fontWeight: FontWeight.bold), ),
      elevation: 0.0,
      backgroundColor: Color(0xfffafafa),
      iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: () async  { await Navigator.push(  context,  MaterialPageRoute(builder: (context) => _TNewUserNicknameWnd() ));
                 _doSyncUserList();
              },
              icon: Icon(Icons.add , size: 32,))
        ],
      ),
      body: Container(
          color: Color(0xfffafafa),
          child: Stack(
            fit: StackFit.expand,
            children: [


              _allUserObjLs.isEmpty ?
              _noUserWid()
            : _allUserWid() ,


              if(_currSyncStatus != _TSyncUserStatus.SyncOk)
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  InkWell(
                    onTap: (){
                      if(_currSyncStatus == _TSyncUserStatus.Syncing)
                        return;
                      setState(() {
                        _currSyncStatus = _TSyncUserStatus.Syncing;
                      });
                      _doSyncUserList();
                    },
                    child: Container(
                    color: Color( _currSyncStatus == _TSyncUserStatus.Syncing ?   0x222C84FF : 0x22FF634E ),
                    //padding: EdgeInsets.all(8.0),
                      height: MediaQuery.of(context).size.height / 16.0,
                      child: Center(
                        child:    Text(  _syncTipStrLs [_currSyncStatus.index], style: TextStyle(fontSize: 14, color: Color(0xff666666)) ),
                      )
                    ),
                  ),
                ]),



              
              
              
            ]   )
      ),
    );

  }

  Future<void> _refreshUserLs() async
  {
    //
    //print('Do refresh user list,,,,.');
    _fetchUserList(false);

  }


  Widget _allUserWid(){

    double scrW = MediaQuery.of(context).size.width;
    double scrH = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 50, 20, 20),

      child: RefreshIndicator(
        onRefresh: _refreshUserLs,
        child: NotificationListener(
          onNotification: (notifi){
            // if( notifi is ScrollUpdateNotification ) {
            //   print(notifi.metrics.extentInside);
            //  // print(notifi.metrics.maxScrollExtent);
            //   print('\n');
            // }

            if( notifi is ScrollEndNotification  && notifi.metrics.extentAfter == 0){
              print(notifi.metrics.extentInside);
              _fetchUserList(false);
            }
            return false;
          },
          child: ListView.separated(
              itemCount: _allUserObjLs.length + 1,
              itemBuilder: (itctx , idx ) {

                String subTitle = '';
                if( idx < _allUserObjLs.length &&  _allUserObjLs[idx]['openNum'] as bool)
                  subTitle += '数字密码 /';

                if(idx < _allUserObjLs.length && _allUserObjLs[idx]['openFp'] as bool)
                  subTitle += ' 指纹 /';

                if(idx < _allUserObjLs.length && _allUserObjLs[idx]['openNfc'] as bool)
                  subTitle += ' NFC /';

                if(subTitle.isNotEmpty)
                   subTitle = subTitle.substring(0, subTitle.length - 1);


                if(idx == _allUserObjLs.length)
                  return SizedBox();

                return ListTile(
                  contentPadding: EdgeInsets.only(bottom: 10),
                 // leading: ClipOval(child: Image.file( File( TGlobalData().currUserPhotoUrl ),fit: BoxFit.fitWidth,)),
                  leading: CircleAvatar(
                      radius: 30,
                      backgroundImage:  FileImage(File( TGlobalData().currUserPhotoUrl )),
                  ),

                  title: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children:[

                       Padding(
                         padding: const EdgeInsets.symmetric(vertical: 8.0),
                         child: Text(_allUserObjLs[idx]['username'] ,
                                          style: TextStyle(color: Color(0xff222222), fontSize: 20, fontWeight: FontWeight.bold),),
                       ) ,


                        _allUserObjLs[idx]['isAdmin'] as bool ?
                        Container(
                          margin: EdgeInsets.only(left: 6.0),
                          padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
                           // color: TGlobalData().crMainThemeColor,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40.0),
                              color:  TGlobalData().crMainThemeColor,
                            ),
                            child: Text('管理员' , style: TextStyle(fontSize: 12, color: Colors.white),))
                      :  SizedBox()
                  ]) ,

                subtitle: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(subTitle),
                ),
                  trailing: Container(
                     // color: Colors.red,
                      height: double.infinity,
                      child: Icon(Icons.navigate_next, size: 32, color: Color(0xffbbbbbb),)),
                  onTap: () async {
                   // print('list item tapped......');

                   final rtn = await Navigator.push(context, MaterialPageRoute(builder: (ctx) => TUserDetailWnd(_allUserObjLs[idx])));

                  // if(rtn != null && rtn as bool)
                     _fetchUserList(true);

                  },

                );
              },
              separatorBuilder: (sctx , idx ) => Divider(),

          ),
        ),
      ),

    );
  }


  Widget _noUserWid(){

    double scrW = MediaQuery.of(context).size.width;
    double scrH = MediaQuery.of(context).size.height;


    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        Align(
          child: Image.asset('images/icons/noUser.png' ,
            width: scrW * .4,
            fit: BoxFit.fill,),
        ),


        Padding(
          padding: const EdgeInsets.all(26.0),
          child: Text('暂无人员' ,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: Color(0xff444444) , fontWeight: FontWeight.bold),),
        ),

        Padding(
          padding:   EdgeInsets.fromLTRB(scrW  * .25, 30, scrW * .25, 10),
          child: ElevatedButton(
            onPressed: () async {
            final rtn = await  Navigator.push(  context,  MaterialPageRoute(builder: (context) => _TNewUserNicknameWnd() ));

            ////  do add user to ble lock device.....


            },
            style: ElevatedButton.styleFrom(
              primary: Color(0xfff8f8f8),
              onPrimary: Colors.white,
              shadowColor: Colors.transparent,

              elevation: 0.0,
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              side: BorderSide(color: Color(0xffaaaaaa)),
            ),
              child: Text('添加人员' , style: TextStyle(fontSize: 20, color: Color(0xff444444)),),
          ),
        ),

      ],
    );
  }

  void _showUserList(List<dynamic> datLs){


    // _allUserObjLs.clear();

    for(int i = 0 ; i < datLs.length; i ++){
      List<dynamic> dyObj = datLs[i];

      var tmpObj = {};
      tmpObj['userid'] =  dyObj[0] as int;
      tmpObj['username'] = dyObj[1].toString();
      tmpObj['isAdmin'] = (dyObj[2] as int) == 1 ? true : false;
      tmpObj['openNum'] = (dyObj[3] as int) == 1 ? true : false;   // number open door
      tmpObj['openFp'] =  (dyObj[4] as int) == 1 ? true : false;
      tmpObj['openNfc'] = (dyObj[5] as int) == 1 ? true : false;
      tmpObj['bornDt'] =  dyObj[6] as int;

      tmpObj['userphoto'] = 'images/photos/beauty01.png';


      _allUserObjLs.add(tmpObj);

    }


    setState(() {  });


  }

  void _fetchUserList(bool fromStart) async {
   // print('_fetchUserList .... ');



    List<dynamic> allUserLs = [];
    Completer tmpC = Completer<void>();
    StreamSubscription<String> jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) {

    //  print('got jsonstr: $jsonStr');

      var jsonObj = jsonDecode(jsonStr);
      var userLs = jsonObj['sjcxyhlb'];

      if(userLs != null){
        allUserLs = userLs as List<dynamic>;
        tmpC.complete();
      }


    });

    if(fromStart) _allUserObjLs.clear();

    var jobj = {};
    jobj["sjcxyhlb"] =    _allUserObjLs.length;

    TBleSingleton().sendFramedJsonData(json.encode(jobj));

    await  tmpC.future;
    jsonSSub.cancel();

    if(allUserLs.isEmpty && _allUserObjLs.isEmpty){
      setState(() {
        _currSyncStatus = _TSyncUserStatus.SyncFailed;
      });
      return;
    }

    if(allUserLs.isEmpty && _allUserObjLs.isNotEmpty){
      TGlobalData().showToastInfo('已到末页....');
      return;
    }

    setState(() {
      _currSyncStatus = _TSyncUserStatus.SyncOk;
    });

   // print(allUserLs);
    _showUserList(allUserLs);

  }


}















class _TNewUserNicknameWnd extends StatefulWidget {


  @override
  _TNewUserNicknameWndState createState() => _TNewUserNicknameWndState();
}


class _TNewUserNicknameWndState extends State<_TNewUserNicknameWnd> {


  final _nicknameTxtCtrlor = TextEditingController();


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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(  '设置人员昵称',
        style: TextStyle(color: Color(0xff222222), fontSize: 20, fontWeight: FontWeight.bold), ),
        elevation: 0.0,
        backgroundColor: Color(0xfffafafa),
        iconTheme: IconThemeData(color: Colors.black),),
        body:GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: (){FocusScope.of(context).unfocus();},
          child: Container
          (
              padding: EdgeInsets.all(20.0),
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Text('设置人员昵称', style: TextStyle(fontSize: 26, color: Color(0xff222222) , fontWeight: FontWeight.bold)),


              Expanded(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    '支持中英文，数字（10个字符内）',
                    style: TGlobalData().tsListCntTS1,
                  ),
                ),
              ),

              Expanded(
                flex: 10,
                child: TextField(
                  controller: _nicknameTxtCtrlor,
                  decoration: InputDecoration(

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.black38),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.black38),
                    ),
                    suffixIcon:  _nicknameTxtCtrlor.text.isEmpty  ? null :  IconButton(icon: Icon(Icons.clear,color: TGlobalData().crMainThemeColor,),
                      onPressed: (){
                        setState(() {
                          _nicknameTxtCtrlor.clear();
                        });

                      } , )  ,

                  ),



                  onChanged: (str){
                    setState(() {  });
                  },
                ),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: TGlobalData().crMainThemeColor,
                  onPrimary: Color(0xff119999),

                  shape: StadiumBorder(),
                  shadowColor: Color(0xff118888),
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 0),
                  // textStyle: TextStyle(fontSize: 18, color: Colors.red),
                ),
                child: Text(
                  '确   定',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                onPressed: _nicknameTxtCtrlor.text.isEmpty  ? null :   () {

                  String str = _nicknameTxtCtrlor.text;
                  setState(() {
                    _nicknameTxtCtrlor.clear();
                  });

                  _appendNewUser(str);

                }  ,
              ),

              Expanded(flex :30,child:SizedBox()),

            ],
          )),
        ),


    );

  }

  Future<bool> _appendNewUser(String n) async {

    bool rtn = false;
    int uid = 0;
    Completer tmpC = Completer<void>();
    StreamSubscription<String> jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) {

      print('got jsonstr: $jsonStr');

      var jsonObj = jsonDecode(jsonStr);
      var newUserId = jsonObj['sjtjxyh'];

      if(newUserId != null){
        uid = int.parse(newUserId.toString());
      }

      tmpC.complete();

    });

    var jobj = {};
    jobj["sjtjxyh"] = n;

    TBleSingleton().sendFramedJsonData(json.encode(jobj));

    await  tmpC.future;
    jsonSSub.cancel();


    if(uid == 0){
      TGlobalData().showToastInfo('添加新用户失败....');
      return Future.value(rtn);
    }


    var tmpObj = {};
    tmpObj['username'] = n;
    tmpObj['userid'] = uid ;
    tmpObj['userphoto'] = 'images/photos/beauty01.png';
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => TUserDetailWnd(tmpObj)));

    return Future.value(rtn);
  }



}













