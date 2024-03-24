
import 'dart:ui';

import 'TRemoteSrv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
//import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:flutter_localizations/flutter_localizations';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'TGlobal_inc.dart';
import 'TBleSingleton.dart';
import 'SignupLogin/TLogingWnd.dart';
import 'TMainWnd.dart';


//import 'package:flutter_gen/gen_l10n/TLocalizations.dart';

//
// api1.smartlock.com 内网
// testapi.ultronlocker.com 外网测试
// api.ultronlocker.com 正式


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await FirebaseMessaging.instance
      .setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

   await TGlobalData().loadPreferences();
  TBleSingleton().initData();




  runApp(Phoenix(child: TSplashWnd()));

  //runApp(MyApp());
}


//
//
// import 'dart:convert';
//
// import 'package:convert/convert.dart';
// import 'package:dart_des/dart_des.dart';
//
// main() {
//   String key = '12345678'; // 8-byte
//   String message = 'Driving in from the edge of town';
//   List<int> encrypted;
//   List<int> decrypted;
//   List<int> iv = [1, 2, 3, 4, 5, 6, 7, 8];
//
//   print('key: $key');
//   print('message: $message');
//
//   DES desECB = DES(key: key.codeUnits, mode: DESMode.ECB);
//   encrypted = desECB.encrypt(message.codeUnits);
//   decrypted = desECB.decrypt(encrypted);
//   print('DES mode: ECB');
//   // print('encrypted: $encrypted');
//   print('encrypted (hex): ${hex.encode(encrypted)}');
//   print('encrypted (base64): ${base64.encode(encrypted)}');
//   // print('decrypted: $decrypted');
//   print('decrypted (hex): ${hex.encode(decrypted)}');
//   print('decrypted (utf8): ${utf8.decode(decrypted)}');
//
//   DES desCBC = DES(key: key.codeUnits, mode: DESMode.CBC, iv: iv);
//   encrypted = desCBC.encrypt(message.codeUnits);
//   decrypted = desCBC.decrypt(encrypted);
//   print('DES mode: CBC');
//   // print('encrypted: $encrypted');
//   print('encrypted (hex): ${hex.encode(encrypted)}  , len: ${encrypted.length} ');
//   print('encrypted (base64): ${base64.encode(encrypted)}');
//   // print('decrypted: $decrypted');
//   print('decrypted (hex): ${hex.encode(decrypted)}');
//   print('decrypted (utf8): ${utf8.decode(decrypted)}');
//
//   key = '1234567812345678'; // 16-byte
//   DES3 des3ECB = DES3(key: key.codeUnits, mode: DESMode.ECB , paddingType: DESPaddingType.None);
//   encrypted = des3ECB.encrypt(message.codeUnits);
//   decrypted = des3ECB.decrypt(encrypted);
//   print('Triple DES mode: ECB');
//   // print('encrypted: $encrypted');
//   print('None.encrypted (hex): ${hex.encode(encrypted)} , len: ${encrypted.length}');
//   print('encrypted (base64): ${base64.encode(encrypted)}');
//   // print('decrypted: $decrypted');
//   print('decrypted (hex): ${hex.encode(decrypted)}');
//   print('decrypted (utf8): ${utf8.decode(decrypted)}');
//
//   key = '123456781234567812345678'; // 24-byte
//   DES3 des3CBC = DES3(key: key.codeUnits, mode: DESMode.CBC, iv: iv);
//   encrypted = des3CBC.encrypt(message.codeUnits);
//   decrypted = des3CBC.decrypt(encrypted);
//   print('Triple DES mode: CBC');
//   // print('encrypted: $encrypted');
//   print('encrypted (hex): ${hex.encode(encrypted)} , len: ${encrypted.length}');
//   print('encrypted (base64): ${base64.encode(encrypted)}');
//   // print('decrypted: $decrypted');
//   print('decrypted (hex): ${hex.encode(decrypted)}');
//   print('decrypted (utf8): ${utf8.decode(decrypted)}');
// }
//



class TLocalChgedNotifyer with ChangeNotifier {
  Locale loca = Locale('en');

  Locale get  getLocale => loca;
  void chgeLocale(Locale l){
    loca = l;
    notifyListeners();
  }

}



