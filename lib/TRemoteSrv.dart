
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



import 'package:convert/convert.dart';


import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

import 'TGlobal_inc.dart';


typedef void tootSendProgressFunc(int val,int total);

// api1.smartlock.com 内网
// testapi.ultronlocker.com 外网测试
// api.ultronlocker.com 正式


// "http://api1.smartlock.com"; // 内网测试
// "https://testelinkapi.aoidc.net"; // 外网测试
// "https://elinkapi.aoidc.net"; // 生产环境

class TRemoteSrv {

  static final _singleton = TRemoteSrv._();
  factory TRemoteSrv() => _singleton;


  TRemoteSrv._() {
    // new Future.delayed(Duration(milliseconds:   0)).then((_) {
    //   loadPreferences();
    // });
  }


  Future<Map> fetchVCode (String pnum) async {

    Map<String,dynamic> queryParameters = {
      'ac':'send_code',
      'ct':'common',
      'ts': '${DateTime.now().millisecondsSinceEpoch}'
    };


    Map<String,dynamic> tmpOjb = {
      'type': '1',
      'account' : pnum,
    };


    return   await  _doHttpPost(queryParameters, tmpOjb);
  }


  Future<Map<String, dynamic> > loginForToken (String pnum , String vcode) async {

    Map<String , dynamic> queryParameters = {
      'ac':'login',
      'ct':'common',
    };

   // {code: 0, msg: successful, timestamp: 1626691542, data: {token: mskfrg2okng3mt0392374h92o0, phone: 85593618123, uid: 39f392a3d2ad4897, username: ecf217784d6eca4a, avatar: https://statictest.ultronlocker.com/avatar/617c8f641d105ca5bd0d3cd797538ae2.jpg, nickname: null, is_new: 1}}

    Map<String , dynamic> tmpOjb = {
      'account': pnum,
      'code' : vcode,
    };


    return   await   _doHttpPost(queryParameters, tmpOjb);;
  }


  Future<Map<String, dynamic> > refreshAccessToken ( ) async {

    Map<String , dynamic> queryParameters = {
      'ac':'refresh_access_token',
      'ct':'common',
    };

    Map<String , dynamic> tmpOjb = {
      'refresh_token': TGlobalData().currUserToken(),
    };

    return   await   _doHttpPost(queryParameters, tmpOjb);
  }















  Future<Map<String, dynamic> > refreshNewToken ( ) async {

    Map<String , dynamic> queryParameters = {
      'ac':'refresh_token',
      'ct':'common',
    };

    // {code: 0, msg: successful, timestamp: 1626691542, data: {token: mskfrg2okng3mt0392374h92o0, phone: 85593618123, uid: 39f392a3d2ad4897, username: ecf217784d6eca4a, avatar: https://statictest.ultronlocker.com/avatar/617c8f641d105ca5bd0d3cd797538ae2.jpg, nickname: null, is_new: 1}}

    Map<String , dynamic> tmpOjb = {
      'refresh': '1',
    };


    return   await   _doHttpPost(queryParameters, tmpOjb);;
  }


  Future<Map<String, dynamic> > oneUserInfo(String uid, String lockId  ) async {

    Map<String , dynamic> queryParameters = {
      'ac':'user_detail',
      'ct': 'admin_center'
    };

    // {code: 0, msg: successful, timestamp: 1626691542, data: {token: mskfrg2okng3mt0392374h92o0, phone: 85593618123, uid: 39f392a3d2ad4897, username: ecf217784d6eca4a, avatar: https://statictest.ultronlocker.com/avatar/617c8f641d105ca5bd0d3cd797538ae2.jpg, nickname: null, is_new: 1}}

    Map<String , dynamic> tmpOjb = {
      'token': TGlobalData().currUserToken()   ,
      'uid':  uid,
      'lock_id':lockId
    };

    return   await    _doHttpPost(queryParameters, tmpOjb );

  }

  Future<Map<String, dynamic> > deleteOneUser(String uid, String lockId) async {

    Map<String , dynamic> queryParameters = {
      'ac':'delete_user',
      'ct': 'admin_center'
    };

    // {code: 0, msg: successful, timestamp: 1626691542, data: {token: mskfrg2okng3mt0392374h92o0, phone: 85593618123, uid: 39f392a3d2ad4897, username: ecf217784d6eca4a, avatar: https://statictest.ultronlocker.com/avatar/617c8f641d105ca5bd0d3cd797538ae2.jpg, nickname: null, is_new: 1}}

    Map<String , dynamic> tmpOjb = {
      'token': TGlobalData().currUserToken(),
      'delete_uid': uid,
      'lock_id':lockId
    };

    return   await   _doHttpPost(queryParameters, tmpOjb);

  }


