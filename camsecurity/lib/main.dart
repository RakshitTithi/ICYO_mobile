import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'transition_route_observer.dart';



void main() async {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor:
          SystemUiOverlayStyle.dark.systemNavigationBarColor,
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  // Obtain a list of the available cameras on the device.
    // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(MyApp(mycamera: firstCamera,));
}

class MyApp extends StatelessWidget {
  MyApp({Key? key, required this.mycamera}) : super(key: key);

  final CameraDescription mycamera;


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login',
      theme: ThemeData(
        textSelectionTheme:
            const TextSelectionThemeData(cursorColor: Colors.orange),
        // fontFamily: 'SourceSansPro',
        textTheme: TextTheme(
          headline3: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 45.0,
            // fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
          button: const TextStyle(
            // OpenSans is similar to NotoSans but the uppercases look a bit better IMO
            fontFamily: 'OpenSans',
          ),
          caption: TextStyle(
            fontFamily: 'NotoSans',
            fontSize: 12.0,
            fontWeight: FontWeight.normal,
            color: Colors.deepPurple[300],
          ),
          headline1: const TextStyle(fontFamily: 'Quicksand'),
          headline2: const TextStyle(fontFamily: 'Quicksand'),
          headline4: const TextStyle(fontFamily: 'Quicksand'),
          headline5: const TextStyle(fontFamily: 'NotoSans'),
          headline6: const TextStyle(fontFamily: 'NotoSans'),
          subtitle1: const TextStyle(fontFamily: 'NotoSans'),
          bodyText1: const TextStyle(fontFamily: 'NotoSans'),
          bodyText2: const TextStyle(fontFamily: 'NotoSans'),
          subtitle2: const TextStyle(fontFamily: 'NotoSans'),
          overline: const TextStyle(fontFamily: 'NotoSans'),
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple)
            .copyWith(secondary: Colors.orange),
      ),
      navigatorObservers: [TransitionRouteObserver()],
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (context) =>  LoginScreen(thisCamera: mycamera),
        DashboardScreen.routeName: (context) => const DashboardScreen(),
      },
    );
  }
}
