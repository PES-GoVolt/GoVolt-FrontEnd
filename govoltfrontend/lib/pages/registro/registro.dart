import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:govoltfrontend/config.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  PhoneNumber? phoneNumber;

  Future<void> register() async {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (emailController.text.isEmpty) {
      showSnackbar("Email requerido.");
      return;
    }

    if (usernameController.text.isEmpty) {
      showSnackbar("Usuario requerido.");
      return;
    }

    if (passwordController.text.isEmpty) {
      showSnackbar("Contraseña requerida.");
      return;
    }

    if (confirmPasswordController.text.isEmpty) {
      showSnackbar("Confirmación de la contraseña requerida.");
      return;
    }

    if (password != confirmPassword) {
      showSnackbar("Las contraseñas no coinciden");
      return;
    }
    
    final url = Uri.http(Config.apiURL, Config.registroAPI);
    final headers = {"Content-Type": "application/json;charset=UTF-8"};

    final userData = {
      "username": usernameController.text,
      "password": passwordController.text,
      "email": emailController.text,
      "phone": phoneController.text,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(userData),
    );

    if (response.statusCode == 201) {
      // Registro exitoso, redirige a la pantalla de inicio de sesión
      Navigator.pushNamed(context, '/login');
    } else {
      print(response);
      // Error en el registro, muestra un mensaje de error
      final data = jsonDecode(response.body);
      print(data);
      final errorMessage = data['message'];
      showSnackbar(errorMessage);
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
                  'assets/images/logo-govolt.png', // Ruta de la imagen en assets
                  height: 50, // Altura deseada
                ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: const Text(
                    'Crear cuenta',
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
                controller: emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
              child: TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nombre de Usuario',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Contraseña',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
              child: TextField(
                obscureText: true,
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Confirmar Contraseña',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  phoneNumber = number;
                },
                selectorConfig: SelectorConfig(
                  selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                ),
                ignoreBlank: false,
                autoValidateMode: AutovalidateMode.disabled,
                inputDecoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Número de Teléfono',
                ),
              ),
            ),
            Container(
                height: 50,
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: ElevatedButton(
                  child: const Text('Registrarse'),
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
                const Text('Ya tienes una cuenta?'),
                TextButton(
                  child: const Text(
                    'Iniciar sesión',
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
                    label: const Text('Registrarse con Facebook'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Iniciar sesión con Google
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50), // Altura de 50
                    ),
                    icon: Image.asset(
                      'assets/images/google_logo_2.png',
                      height: 24,
                    ),
                    label: const Text('Registrarse con Google'),
                  ),
                ],
              ),
            ),
          ],
        )));
  }
}