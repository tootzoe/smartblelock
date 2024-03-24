
import 'dart:io';
import 'dart:convert';
// import 'package:awesmartlock/TRemoteSrv.dart';
import 'TRemoteSrv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:convert/convert.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as pkgPath;
import 'dart:math';
import 'package:xml/xml.dart';
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:encrypt/encrypt.dart' as TAES;
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';




enum ResultCodeToApp_e {
  Rsl_None,
  Rsl_Err_Checksum_Err,
  Rsl_Err_Encrypt_Err,
  Rsl_Err_Data_Len_Err,
  Rsl_Err_Data_Struct_Err,
  Rsl_Err_Invalid_User_Id,
  Rsl_Err_Admin_Existed,
  Rsl_Err_Permisson_Insufficient,
  Rsl_Err_Datetime_Expire,
  Rsl_Err_Datetime_Incorrect,
  Rsl_Err_Out_Of_Datetime_Range,
  Rsl_Err_Out_Of_Passcode_Range,
  Rsl_Err_Out_Of_Log_Range,
  Rsl_Err_Log_Search_Reach_End,
  Rsl_Err_User_Not_Exist,
  Rsl_Err_Parameter_Error,
  Rsl_Err_Pair_Code_Not_Match,
  Rsl_Err_Open_Door_Failed,
  Rsl_Err_Close_Door_Failed,
  Rsl_Err_Unknow_Error,


  Rsl_Ok_Ok,
  Rsl_Ok_Close_Door_Ok,
  Rsl_Ok_Rename_lock_Ok,
  Rsl_Ok_Del_User_Ok,
  Rsl_Ok_Safety_Code_Done,
  Rsl_Ok_Pair_Code_Matched,
  Rsl_Ok_Set_Nickname_Ok,

  // Priv pwd
  Rsl_Pri_Pwd_Append_Ok,
  Rsl_Pri_Pwd_Append_Failed,
  Rsl_Pri_Pwd_Delete_Ok,
  Rsl_Pri_Pwd_Delete_Failed,
  Rsl_Pri_Pwd_Enabled,
  Rsl_Pri_Pwd_Disabled,
  Rsl_Pri_Pwd_Open_Lock_Ok,

  // Fingerprint
  Rsl_Fp_Enroll_Begin,
  Rsl_Fp_Enroll_Round_1_Ok,
  Rsl_Fp_Enroll_Round_2_Ok,
  Rsl_Fp_Enroll_Round_3_Ok,
  Rsl_Fp_Enroll_Round_4_Ok,
  Rsl_Fp_Enroll_Round_5_Ok,
  Rsl_Fp_Enroll_Round_6_Ok,
  Rsl_Fp_Enroll_Round_7_Ok,
  // Rsl_Fp_Enroll_Round_8_Ok, // last time is NOT reported
  Rsl_Fp_Enroll_Successful,
  Rsl_Fp_Enroll_Failed,
  Rsl_Fp_Delete_One_Fp_Ok,
  Rsl_Fp_Enabled,
  Rsl_Fp_Disabled,
  Rsl_Fp_Open_Lock_Ok,
  Rsl_Fp_Finger_Invalid,
  Rsl_Fp_Save_Data_Failed,
  Rsl_Fp_Unknow_Error,

// NFC
  Rsl_Nfc_Append_One_Nfc_Ok,
  Rsl_Nfc_Append_One_Nfc_Failed,
  Rsl_Nfc_Delete_One_Nfc_Ok,
  Rsl_Nfc_Delete_One_Nfc_Failed,
  Rsl_Nfc_Enabled,
  Rsl_Nfc_Disabled,
  Rsl_Nfc_Open_Lock_Ok,
  Rsl_Nfc_Unknow_Error,


  // onetime pwd
  Rsl_OneTime_Pwd_Append_Ok,
  Rsl_OneTime_Pwd_Append_Failed,
  Rsl_OneTime_Pwd_Delete_Ok,
  Rsl_OneTime_Pwd_Delete_Failed,
  Rsl_OneTime_Pwd_Enabled,
  Rsl_OneTime_Pwd_Disabled,
  Rsl_OneTime_Pwd_Open_Lock_Ok,

  // repeat pwd
  Rsl_Repeat_Pwd_Append_Ok,
  Rsl_Repeat_Pwd_Append_Failed,
  Rsl_Repeat_Pwd_Delete_Ok,
  Rsl_Repeat_Pwd_Delete_Failed,
  Rsl_Repeat_Pwd_Enabled,
  Rsl_Repeat_Pwd_Disabled,
  Rsl_Repeat_Pwd_Open_Lock_Ok,

  //
  // logs
  Rsl_Log_Delete_All_Log_Ok,
  Rsl_Log_Delete_One_Log_Ok,
  Rsl_Log_Delete_One_Log_Failed,

  Rsl_Max
}


enum BleConnStatus_e {
  Ble_ConnStatus_Init,
  Ble_ConnStatus_Connting,
  Ble_ConnStatus_Connted,
  Ble_ConnStatus_Disconntet,
  Ble_ConnStatus_Unkonw
}

