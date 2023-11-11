// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:govoltfrontend/config.dart';

import 'dart:convert';

class VolterScreen extends StatefulWidget {
  @override
  _VolterScreenState createState() => _VolterScreenState();
}

class _VolterScreenState extends State<VolterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  bool edit = false; // Estado para controlar si se está editando

  String email = '';
  String phoneNumber = '';
  String firstName = '';
  String lastName = '';
  String photo='';

  Future<void> fetchProfileData() async {
    final response =
        await http.get(Uri.http(Config.apiURL, Config.seeMyProfileAPI));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      email = data['email'];
      phoneNumber = data['phone'];
      dynamic firstNameValue = data['first_name'];
      if (firstNameValue != null) {
        firstName = firstNameValue;
      }
      dynamic lastNameValue = data['last_name'];
      if (lastNameValue != null) {
        lastName = lastNameValue;
      }

      dynamic photoValue = data['photo'];
      if (photoValue != null) {
        photo = photoValue;
      }

      setState(() {
        if (email != "") emailController.text = email;
        if (phoneNumber != "") phoneNumberController.text = phoneNumber;
        if (firstName != "") firstNameController.text = firstName;
        if (lastName != "") lastNameController.text = lastName;
        // Otros campos del perfil...
      });
    } else {
      // Si la solicitud no fue exitosa, maneja el error
      print("Error al obtener el perfil: ${response.statusCode}");
    }
  }

  @override
  void initState() {
    super.initState();
    // Llama a la función fetchProfileData al iniciar la pantalla
    fetchProfileData();

    emailController.text = email;
    phoneNumberController.text = phoneNumber;
    firstNameController.text = firstName;
    lastNameController.text = lastName;
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  StatefulWidget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Volter'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstName,
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      lastName,
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      phoneNumber,
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      email,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Cambia el estado "edit" al contrario cuando se presione el botón
                      edit = !edit;
                    });
                  },
                  child: Text(edit
                      ? 'Cancel'
                      : 'Edit Profile'), // Etiqueta dependiendo de "edit"
                  style: ElevatedButton.styleFrom(
                    backgroundColor: edit
                        ? Colors.red
                        : Colors.green, // Color dependiendo de "edit"
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Opciones:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            
              ListView(
                shrinkWrap: true,
                children: [
                  buildOption('Cambiar contraseña', Icons.lock),
                  buildOption('Logros', Icons.emoji_events),
                  buildOption('Idioma', Icons.language),
                  buildOption('Cerrar sesión', Icons.logout, isRed: true),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget buildOption(String text, IconData icon, {bool isRed = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isRed ? Colors.red : Colors.grey,
      ),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: isRed ? Colors.red : Colors.grey,
        ),
      ),
    );
  }

  Widget buildFormField(
      String labelText, String hintText, TextEditingController controller,
      {bool isPassword = false, bool isNumeric = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
        ),
        obscureText: isPassword,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      ),
    );
  }
}
