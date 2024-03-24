import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import 'dart:ui' as UI;
//import 'package:image/image.dart' as ImgPkg;



import '../TGlobal_inc.dart';
import '../TBleSingleton.dart';
import 'TPrivatePwdWnd.dart';
import '../Misc/TAnimaPath.dart';


class TPrivateFpWnd extends StatefulWidget {

  final int uid;
    final bool isIndicator ;
    final List<UI.Image> stepIndicatorImgLs  ;
    final List<UI.Image> stepIndicatorGreyImgLs  ;
   final List<UI.Image> stepIndicatorBlackImgLs  ;

    TPrivateFpWnd( {required this.uid,
      this.isIndicator = true,
      required this.stepIndicatorImgLs  ,
      required this.stepIndicatorGreyImgLs  ,
      required this.stepIndicatorBlackImgLs
    });

  @override
  _TPrivateFpWndState createState() => _TPrivateFpWndState();
}

int _goBackPages  =0;
class _TPrivateFpWndState extends State<TPrivateFpWnd> {


 // List<UI.Image> _stepIndicatorImgLs = [];

  int _enrollFpTotalCnt = 3;
  int _enrollFpStep = 0;

  bool _canStart = false;
  bool _isStarted = false;



  int _pathStep = 0;
  int _pathMaxStep = 3;



   List<Path> _allFpPathLs = [];
  List<Path> _currFpPathLs = [];

  List<String> _fgNames = ['左小指','左无名指','左中指','左食指' ,'左拇指' ,  '右拇指' ,'右食指' ,'右中指', '右无名指', '右小指'];
  List<bool>  _fgCheckedLs = [];

  late final StreamSubscription<String> _jsonSSub;

  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

    _fgNames.forEach((_) {_fgCheckedLs.add(false);});

    double  fpW = 160;
    double fpH = 160;

    double pathCnt = fpW / 2.0 / 9.0 ;

     for(int i = 0 ; i < pathCnt ; i ++){

       Path tmpPath = Path()
         ..moveTo(0 + i * pathCnt  , fpH  )
         ..cubicTo(0 + i * pathCnt , -50 + i * pathCnt,  fpW - i * pathCnt ,-50 +  i * pathCnt, fpW -  i * pathCnt, fpH);

       _allFpPathLs.add(tmpPath);

     }

     _allFpPathLs = _allFpPathLs.reversed.toList();

    _jsonSSub = TBleSingleton().jsonStream.listen((jsonStr) => handleJsonStr(jsonStr));


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
    return Scaffold(
      appBar: AppBar(title: Text('添加开锁指纹',
        style: TextStyle(color: Color(0xff222222),
            fontSize: 20,
            fontWeight: FontWeight.bold),),
        elevation: 0.0,
        backgroundColor: Color(0xffeeeeee),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(

          padding: EdgeInsets.symmetric(horizontal: 20, vertical:  10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

            if(widget.isIndicator)
              Container(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: TGlobalData().crGreyDD)),
                  ),
                  child: CustomPaint(painter: PwdStepIndicator(  widget.stepIndicatorImgLs ,
                    widget.stepIndicatorGreyImgLs ,
                    widget.stepIndicatorBlackImgLs , 2 ),
                    size: Size(
                        MediaQuery.of(context).size.width * .86,
                        MediaQuery.of(context).size.height  / 5.0
                    ),)),

              Center(child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
                child: Text('添加指纹', style: TGlobalData().tsTxtFn26Grey22Bn),
              )),

              Center(child: Text(
                  '请将手指放置在指纹开锁处', style: TGlobalData().tsTxtFn16GreyAA)),



              // Center(
              //   child: Container(
              //     margin: EdgeInsets.all(20),
              //     padding: EdgeInsets.all(70),
              //     color: Colors.grey,
              //     width: 160,
              //   ),
              // ),