enum LockerOperation_e{
  Locker_Op_None,
  Locker_Op_Open,
  Locker_Op_Authorize,
  Locker_Op_Unknow
}

enum UserOperationType_e{
  UserOp_None  ,
  UserOp_Was_Authorized ,
  UserOp_Open_Locker_OK ,
  UserOp_Open_Locker_Fialed ,
  UserOp_Was_Deleted ,

  UserOp_Unknow ,
  UserOp_Max
}

extension UserOpTypeToStr on UserOperationType_e {
  String get opTyStr {
    switch(this){
      case UserOperationType_e.UserOp_None: return "";
      case UserOperationType_e.UserOp_Was_Authorized: return "授权成功";
      case UserOperationType_e.UserOp_Open_Locker_OK: return "开锁成功";
      case UserOperationType_e.UserOp_Open_Locker_Fialed: return "开锁失败";
      case UserOperationType_e.UserOp_Was_Deleted: return "用户被删除";
      default: return "未知操作";
    }
  }
}

enum LockerOpenResult_e{
  Locker_Open_Init,
  Locker_Open_Ok,
  Locker_Open_Failed,
  Locker_Open_Unknow
}

enum UserType_e {
  UserType_None,
  UserType_Admin ,
  UserType_User,

  UserType_Unknow
}

extension UsertypeToStr on UserType_e {
  String get utstr {
    switch(this){
      case UserType_e.UserType_Admin: return "管理员";
      case UserType_e.UserType_User: return "用  户";
      default: return "";
    }
  }
}


enum AppCmdHeaderCode_e{
  AppCmd_None,
  AppCmd_Get_Locker_Info,
  AppCmd_Get_User_Info,
  AppCmd_Get_User_List,
  AppCmd_Do_User_Authorize,    //4
  //
  AppCmd_Do_User_Authorize_By_Admin,
  AppCmd_Do_Open_Locker,
  AppCmd_Get_Locker_Logs,
  AppCmd_Get_One_User_Locker_Logs,
  AppCmd_Do_Delete_User,         //9
  //
  AppCmd_Do_Datetime_Sync,
  AppCmd_Do_Rename_Door_Locker,
  AppCmd_Do_Reset_Locker_Flash,     // 12




  //// external cmds....
  AppCmd_Get_Locker_Info2,    //  0d
  AppCmd_Get_User_Info2,

  //
  AppCmd_Max_Count
}


  final Map<String, String>  _RslToTextMap = {

  'Rsl_Fp_Open_Lock_Ok':'指纹开锁成功',
    'Rsl_Pri_Pwd_Open_Lock_Ok':'用户密码开锁成功',
    'Rsl_OneTime_Pwd_Open_Lock_Ok':'一次性密码开锁成功',
    'Rsl_Repeat_Pwd_Open_Lock_Ok':'周期性开锁成功',

  };



//
// class TLockerInfoData {
//   int userId;
//   String lockerDoorName;
//   UserType_e userType;
//   LockerOperation_e currOperation;
//
//   int lockerCurrDatetime;
//   int authorizeDatetime;
//   int lastTouchDatetime;
//   int firmwareVersion;
//
//   String lastTouchUserName;
//   int currConnectedUserId;
//
//   String bleMacAddr;
//   LockerOpenResult_e lastTouchResult;
//   int lockerNum;
//  // String bleName;
//
//
//
//   TLockerInfoData(     // for TmainWnd list item
//   this. lockerDoorName,
//       this. userType,
//       this. currOperation,
//   this. lockerCurrDatetime,
//
//   this. authorizeDatetime,
//       this. lastTouchDatetime,
//       this. firmwareVersion,
//   this. lastTouchUserName,
//
//       this. currConnectedUserId,
//       this. bleMacAddr,
//
//   this. lastTouchResult,
//
//       this.lockerNum
//       );
//
//
//   // TLockerInfoData(){
//   //   userId = 0;
//   // }
//
//   String get fetLockerDoorName => lockerDoorName;
//   int get fetLockerCurrDatetime => lockerCurrDatetime;
//   int get fetAuthorizeDatetime => authorizeDatetime;
//   UserType_e get fetUserType=> userType;
//   String get fetLastTouchUserName=> lastTouchUserName;
//   int get fetLastTouchDatetime=> lastTouchDatetime;
//   LockerOpenResult_e get fetLastTouchResult=> lastTouchResult;
//   LockerOperation_e get fetCurrOperation=> currOperation;
//
//   int get fetFirmwareVersion=> firmwareVersion;
//   String get fetBleMacAddr => bleMacAddr;
//   int get fetLockerNum=> lockerNum;
//
//  // set keepDoorName(String dn){nickName = dn;}
//  // set keepPhotoUrl(String st){photoUrl = st;}
//
// }
//
//
//
// class TUserInfoData {
//   int userId;
//   String userName;
//   int authorizeDt;
//   UserType_e userType;
//   //
//   int permissionBits;
//   int validDateStart;
//   int validDateEnd;
//   int validTimeStart;
//   int validTimeEnd;
//   //
//   int validOpCount;
//   String phoneNum;
//   String photoUrl;
//
//   List<int> en_decryptKey = [];  // 24 bytes
//
//
//   TUserInfoData(
//       this. userId,
//       this. userName,
//       // this. authorizeDt,
//       // this. userType,
//       //
//       // this. permissionBits,
//       // this. validDateStart,
//       // this. validDateEnd,
//       // this. validTimeStart,
//       // this. validTimeEnd,
//       //
//       // this. validOpCount,
//       // this.en_decryptKey
//       this.photoUrl
//       );
//
//   int get fetUserId => userId;
//   String get fetUserName => userName;
//   int get fetAuthorizeDt => authorizeDt;
//   UserType_e get fetUserType=> userType;
//
//   int get fetPermissionBits=> permissionBits;
//   int get fetValidDateStart=> validDateStart;
//   int get fetValidDateEnd=> validDateEnd;
//   int get fetValidTimeStart=> validTimeStart;
//   int get fetValidTimeEnd=> validTimeEnd;
//
//   int get fetValidOpCount => validOpCount;
//   List<int> get fetEn_decryptKey=> en_decryptKey;
//   set keepPrivKey(List<int> key) => en_decryptKey = key;
//
//   String get fetPhoneNum => phoneNum;
//   String get fetPhotoUrl => photoUrl;
//    set keepPhoneNum(String s) => phoneNum;
//    set keepPhotoUrl(String s) => photoUrl;
//
// }
//
//
//

