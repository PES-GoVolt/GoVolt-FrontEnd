import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:govoltfrontend/config.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:govoltfrontend/services/token_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


final GoogleSignIn googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  PhoneNumber? phoneNumber;

  Future<void> register() async {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (usernameController.text.isEmpty) {
      showSnackbar(AppLocalizations.of(context)!.usernameReq);
      return;
    }

    if (emailController.text.isEmpty) {
      showSnackbar(AppLocalizations.of(context)!.emailReq);
      return;
    }

    if (passwordController.text.isEmpty) {
      showSnackbar(AppLocalizations.of(context)!.passwordReq);
      return;
    }

    if (confirmPasswordController.text.isEmpty) {
      showSnackbar(AppLocalizations.of(context)!.confirmPassReq);
      return;
    }

    if (phoneNumber?.phoneNumber == null) {
      showSnackbar(AppLocalizations.of(context)!.phoneReq);
      return;
    }

    if (password != confirmPassword) {
      showSnackbar(AppLocalizations.of(context)!.passDontMatch); //FALTA ESTE
      return;
    }
      
    final url = Uri.parse(Config.singupFIREBASE);
    final headers = {"Content-Type": "application/json;charset=UTF-8"};

    final userData = {
      "password": passwordController.text,
      "email": emailController.text,
      "username": usernameController.text,
      "phone": phoneNumber?.phoneNumber ?? "",
      "returnSecureToken": true
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(userData),
    );

    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      final message = data['error']['message'];
      showSnackbar(message);
      return;
    } else {
      
      String token = json.decode(response.body)["idToken"];

      final userStored = {
        "email": emailController.text,
        "username": usernameController.text,
        "phone": phoneNumber?.phoneNumber ?? ""
      };

      final urlStoreUser = Uri.http(Config.apiURL, Config.registroAPI);
      final headersStoredUser = { 'Content-Type': 'application/json',"Authorization": "Bearer $token"};

      final responseStoreUser = await http.post(
        urlStoreUser,
        headers: headersStoredUser,
        body: jsonEncode(userStored),
      );

      if (responseStoreUser.statusCode == 200) {
        await Future.delayed(Duration.zero);
        Navigator.pushNamed(context, '/login');
      } else {
        final data = jsonDecode(response.body);
        final errorMessage = data['message'];
        showSnackbar(errorMessage);
      }

      
    }
  }

  Future<void> signUpWithGoogle() async {
    try {
      // Obtener credenciales de Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        return null;
      }

      print("SIGN IN ACCOUNT: ");
      print(googleUser);

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      String? idToken = googleAuth.accessToken;
      // Registro con Google en Firebase
      await signUpWithGoogleFirebase(idToken!);

    } catch (error) {
      print("Error en el signup con Google: $error");
    }
  }

  Future<void> signUpWithGoogleFirebase(String idToken) async {
    try {
      final url = Uri.parse(Config.singupGoogleFIREBASE);
      final headers = {'Content-Type': 'application/json'};
      
      print(idToken);

      final requestData = {
        "id_token": idToken,
        "providerId": "google.com",
        "requestUri": "http://localhost",
        "returnIdpCredential": true,
        "returnSecureToken": true,
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestData),
      );

      final data = json.decode(response.body);
      print("Respuesta de signup con Google en Firebase:");
      print(data);

      // Aquí puedes manejar la respuesta y extraer el token de autenticación si el signup fue exitoso.
    } catch (error) {
      print("Error en el signup con Google en Firebase: $error");
    }
  }

  void showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
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
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                child: Image.asset(
                  'assets/images/logo-govolt.png',
                  height: 50,
                ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    AppLocalizations.of(context)!.signUp,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
              child: TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.username,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
              child: TextField(
                controller: emailController,
                decoration:  InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.email,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.password,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: TextField(
                obscureText: true,
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.confirmPassword,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 5, 10, 0),
              child: InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  phoneNumber = number;
                },
                selectorConfig: const SelectorConfig(
                  selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                ),
                ignoreBlank: false,
                autoValidateMode: AutovalidateMode.disabled,
                inputDecoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.phoneNumber,
                ),
              ),
            ),
            Container(
                height: 50,
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: ElevatedButton(
                  child: Text(AppLocalizations.of(context)!.signUp),
                  onPressed: () {
                    register();
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
            Row(
              // ignore: sort_child_properties_last
              children: <Widget>[
                 Text(AppLocalizations.of(context)!.alreadyAccount, style: TextStyle(
                      color: Colors.black,
                      ),),
                TextButton(
                  child: Text(
                    AppLocalizations.of(context)!.logIn,
                    style: TextStyle(color: Color(0xff4d5e6b), decoration: TextDecoration.underline),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                )
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
                    height: 1,
                    color: Colors.grey,
                  ),
                ),
                Text(AppLocalizations.of(context)!.or,
                  style: TextStyle(
                  color: Colors.black,
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
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
                      minimumSize: const Size(double.infinity, 50),
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
                      // Iniciar sesión con Google
                      signUpWithGoogle();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    icon: Image.asset(
                      'assets/images/google_logo_2.png',
                      height: 24,
                    ),
                    label: Text(AppLocalizations.of(context)!.logInGoogle,
                      style: TextStyle(
                      color: Colors.white,
                      ),
                    )
                  ),
                ],
              ),
            ),
          ],
        )));
  }
}