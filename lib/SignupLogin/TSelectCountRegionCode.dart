import '../TGlobal_inc.dart';
import 'package:flutter/material.dart';
import 'package:lpinyin/lpinyin.dart';

import '../Misc/CountryList.dart';

class TSelectCountRegionCode extends StatefulWidget {
  @override
  _TSelectCountRegionCodeState createState() => _TSelectCountRegionCodeState();
}

class _TSelectCountRegionCodeState extends State<TSelectCountRegionCode> {
  //final List<String> _recentlyUsedLs = ['840','702','344','116','156'];  // read from shareperence

  final _countryDatLs = Countries.countryList;

  late final List<dynamic> _sortedCountriesLs;

  final List<String> _letterLs = [];
  List<bool> _isLetterBold = [];
  int _currBoldIdx = 0;

  List<Widget> _allCountriesWidLs = [];
  List<Widget> _recentCountriesWidLs = [];

  final Map<String, GlobalKey> _letterToGlobalKey = {};
  
  late ScrollController _scrollCtrlor;

  late final int  _statusBarHeight;
  late final int  _appBarHeight;

  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');

  }

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback(_initAfterLayout);
    super.initState();

    _sortedCountriesLs = sortAllCountries();
    
    _scrollCtrlor = ScrollController();
    _scrollCtrlor.addListener( _listViewScrollControllor);


    prepareAllCountryWid();


  }

  void _initAfterLayout(ts) {
     _appBarHeight = AppBar().preferredSize.height.toInt()  ;
     _statusBarHeight = MediaQuery.of(context).padding.top .toInt();

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

  void _listViewScrollControllor()
  {

    int j = 0;
    if(_scrollCtrlor.offset < 5){
      if(_currBoldIdx != j) {
        _currBoldIdx = j;
        for (int k = 0; k < _isLetterBold.length; k ++)
          _isLetterBold[k] = false;
        setState(() {
          _isLetterBold[j] = true;
        });
      }
      return;
    }




    for (int i = 65; i < 65 + 26; i++)
     // for (int i = 65; i < 65 + 1; i++)
      {
      String L = String.fromCharCode(i);
      if (L == 'O' || L == 'Q' || L == 'I' || L == 'U' || L == 'V') continue;

     GlobalKey _k = _letterToGlobalKey[L]!;

     final RenderBox _rb = _k.currentContext!.findRenderObject()! as RenderBox;
      int  _topOf = _rb.globalToLocal(Offset(0.0, (_statusBarHeight + _appBarHeight).toDouble())).dy .toInt();
      int  _widgetH = _rb.size.height .toInt(); //

      int _diff = _topOf .abs() ;
      // print(' _topOf : $_topOf  _diff: ${_diff.abs()}  _widgetH: $_widgetH'  );
      j ++;
      if(_diff.abs() < _widgetH / 2  )
        {

          if(_currBoldIdx != j){
            _currBoldIdx = j;
            for(int k = 0 ; k < _isLetterBold.length ; k ++)
              _isLetterBold[k] = false;
            setState(() {
              _isLetterBold[j] = true;
            });
          }

          return;
        }

   }
    
  }

  List<dynamic> sortAllCountries() {
    List<String> recentlyUsedLs = TGlobalData().fetRecentUsedCountryLs();

    _letterToGlobalKey.putIfAbsent('#', () => GlobalKey());
    _letterLs.add('#');
    _isLetterBold.add(true);

    List<dynamic> rtnLs = [];
    for (int i = 65; i < 65 + 26; i++) {
      String L = String.fromCharCode(i);
      if (L == 'O' || L == 'Q' || L == 'I' || L == 'U' || L == 'V') continue;
      _letterLs.add(L);
      _letterToGlobalKey.putIfAbsent(L, () =>  GlobalKey());
      _isLetterBold.add(false);
      final tmpObj = {};
      tmpObj["L"] = L;
      rtnLs.add(tmpObj);
      for (int j = 0; j < _countryDatLs.length; j++) {
        var tmpO = _countryDatLs[j];
        String py = PinyinHelper.getShortPinyin(tmpO['nameTranslations']['zh'])
            .toUpperCase();
        if (py.startsWith(L)) {
          final tmpObj2 = {};
          tmpObj2["L"] = L;
          tmpObj2['nc'] = tmpO['num_code'];
          tmpObj2['dc'] = tmpO['dial_code'];
          tmpObj2['a2c'] = tmpO['alpha_2_code'];
          tmpObj2['cn'] = tmpO['nameTranslations']['zh'];
          if (recentlyUsedLs.contains(tmpO['num_code'])) tmpObj2["recent"] = 1;

          rtnLs.add(tmpObj2);
        }
      }
    }

    return rtnLs;
  }


  void prepareAllCountryWid()
  {

    for (int e = 0; e < _sortedCountriesLs.length; e++) {

  var wid = Container(
  decoration: BoxDecoration(
  border: Border(
  bottom: BorderSide(
  color: Color(0xffeeeeee), width: 1.0))),
  child: ListTile(
  onTap: () {

  if(_sortedCountriesLs[e]['a2c'] == null)
  return;

  List<String> recentlyUsedLs =
  TGlobalData().fetRecentUsedCountryLs();

  String targetStr = _sortedCountriesLs[e]['nc'];
  if(recentlyUsedLs.contains( targetStr)){
    recentlyUsedLs.remove(targetStr);
  }
  recentlyUsedLs.add(targetStr);
  TGlobalData().keepRecentUsedCountryLs(recentlyUsedLs);

  Navigator.pop(context , _sortedCountriesLs[e]['dc']);
  },
  focusColor: Colors.red,
  leading: _sortedCountriesLs[e]['a2c'] == null
  ? null
      : Image.asset(
  'images/flags/${_sortedCountriesLs[e]['a2c'].toString().toLowerCase()}.png',
  fit: BoxFit.contain,
  width: 32,
  ),
  title: Text(
  _sortedCountriesLs[e]['cn'] == null
  ? _sortedCountriesLs[e]['L']
      : _sortedCountriesLs[e]['cn'],
  style: _sortedCountriesLs[e]['cn'] == null
  ? TextStyle(
  color: Color(0xff22cccc),
  fontWeight: FontWeight.bold,
  fontSize: 22)
      : TextStyle(),

  key: _sortedCountriesLs[e]['cn'] == null
  ? _letterToGlobalKey[  _sortedCountriesLs[e]['L'] ]
      : null,
  ),
  trailing: Text(
  _sortedCountriesLs[e]['dc'] == null
  ? ''
      : _sortedCountriesLs[e]['dc'],
  style: TextStyle(
  color: Color(0xff666666),
  fontWeight: FontWeight.normal,
  fontSize: 18),
  ),
  ));

    _allCountriesWidLs.add(wid);

  }



    List<String> tmpReorderNcLs = [];
    for (int e = 0; e < _sortedCountriesLs.length; e++)   {
  if (_sortedCountriesLs[e]['recent'] == null)
    continue;

  var wid = Container(
  decoration: BoxDecoration(
  border: Border(
  bottom: BorderSide(
  color: Color(0xffeeeeee), width: 1.0))),
  child: ListTile(
  onTap: () {

    String targetStr = _sortedCountriesLs[e]['nc'];
    List<String> ruls =  TGlobalData().fetRecentUsedCountryLs()  ;
    if(ruls.contains( targetStr)){
      ruls.remove(targetStr);
    }
    ruls.add(targetStr);
    TGlobalData().keepRecentUsedCountryLs(ruls);

    // print('Got dial Code: ${_sortedCountriesLs[e]['dc']}');
  Navigator.pop(context , _sortedCountriesLs[e]['dc']);
  },
  leading: _sortedCountriesLs[e]['a2c'] == null
  ? null
      : Image.asset(
  'images/flags/${_sortedCountriesLs[e]['a2c'].toString().toLowerCase()}.png',
  fit: BoxFit.contain,
  width: 32,
  ),
  title: Text(_sortedCountriesLs[e]['cn']),
  trailing: Text(
  _sortedCountriesLs[e]['dc'],
  style: TextStyle(
  color: Color(0xff666666),
  fontWeight: FontWeight.normal,
  fontSize: 18),
  ),
  ));

  _recentCountriesWidLs.add(wid);
  tmpReorderNcLs.add(_sortedCountriesLs[e]['nc']);

  }

    List<String> ruls =  TGlobalData().fetRecentUsedCountryLs().reversed.toList() ;
    List<Widget> tmpWidLs = [];

    if(ruls.length > 0 && _recentCountriesWidLs.length > 0){
      for(int i = 0 ; i < ruls.length ; i ++){
        for(int j = 0 ; j < tmpReorderNcLs.length ; j ++)
         if(tmpReorderNcLs[j] == ruls[i]){
           tmpWidLs.add(_recentCountriesWidLs[j]);
         }
      }
      _recentCountriesWidLs = tmpWidLs;
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('选择国家或地区',
        style: TextStyle(color: Color(0xff222222), fontSize: 20, fontWeight: FontWeight.bold), ),
      elevation: 0.0,
      backgroundColor: Color(0xffeeeeee),
      iconTheme: IconThemeData(color: Colors.black),
    ),

      resizeToAvoidBottomInset: false,
      body: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Color(0xff11aaaa),
        ),
        child: Container(
            child: Stack(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 40, 0),
            child: SingleChildScrollView(

              controller: _scrollCtrlor,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Container(
                        width: 46,
                        height: 26,
                        decoration: ShapeDecoration(
                            color: Color(0xff22cccc),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0))),
                        child: Center(
                          child: Text(
                            '常用',
                            style: TextStyle(color: Colors.white),
                            key: _letterToGlobalKey['#'],
                          ),
                        ),
                      ),
                    ),
                  ),

                  ..._recentCountriesWidLs,
                  ..._allCountriesWidLs,

                  Container(
                    width: 10,
                    height: 100,
                  ),

                ],
              ),
            ),
          ),


          Positioned(
            top: 4,
            right: 0,
            bottom: 20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ...<int>[for (int i = 0; i < _letterLs.length; i++) i].map((e) {
                  return InkWell(
                      onTap: () {
                        //print('myVal : ${_letterLs[e]}');
                        Scrollable.ensureVisible(_letterToGlobalKey[_letterLs[e]]!.currentContext!);
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(14, 1, 14, 4),
                        child: Text(
                          _letterLs[e],
                          style: _isLetterBold[e] ?  TextStyle(color: Color(0xff444444) , fontWeight: FontWeight.bold,  )
                                                   : TextStyle(color: Color(0xff999999)),
                        ),
                      ));
                }).toList(),

                // Text('常用', style: Theme.of(context).textTheme.headline1),
              ],
            ),
          ),
        ])),
      ),
    );
  }
}