class TDevsSizeFit {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;

  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal = _mediaQueryData.padding.left +
        _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top +
        _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth -
        _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight -
        _safeAreaVertical) / 100;
  }
}


class TGlobalData {

  static final _singleton = TGlobalData._();
  factory TGlobalData() => _singleton;

  late SharedPreferences  appPrefs  ;

  //int currLoginUId = 1;
  String _phoneNum = "";
  String _passCode = "666666";
 // String _nickName = "";
 // String currPhotoUrl = "";
  //TUserInfoData thizUserInfoData;

 // Map<String , TUserInfoData> gUserInfoDataMap;
 // Map<String , TLockerInfoData> gLockerInfoDataMap;

  final List<int> defaultDes3EcbKeyLs = [0x94,0x74,0xB8,0xE8,0xC7,0x3B,0xCA,0x7D,
                                         0x12,0xBC,0x3D,0x91,0x7C,0x29,0xA1,0xF6,
                                         0x84,0xD9,0x9E,0x2A,0xC0,0xF1,0x8D,0x57
                                        ];


  // final List<int> defaultDes3EcbKeyLs = [0x7d, 0xca, 0x3b, 0xc7, 0xe8, 0xb8, 0x74, 0x94,
  //                                        0xf6, 0xa1, 0x29, 0x7c, 0x91, 0x3d, 0xbc, 0x12,
  //                                        0x57, 0x8d, 0xf1, 0xc0, 0x2a, 0x9e, 0xd9, 0x84
  // ];




  late final String _docPath ;

  List<Map> _notifyMsgLs = [];



  TGlobalData._() {
   // new Future.delayed(Duration(milliseconds:   0)).then((_) {
    //  loadPreferences();
   // });
  }

  int get companyFlagVal => 0xAEAC;

  Future<void> loadPreferences( ) async {
    _docPath =( await getApplicationDocumentsDirectory()).path;
    appPrefs = await SharedPreferences.getInstance();

    String dfUserPhoto = _docPath + '/dfPhoto.png';
      File tmpFile = File(dfUserPhoto);
    if(!tmpFile.existsSync()){
      rootBundle.load('images/pngs/defaultPhoto.png').then((cnt) {

        tmpFile.writeAsBytesSync(cnt.buffer.asUint8List());
       // print('Copy png from assets to app Doc dir ok....');

      });
    }

  }

  int _newNotifyMsgCount = 0;
  int get notifyMsgCount => _newNotifyMsgCount;
  void keepNotifyMsg(Map obj)  {
    if(obj.isEmpty)
      _notifyMsgLs.clear();
    _notifyMsgLs.add(obj);
    _newNotifyMsgCount++;
  }

  List<Map> fetchNotifyMsg() {
    _newNotifyMsgCount = 0;
     return  _notifyMsgLs.reversed.toList();
  }

  // List<int> get fetchDefaultDes3EcbKey => defaultDes3EcbKeyLs;

  String  rslToTxt(String str)  {
    if(_RslToTextMap.containsKey(str))
         return _RslToTextMap[str]!;
    return '';
  }

   int get currLoginedUserId => 0;
  //set keepCurrUserId(int uid) => thizUserInfoData.userId = uid;

  int  userIdByBleName(String ble) {
    return   appPrefs.getInt (  phoneNum + '_' +  ble + '_uid'  )! ;
  }

   void keepUserIdByBleName(String ble , int id) {
        appPrefs.setInt (  phoneNum + '_' +  ble + '_uid'  , id );
  }


