import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:govoltfrontend/config.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
      showSnackbar(AppLocalizations.of(context)!.passDontMatch);
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
      final headersStoredUser = {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token"
      };

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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                      border: const OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.username,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
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
                      border: const OutlineInputBorder(),
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
                      border: const OutlineInputBorder(),
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
                    initialValue: PhoneNumber(isoCode: 'ES'),
                    selectorConfig: const SelectorConfig(
                      selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    ),
                    ignoreBlank: false,
                    autoValidateMode: AutovalidateMode.disabled,
                    inputDecoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.phoneNumber,
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ElevatedButton(
                    onPressed: () {
                      register();
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
                      AppLocalizations.of(context)!.signUp,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Row(
                  // ignore: sort_child_properties_last
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context)!.alreadyAccount,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    TextButton(
                      child: Text(
                        AppLocalizations.of(context)!.logIn,
                        style: const TextStyle(
                            color: Color(0xff4d5e6b),
                            decoration: TextDecoration.underline),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
              ],
            )));
  }
}
