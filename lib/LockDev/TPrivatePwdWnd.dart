import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';


import 'dart:ui' as UI;
import 'package:image/image.dart' as ImgPkg;


import '../TGlobal_inc.dart';
import '../TBleSingleton.dart';

import 'TPrivateFpWnd.dart';



class TPrivatePwdWnd extends StatefulWidget {

   final bool isIndicator ;
   final int uid;

     TPrivatePwdWnd({required this.uid, this.isIndicator = true});

  @override
  _TPrivatePwdWndState createState() => _TPrivatePwdWndState();
}


class _TPrivatePwdWndState extends State<TPrivatePwdWnd> {


  List<UI.Image> _stepIndicatorImgLs = [];
  List<UI.Image> _stepIndicatorGreyImgLs = [];
  List<UI.Image> _stepIndicatorBlackImgLs = [];


  final _pwdTxtCtrlor1 = TextEditingController();
  final _pwdTxtCtrlor2 = TextEditingController();

  bool _isShowPwd1 = false;
  bool _isShowPwd2 = false;

  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();


    _loadIndicatorImgs();

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
      appBar: AppBar(title: Text(  '添加开锁密码',
        style: TextStyle(color: Color(0xff222222), fontSize: 20, fontWeight: FontWeight.bold), ),
        elevation: 0.0,
        backgroundColor: Color(0xffeeeeee),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: (){FocusScope.of(context).unfocus();},
        child: Container(

            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

             if(widget.isIndicator)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: TGlobalData().crGreyDD)),
                    ),
                    child: CustomPaint(painter: PwdStepIndicator(  _stepIndicatorImgLs , _stepIndicatorGreyImgLs ,
                        _stepIndicatorBlackImgLs ,  1 ),
                      size: Size(
                    MediaQuery.of(context).size.width * .86,
                    MediaQuery.of(context).size.height  / 5.0
                    ),)),

                Center(child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 16, 10, 10),
                  child: Text('添加密码', style: TGlobalData().tsTxtFn26Grey22Bn),
                )),

                Center(child: Text('此密码请自行保存，App将只显示密码名称', style: TGlobalData().tsTxtFn16GreyAA)),


                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextField(
                    style: TGlobalData().tsListTitleTS1,
                    controller: _pwdTxtCtrlor1,
                    obscureText:  _isShowPwd1,
                   cursorColor: TGlobalData().crMainThemeColor,
                    obscuringCharacter: '●',
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder( borderSide: BorderSide.none,  gapPadding: 0),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                       focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: TGlobalData().crMainThemeColor),
                           borderRadius: BorderRadius.circular(10), gapPadding: 0),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: TGlobalData().crGreyBB),
                          borderRadius: BorderRadius.circular(10), gapPadding: 0),
                      hintText: '请输入密码',
                      suffixIcon:  InkWell(
                        child: _isShowPwd1 ?
                        Icon(   Icons.visibility    ,    size: 26,color: Color(0xff666666),)
                            : Icon(   Icons.visibility_off   ,  size: 26,color: TGlobalData().crCommonGrey,) ,
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,

                        onTap: (){
                          _isShowPwd1 = !_isShowPwd1;

                          setState(() {});

                        },
                      ),

                    ),
                  ),
                ),



                TextField(
                  style: TGlobalData().tsListTitleTS1,
                  controller: _pwdTxtCtrlor2,
                  obscureText:  _isShowPwd2,
                  //  readOnly: true,
                  obscuringCharacter: '●',
                  maxLength: 10,
                  cursorColor: TGlobalData().crMainThemeColor,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder( borderSide: BorderSide.none,  gapPadding: 0),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: TGlobalData().crMainThemeColor),
                        borderRadius: BorderRadius.circular(10), gapPadding: 0),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: TGlobalData().crGreyBB),
                        borderRadius: BorderRadius.circular(10), gapPadding: 0),
                    hintText: '再次输入密码',
                    suffixIcon:  InkWell(
                      child: _isShowPwd2 ?
                      Icon(   Icons.visibility    ,    size: 26,color: Color(0xff666666),)
                          : Icon(   Icons.visibility_off   ,  size: 26,color: TGlobalData().crCommonGrey,) ,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,

                      onTap: (){
                        _isShowPwd2 = !_isShowPwd2;

                        setState(() {});

                      },
                    ),

                  ),
                ),



                Expanded(  child: SizedBox()),

                ElevatedButton(
                  child: Text(  widget.isIndicator ?
                    '下 一 步' : '完  成',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),

                  style: ElevatedButton.styleFrom(
                    primary: TGlobalData().crMainThemeColor,
                    onPrimary: TGlobalData().crMainThemeOnColor,
                    shadowColor: Colors.white,
                    padding: EdgeInsets.symmetric( vertical: 10),
                    shape: StadiumBorder(),

                  ),

                  onPressed:   _pwdTxtCtrlor1.text.length < 6  ? null:
                      () async {


                    if( _pwdTxtCtrlor1.text == _pwdTxtCtrlor2.text) {

                      String pwdStr = _pwdTxtCtrlor1.text;
                      setState(() {
                        _pwdTxtCtrlor1.clear();
                        _pwdTxtCtrlor2.clear();
                      });


                      bool isOk = await _pushDataToLock(pwdStr);

                      if(!isOk){
                        TGlobalData().showToastInfo("上传数据到锁具失败！" );
                        return;
                      }

                      if(!widget.isIndicator){
                        Navigator.pop(context , isOk);
                        return;
                      }

                      Navigator.push(context, MaterialPageRoute(
                          builder: (ctx) =>
                              TPrivateFpWnd(
                                  uid: widget.uid,
                                  stepIndicatorImgLs : _stepIndicatorImgLs,
                                  stepIndicatorGreyImgLs :_stepIndicatorGreyImgLs,
                                  stepIndicatorBlackImgLs: _stepIndicatorBlackImgLs)));
                    }else
                    TGlobalData().showToastInfo("密码不一致，请重新输入!" );

                  },
                ),


              ],
            )),
      ),
    );

  }

  Future<bool> _pushDataToLock(String pwd) async {
    bool rsl = false;

    final Completer tmpC = Completer<void>();

    StreamSubscription<String> jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) {

      //  print('got jsonstr: $jsonStr');

      var jsonObj = jsonDecode(jsonStr);

      if(  jsonObj['rsl'] == ResultCodeToApp_e.Rsl_Pri_Pwd_Append_Ok.index)
        rsl = true;


      if(!tmpC.isCompleted)
        tmpC.complete();

    });

    var jobj = {};
    jobj["sjtjyhmm"] =  pwd;
    jobj["uid"] =  widget.uid ;
    jobj["isAlarm"] =  1;
    TBleSingleton().sendFramedJsonData(json.encode(jobj));


    await tmpC.future;
    jsonSSub.cancel();


    return Future.value(rsl);

  }


  _loadIndicatorImgs() async {

    // ByteData tmpBd = await rootBundle.load('images/photos/beauty01.png');
    //
    // final Uint8List baLs = Uint8List.view(tmpBd.buffer);
    //
    // final UI.Codec codec = await UI.instantiateImageCodec(baLs);
    //
    // final UI.Image img = (await codec.getNextFrame()).image;
    //
    // _stepIndicatorImgLs.add(img);

    for(int i = 1; i < 4  ; i ++){
      await fetUiImage('images/icons/pwdstep$i.png', 40  , 45 ,
          _stepIndicatorImgLs, _stepIndicatorGreyImgLs  , _stepIndicatorBlackImgLs);
     // _stepIndicatorImgLs.add(tmpImg);
    }



    // print(_stepIndicatorImgLs);

    setState(() {  });
  }