  Color get crMainThemeColor => Color(0xff22cccc);
  Color get crMainThemeOnColor => Color(0xff11aaaa);
  Color get crMainThemeDownColor => Color(0xff00bbbb);
  Color get crMainBgColor => Color(0xffeeeeee);
  Color get crToastBgColor => Color(0xaa000000);
  Color get crCommonGrey => Color(0xff999999);
  Color get crWWeakGrey => Color(0xffe8e8e8);
  Color get crWeakGrey => Color(0xffdddddd);


  Color get crGrey22 => Color(0xff222222);
  Color get crGrey44 => Color(0xff444444);
  Color get crGrey66 => Color(0xff666666);

  Color get crGrey88 => Color(0xff888888);
  Color get crGreyAA => Color(0xffaaaaaa);
  Color get crGreyBB => Color(0xffbbbbbb);
  Color get crGreyCC => Color(0xffdddddd);
  Color get crGreyDD => Color(0xffdddddd);

  TextStyle get tsHeaderTextStyle => TextStyle(fontSize: 20, color: Colors.black,fontWeight: FontWeight.bold);
  TextStyle get tsHeader0TextStyle => TextStyle(fontSize: 26, color: Color(0xff222222),fontWeight: FontWeight.bold);


  TextStyle get tsListTitleTS1 => TextStyle(fontSize: 20, color: Color(0xff222222),fontWeight: FontWeight.normal);
  TextStyle get tsListTitleTS1MainCr => TextStyle(fontSize: 20, color: crMainThemeColor,fontWeight: FontWeight.normal);
  TextStyle get tsListCntTS1 => TextStyle(fontSize: 20, color: crCommonGrey,fontWeight: FontWeight.normal);

  TextStyle get tsTxtFn14GreyAA => TextStyle(fontSize: 14, color: Color(0xffaaaaaa),fontWeight: FontWeight.normal);

  TextStyle get tsTxtFn16Grey00 => TextStyle(fontSize: 16, color: Color(0xff000000),fontWeight: FontWeight.normal);
  TextStyle get tsTxtFn16Grey66 => TextStyle(fontSize: 16, color: Color(0xff666666),fontWeight: FontWeight.normal);
  TextStyle get tsTxtFn16GreyAA => TextStyle(fontSize: 16, color: Color(0xffaaaaaa),fontWeight: FontWeight.normal);
  TextStyle get tsTxtFn16Grey22BW900 => TextStyle(fontSize: 16, color: Color(0xff222222),fontWeight: FontWeight.w900);


  TextStyle get tsTxtFn18GreyBB => TextStyle(fontSize: 18, color: Color(0xffbbbbbb),fontWeight: FontWeight.normal);

  TextStyle get tsTxtFn18Grey88 => TextStyle(fontSize: 18, color: Color(0xff888888),fontWeight: FontWeight.normal);
  TextStyle get tsTxtFn18Grey44 => TextStyle(fontSize: 18, color: Color(0xff444444),fontWeight: FontWeight.normal);
  TextStyle get tsTxtFn18Grey22Bn => TextStyle(fontSize: 18, color: Color(0xff222222),fontWeight: FontWeight.bold);

  TextStyle get tsTxtFn18Grey22 => TextStyle(fontSize: 18, color: Color(0xff222222),fontWeight: FontWeight.normal);
  TextStyle get tsTxtFn18Grey22BW900 => TextStyle(fontSize: 18, color: Color(0xff222222),fontWeight: FontWeight.w900);


  TextStyle get tsTxtFn20Grey22 => TextStyle(fontSize: 20, color: Color(0xff222222),fontWeight: FontWeight.normal);

  TextStyle get tsTxtFn20Grey22Bn => TextStyle(fontSize: 20, color: Color(0xff222222),fontWeight: FontWeight.bold);
  TextStyle get tsTxtFn20Grey22BW900 => TextStyle(fontSize: 20, color: Color(0xff222222),fontWeight: FontWeight.w900);
  TextStyle get tsTxtFn20Grey88 => TextStyle(fontSize: 20, color: Color(0xff888888),fontWeight: FontWeight.normal);
  TextStyle get tsTxtFn20GreyAA => TextStyle(fontSize: 20, color: Color(0xffaaaaaa),fontWeight: FontWeight.normal);

  TextStyle get tsTxtFn20GreyCC => TextStyle(fontSize: 20, color: Color(0xffcccccc),fontWeight: FontWeight.normal);


  TextStyle get tsTxtFn20GreyFF => TextStyle(fontSize: 20, color: Colors.white,fontWeight: FontWeight.normal);

  TextStyle get tsTxtFn22Grey22 => TextStyle(fontSize: 22, color: Color(0xff222222),fontWeight: FontWeight.normal);
  TextStyle get tsTxtFn22Grey22Bn => TextStyle(fontSize: 22, color: Color(0xff222222),fontWeight: FontWeight.bold);


  TextStyle get tsTxtFn24Grey22Bn => TextStyle( fontSize: 24, color: Color(0xff222222),fontWeight: FontWeight.bold);
  TextStyle get tsTxtFn24GreyBB => TextStyle( fontSize: 24, color: Color(0xffbbbbbb),fontWeight: FontWeight.normal);


