import 'dart:async';

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as pkgPath;

import '../TRemoteSrv.dart';
import '../TGlobal_inc.dart';

import '../TMainWnd.dart';


class TUserPhotoWnd extends StatefulWidget {

  final String photoUrl;

  TUserPhotoWnd(this.photoUrl);

  @override
  _TUserPhotoWndState createState() => _TUserPhotoWndState();
}


class _TUserPhotoWndState extends State<TUserPhotoWnd> {

  CameraController? _camCtlor;

  String _tmpPhotoUri = '';


  Future<bool>   _doUpdateImgWnd = Future.value(true);  // true = Use png photo, false = open camera


 // late final Future<List<CameraDescription>> _cameraLs ; //= await availableCameras();
    late final  List<CameraDescription>  _cameraLs  ; //= await availableCameras();

  bool _isFrontCam = true;

  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {

    super.initState();

    _tmpPhotoUri = widget.photoUrl;

    print('${this.runtimeType.toString()} initState()......................');

    new Future.delayed(Duration(milliseconds: 0)).then((_) {
      fetchCameraLs();
    });



  }

  @override
  void deactivate() {
    print('${this.runtimeType.toString()} deactivate()......................');
  }

  @override
  void dispose() {
    print('${this.runtimeType.toString()} dispose()......................');

    _camCtlor?.dispose();

    super.dispose();
  }

  void fetchCameraLs () async
  {
    _cameraLs = await availableCameras();

  }

  Future<void> _openOneCamera2   () async
  {
    print('open camera....');

    _camCtlor = CameraController(
        _isFrontCam ?  (_cameraLs .length > 1 ? _cameraLs[1] : _cameraLs.first)
            : _cameraLs.first  , ResolutionPreset.medium);


    // _camCtlor!.value.isInitialized;

    // setState(() {
    await _camCtlor?.initialize();
    // });

    if(_camCtlor!.value.isInitialized){
      setState(() {
        _doUpdateImgWnd = Future.value(false);
      });
    }

   // _cameraLs  = await availableCameras();


    // _camCtlor = CameraController(
    //     _isFrontCam ?  (_cameraLs .length > 1 ? _cameraLs[1] : _cameraLs.first)
    //         : _cameraLs.first  , ResolutionPreset.medium);
    //

   // _camCtlor!.value.isInitialized;

    // setState(() {
    //   _camFuture =  _camCtlor?.initialize();
    // });

    // _camCtlor.initialize().then((_) {
    //   if(!mounted)
    //     return;
    //
    //   setState(() {
    //
    //   });
    // }
    // );


  }


