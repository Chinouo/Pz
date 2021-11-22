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
              onPressed: () async {
                String arg = await Navigator.push(context, routePageBuilder());
                debugPrint("arg:$arg");
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
      body: _buildWebView(),
    );
  }

  Widget _buildWebView() {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse("https://bing.com")),
    );
  }
}
