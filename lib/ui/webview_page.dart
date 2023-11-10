
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key}) : super(key: key);

  @override
  WebViewPageState createState() => WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> {
  final GlobalKey webViewKey = GlobalKey();
  int posX = 325;
  int posY = 300;
  bool topScrollBar = false;
  bool botttomScrollBar = false;
  // InAppWebViewController? webViewController;
  late WebViewController controller;
  // InAppWebViewSettings settings = InAppWebViewSettings(
  //     useShouldOverrideUrlLoading: true,
  //     mediaPlaybackRequiresUserGesture: false,
  //     allowsInlineMediaPlayback: true,
  //     iframeAllow: "camera; microphone",
  //     iframeAllowFullscreen: true
  // );
  @override
  void initState(){
    debugPrint("init state");
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))

      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            CircularProgressIndicator();
            // Update loading bar.
          },
          onPageStarted: (String url) {
            debugPrint("loading url is ${url}");
          },
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          // onNavigationRequest: (NavigationRequest request) {
          //   if (request.url.startsWith('https://www.youtube.com/')) {
          //     return NavigationDecision.prevent;
          //   }
          //   return NavigationDecision.navigate;
          // },
        ),
      )
      ..loadRequest(Uri.parse('https://mhdtvworld.tv/'));

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()=> _exitApp(context),
      child: Scaffold(
        appBar: AppBar(title: Text("Chiku TV")),
        body: Stack(
          children: [
            RawKeyboardListener(
                focusNode: new FocusNode(),
                onKey: (value) => handleKey(value, context),
                child: WebViewWidget(controller: controller,)),
            Visibility(
              visible: topScrollBar,
              child: Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 25,
                  child: Center(
                    child: Icon(Icons.keyboard_arrow_up),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withOpacity(0.5),
                        Colors.white.withOpacity(0.5)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Visibility(
            //   visible: botttomScrollBar,
            //   child: Positioned(
            //     bottom: 0,
            //     left: 0,
            //     right: 0,
            //     child: Container(
            //       height: 25,
            //       child: Center(
            //         child: Icon(Icons.keyboard_arrow_down),
            //       ),
            //       decoration: BoxDecoration(
            //         gradient: LinearGradient(
            //           colors: [
            //             Colors.blue.withOpacity(0.5),
            //             Colors.white.withOpacity(0.5)
            //           ],
            //           begin: Alignment.bottomCenter,
            //           end: Alignment.topCenter,
            //         ),
            //         border: Border(
            //           top: BorderSide(
            //             color: Colors.black.withOpacity(0.5),
            //             width: 1,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            // Positioned(
            //     left: posX.toDouble(),
            //     top: posY.toDouble(),
            //     child: Image.asset("assets/icon/cursor.png",height: 48,width: 48,color: Colors.pinkAccent,))
          ],
        ),
        resizeToAvoidBottomInset: false,
      ),
    );
  }
  handleKey(RawKeyEvent key, BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    if (key.runtimeType.toString() == 'RawKeyDownEvent') {
      RawKeyEventDataAndroid data = key.data as RawKeyEventDataAndroid;
      String _keyCode;
      _keyCode = data.keyCode.toString();

      context.visitChildElements((element) {
        print("-> ${element.widget.key}");
      });
      debugPrint("key press is $_keyCode");
      switch (_keyCode) {
        case '19': //up
          setState(() {
            posY -= 10;
            if (posY < 0) {
              posY = 0;
            }
          });
          break;
        case '22': //right
          setState(() {
            posX += 10;
            if (posX > width) {
              posX = width.toInt();
            }
          });
          break;
        case '20': //down
          setState(() {
            posY += 10;
            if (posY > height) {
              posY = height.toInt();
            }
          });
          break;
        case '21': //left
          setState(() {
            posX -= 10;
            if (posX < 0) {
              posX = 0;
            }
          });
          break;
        case '23': //OK
          controller.runJavaScriptReturningResult( """            
            var cb = document.elementFromPoint($posX,$posY);
            cb.click();
            cb.focus(); 
            """);
          break;
      }
    }
    debugPrint("posY is $posY and height is $height");
    if (posY < 5) {
      setState(() {
        topScrollBar = true;
      });
      controller.scrollBy( 0,  -20);
      debugPrint("controller.scrollBy( 0,  -20);");
    } else if (posY > height - 5) {
      setState(() {
        botttomScrollBar = true;
      });
      controller.scrollBy( 0, 20);
      debugPrint("controller.scrollBy( 0,  20);");
    } else {
      setState(() {
        topScrollBar = false;
        botttomScrollBar = false;
      });
      debugPrint("going in else");
    }
  }
  Future<bool> _exitApp(BuildContext context) async {
    controller.goBack();

    return Future.value(false);
    // if (await controller.canGoBack()) {
    //   print("onwill goback");
    //   controller.goBack();
    //   return Future.value(true);
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("This will exit the app")));
    //   return Future.value(false);
    // }
  }
}
