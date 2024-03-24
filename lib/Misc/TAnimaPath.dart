
import 'dart:ui';

import 'dart:math' as TMath;
import 'package:flutter/material.dart';


import '../TGlobal_inc.dart';


class TAnimaPath extends StatefulWidget {

  final int _step;
  final int _maxStep;
  final double _width;
  final double _height;

  TAnimaPath( this._step , this._maxStep, this._width  , this._height );



  @override
  _TAnimaPath createState() => _TAnimaPath();
}


class _TAnimaPath extends  State<TAnimaPath> with SingleTickerProviderStateMixin {

  late AnimationController _pathAnimaCtrlor;

  int _currStep = 0;


  List<Path> _svgPathsLs = [];
  List<Path> _darwedPathsLs = [];
  List<Path> _remainedPathsLs = [];
  List<Path> _animaingPathsLs = [];

  @override
  void initState()   {
    super.initState();


    _pathAnimaCtrlor =   AnimationController(
      upperBound: 0.49,
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _pathAnimaCtrlor.addStatusListener((status) {

    //  print(status);
      if( status == AnimationStatus.completed){
         _darwedPathsLs += _animaingPathsLs;
         _animaingPathsLs.clear();
         setState(() { });
      }

    });


    setupPathLs();


  }


  @override
  void dispose() {


    _pathAnimaCtrlor.dispose();


    super.dispose();
  }

  void setupPathLs() async {

    _svgPathsLs.clear();
    _svgPathsLs += await  TGlobalData().svgXmlDataToPathPoints( 'images/svgs/fingerPath.svg');
    _remainedPathsLs.clear();
    _remainedPathsLs += _svgPathsLs;
    _darwedPathsLs.clear();

    setState(() { });

   // _startPathAnima();
   // _pathAnimaCtrlor.forward();
  //  await  _pathAnimaCtrlor.reverse();

  }


  void _startPathAnima() {
    _pathAnimaCtrlor.stop();
    _pathAnimaCtrlor.reset();
    _pathAnimaCtrlor.repeat(
      period: Duration(seconds: 1),
    );

  }


  @override
  Widget build(BuildContext context)
  {
    if( ( _currStep != widget._step) ){
      _currStep = widget._step;

      _animaingPathsLs.clear();
      int pcount = (_svgPathsLs.length  / widget._maxStep).ceil();
      for(int i = 0 ;  (i < pcount ) &&   _remainedPathsLs.isNotEmpty  ; i ++){

        int idx = 0;
        final rnd = TMath.Random();
        if(_remainedPathsLs.length > 1)
         idx = rnd.nextInt(_remainedPathsLs.length );


        Path tmpP = _remainedPathsLs[idx];
        _animaingPathsLs.add(tmpP );
        _remainedPathsLs.removeAt(idx);

      }

          _pathAnimaCtrlor.stop();
          _pathAnimaCtrlor.reset();
          _pathAnimaCtrlor.forward();


    }


   return Container(
     width: widget._width,
     height: widget._height,
    // color: Color(0x110000ff),
     child: CustomPaint(painter: _TFpPathAnima(  _svgPathsLs , _darwedPathsLs,  _animaingPathsLs  , _pathAnimaCtrlor ),
        size: Size(widget._width,widget._height),
      ),
   );
  }

}



class _TFpPathAnima extends CustomPainter
{
  final Animation<double> _animation;

  late Paint _mypaint;


  final  List<Path>  _drawingPathLs  ;
  final  List<Path>  _drawedPathLs  ;
  final  List<Path>  _basePathLs  ;

  _TFpPathAnima(this._basePathLs , this._drawedPathLs, this._drawingPathLs , this._animation) : super(repaint: _animation) {
    _mypaint = Paint()
      ..color = Color(0x22ff0000)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
       ..strokeMiterLimit = 0 ;
  }



  @override
  void paint(Canvas canvas, Size size) {

    // canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _mypaint);

    _mypaint.color = Color(0x11000000);
    _basePathLs.forEach((path) {
      canvas.drawPath(path, _mypaint);
    });


    _mypaint.color =  TGlobalData().crMainThemeColor ;//  Color(0xffff8888);

    _drawedPathLs.forEach((path) {
      canvas.drawPath(path, _mypaint);
    });

    _drawingPathLs.forEach((path) {

      final animationPercent = this._animation.value;

      // print("Painting + $animationPercent ");

      final tmpPath = createAnimatedPath( path , animationPercent);


      //  _mypaint.color = Color((TMath.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0) ;// Color(0xffffcccc);

      canvas.drawPath(tmpPath, _mypaint);
    });


  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    // throw UnimplementedError();
    return true;
  }

}



Path extractPathUntilLength(
    Path originalPath,
    double length,
    ) {
  var currentLength = 0.0;

  final path = new Path();

  var metricsIterator = originalPath.computeMetrics().iterator;

  while (metricsIterator.moveNext()) {
    var metric = metricsIterator.current;

    //  print('11 m len: ${metric.length} , currentLength : ${currentLength}');

    var nextLength = currentLength + metric.length;

    final isLastSegment = nextLength > length;
    if (isLastSegment) {

     // print('aaaaaaaa....m len: ${metric.length} , currentLength : ${currentLength}');


      final remainingLength = length - currentLength;
      final pathSegment = metric.extractPath(0.0, remainingLength);

      path.addPath(pathSegment, Offset.zero);


      break;
    } else {
      // There might be a more efficient way of extracting an entire path

     // print('bbbbbbbb..............m len: ${metric.length} , currentLength : ${currentLength}');

      final pathSegment = metric.extractPath(0.0, metric.length);
      path.addPath(pathSegment, Offset.zero);
    }

    currentLength = nextLength;
  }

  return path;
}


Path createAnimatedPath(
    Path originalPath,
    double animationPercent,
    ) {

  //print('animationPercent = $animationPercent');

  // ComputeMetrics can only be iterated once!
  final totalLength = originalPath
      .computeMetrics()
      .fold(0.0, (double prev, PathMetric metric) => prev + metric.length);

  final currentLength = totalLength * animationPercent;

  return extractPathUntilLength(originalPath, currentLength);
}