  Future<Map<String, dynamic> > updateUsernamePhoto ( String? un , String? photo ) async {

    Map<String , dynamic> queryParameters = {
      'ac':'save_profile',
    };

    Map<String , dynamic> tmpOjb = {
      'token': TGlobalData().currUserToken(),
      //'nickname' : un,
     // 'avatar': 'afafasf.jpg',
    };

    if(un != null)
    tmpOjb['nickname'] = un  ;

    if(photo != null)
      tmpOjb['avatar'] = photo  ;


    return   await   _doHttpPost(queryParameters, tmpOjb);
  }

  Future<Map<String, dynamic> > authNewLock(Map<String , dynamic> inObj) async {

    Map<String , dynamic> queryParameters = {
      'ac':'auth_door',
      // 'ct':'common',
    };

    return  await  _doHttpPost(queryParameters, inObj);

  }


  Future<Map<String, dynamic> > renameLock( String lockId , String nName) async {

    Map<String , dynamic> queryParameters = {
      'ac':'update_lock_name',
      // 'ct':'common',
    };

    Map<String , dynamic> tmpOjb = {
      'access_token': TGlobalData().currUserAcceToken(),
      'lock_id':lockId,
      'name': nName,
    };


    return   await   _doHttpPost(queryParameters, tmpOjb);

  }

  Future<Map<String, dynamic> > allDoorLocksList() async {

    Map<String , dynamic> queryParameters = {
      'ac':'list_door',

    };

    Map<String , dynamic> tmpOjb = {
     // 'token': TGlobalData().currUserToken(),
      'access_token': TGlobalData().currUserAcceToken()  ,

    };

    return   await   _doHttpPost(queryParameters, tmpOjb);

  }

  Future<Map<String, dynamic> > oneLockInfo(String lockId) async {

    Map<String , dynamic> queryParameters = {
      'ac':'show_door',
    };


    print('lock_id: $lockId');

    Map<String , dynamic> tmpOjb = {
      'access_token': TGlobalData().currUserAcceToken(),
      'lock_id':lockId,
    };


    return  await   _doHttpPost(queryParameters, tmpOjb);

  }


  Future<Map<String, dynamic> > oneLockAseKey(String lockId) async {

    Map<String , dynamic> queryParameters = {
      'ac':'get_key',
    };


    Map<String , dynamic> tmpOjb = {
      'access_token': TGlobalData().currUserAcceToken(),
      'lock_id':lockId,
    };


    return  await   _doHttpPost(queryParameters, tmpOjb);

  }



  Future<Map<String, dynamic> > deleteOneLock(String lockId) async {

    Map<String , dynamic> queryParameters = {
      'ac':'del_door',
    };

    Map<String , dynamic> tmpOjb = {
      'access_token': TGlobalData().currUserAcceToken(),
      'lock_id' : lockId,
    };


    return   await   _doHttpPost(queryParameters, tmpOjb);

  }



  // Future<Map<String, dynamic> > submitLockLog(String lockId , int evtType ) async {
  //
  //   Map<String , dynamic> queryParameters = {
  //     'ac':'add_open_log',
  //     // 'ct':'index',
  //   };
  //
  //
  //   Map<String , dynamic> tmpOjb = {
  //     'access_token': TGlobalData().currUserAcceToken(),
  //     'id':lockId,
  //     'type':evtType,
  //   };
  //
  //
  //   return   await   _doHttpPost(queryParameters, tmpOjb);
  //
  // }

  Future<Map<String, dynamic> > batchSubmitLockLog(List< Map<String , dynamic> > inObjLs, String lockId ) async {

    Map<String , dynamic> queryParameters = {
      'ac':'batch_open_log',
      // 'ct':'common',
    };

    Map<String , dynamic> tmpOjb = {
      'access_token': TGlobalData().currUserAcceToken(),
       'logs':  inObjLs,
      'lock_id': lockId ,
    };

   // print( json.encode(  tmpOjb)  );

    return   await   _doHttpPost(queryParameters, tmpOjb);

  }

