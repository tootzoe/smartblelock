import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:collection/collection.dart';

import '../TGlobal_inc.dart';
import '../TBleSingleton.dart';

class TDoorNfcWnd extends StatefulWidget {


  @override
  _TDoorNfcWndState createState() => _TDoorNfcWndState();
}


class _TDoorNfcWndState extends State<TDoorNfcWnd> {


  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

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
      appBar: AppBar(title: Text('NFC',
        style: TextStyle(color: Color(0xffeeeeee), fontSize: 20, fontWeight: FontWeight.bold), ),
      elevation: 0.0,
      backgroundColor: Color(0xff3D3D3D),
      iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(child: Text('NFC 功能开发中....', style: TGlobalData().tsTxtFn26Grey22Bn)),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('测试指纹通信', style: TGlobalData().tsHeaderTextStyle,),
              ),

              Wrap(
                spacing: 10,
                children: [

                  ElevatedButton(onPressed: (){
                    var jobj = {};
                    jobj["sjhqzwxx"] = "" ;


                    TBleSingleton().sendFramedJsonData(json.encode(jobj));


                  }, child: Text('unique id')),

                  ElevatedButton(onPressed: (){_chgeFpLed(3,1,50,0);}, child: Text('红色常亮')),
                  ElevatedButton(onPressed: (){_chgeFpLed(3,2,50,0);}, child: Text('绿色常亮')),
                  ElevatedButton(onPressed: (){_chgeFpLed(3,4,50,0);}, child: Text('蓝色常亮')),

                  ElevatedButton(onPressed: (){_chgeFpLed(2,1,50,0);}, child: Text('红色闪烁')),
                  ElevatedButton(onPressed: (){_chgeFpLed(2,2,80,0);}, child: Text('绿色闪烁')),
                  ElevatedButton(onPressed: (){_chgeFpLed(2,4,150,0);}, child: Text('蓝色闪烁')),

                  ElevatedButton(onPressed: (){_chgeFpLed(1,1,30,0);}, child: Text('红色呼吸灯')),
                  ElevatedButton(onPressed: (){_chgeFpLed(1,2,100,0);}, child: Text('绿色呼吸灯')),
                  ElevatedButton(onPressed: (){_chgeFpLed(1,4,200,0);}, child: Text('蓝色呼吸灯')),

                  ElevatedButton(onPressed: (){_chgeFpLed(2,6,50,0);}, child: Text('青色闪烁')),
                  ElevatedButton(onPressed: (){_chgeFpLed(3,3,50,0);}, child: Text('黄色常亮')),
                  ElevatedButton(onPressed: (){_chgeFpLed(1,5,100,0);}, child: Text('紫色呼吸灯')),
                  ElevatedButton(onPressed: (){_chgeFpLed(1,7,100,0);}, child: Text('白色呼吸灯')),
                  ElevatedButton(onPressed: (){_chgeFpLed(1,0x20,150,0);}, child: Text('三彩呼吸灯')),
                  ElevatedButton(onPressed: (){_chgeFpLed(1,0x30,80,0);}, child: Text('七彩仅呼吸灯')),


                ],
              ),



            ],
          )),
    );

  }

  // 控制类型
  // 1：呼吸灯
  // 2:  闪烁灯
  // 3:  常开
  // 4: 常关
  // 5: 渐亮
  // 6: 渐灭

  // 颜色
  // 1: 红色
  // 2: 绿色
  // 3: 黄色
  // 4: 蓝色
  // 5: 紫色
  // 6：青色
  // 7: 白色
  // 0x20 : 三彩 （仅呼吸灯）
  // 0x30 : 七彩 （仅呼吸灯）

  // 速度  : 0 - 255

  // 次数: 值越大越慢
  // 1 - 255
  // 0 表示无限次

  void _chgeFpLed(int t, int c, int s, int n)
  {


    var jobj = {};
    jobj["sjszzwled"] =  t ;
    jobj["c"] =  c ;
    jobj["s"] =  s ;
    jobj["n"] =  n ;

    TBleSingleton().sendFramedJsonData(json.encode(jobj));

  }


}