              if(!_isStarted)
                Column(
                  children: [
                    SizedBox(height: 12,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                      ... <int>[   for(int i = 0  ; i <= _fgNames.length ; i ++) i ].map((_idx) {
                        int idx = _idx;
                        if(_idx > 5) idx --;
                        if(_idx == 5) return SizedBox(width: 12,);
                        return Container(
                         // color: Colors.red,
                          width: 24,
                          height: 124,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    value: _fgCheckedLs[idx],
                                  visualDensity: VisualDensity(),
                                  onChanged: (b){
                                for(int i = 0 ; i < _fgCheckedLs.length ; i ++)
                                  _fgCheckedLs[i] = false;
                                _fgCheckedLs[idx] = b!;

                                bool isFound = false;
                                for(var b in _fgCheckedLs){
                                  if(b){ isFound = true;
                                      break;
                                  }
                                }
                                _canStart = isFound;

                                setState(() {  });
                            }),
                              ),

                              SizedBox(
                                width: 16,
                                  child: Text(_fgNames[idx] , style: TextStyle(fontSize: 16),)),



                            ]
                          ),
                        );
                  }).toList(),


                      ],
                    ),

                    SizedBox(height: 12,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset('images/icons/lhandIcon.png' ,width: 110, fit: BoxFit.fill, ),
                        Image.asset('images/icons/rhandIcon.png' , width: 110, fit: BoxFit.fill,),

                      ],
                    ),



                  ],
                ),


              // if(_isStarted)
              // Padding(
              //   padding: const EdgeInsets.only(top: 16),
              //   child: Center(
              //     child: CustomPaint(painter: TFingerprintPathAnima( _allFpPathLs , _currFpPathLs ),
              //     size: Size(160,160),
              //     ),
              //   ),
              // ),



               Expanded(flex: 10,child: SizedBox()),
              if(_isStarted)
              Center(
                  child: TAnimaPath(_pathStep, _pathMaxStep , 82, 128)),

               Expanded(flex: 10,child: SizedBox()),




              if(_isStarted)
              Container(
                margin: EdgeInsets.symmetric(horizontal: MediaQuery
                    .of(context)
                    .size
                    .width * .26, vertical: 20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: TGlobalData().crGreyDD,),
                    top: BorderSide(color: TGlobalData().crGreyDD),
                  ),
                ),

                child: Text('$_pathStep / $_pathMaxStep', textAlign: TextAlign.center,
                  style: TGlobalData().tsTxtFn18Grey22,),
              ),


              Expanded(child: SizedBox()),


              ElevatedButton(
                child: Text(
                  '开  始',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),

                style: ElevatedButton.styleFrom(
                  primary: TGlobalData().crMainThemeColor,
                  onPrimary: TGlobalData().crMainThemeOnColor,
                  shadowColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: StadiumBorder(),

                ),
                onPressed: _canStart ?  () {
                  // print(ModalRoute.of(context)!.settings.name);

                  _isStarted = true;
                  _canStart = false;

                  int i = 0;
                  for( ; i < _fgCheckedLs.length ; i ++){
                    if(_fgCheckedLs[i] ) break;
                  }
                  i++;

                  print('fg is : $i');

                  _startEnrollFingerprint(i);
                  _updateFingerPathPaint(0);


                //   final totalLength = _finalPath
                //       .computeMetrics()
                //       .fold(0.0, (double prev, PathMetric metric) => prev + metric.length);
                //
                // //  print('totalLength : $totalLength');
                //
                //   var metricsIterator = _finalPath.computeMetrics().iterator;
                //   if(metricsIterator.moveNext())
                //      _pathToDraw.addPath(metricsIterator.current.extractPath(.0 , totalLength), Offset.zero);
                //
                //   return;
                //
                //   double length = _currPathPercent.toDouble();

/*
          double currentLength = 0.0;
         if(metricsIterator.moveNext()){
           var metric = metricsIterator.current;

           print('11 m len: ${metric.length}');

           var nextLength = currentLength + metric.length;

           final isLastSegment = nextLength > length;
           if (isLastSegment) {
             final remainingLength = length - currentLength;
             final pathSegment = metric.extractPath(0.0, remainingLength);

             _pathToDraw.addPath(pathSegment, Offset.zero);

             print('aaaaaaaa....');

            // break;
           } else {
             // There might be a more efficient way of extracting an entire path
             final pathSegment = metric.extractPath(0.0, metric.length);
             _pathToDraw.addPath(pathSegment, Offset.zero);
             print('bbbbbbbb....');
           }
         }

         print(_currPathPercent);

 */

                  setState(() {  });

                  return;



                  _goBackPages = 3;
                  Navigator.popUntil(context, (route) {
                    //(route.settings.arguments as Map)['rsl'] = 1;

                    // return  route.isFirst;

                    _goBackPages --;

                    if (_goBackPages == 0)
                      return true;

                    return false;
                  });



                } : null,
              )


            ],
          )),
    );
  }


  Future<void> _startEnrollFingerprint(int fgIdx) async
  {

    var jobj = {};

    jobj["sjtjxzw"] =  fgIdx ;
    jobj["uid"] = widget.uid ;// TGlobalData().currUid;
    jobj["c"] = _pathMaxStep;

    TBleSingleton().sendFramedJsonData(json.encode(jobj));

  }

  void handleJsonStr(String jsonStr) async {
    // print('Got jstr : $jsonStr');

    var jsonObj = jsonDecode(jsonStr);

    var rsl = jsonObj['rsl'];
    if (rsl != null) {
      await _handleFpResult(int.parse( rsl.toString()));

    }


  }

  void fingerprintAnimGoStep(int step)
  {
    setState(() {
      _pathStep = (step) % (_pathMaxStep + 1);
    });
  }

  Future<void> _handleFpResult(int rsl) async
  {
     if(rsl == ResultCodeToApp_e.Rsl_Fp_Enroll_Begin.index){
       TGlobalData().showToastInfo('请录入指纹....');
      // _updateFingerPathPaint(0);
     }else if(rsl == ResultCodeToApp_e.Rsl_Fp_Enroll_Round_1_Ok.index){
       fingerprintAnimGoStep(1);
       //_updateFingerPathPaint(1);
     }else if(rsl == ResultCodeToApp_e.Rsl_Fp_Enroll_Round_2_Ok.index){
      // _updateFingerPathPaint(2);
       fingerprintAnimGoStep(2);
     }else if(rsl == ResultCodeToApp_e.Rsl_Fp_Enroll_Round_3_Ok.index){

     }else if(rsl == ResultCodeToApp_e.Rsl_Fp_Enroll_Round_4_Ok.index){

     }else if(rsl == ResultCodeToApp_e.Rsl_Fp_Enroll_Round_5_Ok.index){

     }else if(rsl == ResultCodeToApp_e.Rsl_Fp_Enroll_Round_6_Ok.index){

     }else if(rsl == ResultCodeToApp_e.Rsl_Fp_Enroll_Round_7_Ok.index){

     }else if(rsl == ResultCodeToApp_e.Rsl_Fp_Enroll_Successful.index){
       fingerprintAnimGoStep(3);
       await Future.delayed(Duration(seconds: 1));
       TGlobalData().showToastInfo('录入指纹成功！！');
       //_updateFingerPathPaint(3);
       if(widget.isIndicator){

       }else{
         await Future.delayed(Duration(seconds: 1));
         Navigator.pop(context, true);
       }

     }else if(rsl == ResultCodeToApp_e.Rsl_Fp_Enroll_Failed.index){
       TGlobalData().showToastInfo('录入指纹失败！！');
       if(widget.isIndicator){

       }else{
         Navigator.pop(context, false);
       }
     }

  }

  void _updateFingerPathPaint(int step){

    _enrollFpStep  = step;

    if(_allFpPathLs.isNotEmpty) {
      _currFpPathLs = _currFpPathLs + _allFpPathLs.sublist(0, 3);
      _allFpPathLs.removeRange(0, 3);
    }

    if(_enrollFpStep > 2){
      _currFpPathLs += _allFpPathLs;
      _allFpPathLs.clear();
    }

     setState(() { });

  }


}