  void _showCameraButtons() async {


    final rtn =  await    showDialog(context: context,
        barrierColor: Colors.transparent,
        builder: (BuildContext bctx){


          return Material(
              color: Colors.transparent,
              child: Container(
                  color: Colors.black,
                // margin: Ed,
                  margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3.0 * 2.37),
                  // color: Colors.cyan,
                  //   decoration: ShapeDecoration(
                  //     color: Colors.cyan,
                  //      shape: RoundedRectangleBorder(
                  //        borderRadius: BorderRadius.vertical(top: Radius.circular(40.0))
                  //      )
                  //   ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      Expanded(
                        flex: 10,
                        child: ElevatedButton(
                          onPressed: () async {

                            _camCtlor?.dispose();

                            setState(() {
                              _doUpdateImgWnd = Future.value(true);
                            });

                            Navigator.pop(bctx);
                          },
                          child: Text('取 消', style: TGlobalData().tsListTitleTS1,),
                          // style: ElevatedButton.styleFrom(
                          //     padding: EdgeInsets.all(26.0),
                          //     primary: Colors.white,
                          //     onPrimary: Color(0xff119999),
                          //
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.zero,
                          //     )
                          // ),
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(22.0),
                              primary: Colors.white,
                              onPrimary: Color(0xff119999),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              )
                          ),
                        ),
                      ),

                      Expanded(
                        flex: 16,
                        child: ElevatedButton(
                          onPressed: () async {
                               XFile ? pic;

                                  try{

                                     pic = await   _camCtlor?.takePicture();

                                  }catch (e) {
                                    print(e);
                                  }

                                  if(pic != null){
                                    /*
                                    String docPath = TGlobalData().docDirPath;
                                    final File pf = File(pic.path);

                                   final String fext = pkgPath.extension(pic.path);


                                    String photoName = TGlobalData().phoneNum + fext;
                                    photoName =  photoName.replaceAll('+', 'P');



                                    imageCache!.clear();
                                    imageCache!.clearLiveImages();


                                    final File newImg =     pf .copySync('$docPath/$photoName');

                                    TGlobalData().currUserPhotoUrl = newImg.path;
*/
                                    _tmpPhotoUri = pic.path;
                                    Future.delayed(Duration(milliseconds: 500)).then((_) {
                                      setState(() {
                                        _doUpdateImgWnd = Future.value(true);
                                      });
                                    });

                                  }else{
                                    TGlobalData().showToastInfo('拍照失败 !!');
                                  }


                            Navigator.pop(bctx);
                          },
                          child: Text('确  定', style: TGlobalData().tsListTitleTS1,),
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(22.0),
                              primary: Colors.white,
                              onPrimary: Color(0xff119999),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              )
                          ),
                        ),
                      ),


                      Expanded(
                        flex: 10,
                        child: ElevatedButton(
                          onPressed: () async {

                            _isFrontCam = ! _isFrontCam;

                            _camCtlor?.dispose();

                            Future.delayed(Duration(milliseconds: 100)).then((value) {
                              _openOneCamera2();
                            });

                          },
                          child: Text('切换摄像头', style: TGlobalData().tsListTitleTS1,),
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(22.0),
                              primary: Colors.white,
                              onPrimary: Color(0xff119999),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              )
                          ),
                        ),
                      ),

                    ],
                  ))
          );

        });

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _saveBeforeLeave ,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('个人头像'),

        ),
        body:

        Container(
          color: Colors.black,
         // padding: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Container(
                 // height: 300,
                  child:
              // _isImgOk ?
              // // Expanded(
              // //   flex: 100,
              // //   child:   Image.asset('images/icons/dabai.png'),
              // //   // child: Text('safaffafadf'),
              // // )
              //
              // FutureBuilder<XFile>(
              //   future: _imgXFile,
              //   builder: (context, ss){
              //
              //     if(ss.connectionState == ConnectionState.done){
              //
              //        final rslImg = Image.file(File(ss.data!.path));
              //
              //       _camFuture  = null;
              //       _camCtlor?.dispose();
              //
              //
              //        return rslImg;
              //
              //      // return Image.file(File(ss.data!.path));
              //
              //     }else{
              //       return Center(child: CircularProgressIndicator(),);
              //     }
              //
              //
              //   },
              //
              // )
              // :
              FutureBuilder<bool>(
                  future: _doUpdateImgWnd,
                  builder: (context, ss) {
                    if(ss.connectionState == ConnectionState.done){

                      double h =  MediaQuery.of(context).size.height / 5.0 * 3.5;

                      if(ss.data as bool)
                      {
                      //  print('show.....\n\n');
                      //  print(TGlobalData().currUserPhotoUrl);
                         return Center(child:

                         LayoutBuilder(builder: (BuildContext bctx, BoxConstraints cts){
                           Image tmpImg = Image.file(
                             File(_tmpPhotoUri),key: UniqueKey(), height: h, fit: BoxFit.fitWidth,

                           );
                           // print(' ******************  ss : ${cts.maxHeight}  , wid: ${cts.maxWidth}');
                          // print(' ******************  tmpImg : ${tmpImg.height}  , wid: ${tmpImg.width}');
                         return  tmpImg;
                           }

                         ));
                      }else
                       return Container(
                         height:  h,
                           child: CameraPreview(_camCtlor!));
                    }else{
                      return Center(child:    CircularProgressIndicator(),
                        );
                    }
                  },

              )
              ),


              Padding(
                padding: const EdgeInsets.all(36.0),
                child: ElevatedButton(

                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      onPrimary: Color(0xaaffffff),
                      padding:             EdgeInsets.fromLTRB(50, 10, 50, 10),

                      shape:  RoundedRectangleBorder(
                        side:BorderSide(color: Color(0xaaffffff)),
                        borderRadius: BorderRadius.circular(30),


                      ),

                    ),
                    onPressed: () async {
                     // final dir = await getApplicationDocumentsDirectory();
                      // final String docPath =( await getApplicationDocumentsDirectory()).path;
                    // print(' doc path : $docPath');

                      final rtn =  await    showDialog(context: context,
                          //barrierColor: Colors.transparent,
                          builder: (BuildContext bctx){

                        // Future.delayed(Duration(seconds: 3)).then((value) {
                        //   Navigator.pop(bctx);
                        // });

                       return Material(
                         color: Colors.transparent,
                           child: GestureDetector(
                             behavior: HitTestBehavior.opaque,
                             onTap: (){Navigator.pop(bctx);},
                             child: Container(
                              // color: Colors.purple,
                              // margin: Ed,
                                 margin: EdgeInsets.only(top: MediaQuery.of(context).size.height  * .625),
                               // color: Colors.cyan,
                               //   decoration: ShapeDecoration(
                               //     color: Colors.cyan,
                               //      shape: RoundedRectangleBorder(
                               //        borderRadius: BorderRadius.vertical(top: Radius.circular(40.0))
                               //      )
                               //   ),
                                 child: Column(
                                   mainAxisAlignment: MainAxisAlignment.start,
                                   crossAxisAlignment: CrossAxisAlignment.stretch,
                                   children: [
                                     ClipRRect(
                                       borderRadius: BorderRadius.vertical(top: Radius.circular(40.0)),
                                       child:
                                       ElevatedButton(
                                         onPressed: () async {

                                               //  ImagePicker.platform.pickImage(source: source)
                                                await _pickPhotoFromGallery();

                                                 Navigator.pop(bctx  );

                                         },
                                         child: Text('从相册选择', style: TGlobalData().tsListTitleTS1,),
                                         style: ElevatedButton.styleFrom(
                                             padding: EdgeInsets.all(26.0),
                                             primary: Colors.white,
                                             onPrimary: Color(0xff119999),

                                             shape: RoundedRectangleBorder(
                                               borderRadius: BorderRadius.zero,
                                             )
                                         ),
                                       ),

                                     ),






                                     ElevatedButton(
                                         onPressed: () async {

                                           _camCtlor = CameraController(
                                               _isFrontCam ?  (_cameraLs .length > 1 ? _cameraLs[1] : _cameraLs.first)
                                                   : _cameraLs.first  , ResolutionPreset.medium);


                                           // _camCtlor!.value.isInitialized;

                                           // setState(() {
                                           await _camCtlor?.initialize();
                                           // });

                                           if(_camCtlor!.value.isInitialized){
                                             setState(() {
                                               _doUpdateImgWnd = Future.value(false);
                                             });
                                           }


                                           Future.delayed(Duration(milliseconds: 200)).then((value) {
                                             _showCameraButtons();
                                           });


                                           Navigator.pop(bctx);
                                         },
                                         child: Text('拍  照', style: TGlobalData().tsListTitleTS1,),
                                       style: ElevatedButton.styleFrom(
                                         padding: EdgeInsets.all(22.0),
                                         primary: Colors.white,
                                           onPrimary: Color(0xff119999),

                                         shape: RoundedRectangleBorder(
                                           borderRadius: BorderRadius.zero,
                                         )
                                       ),
                                     ),

                                     // Container(
                                     //   color: Color(0xff999999),
                                     //   height: 8,
                                     // ),

                                    // SizedBox(height: 9,),
                                     Expanded(child:
                                       Container(
                                         color: Color(0xff999999),

                                       ),
                                     ),

                                     ElevatedButton(
                                       onPressed: (){
                                         Navigator.pop(bctx);
                                       },
                                       child: Text('取   消', style: TGlobalData().tsListTitleTS1,),
                                       style: ElevatedButton.styleFrom(
                                           padding: EdgeInsets.all(22.0),
                                           primary: Colors.white,
                                           onPrimary: Color(0xff119999),

                                           shape: RoundedRectangleBorder(
                                             borderRadius: BorderRadius.zero,
                                           )
                                       ),
                                     ),

                                     // Expanded(
                                     //   child: Container(
                                     //     color: Color(0xff999999),
                                     //    // height: 8,
                                     //   ),
                                     // ),

                                   ],
                                 )),
                           )
                       );

                     });

                    },
                    child: Text('修改头像'  , style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),)
                ),
              ),


              //
              //
              // TextButton(
              //     onPressed: () async {
              //
              //       try{
              //         await _camFuture;
              //
              //         setState(() {
              //           _imgXFile =   _camCtlor?.takePicture();
              //           _isImgOk = true;
              //
              //         });
              //
              //
              //       }catch (e) {
              //         print(e);
              //       }
              //
              //       // _camFuture  = null;
              //       // _camCtlor?.dispose();
              //
              //
              //     }, child: Text('拍  照')
              // ),
              //
              // TextButton(
              //     onPressed: (){
              //
              //       new Future.delayed(Duration(milliseconds: 100)).then((_) {
              //         _openOneCamera();
              //       });
              //
              //       setState(() {
              //         _isImgOk = false;
              //       });
              //
              //
              //     }, child: Text('重  拍')
              // ),
              //
              // TextButton(
              //     onPressed: (){
              //
              //       _camFuture  = null;
              //
              //       _camCtlor?.dispose();
              //
              //
              //       setState(() {
              //         _isFrontCam = !_isFrontCam;
              //       });
              //
              //       new Future.delayed(Duration(milliseconds: 100)).then((_) {
              //         _openOneCamera();
              //       });
              //
              //
              //     }, child: Text('切换前后摄像头')
              // ),
              //
              // TextButton(
              //     onPressed: () async {
              //
              //       await _camCtlor?.dispose();
              //       _camCtlor = null;
              //       _camFuture  = null;
              //
              //       final PickedFile? pickedImg = await  ImagePicker().getImage(source: ImageSource.gallery);
              //
              //       if(pickedImg != null){
              //         print('Image picked.....');
              //       }else{
              //         //print('Image pick Failed.....');
              //
              //         new Future.delayed(Duration(milliseconds: 100)).then((_) {
              //           _openOneCamera();
              //         });
              //       }
              //
              //       setState(() {
              //         //_isFrontCam = !_isFrontCam;
              //       });
              //
              //
              //
              //
              //     }, child: Text('相册选取照片')
              // ),


            ],
          ),

        ),



      ),
    );

  }

  Future<bool> _saveBeforeLeave() async {

    if(_tmpPhotoUri == widget.photoUrl ) return true;

    final rtn =  await    showDialog(context: context,
        //barrierColor: Colors.transparent,
        builder: (BuildContext bctx){

          return _TUploadPhotoWnd(_tmpPhotoUri);

        });

    if(rtn != null && rtn as bool){
     // print('upload photo successfull.......');
    }

    return true;
  }

  Future _pickPhotoFromGallery() async {

  //  String rtnPath = '';
    final PickedFile? pickedImg =  null ; // await  ImagePicker().getImage(source: ImageSource.gallery);

    if(pickedImg == null)
       return;


      // print('Image picked.....path: ${pickedImg.path}');
      final String docPath  = TGlobalData().docDirPath;

      final String fext = pkgPath.extension(pickedImg.path);

      // print('fext: $fext');

      //String photoName = TGlobalData().phoneNum + fext;
       String photoName = 'tmpimg'+ fext;

      //photoName =  photoName.replaceAll('+', 'P');



      final File pf = File(pickedImg.path);

      // print('photoName : $photoName');
      //  print('pf path : ${pf.path}');
      //  DateTime dt =await pf.lastModified();
      //  print('pf lastModified : $dt');

      String targetPathname = docPath + '/' + photoName;
      //   print('targetPathname : $targetPathname');

      // final File checkFile = File(targetPathname);
      // if(checkFile.existsSync())
      //   checkFile.deleteSync();

      // PaintingBinding.instance!.imageCache!.clear();


      // late final File newImg;
      // try{
      //   newImg =     pf .copySync(targetPathname);
      // }catch(e){
      //   print('Thor Copy user photo Error......');
      //   return;
      // }

      imageCache!.clear();
      imageCache!.clearLiveImages();



    //  TGlobalData().currUserPhotoUrl =     newImg.path;
     // print(TGlobalData().currUserPhotoUrl);
      //  print('newImg Path: ${newImg.path}');

    _tmpPhotoUri = pickedImg.path;// newImg.path;

   // print(_tmpPhotoUri);

      // XFile xf = XFile(newImg.path);
      // print('xf path: ${xf.path}');

      setState(() {
        _doUpdateImgWnd = Future.value(true);
      });


  }

}







