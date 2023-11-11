// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:govoltfrontend/config.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  XFile? _imageFile;
  String email = '';
  String phoneNumber = '';
  String firstName = '';
  String lastName = '';
  String photo = '';


  Future<void> _getImage() async {
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = XFile(pickedFile.path);
      });
    }
  }

 


  void saveChanges() async {
    try {
      firstName = firstNameController.text;
      lastName = lastNameController.text;
      email = emailController.text;
      phoneNumber = phoneNumberController.text;

      Map<String, dynamic> requestBody = {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phoneNumber,
        'photo_url': photo
        // Otros campos...
      };

      final response = await http.post(
        Uri.http(Config.apiURL, Config.editMyProfileAPI),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print("Cambios guardados exitosamente");
      } else {
        print(
            "Error al guardar los cambios. Código de estado: ${response.statusCode}");
        // Puedes manejar el error de acuerdo a tus necesidades
      }
    } catch (error) {
      print("Error al realizar la solicitud HTTP: $error");
      // Puedes manejar el error de acuerdo a tus necesidades
    }
  }

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
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                      child: _imageFile != null
                          ? ClipOval(
                              child: Image.file(
                                File(_imageFile!.path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                    ),
                    if (edit)
                      GestureDetector(
                        onTap: () async {
                          await _getImage();
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$firstName $lastName',
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

                      if (edit == false) {
                        if (email != "") emailController.text = email;
                        if (phoneNumber != "")
                          phoneNumberController.text = phoneNumber;
                        if (firstName != "")
                          firstNameController.text = firstName;
                        if (lastName != "") lastNameController.text = lastName;
                      }
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
            if (edit) // Mostrar formularios si "edit" es verdadero
              Column(
                children: [
                  buildFormField('First Name', 'Change your first name',
                      firstNameController),
                  buildFormField(
                      'Last Name', 'Change your last name', lastNameController),
                  buildFormField('Phone Number', 'Change your phone number',
                      phoneNumberController,
                      isNumeric: true),
                  ElevatedButton(
                    onPressed: () {
                      saveChanges();
                      setState(() {
                        edit = !edit;
                      });
                    },
                    child: Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Color de fondo azul
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ],
              )
            else
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
        onChanged: (value) {
          controller.text = value;
        },
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