  TextStyle get tsTxtFn26Grey22Bn => TextStyle( fontSize: 26, color: Color(0xff222222),fontWeight: FontWeight.bold);
  TextStyle get tsTxtFn26GreyBB => TextStyle( fontSize: 26, color: Color(0xffbbbbbb),fontWeight: FontWeight.normal);


  TextStyle get tsTxtFn26Grey22Bw900Sp6 => TextStyle(letterSpacing: 6 ,fontSize: 26, color: Color(0xff222222),fontWeight: FontWeight.w900);


  String get phoneNum => _phoneNum;
  set phoneNum(String str) => _phoneNum = str ;


  String get docDirPath => _docPath;


  String  weekNameByNum (int idx) {
     final  List<String> wn = ['','星期一','星期二','星期三','星期四','星期五','星期六','星期日'];
    return wn[idx % wn.length];
  }

  static String get aesFixKey {
    String k = '595d647143d57be3111937d6a6957732';

    if (Platform.isAndroid)
      k = '5679aac140f0c32f6b58fe55b20b7501';

    // if(kReleaseMode){
    //   k = '695d647143d57be3111937d6a6957738';
    //   if (Platform.isAndroid)
    //     k = '6679aac140f0c32f6b58fe55b20b7509';
    // }
     return k;
  }

  static String get srvBaseUrl {
    // String url = 'https://testapi.ultronlocker.com/';
      String url = 'http://api1.smartlock.com/';

     // if(kReleaseMode)   // this will influnce testflight app.... so disabled temporary
     //   url = 'https://api.ultronlocker.com/';

    return url;
  }

  //set keepUserInfoData(TUserInfoData dat) => thizUserInfoData = dat;
  //TUserInfoData get fetUserInfoData => thizUserInfoData;

  // TUserInfoData   fetUserInfoDataByBleName(String blename)
  // {
  //    return gUserInfoDataMap[blename];
  // }

  // void keepUserInfoDataByBleName(String blename , TUserInfoData dat)
  // {
  //     gUserInfoDataMap[blename]  = dat;
  //}

  // TLockerInfoData   fetLockerInfoDataByBleName(String blename)
  // {
  //   return gLockerInfoDataMap.putIfAbsent(blename, () =>   TLockerInfoData() )  ;
  // }

  // void keepLockerInfoDataByBleName(String blename , TUserInfoData dat)
  // {
  //   gUserInfoDataMap[blename]  = dat;
  // }

  String _currUid = '';
  set currUid (String uid) => _currUid = uid;
  String get currUid => _currUid;


  String get nickName {
    String ? nn = appPrefs.getString( phoneNum + '_nickname');

    if(nn != null){
      return nn;
    }


    return '新用户';
  }

  // set userId(String str)
  // {
  //   appPrefs.setString ( phoneNum + '_userId'  , str);
  // }
  //
  // String get userId {
  //   String ? nn = appPrefs.getString( phoneNum + '_userId');
  //
  //   if(nn == null){
  //      nn = hex.encode(generateRndBytes(8)) ;
  //      userId = nn;
  //   }
  //
  //   return nn;
  // }

  set nickName(String str)
  {
    appPrefs.setString ( phoneNum + '_nickname'  , str);
  }


  String get currUserPhotoUrl {
     String ? url =  appPrefs.getString (  phoneNum + '_photourl'  );

     if(url != null) {
       final File tmpF = File(url);
       if (tmpF.existsSync()) {
         return tmpF.path;
       }
     }

   //  print('return default photo....');

    return '$_docPath/dfPhoto.png';
  }

  set currUserPhotoUrl(String str)
  {
    appPrefs.setString (  phoneNum + '_photourl'  , str);
  }

  String   userPhotoUrlById(int uid)
  {
    String photoName = phoneNum ;
    photoName =  photoName.replaceAll('+', 'P');

    final File tmpF = File('$docDirPath/$photoName.png');

    if(tmpF.existsSync()){
      return tmpF.path;
    }

    final File tmpFjpg = File('$docDirPath/$photoName.jpg');

    if(tmpFjpg.existsSync()){
      return tmpFjpg.path;
    }

    return '$_docPath/dfPhoto.png';
  }

  String userAccount = '';
  String _remotePhotoUrl = '';


  String _userNickname = '';

  set userNickname (String str ) => _userNickname = str;
  String fetchNickname() {
     if(_userNickname.isNotEmpty)
       return _userNickname;

    return '新用户';
  }

  set remotePhotoUrl (String str ) => _remotePhotoUrl = str;
  String fetchRemotPhotoUrl() {
    if(_remotePhotoUrl.isNotEmpty)
      return _remotePhotoUrl;

    return   '$_docPath/dfPhoto.png';
  }


