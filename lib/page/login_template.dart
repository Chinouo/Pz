import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class LoginTemplate extends StatefulWidget {
  const LoginTemplate({Key? key}) : super(key: key);

  @override
  _LoginTemplateState createState() => _LoginTemplateState();
}

class _LoginTemplateState extends State<LoginTemplate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Template"),
      ),
      body: Center(
        child: Column(
          children: [
            MaterialButton(
              onPressed: () {
                Navigator.push(context, routePageBuilder());
              },
              child: Text("Go Route"),
            )
          ],
        ),
      ),
    );
  }

  PageRouteBuilder routePageBuilder() {
    return PageRouteBuilder(
        pageBuilder: (_, __, ___) => LoginWebView(),
        transitionsBuilder: (_, animation, __, child) {
          var tween = Tween(begin: Offset(0.0, 1.0), end: Offset.zero);
          var ani =
              tween.chain(CurveTween(curve: Curves.ease)).animate(animation);
          return SlideTransition(
            position: ani,
            child: child,
          );
        });
  }
}

class LoginWebView extends StatelessWidget {
  const LoginWebView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () async {
              Navigator.pop(context, "meg from pop Navigator!");
            },
          ),
          title: Text("Login WebView"),
        ),
        body: InAppWebView(
          initialOptions: InAppWebViewGroupOptions(
              android: AndroidInAppWebViewOptions(useHybridComposition: true)),
          initialUrlRequest: URLRequest(url: Uri.parse("https://bing.com")),
          onLoadStart: (controller, uri) {
            if (uri.toString().contains("baidu")) {
              controller.loadUrl(
                  urlRequest: URLRequest(url: Uri.parse("about:blank")));
              //Navigator.pop(context);
            }
          },
        ));
  }
}
