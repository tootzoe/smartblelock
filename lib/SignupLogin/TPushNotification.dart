
import 'package:flutter/material.dart';


class TPushNotification extends StatefulWidget {

   final String msgStr;

    TPushNotification({required this.msgStr});

  @override
  _TPushNotificationState createState() => _TPushNotificationState();
}


class _TPushNotificationState extends State<TPushNotification>
      with SingleTickerProviderStateMixin
{

  late  AnimationController _animCtrllor;
  late Animation<Offset> _pos;

  // @override
  // void reassemble() {
  //   print('${this.runtimeType.toString()} reassemble().... .......');
  // }

  @override
  void initState() {
    super.initState();

    _animCtrllor = AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _pos = Tween<Offset>(begin: Offset(0.0, -4.0), end: Offset.zero).animate(
      CurvedAnimation(parent: _animCtrllor, curve: Curves.bounceInOut)
    );

    _animCtrllor.forward();

    Future.delayed(Duration(seconds: 4)).then((_) {
        _animCtrllor.reverse();
    });

  }

  @override
  void deactivate() {
   // print('${this.runtimeType.toString()} deactivate()......................');
  }

  @override
  void dispose() {
     print('${this.runtimeType.toString()} dispose()......................');

    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    // return Material(
    //   elevation: 0,
    //   color: Colors.transparent,
    //   child: Align(
    //     alignment: Alignment.topCenter,
    //     child: Padding(
    //       padding: EdgeInsets.only(top: 32.0),
    //       child: SlideTransition(
    //         position: _pos,
    //         child: Container(
    //           decoration: ShapeDecoration(
    //             color: Color.fromARGB(255, 0x22, 0xcc, 0xcc),
    //             shape: RoundedRectangleBorder(
    //               borderRadius: BorderRadius.circular(16.0)
    //             )
    //           ),
    //           child: Padding(
    //             padding: EdgeInsets.all(10.0),
    //             child: Text(
    //               widget.msgStr,
    //               style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    //             ),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );

    return DefaultTextStyle(
      style: TextStyle(decoration: TextDecoration.none),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: 32.0),
          child: SlideTransition(
            position: _pos,
            child: Container(
              decoration: ShapeDecoration(
                  color: Color.fromARGB(255, 0x22, 0xcc, 0xcc),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)
                  )
              ),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  widget.msgStr,
                 // style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ),
    );


  }



  //
  // @override
  // Widget build(BuildContext context) {
  //   return SafeArea(
  //     child: Container(
  //       child: Center(
  //         child: Text(widget.msgStr),
  //       ),
  //     ),
  //   );
  //
  // }


}
