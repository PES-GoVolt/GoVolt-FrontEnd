import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:govoltfrontend/pages/user/google_login.dart';
import 'package:govoltfrontend/services/notification.dart';
import 'package:govoltfrontend/services/notifications_service.dart';
import 'package:govoltfrontend/blocs/application_bloc.dart';
import 'package:govoltfrontend/models/markers_data.dart';
import 'package:govoltfrontend/menu.dart';
import 'package:govoltfrontend/pages/registro/registro.dart';
import 'package:govoltfrontend/config.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:govoltfrontend/services/token_service.dart';
import 'package:govoltfrontend/services/user_service.dart';
import 'firebase_options.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];
String email = "";
String username = "";
String phone = "";
EditUserService editUserService = EditUserService();
GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: scopes,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //loadData();
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
        '/registroGoogle': (context) => GoogleUserScreen(email: email),
        '/login': (context) => const Scaffold(
              body: MyStatefulWidget(),
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
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //final urlobtenertoken = Uri.parse("http://192.168.1.108/api/api-token-auth/");
  final urllogin = Uri.parse(Config.loginFIREBASE);
  final applicationBloc = AplicationBloc();
  EditUserService editUserService = EditUserService();
  NotificationService notificationService = NotificationService();
  final headers = {"Content-Type": "application/json;charset=UTF-8"};

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      setState(() {});
    });
  }

  Future<void> _handleSignIn() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken
      );
      await _auth.signInWithCredential(credential);
      User? mUser = _auth.currentUser;
      String? token = await mUser?.getIdToken();
      Token.token = 'Bearer $token';
        email = googleUser.email;
        username = googleUser.displayName!;
        dynamic user = await editUserService.getCurrentUserData();
        if (user == null){
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(
          context,
          '/registroGoogle',
        ).then((value) => {
            if (Token.token != "")
            {
              Navigator.pushNamed(
                context,
                '/home',
              )
            }
        } )
        ;}
        else{
          Navigator.pushNamed(
                context,
                '/home',
              );
        }

    } catch (error) {}
    setState(() {});
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

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
                      border: const OutlineInputBorder(),
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
                      border: const OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.password,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
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
                  ],
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
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xff4d5e6b)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ))),
                    child: Text(
                      AppLocalizations.of(context)!.logIn,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
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
                        side: MaterialStateProperty.all(const BorderSide(
                            color: Color(0xff4d5e6b), width: 1.0)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ))),
                    child: Text(
                      AppLocalizations.of(context)!.signUp,
                      style: const TextStyle(
                        color: Color(0xff4d5e6b),
                      ),
                    ),
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
                    Text(AppLocalizations.of(context)!.or),
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
                          _handleSignIn();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        icon: Image.asset(
                          'assets/images/google_logo_2.png',
                          height: 24,
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.logInGoogle,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )));
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

    dynamic res =
        await applicationBloc.login(jsonEncode(datosdelposibleusuario));

    if (res.statusCode != 200) {
      final data = json.decode(res.body);
      final message = data['error']['message'];

      showSnackbar(message);
      return;
    }

    dynamic id = await editUserService.getCurrentUserID();
    notificationService.setupDatabaseSngleListener(id);
    //Navigator.push(context,MaterialPageRoute(builder: (context) => Home()),);
    // ignore: use_build_context_synchronously
    await Future.delayed(Duration.zero);
    Navigator.pushNamed(
      context,
      '/home',
    ).then((result) {
      Token.token = "";
    }).then((value) => passwordController.clear());
  }
}