 Future<String>   checkAndFindUserPhotoUrl() async
  {

    final rtnObj = fetchCommonLoginData();
   // print(rtnObj);

    final tmpUri = Uri.parse(rtnObj[4]);
    String fn = tmpUri.pathSegments.last;
    if(fn.isEmpty)
      return '';

    String localPFP = _docPath + '/' + fn;
   // print(localPFP );
    final pf = File( localPFP);

   // print(pf.existsSync());
    if(pf.existsSync())
      return pf.path;


     File f = await  TRemoteSrv().doDownloadFile(rtnObj[4],localPFP);
    return f.path;

  }




  List<int> fetCryptKeyByBleUId(String blename, int uid)
  {    
    if(uid == 0 ) {
      return defaultDes3EcbKeyLs;
    }
    
    String hexStr = appPrefs.getString (  phoneNum + '_' + blename + '_' + uid.toString()  )!;

    return  hexStr == null ? defaultDes3EcbKeyLs : hex.decode(hexStr)  ;
  }

  void keepCryptKeyByBleUId(String blename, int uid , List<int > key)
  {
    appPrefs.setString (  phoneNum + '_' + blename + '_' + uid.toString()   , hex.encode(key));
  }

  void keepFactory(String hexStrKey)
  {
    appPrefs.setString('factoryKey', hexStrKey);

  }

  String fetchFactoryKey()
  {
    return appPrefs.getString('factoryKey')!;
  }

  void keepInitLockData( String devMac, List<String> datLs)
  {
    appPrefs.setStringList( phoneNum + '_' + devMac, datLs);
  }

  List<String> fetchInitLockData(String devMac ){
    List<String> rtnStrLs = [];

    List<String>? tmpLs = appPrefs.getStringList(phoneNum + '_' + devMac);
    if(tmpLs != null)
      rtnStrLs = tmpLs;

    return rtnStrLs;
}

 void keepCurrUserToken(String str) =>  appPrefs.setString(  'appToken', str);
  String currUserToken (){
    String ?str = appPrefs.getString(  'appToken' );
    if(str != null)
      return str;
    return '';
  }

  void keepCurrUserAcceToken(String str) =>  appPrefs.setString(  'appAcceToken', str);
  String currUserAcceToken (){
    String ?str = appPrefs.getString(  'appAcceToken' );
    if(str != null)
      return str;
    return '';
  }

  void keepCommonLoginData(List<String> strLs) =>  appPrefs.setStringList(  'commonlogindata', strLs);
  List<String> fetchCommonLoginData (){
    // The order is below:
    // List<String> strLs = [
    //   datObj['phone'], // 0
    //   datObj['uid'],  // 1
    //   datObj['username'],  // 2
    //   datObj['nickname'],  // 3
    //   datObj['avatar']  // 4 , photo url
    // ];
    List<String> ?strLs = appPrefs.getStringList(  'commonlogindata' );
    if(strLs != null)
      return strLs;
    return [];
  }

  void keepRemoteAuthDatPackage(List<int> datLs)
  {
    print('keepRemoteAuthDatPackage..............len: ${datLs.length}');


    int currDt = (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).toInt();

    String tmpKey = 'RemoteKey_' + currDt.toString();

    print('Append Remote auth key.....$tmpKey');
    print('key cnt: ${hex.encode(datLs)} ');

    appPrefs.setString(tmpKey, hex.encode(datLs));


  }

  List<Map> allLanguages () {
  final List<Map> rtnObjLs = [
      {'title':'English', 'langCode':'en', 'countryCode':'', 'scriptCode':'' },
    {'title':'简体中文', 'langCode':'zh', 'countryCode':'', 'scriptCode':'' },
    {'title':'繁體中文', 'langCode':'zh', 'countryCode':'TW', 'scriptCode':'Hant' },

    ];

    return rtnObjLs;
  }

  void keepCurrLanguage(List<String> langStrLs)
  {
    appPrefs.setStringList('AppCurrLanguage', langStrLs);
  }

  List<String> fetAppCurrLanguage()
  {
    List<String>? tmpLs = appPrefs.getStringList('AppCurrLanguage');

    if(tmpLs != null)
      return tmpLs;

    return  ['zh','',''];
  }


  List<String> fetAllRemoteAuthKeys()
  {
    List<String> rtnLs = [];
    Set<String> allKeys = appPrefs.getKeys();

    for(var k in allKeys){
      if(k.contains('RemoteKey')){
        rtnLs.add(k);
      }
    }

    return rtnLs;
  }

  List<int> fetOneRemoteAuthDatByKey(String key)
  {
    List<int> rtnLs = [];

    String str = appPrefs.getString(key)!;

    if(str != null){
      return hex.decode(str);
    }

    return rtnLs;
  }


  void cleanAllRemoteAuthData()
  {
    Set<String> allKeys = appPrefs.getKeys();

    for(var k in allKeys){
      if(k.contains('RemoteKey')){
        print(' Remove key : $k');
        appPrefs.remove(k);
      }
    }
  }