class TSplashWnd extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:(_) => TLocalChgedNotifyer(),
      child: Consumer<TLocalChgedNotifyer>(
        builder:(context , provider, child) =>
          MaterialApp(
         // on
          title: 'AwesomeBleLock',
          debugShowCheckedModeBanner: false,
         // onGenerateTitle: (BuildContext context) => DemoLocalizations.of(context).title,





//
//          locale: Provider.of<TLocalChgedNotifyer>(context).loca,
//           localizationsDelegates: AppLocalizations.localizationsDelegates,
//           supportedLocales: AppLocalizations.supportedLocales,
//           localeListResolutionCallback: (List<Locale>? locLs, Iterable<Locale> supportedLoacs) {
//
//             List<String> appCurrLangLs = TGlobalData().fetAppCurrLanguage();
//
//             final appLocal =   Locale.fromSubtags(languageCode: appCurrLangLs[0],
//                 countryCode: appCurrLangLs[1].isEmpty ? null : appCurrLangLs[1] ,
//                 scriptCode: appCurrLangLs[2].isEmpty ? null : appCurrLangLs[2]);
//
//             for (var ll in supportedLoacs) {
//                 if(ll == appLocal ){
//                   return ll;
//                 }
//
//             }
//
//             return supportedLoacs.first;
//             },












          home: TSplashLogoWnd(),
          //theme: ThemeData.dark(),
           // themeMode: ThemeMode.dark,
            theme: ThemeData.light(),

           themeMode: ThemeMode.light,
         //  theme: ThemeData(
         //    // Define the default brightness and colors.
         //    brightness: Brightness.dark,
         //    primaryColor: Colors.lightBlue[800],
         //    accentColor: Colors.cyan[600],
         //
         //    splashColor: Colors.transparent,
         //    hoverColor: Colors.transparent,
         //
         //    // Define the default font family.
         //    // fontFamily: 'Georgia',
         //
         //
         //
         //    // Define the default TextTheme. Use this to specify the default
         //    // text styling for headlines, titles, bodies of text, and more.
         //    textTheme: TextTheme(
         //      headline1: TextStyle(
         //          fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.black),
         //      headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
         //      bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
         //    ),
         //  ),
        ),
      ),
    );
  }
}

class TSplashLogoWnd extends StatefulWidget {
  @override
  _TSplashLogoWndState createState() => _TSplashLogoWndState();
}

class _TSplashLogoWndState extends State<TSplashLogoWnd> {
  @override
  void reassemble() {
    // print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();


      Future.delayed(Duration(milliseconds: 2000)).then((_) async {


      TDevsSizeFit().init(context);

      if(TGlobalData().currUserToken().isEmpty){
        _goLoginWnd();
        return;
      }



      print('================= Fetch all locks list and decide go which page....');
      final rtnObj = await TRemoteSrv().allDoorLocksList();

      if(rtnObj.isEmpty){
        _goLoginWnd();
        return;
      }

      int code = rtnObj['code'];

      if(code == 0)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              settings: RouteSettings(name: '/tmainwnd', arguments: Map()),
              builder: (context) => TMainWnd()),
        );
       else _goLoginWnd();



    });

   testFireBase();

  }

  void _goLoginWnd(){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  TLogingWnd()),
      //MaterialPageRoute(builder: (context) => TDevMainWnd()),
    );
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

  void testFireBase() async {


   // FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // FirebaseMessaging.instance.getToken().then((value) {
    //   print('FCM token: $value');
    // } );



    FirebaseMessaging.instance.getInitialMessage()
       .then((RemoteMessage? message) {
         if(message != null){
           print('Got a message from getInitialMessage!');
           print('Message data: ${message.data}');

           if (message.notification != null) {
             print('Message also contained a notification: ${message.notification}');
             print( 'title:    ${message.notification!.title} ');
             print( 'text cnt:    ${message.notification!.body} ');
           }
         }

   });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
       print( 'title:    ${message.notification!.title} ');
        print( 'text cnt:    ${message.notification!.body} ');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was Arrived....!');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        print( 'title:    ${message.notification!.title} ');
        print( 'text cnt:    ${message.notification!.body} ');
      }

    });



  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [


              //
              // CustomPaint( painter:  TLineCorner2() ,
              // //  size: Size(MediaQuery.of(context).size.width,  MediaQuery.of(context).size.height * .7 ),
              //   size: Size(200, 200),
              // ),


                // SizedBox(
                //   width: 90,
                //   height: 90,
                  // child:
                SvgPicture.asset( 'images/svgs/AppLogo.svg' ,width: 90, fit: BoxFit.contain, ),
                  // child:
                  // Image.asset(  'images/AppLogo.png' , width: 90, fit: BoxFit.fill, ),
              //  ),


              SizedBox(height: 12,),

               Text('Smart Lock',
                 style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w400),),
              SizedBox(height: 50,),

            ],
          )),
    );
  }
}