class _TUploadPhotoWnd extends StatefulWidget {

  final String photoUrl;

  _TUploadPhotoWnd(this.photoUrl);

  @override
  _TUploadPhotoWndState createState() => _TUploadPhotoWndState();
}


class _TUploadPhotoWndState extends State<_TUploadPhotoWnd> {


  double _currPorgressVal = 0.1;


  @override
  void reassemble() {
    print('${this.runtimeType.toString()} reassemble().... .......');
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 100)).then((_) {

     // Navigator.pop(context);
      _doUploadPhoto(widget.photoUrl);

    });

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
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            value: _currPorgressVal,strokeWidth: 6.0,
            backgroundColor: Colors.white,
            color: TGlobalData().crMainThemeColor,),

          SizedBox(height: 20,),

          Text('正在上传图片....', style: TGlobalData().tsTxtFn20GreyCC,),
        ],
      ),
    );

  }

  void onSendProgressFunc(int val, int total){

    setState(() {
      _currPorgressVal = val / total;
    });
  }

  Future _doUploadPhoto(String fn) async {

    bool rsl = false;

    File imgF = File(fn);
    if(!imgF.existsSync())
      return;

   final rtnObj = await TRemoteSrv().uploadFileByDio(imgF , onSendProgressFunc);

  // print(rtnObj.toString());

   int code = rtnObj['code'];
    String url = rtnObj['data']['url'];


   if(code == 0){
    // print('url = $url');
     String targetFn = TGlobalData().docDirPath + '/' +  Uri.parse(url).pathSegments.last ;

    // print(targetFn);


     final rtnObj2 =  await TRemoteSrv().updateUsernamePhoto( null ,  rtnObj['data']['filename']);


     if(rtnObj2['code'] == 0){

       late final File newImg;
       try{
         newImg =    imgF .copySync(targetFn);
         rsl = true;
       }catch(e){
         TGlobalData().showToastInfo('Thor Copy user photo Error......');
         rsl = false;
       }


     }


   }

   if(rsl){
     List<String> tmpLs = TGlobalData().fetchCommonLoginData();
     File f = File(TGlobalData().photoUrlToDocPathname(tmpLs[4]) );
     if(f.existsSync()) {
       f.deleteSync();
      // print('delete ori img file....................');
     }
     tmpLs[4] = url; // update user's  new photo url
     TGlobalData().keepCommonLoginData(tmpLs);
   }


    Navigator.pop(context , rsl);

  }



}


















