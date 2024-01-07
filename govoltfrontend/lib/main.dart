import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:govoltfrontend/services/notifications_service.dart';
import 'package:govoltfrontend/blocs/application_bloc.dart';
import 'package:govoltfrontend/models/markers_data.dart';
import 'package:govoltfrontend/services/token_service.dart';
import 'package:http/http.dart' as http;
import 'package:govoltfrontend/menu.dart';
import 'package:govoltfrontend/pages/registro/registro.dart';
import 'package:govoltfrontend/config.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart'; // Agrega esta importación

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  loadData();
  await LocalNotificationService().init();
  runApp(const MyApp());
}

void loadData() async {
  final applicationBloc = AplicationBloc();
  final puntosDeCarga = await applicationBloc.getChargers();
  MarkersData.chargers = puntosDeCarga;
  final bikeStations = await applicationBloc.getBikeStations();
  MarkersData.bikeStation = bikeStations;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = Config.appName;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: _title,
      home: const Scaffold(
        body: MyStatefulWidget(),
      ),
      routes: {
        '/home': (context) => const Menu(),
        '/registro': (context) => RegisterScreen(),
        '/login': (context) => const Scaffold(
              body:
                  MyStatefulWidget(),
            ),
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  //final GoogleSignIn _googleSignIn = GoogleSignIn();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  //final urlobtenertoken = Uri.parse("http://192.168.1.108/api/api-token-auth/");
  final urllogin = Uri.parse(Config.loginFIREBASE);
  final applicationBloc = AplicationBloc();

  final headers = {"Content-Type": "application/json;charset=UTF-8"};

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    // Suscríbete al stream en el método initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Image.asset(
                    'assets/images/logo-govolt.png',
                    height: 200,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.email,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.password,
                    ),
                  ),
                ),
                Row(
                  // ignore: sort_child_properties_last
                  children: <Widget>[
                    Text(AppLocalizations.of(context)!.forgotPassword),
                    TextButton(
                      child: Text(
                        AppLocalizations.of(context)!.clickHere,
                        style: TextStyle(
                            color: Color(0xff4d5e6b),
                            decoration: TextDecoration.underline),
                      ),
                      onPressed: () {
                        //signup screen change later(this is a instalogin)
                        Navigator.pushNamed(
                          context,
                          '/home',
                        );
                      },
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                Container(
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ElevatedButton(
                    onPressed: () {
                      login();
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Color(0xff4d5e6b)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ))),
                    child: Text(AppLocalizations.of(context)!.logIn, style: TextStyle(
                      color: Colors.white,
                      ),),
                  ),
                ),
                Container(
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/registro');
                    },
                    style: ButtonStyle(
                        foregroundColor: MaterialStateColor.resolveWith(
                            (states) => Color(0xff4d5e6b)),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        side: MaterialStateProperty.all(
                            BorderSide(color: Color(0xff4d5e6b), width: 1.0)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ))),
                    child: Text(AppLocalizations.of(context)!.signUp,style: TextStyle(
                      color: Color(0xff4d5e6b),
                      ),),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(
                            right: 10, top: 10, bottom: 10),
                        height: 1,
                        color: Colors.grey,
                      ),
                    ),
                    Text(" Or "),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 10, top: 10, bottom: 10),
                        height: 1,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: <Widget>[
                      ElevatedButton.icon(
                        onPressed: () {
                          // Iniciar sesión con Facebook
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff3b5998),
                          minimumSize:
                              const Size(double.infinity, 50),
                        ),
                        icon: Image.asset(
                          'assets/images/facebook_logo.png',
                          height: 24,
                        ),
                        label: Text(AppLocalizations.of(context)!.logInFacebook),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          signInWithGoogle();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize:
                              const Size(double.infinity, 50),
                        ),
                        icon: Image.asset(
                          'assets/images/google_logo_2.png',
                          height: 24,
                        ),
                        label:  Text(AppLocalizations.of(context)!.logInGoogle),
                      ),
                    ],
                  ),
                ),
              ],
            )));
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      print(googleUser);

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      
      print("Google Sign-In Authentication:");
      print("ID Token: ${googleAuth.idToken}");
      print("Access Token: ${googleAuth.accessToken}");

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken
      );

      print("credenciales");
      print(credential);

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User? user = authResult.user;
      return user;
    } catch (error) {
      return null;
    }
  }

  void showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2)),
    );
  }

  Future<void> login() async {
    if (emailController.text.isEmpty) {
      showSnackbar(AppLocalizations.of(context)!.emailReq);
      return;
    }

    if (passwordController.text.isEmpty) {
      showSnackbar(AppLocalizations.of(context)!.passwordReq);
      return;
    }

    final datosdelposibleusuario = {
      "email": emailController.text,
      "password": passwordController.text,
      "returnSecureToken": true
    };

    print(jsonEncode(datosdelposibleusuario));

    dynamic res = await applicationBloc.login(jsonEncode(datosdelposibleusuario));

    if (res.statusCode != 200) {
      final data = json.decode(res.body);
      final message = data['error']['message'];

      showSnackbar(message);
      return;
    }
    //Navigator.push(context,MaterialPageRoute(builder: (context) => Home()),);
    // ignore: use_build_context_synchronously
    await Future.delayed(Duration.zero);
    Navigator.pushNamed(
      context,
      '/home',
    );
  }
}