/*
  Future<UI.Image> fetUiImage(String imageAssetPath, int width  ,int height) async {


    final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
    ImgPkg.Image ? baseSizeImage = ImgPkg.decodeImage(assetImageByteData.buffer.asUint8List());
    if(baseSizeImage != null){
      ImgPkg.Image resizeImage = ImgPkg.copyResize(baseSizeImage, height: height, width: width);
      //  resizeImage = ImgPkg.adjustColor(resizeImage,saturation:0  ,brightness: 1.0, amount: 1.0);   // grey
      // resizeImage = ImgPkg.colorOffset(resizeImage,red:0x22  ,green: 0xcc, blue: 0xcc);
     // resizeImage = ImgPkg.adjustColor(resizeImage, saturation: .0, brightness: .5 , contrast: 1.0  , amount:1);
      //resizeImage = ImgPkg.adjustColor(resizeImage,   contrast: 1.0  , amount:  0);
      UI.Codec codec = await UI.instantiateImageCodec( Uint8List.fromList( ImgPkg.encodePng(resizeImage)) );
      UI.FrameInfo frameInfo = await codec.getNextFrame();

      return frameInfo.image;
    }

    UI.Image? rtnImg;
    UI.decodeImageFromPixels(
        Uint8List(0), 0 , 0, UI.PixelFormat.rgba8888, (img) {
      rtnImg = img;
    });


    return Future.value(  rtnImg );

  }
*/


   fetUiImage(String url, int width  ,int height ,
       List<UI.Image> crImgLs,
       List<UI.Image> greyImgLs,
       List<UI.Image> blackImgLs ) async {


    final ByteData assetImageByteData = await rootBundle.load(url);
    ImgPkg.Image ? baseSizeImage = ImgPkg.decodeImage(assetImageByteData.buffer.asUint8List());
    if(baseSizeImage != null){
      ImgPkg.Image resizeImage = ImgPkg.copyResize(baseSizeImage, height: height, width: width);

      UI.Codec codec = await UI.instantiateImageCodec( Uint8List.fromList( ImgPkg.encodePng(resizeImage)) );
      UI.FrameInfo frameInfo = await codec.getNextFrame();
      crImgLs.add(  frameInfo.image );

      resizeImage = ImgPkg.adjustColor(resizeImage,saturation:0  ,brightness: 1.0, amount: 1.0);   // grey
        codec = await UI.instantiateImageCodec( Uint8List.fromList( ImgPkg.encodePng(resizeImage)) );
        frameInfo = await codec.getNextFrame();
      greyImgLs.add(  frameInfo.image );

      resizeImage = ImgPkg.adjustColor(resizeImage, saturation: .0, brightness: .5 , contrast: 1.0  , amount:1);
      codec = await UI.instantiateImageCodec( Uint8List.fromList( ImgPkg.encodePng(resizeImage)) );
      frameInfo = await codec.getNextFrame();
      blackImgLs.add(  frameInfo.image );
    }



  }







}




