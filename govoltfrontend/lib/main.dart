import 'dart:convert';
import 'package:govoltfrontend/models/message.dart';
import 'package:govoltfrontend/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:govoltfrontend/menu.dart';
import 'package:govoltfrontend/pages/registro/registro.dart';
import 'package:govoltfrontend/config.dart';
import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart'; // Agrega esta importación
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Cambia la función main para inicializar Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
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
                  MyStatefulWidget(), // El contenido de tu pantalla de inicio de sesión
            ),
      },
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
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  ChatService chatService = ChatService();
  late StreamSubscription<MessageVolt> messageArrivedSubscription;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  //final urllogin = Uri.parse("http://192.168.1.108/api/login/");
  final urllogin = Uri.https(Config.apiURL, Config.loginAPI);

  //final urlobtenertoken = Uri.parse("http://192.168.1.108/api/api-token-auth/");
  final urlobtenertoken = Uri.http(Config.apiURL, Config.obtenertokenAPI);
  final headers = {"Content-Type": "application/json;charset=UTF-8"};

  @override
  void dispose() {
    messageArrivedSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    chatService.setupDatabaseListener();
    // Suscríbete al stream en el método initState
    messageArrivedSubscription =
        chatService.onMessageArrivedChanged.listen((messageArrived) {
      // Maneja los cambios en la variable messageArrived
      exit(0);
    });
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
                    'assets/images/logo-govolt.png', // Ruta de la imagen en assets
                    height: 200, // Altura deseada
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),
                Row(
                  // ignore: sort_child_properties_last
                  children: <Widget>[
                    const Text('Forgot your password?'),
                    TextButton(
                      child: const Text(
                        'Click here',
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
                    child: const Text('Log In'),
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
                  ),
                ),
                Container(
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ElevatedButton(
                    child: const Text('Sign Up'),
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
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(
                            right: 10, top: 10, bottom: 10),
                        height: 1, // Altura de la línea (grosor)
                        color: Colors.grey, // Color de la línea
                      ),
                    ),
                    Text(" Or "),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 10, top: 10, bottom: 10),
                        height: 1, // Altura de la línea (grosor)
                        color: Colors.grey, // Color de la línea
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
                              const Size(double.infinity, 50), // Altura de 50
                        ),
                        icon: Image.asset(
                          'assets/images/facebook_logo.png',
                          height: 24,
                        ),
                        label: const Text('Log in with Facebook'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          signInWithGoogle();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize:
                              const Size(double.infinity, 50), // Altura de 50
                        ),
                        icon: Image.asset(
                          'assets/images/google_logo_2.png',
                          height: 24,
                        ),
                        label: const Text('Log in with Google'),
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
        return null; // El usuario canceló la autenticación
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

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
      showSnackbar("Email required.");
      return;
    }

    if (passwordController.text.isEmpty) {
      showSnackbar("Password required.");
      return;
    }

    final datosdelposibleusuario = {
      "email": emailController.text,
      "password": passwordController.text
    };
    final res = await http.post(urllogin,
        headers: headers, body: jsonEncode(datosdelposibleusuario));
    //final data = Map.from(jsonDecode(res.body));

    final data = json.decode(res.body);
    final message = data['message'];

    if (res.statusCode != 200) {
      // final errorMessage = responseData['error']['message'];
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
