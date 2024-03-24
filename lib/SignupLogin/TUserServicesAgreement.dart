import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

// import 'package:http/http.dart' as http;

import 'package:fluttertoast/fluttertoast.dart';
//import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'package:flutter_html/flutter_html.dart';



import '../TGlobal_inc.dart';

import '../TRemoteSrv.dart';

// import 'TAuthorizeWnd.dart';


class TUserServicesAgreement extends StatefulWidget {


   // TUserServicesAgreement();

  @override
  _TUserServicesAgreementState createState() => _TUserServicesAgreementState();
}


class _TUserServicesAgreementState extends State<TUserServicesAgreement> {


  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

  //  Future.delayed(Duration(milliseconds: 50)).then((_) => _fetchUserAgrementData( ));



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
      appBar: AppBar(title: Text( '用户服务协议',
        style: TextStyle(color: Color(0xff222222), fontSize: 20, fontWeight: FontWeight.bold), ),
        elevation: 0.0,
        backgroundColor: Color(0xffeeeeee),
        iconTheme: IconThemeData(color: Colors.black),
      ),
     // body: Text('《用户服务协议》', style: Theme.of(context).textTheme.headline1),

      body: SingleChildScrollView(

        child: FutureBuilder<String>(
          future: _fetchUserAgrementData(), // async work
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting: return Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError)
                  return Text('Error: ${snapshot.error}');
                else
                  return Html(
                    data: snapshot.data.toString(),

                      // onLinkTap: (String? url, RenderContext context, Map<String, String> attributes, dom.Element? element)
                      // {
                      //   print("Opening $url...");
                      // }

    // customRender: {
    // "table": (context, child) {
    // return SingleChildScrollView(
    // scrollDirection: Axis.horizontal,
    // child:
    // (context.tree as TableLayoutElement).toWidget(context),
    // );
    // },
    // "bird": (RenderContext context, Widget child) {
    // return TextSpan(text: "🐦");
    // },
    // "flutter": (RenderContext context, Widget child) {
    // return FlutterLogo(
    // style: (context.tree.element!.attributes['horizontal'] != null)
    // ? FlutterLogoStyle.horizontal
    //     : FlutterLogoStyle.markOnly,
    // textColor: context.style.color!,
    // size: context.style.fontSize!.size! * 5,
    // );
    // },
    // },

                  //    return Text( snapshot.data.toString() );
                  //
                  //   },
                   );

                 // return  Text( snapshot.data.toString() );
             }
          },
        ),
      ),



    );

  }


  Future<String>   _fetchUserAgrementData(  ) async
  {
    final tmpObj = await TRemoteSrv().fetUserAgreementAndPrivPolicy('detail');

    String cnt = '';


    if(tmpObj['code'] == 0){
      cnt = tmpObj['data']['content'].toString();
    }

    return Future.value(cnt);


  }

}