  Future<Map<String, dynamic> > pullLockLogs(String lockId,   int pageIdx ,  int evttype   , String evtdt   ) async {


    print('lock id: $lockId');

    Map<String , dynamic> queryParameters = {
      'ac':'list_logs',
      // 'ct':'index',
    };

    Map<String , dynamic> tmpOjb = {
      'access_token': TGlobalData().currUserAcceToken(),
      'lock_id' : lockId ,
      'page':pageIdx,
     // 'evttype'   : evttype,
     //  'evtdate' : evtdt
    };

    if( evttype > 0  )
      tmpOjb['evttype'] = evttype;

    if( evtdt.isNotEmpty )
      tmpOjb['evtdate'] = evtdt;

    return  await    _doHttpPost(queryParameters, tmpOjb);

  }

  Future<Map<String, dynamic> > pullNotifyMsg(int pageIdx , int pageSize ) async {

    Map<String , dynamic> queryParameters = {
      'ac':'list_msg',
      'ct':'index',
    };

    // {code: 0, msg: successful, timestamp: 1626691542, data: {token: mskfrg2okng3mt0392374h92o0, phone: 85593618123, uid: 39f392a3d2ad4897, username: ecf217784d6eca4a, avatar: https://statictest.ultronlocker.com/avatar/617c8f641d105ca5bd0d3cd797538ae2.jpg, nickname: null, is_new: 1}}

    Map<String , dynamic> tmpOjb = {
      'access_token': TGlobalData().currUserAcceToken(),
      'page':pageIdx,
      'pagesize': pageSize,
    };


    return   await   _doHttpPost(queryParameters, tmpOjb);

  }



  // Future<Map<String, dynamic> > pushOneLockLog(String lockId , int evtType ) async {
  //
  //   Map<String , dynamic> queryParameters = {
  //     'ac':'add_open_log',
  //     // 'ct':'index',
  //   };
  //
  //
  //   Map<String , dynamic> tmpOjb = {
  //     'access_token': TGlobalData().currUserAcceToken(),
  //     'id':lockId,
  //     'type':evtType,
  //   };
  //
  //
  //   return   await   _doHttpPost(queryParameters, tmpOjb);
  //
  // }


  Future<Map<String, dynamic> > fetUserAgreementAndPrivPolicy( String type  ) async {

    Map<String , dynamic> queryParameters = {
      'ac':type,
      'ct': 'agreement',
    };

    Map<String , dynamic> tmpOjb = {
      'token': TGlobalData().currUserToken(),
    };

    return   await   _doHttpPost(queryParameters, tmpOjb);

  }






  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////


  Future<Map<String, dynamic> > uploadFileByDio(  File imgFile , tootSendProgressFunc ? progressFunc) async {
    var dio = new Dio();
    dio.options.baseUrl = TGlobalData.srvBaseUrl;
    dio.options.connectTimeout = Duration(seconds: 30); //30s
    dio.options.receiveTimeout = Duration(seconds: 30);
    dio.options.headers = {
      'token':TGlobalData().currUserToken(),

    };

  //  http.ByteStream(imgFile.openRead());

   // print('Upload file...... ${imgFile.path}');

    FormData formData = FormData.fromMap(
        {
          'token':TGlobalData().currUserToken(),
          'gid': DateTime.now().millisecondsSinceEpoch.toString(),
          'chunk': 0,
          'chunks': 1,
          'avatar': MultipartFile.fromBytes(imgFile.readAsBytesSync(), filename: basename(imgFile.path))
        });

    var response = await dio.post("?ac=upload",
    data: formData,
    options: Options(
        method: 'POST',
        //contentType: 'multipart/form-data'
        contentType: 'application/x-www-form-urlencoded'
    ),
      // onSendProgress: (int currVal, int totalVal){
      //   print('uploading: $currVal / $totalVal  ....');
      // }
      onSendProgress: progressFunc,

    );

    print("Response status: ${response.statusCode}");
    print("Response data: ${response.data}");

    return response.data as Map<String,dynamic>;

    // Map<String , dynamic> jsonObj = {};  //
    // try{
    //   jsonObj = json.decode(response.data as Map );
    // }catch(e){
    //   print(e);
    // }

   // print('upload img httpResp : $jsonObj');

   // return jsonObj;

  }

  static var httpClient = new HttpClient();
  Future<File> doDownloadFile(String url, String storePath) async {
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    //String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File(storePath);
    await file.writeAsBytes(bytes);
    return file;
  }