  void resetAllPreference(){
    print('resetAllPreference.......');
    appPrefs.clear();
    //docDirPath;
   List<FileSystemEntity> allFilesLs = Directory(docDirPath).listSync();

    allFilesLs.forEach((f) {
      String fExt = pkgPath.extension(f.path).replaceAll('.', '').toUpperCase();
     if( fExt == 'PNG' || fExt == 'JPG' || fExt == 'JPEG'){
      // print(f.path);
       f.deleteSync(recursive: true);
     }
    });

  }
  //
  // Future<String>  fetchAppBuildDatetime() async {
  //   String rtnStr = '';
  //   //
  //   // try{
  //   //   rtnStr = await _nativeChannel.invokeMethod("GetBuildDt");
  //   //   // rtnStr = await _nativeChannel.invokeMethod("WhoAreU", {'txt':'this is txt cnt from flutter.....'});
  //   //
  //   //   //rtn  = await _nativeChannel.invokeMethod("subscribeTopic");
  //   // }catch(e){
  //   //   print(e.toString());
  //   // }
  //
  //
  //   return rtnStr;
  // }

  String photoUrlToDocPathname(String url){
    return docDirPath + '/' + Uri.parse(url).pathSegments.last ;
  }

  List<int> generateRndBytes(int len){
    List<int> tmpLs = List<int>.generate(254, (index) => index + 1);
    Random _rnd = Random();
    return Iterable.generate(len, (_) => tmpLs[(_rnd.nextInt(tmpLs.length))]).toList();

  }

  String generateRndNumberStr(int len){
    String rtn = '';
   // const int int64MaxValue = 9223372036854775807;
   while(rtn.length < len){
    Random _rnd = Random();
    rtn += _rnd.nextInt(0xffffffff).toString();
    }
    
    
    return rtn.substring(0, len);
  }

  String getRandString(int len) {

    // return '7UquAbE=';
    var random = Random.secure();
    var values = List<int>.generate(len, (i) =>  random.nextInt(255));
    return base64UrlEncode(values);
  }

  String getRandKeyStr( ) {
    int len = Random().nextInt(8) + 4;
    String tmpStr = getRandString(len);
   // print('Random key Str: --------------- $tmpStr   len: ${tmpStr.length}');
   // List<int> keyBytes = utf8.encode( tmpStr    ).toList();
   // keyBytes .insert(0, keyBytes.length);
    return tmpStr;
  }


  List<String> fetRecentUsedCountryLs()
  {
    List<String>?  rtnLs = appPrefs.getStringList('RecentUsedCountries');
    //
    // String ? str = appPrefs.getStringList('RecentUsedCountries');
    //
    // if(str != null){
    //   return str.split(',');
    // }

    return rtnLs == null ? [] : rtnLs;
  }

  void keepRecentUsedCountryLs(List<String> strLs)
  {
    if(strLs.length > 6){
      strLs.removeAt(0);
    }
    appPrefs.setStringList('RecentUsedCountries', strLs);
  }



  List<String> fetAllLockDevLs()
  {
    List<String>?  rtnLs = appPrefs.getStringList(phoneNum + '_AllLockDevLs');
    //
    // String ? str = appPrefs.getStringList('RecentUsedCountries');
    //
    // if(str != null){
    //   return str.split(',');
    // }

    return   rtnLs ?? [];
  }


  void appendNewLockDev( List<String>  lockInfoLs)
  {
      final dummyChar = '\u200B';

    String tmpStr = '';
    for(int i = 0 ; i < lockInfoLs.length ; i ++)
      tmpStr += lockInfoLs[i] + dummyChar;

    List<String>?  strLs ;
    strLs = appPrefs.getStringList( phoneNum + '_AllLockDevLs');

     if(strLs == null)
       strLs = [];

     strLs.add(tmpStr);

    appPrefs.setStringList(phoneNum + '_AllLockDevLs', strLs);
  }

  void keepLockByDevId(List<String> lockInfoLs)
  {
    // [  widget.devId,
    //   _lockNameTxtCtrlor.text.trim(),
    //   TBleSingleton().Userid.toString(),
    //   TBleSingleton().keepDfk,
    // ];
    if(lockInfoLs.length < 2) return;
    String keyName = 'lock' + lockInfoLs[0];
    appPrefs.setStringList(keyName, lockInfoLs);
  }

  List<String> fetchLockByDevId(String devId)
  {
      List<String>? rtnLs   = appPrefs.getStringList( 'lock' + devId );
      if(rtnLs != null)
        return rtnLs;
    return [];
  }

  void deleteLockByDevId(String devId)
  {
    String keyName = 'lock' +devId;
    appPrefs.remove(keyName);

  }

  List<Map> generateCalendar(DateTime targetDt)
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

    for(int i = 0 ; currMFD.weekday != 7 &&  i  < currMFD.weekday ; i ++)
      rtn.insert(7, {});


