import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';


enum _SwitchBoxProps { paddingTop, color, icon , rotation }


class CustomSwitch extends StatelessWidget {
    final bool switched;
    double widW;
    double widH;

  CustomSwitch({required this.switched , required this.widW, required this.widH});

  @override
  Widget build(BuildContext context) {


//     var tween = MultiTween<_SwitchBoxProps>()
//       ..add(_SwitchBoxProps.paddingTop, 0.0.tweenTo(32.0), 500.milliseconds)
//       ..add(_SwitchBoxProps.color, '#FF634E'.toColor().tweenTo('#22CCCC'.toColor()), 500.milliseconds)
//       ..add(_SwitchBoxProps.icon, ConstantTween(Icons.lock), 250.milliseconds)
//       ..add(_SwitchBoxProps.icon, ConstantTween(Icons.lock_open), 250.milliseconds)
//      // ..add(_SwitchBoxProps.rotation, (-2 * pi).tweenTo(0.0), 1.seconds)
//     ;

//     return CustomAnimation<MultiTweenValues<_SwitchBoxProps>>(
//       control: switched  ? CustomAnimationControl.play  : CustomAnimationControl.playReverse,
//       startPosition: switched ? 1.0 : 0.0,
//       duration: tween.duration * 1.2,
//       tween: tween,
//       curve: Curves.easeInOut,
//       builder: _buildSwitchBox,
//     );

    return Text("SwifthButtonHere22");

  }
//
//   Widget _buildSwitchBox(  context, child, MultiTweenValues<_SwitchBoxProps> value) {
//     return Container(
//      // color: Colors.red,
//        //decoration: _outerBoxDecoration(value.get(_SwitchBoxProps.color)),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(widW / 2.0),
//         color: Color(0xffeeeeee),
//       ),
//       width: widW,
//       height: widH,
//       padding: const EdgeInsets.all(12.0),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(widW / 2.0),
//           color: Color(0xff222222),
//         ),
//         child: Stack(
//           children: [
//
//             Positioned(
//               top: widH / 14.0 ,
//                 left:  widW / 4.6  ,
//                 child: Text('OFF', style: labelStyle,)),
//
//             Positioned(
//                 top: widH * .66 ,
//                 left:  widW / 4.0  ,
//                 child: Text('ON', style: labelStyle,)),
//
//             Positioned(
//                 top: widH * .026 ,
//                 left:  widW * .03 ,
//                 child: Padding(
//                   padding:  EdgeInsets.only(top: value.get(_SwitchBoxProps.paddingTop)),
//                   child: Transform.translate(
//                     //angle: value.get(_SwitchBoxProps.rotation),
//                     offset: Offset(0.0 ,  0.0),
//                     child: Container(
//                       decoration: _innerBoxDecoration(),
//                       width: widW * .7,
//                       height: widH * .6,
//                       child: Center(
//                           child: Icon(value.get(_SwitchBoxProps.icon), size: 44, color: value.get(_SwitchBoxProps.color) ,)),
//                     ),
//                   ),
//                 ))
//           ],
//         ),
//       ),
//     );
//   }

  BoxDecoration _innerBoxDecoration( ) => BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(50)), color: Colors.white);

  BoxDecoration _outerBoxDecoration(Color color) => BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(30)),
    border: Border.all(
      width: 2,
      color: color,
    ),
  );

static
  final labelStyle = TextStyle(
     // height: 1.4,
      fontWeight: FontWeight.w600,
      fontSize: 16,
      color: Color(0xffeeeeee),
     );
}