  Future<Map<String, dynamic> > _doHttpPost( Map<String , dynamic> queryObj , Map<String , dynamic> datObj) async {

    String csrf =   hex.encode(     TGlobalData().generateRndBytes(16) );

    queryObj[ 'ts' ] = DateTime.now().millisecondsSinceEpoch.toString();

    Uri tmpUri = Uri.parse(TGlobalData.srvBaseUrl);
    // Uri tmpUri = Uri.parse('https://testapi.ultronlocker.com/list_msg');

    print("curr Uri is : $tmpUri  ,  ${tmpUri.scheme}");

      String aaa =  'os=${Platform.isAndroid ? 'android' : 'ios'}&post_data=${TGlobalData().encryptHttpPost(datObj,  TGlobalData.aesFixKey ,  csrf)}';

     //  print('aaa = $aaa');
      //  print(csrf);
    // print(tmpUri.host);
    // print(tmpUri.path);


     var    httpResp  ;

    try{

       httpResp = await  http.post(

      tmpUri.scheme == 'http' ?
      Uri.http(tmpUri.host, tmpUri.path, queryObj)
      :
      Uri.https(tmpUri.host, tmpUri.path, queryObj) ,

      headers:   <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json; charset=UTF-8',
        'csrf' : csrf,
        'ENCRYPT':'1',
        'lang':'en',
       // 'debug':'1',
        //'os': Platform.isAndroid ? 'android' : 'ios',
      },
     // body: 'os=${Platform.isAndroid ? 'android' : 'ios'}&post_data=${TGlobalData().encryptHttpPost(datObj,  TGlobalData.aesFixKey ,  csrf)}',
       body: aaa,
    );


    }catch(  e){
      print(e);
    }


      if(httpResp == null)
       return  {};


    print( '===============  http return byte len: ${httpResp.bodyBytes.length}' );

   // final String bodyStr = utf8.decode(httpResp.bodyBytes)  ;
    final String bodyStr = (httpResp.body)  ;

   // print('Login Resp: $bodyStr');

    if(bodyStr.startsWith('<html>')){
      print(bodyStr);
      TGlobalData().showToastInfo(bodyStr);
      return {};
    }

      final Map<String , dynamic>  jsonObj  = TGlobalData().decrytpHttpRespon( bodyStr  , TGlobalData.aesFixKey  , csrf);

   // print(jsonObj.toString());


  //   curl -X POST    -d 'os=android&post_data=UGkbC_4XmCsoo74SKbjCetcBBuLkXUaJGGAUvsH6rf5_IxreJPd1VyAEgT6naZH3OQkdSu9klSqkPWjavnYNbLzDaIvrd1QAL87jPcuSzAOrzQYvK6RAGdTn4s5P6zUALemraIdLVInEpe2f6KC01Ez4XgQwS1ySMZacXRg_LRNfJsC6VosqaPWq-vdYoxqkeGRmK7-Dpvoruwf5xhvQv6t_J4iGVy-zZO_xWOmx1sCXjIqEJLNXnX3CDBj6F8j30yG-wojWElphJeq3zoml5YiVctu5uOZSCtJh0iJyTMNW3gZyKKmlk4X7dZgrlwp0' -H 'content-type: application/x-www-form-urlencoded' -H 'token: ' -H 'csrf: 7d2cf6d2f991115393cdd1b842aaba75' -H 'ENCRYPT: 1' "http://api1.smartlock.com/?ac=batch_open_log"
   // return {};

/*
    Map<String , dynamic> jsonObj = {};  //
    try{
      jsonObj = json.decode(bodyStr);
    }catch(e){
      print(e);
    }


*/

     print('httpResp : $jsonObj');

  if(jsonObj.isNotEmpty && jsonObj['code'] != null){
    int code = jsonObj['code'];
    String msg = jsonObj['msg'];
    if(! handleHttpReturnCode(code , msg) )
      return {};
  }

    return jsonObj;

  }


  bool handleHttpReturnCode(int code , String msg){
   // print(code);
    switch(code){
      case -10001:
        doRefreshAccessToken();
        TGlobalData().showToastInfo(msg);
        return false;

      default:
        break;
    }

    return true;
  }

  void doRefreshAccessToken() async {

    //print('token: ${TGlobalData().currUserToken()}');

    final obj =  await refreshAccessToken();

   // print(obj);

    if(obj['code'] != null && obj['code'] == 0){
      TGlobalData().keepCurrUserAcceToken(obj['data']['access_token']);
      TGlobalData().showToastInfo('登陆信息已更新,　请重新操作！');
    }

  }




}
