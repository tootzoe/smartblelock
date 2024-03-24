import 'dart:math';
import '../TGlobal_inc.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';


enum _SwitchBoxProps { paddingLeft, color, icon , rotation }


class CustomSwitchRound extends StatelessWidget {
  final bool switched;
  final double widW;
  final double widH;

  CustomSwitchRound({required this.switched , required this.widW, required this.widH});

  @override
  Widget build(BuildContext context) {
//     var tween = MultiTween<_SwitchBoxProps>()
//       ..add(_SwitchBoxProps.paddingLeft, 2.0.tweenTo(widW * .5), 500.milliseconds)
//       ..add(_SwitchBoxProps.color, '#bbbbbb'.toColor().tweenTo('#22CCCC'.toColor()), 500.milliseconds)
//
//     // ..add(_SwitchBoxProps.rotation, (-2 * pi).tweenTo(0.0), 1.seconds)
//         ;

//     return CustomAnimation<MultiTweenValues<_SwitchBoxProps>>(
//       control: switched  ? CustomAnimationControl.play  : CustomAnimationControl.playReverse,
//       startPosition: switched ? 1.0 : 0.0,
//       duration: tween.duration * 1.2,
//       tween: tween,
//       curve: Curves.easeInOut,
//       builder: _buildSwitchBox,
//     );

    return Text("SwifthButtonHere");

  }
//
//   Widget _buildSwitchBox(  context, child, MultiTweenValues<_SwitchBoxProps> value) {
//     return Container(
//        // color: Colors.red,
//       //decoration: _outerBoxDecoration(value.get(_SwitchBoxProps.color)),
//       // decoration: BoxDecoration(
//       //   borderRadius: BorderRadius.circular(widW / 2.0),
//       //   color: Color(0xffaaaaaa),
//       // ),
//       width: widW,
//       height: widH,
//      // padding: const EdgeInsets.all(12.0),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(widW / 2.0),
//           color: value.get(_SwitchBoxProps.color),
//         ),
//         child:
//                 Align(
//                  alignment: Alignment.centerLeft,
//                   child: Padding(
//                     padding:  EdgeInsets.only(left: value.get(_SwitchBoxProps.paddingLeft)),
//                     child:  Container(
//                         decoration: _innerBoxDecoration(),
//                         width: widW * .46,
//                         height: widW * .46,
//
//                       ),
//
//                   ),
//                 )
//
//       ),
//     );
//   }

  BoxDecoration _innerBoxDecoration( ) => BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(50)), color: Colors.white,);

  BoxDecoration _outerBoxDecoration(Color color) => BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(30)),
    border: Border.all(
      width: 2,
      color: color,
    ),
  );

}