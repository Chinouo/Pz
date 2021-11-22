import 'package:flutter/widgets.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late bool isOnline;

  @override
  void initState() {
    super.initState();
    isOnline = false;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [Text("Hello ! This is SplashPage")],
      ),
    );
  }
}
