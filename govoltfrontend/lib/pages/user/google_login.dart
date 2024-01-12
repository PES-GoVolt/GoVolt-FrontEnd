import 'dart:convert';
import 'package:http/http.dart' as httpsend;
import 'package:flutter/material.dart';
import 'package:govoltfrontend/config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:govoltfrontend/services/token_service.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class GoogleUserScreen extends StatefulWidget {

  final String email;
  final String? username;
  final String ?phone;

  const GoogleUserScreen({ required this.email, this.username, this.phone});

  @override
  _GoogleUserScreenState createState() => _GoogleUserScreenState();
}

class _GoogleUserScreenState extends State<GoogleUserScreen> {
  
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  PhoneNumber? phoneNumber;
  
  get http => null;

  Future<void> register() async {

    if (usernameController.text.isEmpty) {
      showSnackbar(AppLocalizations.of(context)!.usernameReq);
      return;
    }

    if (emailController.text.isEmpty) {
      showSnackbar(AppLocalizations.of(context)!.emailReq);
      return;
    }


    if (phoneNumber?.phoneNumber == null) {
      showSnackbar(AppLocalizations.of(context)!.phoneReq);
      return;
    }


      String token = Token.token;

      final userStored = {
        "email": emailController.text,
        "username": usernameController.text,
        "phone": phoneNumber?.phoneNumber ?? ""
      };

      final urlStoreUser = Uri.https(Config.apiURL, Config.registroAPI);
      final headersStoredUser = {
        'Content-Type': 'application/json',
        "Authorization": token
      };
      final response = await httpsend.post(
        urlStoreUser,
        headers: headersStoredUser,
        body: jsonEncode(userStored),
      );

      if (response.statusCode == 200) {
        await Future.delayed(Duration.zero);
        Navigator.pop(context);
      } else {
        final data = jsonDecode(response.body);
        final errorMessage = data['message'];
        showSnackbar(errorMessage);
        Navigator.pop(context);
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
  void initState() {
    emailController.text = widget.email;
    if (widget.username != null)
    {
      usernameController.text = widget.username!;
    }
    else if (widget.phone != null)
    {
      phoneController.text = widget.username!;
    }
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
                Container(
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ElevatedButton(
                    onPressed: () {
                      Token.token = "";
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color.fromARGB(255, 238, 52, 52)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ))),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            )));
  }
}