class TFingerprintPathAnima extends CustomPainter
{

  int currStep = 0;

  late Paint _mypaint;


  final  List<Path>  _drawingPathLs  ;
  final  List<Path>  _basePathLs  ;

  TFingerprintPathAnima(this._basePathLs , this._drawingPathLs){
    _mypaint = Paint()
        ..color = Color(0x22ff0000)
    ..strokeWidth = 2.0
    ..style = PaintingStyle.stroke
        ;

  }



  @override
  void paint(Canvas canvas, Size size) {

   // print(' fp step : $currStep');

   // canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _mypaint);

    _mypaint.color = Color(0x11000000);
    _basePathLs.forEach((path) {
      canvas.drawPath(path, _mypaint);
    });

    _mypaint.color = Color(0xffffcccc);
    _drawingPathLs.forEach((path) {
      canvas.drawPath(path, _mypaint);
    });


  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
   // throw UnimplementedError();
    return false;
  }
  
}


























  //
  // _loadIndicatorImgs() async {
  //
  //   // ByteData tmpBd = await rootBundle.load('images/photos/beauty01.png');
  //   //
  //   // final Uint8List baLs = Uint8List.view(tmpBd.buffer);
  //   //
  //   // final UI.Codec codec = await UI.instantiateImageCodec(baLs);
  //   //
  //   // final UI.Image img = (await codec.getNextFrame()).image;
  //   //
  //   // _stepIndicatorImgLs.add(img);
  //
  //   for(int i = 1; i < 4  ; i ++){
  //     UI.Image tmpImg = await fetUiImage('images/icons/pwdstep$i.png', 40  , 40);
  //     _stepIndicatorImgLs.add(tmpImg);
  //   }
  //
  //
  //
  //  // print(_stepIndicatorImgLs);
  //
  //   setState(() {  });
  // }
































