import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:govoltfrontend/usuario.dart';
import 'package:govoltfrontend/menu.dart';
import 'package:govoltfrontend/pages/registro/registro.dart';
import 'package:govoltfrontend/config.dart';

import 'package:firebase_auth/firebase_auth.dart';  // Agrega esta importación
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {  // Cambia la función main para inicializar Firebase
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
            body: MyStatefulWidget(), // El contenido de tu pantalla de inicio de sesión
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

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  //final urllogin = Uri.parse("http://192.168.1.108/api/login/");
  final urllogin = Uri.http(Config.apiURL, Config.loginAPI);

  //final urlobtenertoken = Uri.parse("http://192.168.1.108/api/api-token-auth/");
  final urlobtenertoken = Uri.http(Config.apiURL, Config.obtenertokenAPI);
  final headers = {"Content-Type": "application/json;charset=UTF-8"};

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
                  labelText: 'Contraseña',
                ),
              ),
            ),
            Row(
              // ignore: sort_child_properties_last
              children: <Widget>[
                const Text('Has olvidado tu contraseña?'),
                TextButton(
                  child: const Text(
                    'Click aquí',
                    style: TextStyle(color: Color(0xff4d5e6b), decoration: TextDecoration.underline),
                  ),
                  onPressed: () {
                    //signup screen
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
                  child: const Text('Acceder'),
                  onPressed: () {
                    login();
                  },
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xff4d5e6b)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
                  child: const Text('Registrarse'),
                  onPressed: () {
                    Navigator.pushNamed(context, '/registro');
                  },
                  style: ButtonStyle(
                      foregroundColor: MaterialStateColor.resolveWith(
                          (states) => Color(0xff4d5e6b)),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      side: MaterialStateProperty.all(BorderSide(
                        color: Color(0xff4d5e6b),
                        width: 1.0
                      )),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ))),
                ),
            ),
            
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
                    height: 1, // Altura de la línea (grosor)
                    color: Colors.grey, // Color de la línea
                  ),
                ),
                Text(" Or "),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
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
                      minimumSize: const Size(double.infinity, 50), // Altura de 50
                    ),
                    icon: Image.asset(
                      'assets/images/facebook_logo.png',
                      height: 24,
                    ),
                    label: const Text('Iniciar sesión con Facebook'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      _signInWithGoogle();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50), // Altura de 50
                    ),
                    icon: Image.asset(
                      'assets/images/google_logo_2.png',
                      height: 24,
                    ),
                    label: const Text('Iniciar sesión con Google'),
                  ),
                ],
              ),
            ),
          ],
        )));
  }

  // Función para iniciar sesión con Google
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount == null) {
        return;
      }

      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      await _auth.signInWithCredential(credential);
      
      // Redirige a la pantalla de inicio, o realiza cualquier otra acción necesaria.
      Navigator.pushNamed(
        context,
        '/home',
      );
    } catch (error) {
      print(error);
      showSnackbar("Error al iniciar sesión con Google.");
    }
  }

  void showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2)
      ),
    );
  }

  Future<void> login() async {
    
    if (emailController.text.isEmpty) {
      showSnackbar("Email requerido.");
      return;
    }

    if (passwordController.text.isEmpty) {
      showSnackbar("Contraseña requerida.");
      return;
    }

    final datosdelposibleusuario = {
      "email": emailController.text,
      "password": passwordController.text
    };
    final res = await http.post(
      urllogin,
      headers: headers, 
      body: jsonEncode(datosdelposibleusuario)
    );
    //final data = Map.from(jsonDecode(res.body));

    print(res.body);
    print(res.reasonPhrase);
    print(res.request);
    
    if (res.statusCode != 200) {
      // final errorMessage = responseData['error']['message'];
      showSnackbar("El email y la contraseña no existen.");
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