    return rtn;
  }


  Future<List<Path>>  svgXmlDataToPathPoints(  String svgPath) async
  {
    List<Path> rtnLs = [];
    String xmlCnt =  await rootBundle.loadString(svgPath);

    //print(xmlCnt);

    try{
     // final svgFile = File(svgPath);
      final xmlDoc = XmlDocument.parse(xmlCnt);
      
      final pathLs = xmlDoc.findAllElements('path');

      pathLs.map((node) => node.getAttribute('d') ).forEach((str) {

        Path p = parseSvgPath( str! , failSilently: true);

        rtnLs.add(  p);
      });


    }catch(e){
      print(e);
    }

    return rtnLs;
  }



   String encryptHttpPost( Map  obj, String fixKey , String csrf)
  {

   // print('fixKey  = $fixKey');
    //print('csrf  = $csrf');

    String cntStr =  json.encode( obj  );
   //  print('post_data befor encrypt: $cntStr');

    String beforeMd5 = fixKey + csrf;
   // print('beforeMd5 : $beforeMd5');
    String keyIv = md5.convert(utf8.encode(  beforeMd5) ).toString() ;

   // print('After md5: $keyIv');

    String encKey = keyIv.substring(0,16);
    String aseIv = keyIv.substring(16,32);

   // print('enckey: $encKey');
   // print('aseIv: $aseIv');

    final key = TAES. Key.fromUtf8(encKey);
    final encrypter = TAES.Encrypter(TAES.AES(key  , mode: TAES.AESMode.cbc));

    final iv = TAES.IV.fromUtf8(aseIv);
    final encrypted = encrypter.encrypt(cntStr, iv: iv);

    String rtnStr = encrypted.base64;
    //print('base64:  $rtnStr');
    //print('len :  ${rtnStr.length}');
    rtnStr = rtnStr.replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '');
    // print('post_data=$rtnStr');

    return rtnStr;
  }

  Map<String , dynamic>  decrytpHttpRespon( String resp , String fixKey ,  String csrf)
  {

  //  print('ori data: $resp');
  // print('ori data len : ${resp.length}');

    String beforeMd5 = fixKey + csrf;
    // print('beforeMd5 : $beforeMd5');
    String keyIv = md5.convert(utf8.encode(  beforeMd5) ).toString() ;

    resp = resp.replaceAll('[\\x00-\\x1F\\x80-\\x9F]', '').replaceAll('-', '+').replaceAll('_', '/');

    // print('After md5: $keyIv');

    //int appendCount = resp.length % 4;

    for(int i = 0 ; i < resp.length % 4 ; i ++)
      resp += '=';

    String encKey = keyIv.substring(0,16);
    String aseIv = keyIv.substring(16,32);

   // print('encKey: $encKey');
   // print('aseIv: $aseIv');



    final key = TAES. Key.fromUtf8(encKey);
    final encrypter = TAES.Encrypter(TAES.AES(key  , mode: TAES.AESMode.cbc , padding: null));

    final iv = TAES.IV.fromUtf8(aseIv);

   // print('befor decrypt data: $resp');
   // print('befor decrypt data len : ${resp.length}');

    String encrypted = encrypter.decrypt64(resp, iv: iv);

    // print('dncrypted : $encrypted');
  //  print('--------------------------- ');


    if(encrypted.startsWith('{'))
      encrypted =  encrypted.substring(0, encrypted.lastIndexOf('}') + 1 );


    Map<String , dynamic>  rntObj  = {};

    try{
      rntObj = json.decode(encrypted);
    }catch(e){
      print(e);
    }


    return rntObj;
  }

  void showToastInfo(String str){
    Fluttertoast.showToast(
      msg: str,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: TGlobalData().crToastBgColor,
      textColor: Colors.white,
      fontSize: 18.0,
    );
  }


}

//
// class NoSplashFactory extends InteractiveInkFeatureFactory{
//   @override
//   InteractiveInkFeature create(
//       {
// BorderRadius? borderRadius,
// required Color color,
// bool containedInkWell = false,
// required MaterialInkController controller,
// ShapeBorder? customBorder,
// void Function()? onRemoved,
// required Offset position,
// double? radius,
// Rect Function()? rectCallback,
// required RenderBox referenceBox,
// required TextDirection textDirection
//   } )
//   {
//     return NoSplash(
//       controller: controller,
//       referenceBox: referenceBox,
//       color: color,
//     );
//   }
//
// }


// class NoSplashFactory extends InteractiveInkFeatureFactory {
//   const NoSplashFactory();
//
//   @override
//   InteractiveInkFeature create({
//     required MaterialInkController controller,
//     required RenderBox referenceBox,
//     required Offset position,
//     required Color color,
//     required TextDirection textDirection,
//     bool containedInkWell = false,
//     required Rect Function() rectCallback,
//     required BorderRadius borderRadius,
//     required ShapeBorder customBorder,
//     required double radius,
//     required VoidCallback onRemoved,
//   }) {
//     return NoSplash(
//       controller: controller,
//       referenceBox: referenceBox,
//       cr: color,
//     );
//   }
// }
//
// class NoSplash extends InteractiveInkFeature {
//   NoSplash({
//     required MaterialInkController controller,
//     required RenderBox referenceBox,
//     required Color color
//   })  : assert(controller != null),
//         assert(referenceBox != null),
//         assert(color != null),
//         super(
//         controller: controller,
//         referenceBox: referenceBox,
//         color: color,
//       );
//
//   @override
//   void paintFeature(Canvas canvas, Matrix4 transform) {}
// }