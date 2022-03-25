// import 'package:all_in_one/api/api_client.dart';
// import 'package:all_in_one/constant/constant.dart';
// import 'package:all_in_one/generated/l10n.dart';
// import 'package:all_in_one/page/home/home_page.dart';
// import 'package:all_in_one/page/login/login_page_real.dart';
// import 'package:all_in_one/provider/illust_rank_provider.dart';
// import 'package:all_in_one/provider/pivision_provider.dart';
// import 'package:all_in_one/provider/recommand_illust_provider.dart';
// import 'package:all_in_one/provider/trend_tag_provider.dart';
// import 'package:all_in_one/screen_fit/media_query_wrap.dart';
// import 'package:all_in_one/widgets/b2t_cupertino_route.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:provider/provider.dart';
// import 'package:provider/single_child_widget.dart';

// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     //透明化状态栏
//     if (Theme.of(context).platform == TargetPlatform.android) {
//       SystemChrome.setSystemUIOverlayStyle(
//           const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
//     }

//     return MultiProvider(
//       providers: _buildProviders(),
//       child: MaterialApp(
//         navigatorKey: Constant.navigatorKey,
//         builder: (context, widget) {
//           return MediaQueryWrapper(
//             builder: (BuildContext context) {
//               return Material(child: widget!);
//             },
//           );
//         },
//         title: 'Localizations Sample App',
//         theme: ThemeData(
//           brightness: Brightness.light,
//         ),
//         localizationsDelegates: const [
//           ...GlobalMaterialLocalizations.delegates,
//           GlobalWidgetsLocalizations.delegate,
//           GlobalCupertinoLocalizations.delegate,
//           S.delegate,
//         ],
//         supportedLocales: S.delegate.supportedLocales,
//         initialRoute: Constant.isLogged ? '/home' : '/login',
//         onGenerateInitialRoutes: (initialRoute) => _handleInitialRoute(initialRoute),
//         onGenerateRoute: (settings) => _handleCustomRoute(settings),
//       ),
//     );
//   }

//   // 自己搞一套路由 ...
//   List<Route<dynamic>> _handleInitialRoute(String initialRoute) {
//     if (initialRoute == '/home') {
//       return [MaterialPageRoute(builder: (context) => const MyHomePage())];
//     }
//     if (initialRoute == '/login') {
//       return [FoundationRoute(builder: (context) => LoginEntry())];
//     }
//     return [
//       PageRouteBuilder(pageBuilder: (_, __, ___) {
//         return Container(
//           color: Colors.white,
//           child: Center(
//             child: Text("Internal Error"),
//           ),
//         );
//       })
//     ];
//   }

//   Route<dynamic>? _handleCustomRoute(RouteSettings settings) {
//     if (settings.name == "/loginEntry") {
//       return FoundationRoute(
//         builder: (context) {
//           return LoginEntry();
//         },
//       );
//     }

//     if (settings.name == '/home') {
//       return MaterialPageRoute(
//         builder: (context) {
//           return const MyHomePage();
//         },
//       );
//     }
//     return null;
//   }

//   List<SingleChildWidget> _buildProviders() {
//     return <SingleChildWidget>[
//       ChangeNotifierProvider<IllustProvider>(create: (_) => IllustProvider()),
//       ChangeNotifierProvider<RecommandProvider>(create: (_) => RecommandProvider()),
//       ChangeNotifierProvider<PixivsionProvider>(create: (_) => PixivsionProvider()),
//       ChangeNotifierProvider<TrendTagProvider>(create: (_) => TrendTagProvider())
//     ];
//   }
// }