/*
class TLineCorner2 extends CustomPainter{
  late Paint _myPaint;

  TLineCorner2(   ) {
    _myPaint = Paint()
      ..color =   Color(0xffaaaaaa)
      ..strokeWidth = 2.0
      ..style =PaintingStyle.stroke;
  }

  @override
  void paint(Canvas canvas, Size size) {

    final height = size.height  ;
    final width = size.width ;

    print('do paint....................');
    Rect rect = Offset.zero & size;
    //Number 0
    Path path0 = Path();
    path0.moveTo(width * 0.461 , height * -0.3513);
    path0.quadraticBezierTo(width * 0.5728, height * -0.3458, width * 0.5903, height * -0.4686);
    path0.cubicTo(width * 0.6079, height * -0.5914, width * 0.6287, height * -0.7318, width * 0.6101, height * -0.7362);
    path0.cubicTo(width * 0.5914, height * -0.7405, width * 0.5947, height * -0.7438, width * 0.5695, height * -0.6243);
    path0.cubicTo(width * 0.5443, height * -0.5048, width * 0.5761, height * -0.4226, width * 0.4818, height * -0.3842);
    path0.quadraticBezierTo(width * 0.3875, height * -0.3458, width * 0.3688, height * -0.3535);
    Paint spaint0 = Paint();
    spaint0.color = Colors.red;
    spaint0.strokeWidth = 1;
    spaint0.strokeMiterLimit = 4;
    spaint0.style = PaintingStyle.stroke;
    canvas.drawPath(path0, spaint0);

    //Number 1
    Path path1 = Path();
    path1.moveTo(width * 0.3342 , height * -0.3771);
    path1.quadraticBezierTo(width * 0.4811, height * -0.4188, width * 0.4942, height * -0.4604);
    path1.cubicTo(width * 0.5074, height * -0.5021, width * 0.5348, height * -0.5745, width * 0.5392, height * -0.6468);
    path1.cubicTo(width * 0.5436, height * -0.7192, width * 0.5458, height * -0.7762, width * 0.5677, height * -0.785);
    path1.cubicTo(width * 0.5896, height * -0.7938, width * 0.6576, height * -0.8256, width * 0.6521, height * -0.7729);
    path1.cubicTo(width * 0.6467, height * -0.7203, width * 0.651, height * -0.6841, width * 0.6456, height * -0.6315);
    path1.cubicTo(width * 0.6401, height * -0.5789, width * 0.6324, height * -0.5383, width * 0.6247, height * -0.5142);
    path1.cubicTo(width * 0.6171, height * -0.49, width * 0.6072, height * -0.4177, width * 0.5842, height * -0.3892);
    path1.cubicTo(width * 0.5611, height * -0.3606, width * 0.5107, height * -0.3343, width * 0.4679, height * -0.3278);
    path1.cubicTo(width * 0.4252, height * -0.3212, width * 0.4285, height * -0.3299, width * 0.3813, height * -0.3201);
    Paint spaint1 = Paint();
    spaint1.color =  Colors.green;
    spaint1.strokeWidth = 1;
    spaint1.strokeMiterLimit = 4;
    spaint1.style = PaintingStyle.stroke;
    canvas.drawPath(path1, spaint1);

    //Number 2
    Path path2 = Path();
    path2.moveTo(width * 0.2936 , height * -0.4045);
    path2.cubicTo(width * 0.3451, height * -0.4593, width * 0.3506, height * -0.4396, width * 0.3868, height * -0.5383);
    path2.cubicTo(width * 0.423, height * -0.637, width * 0.4208, height * -0.7346, width * 0.4734, height * -0.8069);
    path2.cubicTo(width * 0.526, height * -0.8793, width * 0.5918, height * -0.9253, width * 0.65, height * -0.8815);
    path2.cubicTo(width * 0.7081, height * -0.8376, width * 0.7903, height * -0.7696, width * 0.7881, height * -0.728);
    path2.cubicTo(width * 0.7859, height * -0.6863, width * 0.7662, height * -0.5383, width * 0.7388, height * -0.4791);
    path2.cubicTo(width * 0.7114, height * -0.4199, width * 0.651, height * -0.3124, width * 0.5776, height * -0.2598);
    path2.cubicTo(width * 0.5041, height * -0.2071, width * 0.4932, height * -0.2367, width * 0.3989, height * -0.2071);
    path2.cubicTo(width * 0.3046, height * -0.1775, width * 0.3287, height * -0.1468, width * 0.332, height * -0.1172);
    Paint spaint2 = Paint();
    spaint2.color = Colors.blue;
    spaint2.strokeWidth = 1;
    spaint2.strokeMiterLimit = 4;
    spaint2.style = PaintingStyle.stroke;
    canvas.drawPath(path2, spaint2);

    //Number 3
    Path path3 = Path();
    path3.moveTo(width * 0.2719 , height * -0.6191);
    path3.lineTo(width * 0.0778, height * -0.6191);
    path3.lineTo(width * 0.0778, height * -0.7299);
    path3.lineTo(width * 0.2719, height * -0.7299);
    path3.lineTo(width * 0.2719, height * -0.6191);
    Paint fpaint3 = Paint();
    var fgradient3 = LinearGradient(
      begin: const Alignment(-0.845, -2.3474),
      end: const Alignment(-0.4568, -2.3474),
      colors: [
      Colors.red ,
      Colors.green ,
      Colors.blue ,
        Colors.cyan ,
      ],
      stops: [0, 0.30898899078369, 0.71348297119141, 1, ],
    );
    fpaint3.shader = fgradient3.createShader(rect);
    canvas.drawPath(path3, fpaint3);
    Paint spaint3 = Paint();
    spaint3.color =  Colors.purple ;
    spaint3.strokeWidth = 1;
    spaint3.strokeMiterLimit = 4;
    spaint3.style = PaintingStyle.stroke;
    canvas.drawPath(path3, spaint3);

    //Number 4
    Path path4 = Path();
    path4.moveTo(width * 0.2475 , height * -0.2208);
    path4.lineTo(width * 0.1765, height * -0.2534);
    path4.lineTo(width * 0.1093, height * -0.2134);
    path4.lineTo(width * 0.1184, height * -0.2911);
    path4.lineTo(width * 0.0596, height * -0.3426);
    path4.lineTo(width * 0.1363, height * -0.358);
    path4.lineTo(width * 0.1671, height * -0.4298);
    path4.lineTo(width * 0.2054, height * -0.3616);
    path4.lineTo(width * 0.2833, height * -0.3545);
    path4.lineTo(width * 0.2302, height * -0.297);
    path4.lineTo(width * 0.2475, height * -0.2208);
    Paint fpaint4 = Paint();
    var fgradient4 = RadialGradient(
      center: const Alignment(-0.6574, -1.6424),
      radius: 0.11737929280599,
      colors: [
        Colors.red ,

        Colors.cyan ,
      ],
      stops: [0, 1, ],
    );
    fpaint4.shader = fgradient4.createShader(rect);
    canvas.drawPath(path4, fpaint4);
    Paint spaint4 = Paint();
    spaint4.color =  Colors.cyan ;
    spaint4.strokeWidth = 1;
    spaint4.strokeMiterLimit = 4;
    spaint4.style = PaintingStyle.stroke;
    canvas.drawPath(path4, spaint4);


  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    // throw UnimplementedError();
    return false;
  }

}



*/





