// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:govoltfrontend/blocs/application_bloc.dart';
import 'package:govoltfrontend/models/usuario.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


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
  final applicationBloc = AplicationBloc();

  XFile? _imageFile;
  String email = '';
  String phoneNumber = '';
  String firstName = '';
  String lastName = '';
  String photo = '';

  void logout() async {
    bool allOkey = await applicationBloc.logOutUser();
    if (allOkey) {
      Navigator.pushNamed(context, '/login');
    }
  }

  Future<void> _getImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = XFile(pickedFile.path);
      });
    }
  }

  void saveChanges() async {
    firstName = firstNameController.text;
    lastName = lastNameController.text;
    email = emailController.text;
    phoneNumber = phoneNumberController.text;

    applicationBloc.saveUserChanges(
        firstName, lastName, email, phoneNumber, photo);
  }

  Future<void> fetchProfileData() async {
    dynamic response = await applicationBloc.getCurrentUserData();

    if (response != null) {
      final userData = response as Usuario;
      email = userData.email;
      phoneNumber = userData.phoneNumber;
      firstName = userData.firstName;
      lastName = userData.lastName;
      email = userData.email;
      phoneNumber = userData.phoneNumber;
      setState(() {
        if (userData.email != "") emailController.text = userData.email;
        if (userData.phoneNumber != "") {
          phoneNumberController.text = userData.phoneNumber;
        }
        if (userData.firstName != "") {
          firstNameController.text = userData.firstName;
        }
        if (userData.lastName != "") {
          lastNameController.text = userData.lastName;
        }
      });
    } else {
      print("Error al obtener el perfil: ${response.statusCode}");
    }
  }

  @override
  void initState() {
    super.initState();
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
      resizeToAvoidBottomInset: false,
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
                      edit = !edit;

                      if (edit == false) {
                        if (email != "") emailController.text = email;
                        if (phoneNumber != "") {
                          phoneNumberController.text = phoneNumber;
                        }
                        if (firstName != "") {
                          firstNameController.text = firstName;
                        }
                        if (lastName != "") lastNameController.text = lastName;
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: edit
                        ? Colors.red
                        : Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(edit
                      ? 'Cancel'
                      : 'Edit Profile'),
                )
              ],
            ),
            SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.options, //options
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            if (edit) // Mostrar formularios si "edit" es verdadero
              Column(
                children: [
                  buildFormField(AppLocalizations.of(context)!.firstName, 'Change your first name',
                      firstNameController),
                  buildFormField(
                      AppLocalizations.of(context)!.lastName, 'Change your last name', 
                      lastNameController),
                  buildFormField(AppLocalizations.of(context)!.phoneNumber, 'Change your phone number',
                      phoneNumberController,
                      isNumeric: true),
                  ElevatedButton(
                    onPressed: () {
                      saveChanges();
                      setState(() {
                        edit = !edit;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.saveChanges),
                  ),
                ],
              )
            else
              ListView(
                shrinkWrap: true,
                children: [
                  buildOption(AppLocalizations.of(context)!.changePassword, Icons.lock),
                  buildOption(AppLocalizations.of(context)!.achievements, Icons.emoji_events),
                  buildOption('Idioma', Icons.language), //NO HACE FALTA
                  buildOption(AppLocalizations.of(context)!.logOut, Icons.logout, isRed: true),
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
        onTap: () {
          if (isRed) {
            logout();
          }
        });
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
