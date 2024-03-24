import '../TRemoteSrv.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';

import '../TGlobal_inc.dart';

import '../TMainWnd.dart';

class TUserChgeNickname extends StatefulWidget {

  final String oriNickname;

  TUserChgeNickname(this.oriNickname);


  @override
  _TUserChgeNicknameState createState() => _TUserChgeNicknameState();
}

class _TUserChgeNicknameState extends State<TUserChgeNickname> {

  final _nicknameTxtCtrlor = TextEditingController();

  bool _isBtnEnabled = true;

  @override
  void reassemble() {
    // print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();


    _nicknameTxtCtrlor.text = widget.oriNickname;

    // new Future.delayed(Duration(milliseconds: 1200)).then((_) {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => TLogingWnd()),
    //     //MaterialPageRoute(builder: (context) => TDevMainWnd()),
    //   );
    // });
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          '设置昵称',
          style: TGlobalData().tsListTitleTS1,
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(

        behavior: HitTestBehavior.opaque,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Container(

              padding: EdgeInsets.all(20.0),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  Expanded(
                    flex: 10,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        '支持中英文，数字（10个字符内）',
                        style: TGlobalData().tsListCntTS1,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 10,
                    child: TextField(
                      controller: _nicknameTxtCtrlor,
                      decoration: InputDecoration(

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.black38),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.black38),
                        ),
                          suffixIcon:  _nicknameTxtCtrlor.text.isEmpty  ? null :  IconButton(icon: Icon(Icons.clear,color: TGlobalData().crMainThemeColor,),
                            onPressed: (){
                            setState(() {
                              _nicknameTxtCtrlor.clear();
                            });

                            } , )  ,

                      ),



                      onChanged: (str){
                        setState(() {
                          _isBtnEnabled = ! str.isEmpty;
                        });


                      },
                    ),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: TGlobalData().crMainThemeColor,
                      onPrimary: Color(0xff119999),

                      shape: StadiumBorder(),
                      shadowColor: Color(0xff118888),
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 0),
                      // textStyle: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                    child: Text(
                      '确   定',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    onPressed: _nicknameTxtCtrlor.text.isEmpty  ? null :   () async  {

                      String nn = _nicknameTxtCtrlor.text;
                      var rtnObj =  await TRemoteSrv().updateUsernamePhoto(nn, null);

                      if(rtnObj['code'] == 0){
                        Navigator.pop(context , nn);
                        return;
                      }

                      TGlobalData().showToastInfo('修改昵称失败....');


                    }  ,
                  ),

                  Expanded(flex :30,child:SizedBox()),

                ],
              )),
        ),
      ),
    );
  }
}