/*


void main3() => runApp(
  new MaterialApp(
    home: new AnimatedPathDemo(),
  ),
);


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

      print('aaaaaaaa....m len: ${metric.length} , currentLength : ${currentLength}');


      final remainingLength = length - currentLength;
      final pathSegment = metric.extractPath(0.0, remainingLength);

      path.addPath(pathSegment, Offset.zero);


      break;
    } else {
      // There might be a more efficient way of extracting an entire path

      print('bbbbbbbb..............m len: ${metric.length} , currentLength : ${currentLength}');

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

  // ComputeMetrics can only be iterated once!
  final totalLength = originalPath
      .computeMetrics()
      .fold(0.0, (double prev, PathMetric metric) => prev + metric.length);

  final currentLength = totalLength * animationPercent;

  return extractPathUntilLength(originalPath, currentLength);
}

class AnimatedPathPainter extends CustomPainter {
  final Animation<double> _animation;

  AnimatedPathPainter(this._animation) : super(repaint: _animation);

  Path _createAnyPath(Size size) {
    return Path()
      ..moveTo(size.height / 4, size.height / 4)
      ..lineTo(size.height, size.width / 2)
      ..lineTo(size.height / 2, size.width)
      ..quadraticBezierTo(size.height / 2, 100, size.width, size.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final animationPercent = this._animation.value;

   // print("Painting + $animationPercent ");

    final path = createAnimatedPath(_createAnyPath(size), animationPercent);



    final Paint paint = Paint();
    paint.color = Colors.amberAccent;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 10.0;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class AnimatedPathDemo extends StatefulWidget {
  @override
  _AnimatedPathDemoState createState() => _AnimatedPathDemoState();
}

class _AnimatedPathDemoState extends State<AnimatedPathDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  void _startAnimation() {
    _controller.stop();
    _controller.reset();
    _controller.repeat(
      period: Duration(seconds: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: const Text('Animated Paint')),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            width: 300,
            child: new CustomPaint(
              painter: new AnimatedPathPainter(_controller),
            ),
          ),


          ElevatedButton(onPressed: _startAnimation, child: Icon(Icons.play_arrow)),
          ElevatedButton(onPressed: (){_controller.stop();}, child: Icon(Icons.stop)),




        ],
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _startAnimation,
        child: new Icon(Icons.play_arrow),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}





*/

