
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class TTabbarIndicator extends Decoration{

  final double height;
  final Color cr;

  TTabbarIndicator(  {required this.height, required this.cr});


  @override
  _TIndicatorPainter createBoxPainter([VoidCallback? onChanged]) {

    return _TIndicatorPainter(this, onChanged!);
  }

}

class _TIndicatorPainter extends BoxPainter {

  final TTabbarIndicator targetWid;

  _TIndicatorPainter(this.targetWid,   VoidCallback onChged):
      assert( targetWid != null) ,super(onChged);


  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration != null);
    assert(configuration.size != null);

    Rect rc;

    rc = Offset(offset.dx,  offset.dy) & Size(configuration.size!.width, configuration.size!.height ) ;

    final Paint p = Paint();


    p.color = targetWid.cr;
    p.style = PaintingStyle.fill;

    double roundness = 30;

    canvas.drawRRect(RRect.fromRectAndCorners(rc ,
        topLeft: Radius.circular(roundness),
    topRight:  Radius.circular(roundness),
      bottomLeft: Radius.circular(roundness),
      bottomRight: Radius.circular(roundness),
    ) , p) ;


  }

}