class PwdStepIndicator extends CustomPainter {

    int _currStep;
  final List<UI.Image> _imgLs;
    final List<UI.Image> _greyImgLs;
    final List<UI.Image> _blackImgLs;


  late Paint _myPaint;

  PwdStepIndicator( this._imgLs ,this._greyImgLs ,this._blackImgLs   , this._currStep){
    _myPaint = Paint()
      ..color = Color(0xffff0000)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
    ;

    _currStep = _currStep.clamp(1, 4) ;
  }


  @override
  void paint(Canvas canvas, Size size)   {

    double widW = size.width;
    double widH = size.height;

  //  print(' curr step : $_currStep');

   // _myPaint.color = Color(0x11ff0000);
   // canvas.drawRect(Rect.fromLTWH(0, 0, widW, widH), _myPaint);

    if(_imgLs.isEmpty) return;

    _myPaint.color = Color(0xff222222);
    //var img1 =   loadUiImage('images/photos/beauty01.png');

    double grap = widW / 2.6;

    List<String> txtLs = ['添加密码' ,'添加指纹' ,'设置完成' , ''  ];
    List<Color> crLs = [Color(0xffcccccc) , Color(0xffcccccc) ,Color(0xffcccccc) ,Color(0xffcccccc) ];

    for(int i = 0 ; i < 4 ; i ++) {

      if( i < 3) {
        UI.Image img = _imgLs[i];
        if( (i + 1 )< _currStep) {

        } else if( (i + 1 ) == _currStep)
          img = _blackImgLs[i];
        else img = _greyImgLs[i];

        canvas.drawImage(img , Offset(i * grap + 16, 0), _myPaint);
      }

      for(int j = 0 ; j < _currStep ; j ++) {
        crLs[j ] = Color(0xff22cccc);
      //  txtCrLs [j ] = Color(0xff222222);
      }


      if(i < 2){
        _myPaint.color = crLs[i + 1];
        canvas.drawLine(Offset(grap * i + 36 + 5, widH * .52), Offset(grap * (i+1) + 36 - 5, widH * .52), _myPaint);
      }

      _myPaint.color = crLs[i];
      if( i  == _currStep - 1)
        _myPaint.color = Color(0xff222222) ;

      if( i < 3)
      canvas.drawCircle(Offset(grap * i + 36, widH * .52), 6  , _myPaint);



      final textStyle = TextStyle(
        color: i  == _currStep - 1 ? Color(0xff222222)  :  crLs[i],
        fontSize: 16,
      );
      final textSpan = TextSpan(
        text: txtLs[i],
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      final xCenter = i * grap + 4 ;
      final yCenter =  widH * .66 ;
      final offset = Offset(xCenter, yCenter);
      if( i < 3)
         textPainter.paint(canvas, offset);

    }

    //canvas.draw


  }



  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;



}
