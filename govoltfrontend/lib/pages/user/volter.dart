// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:govoltfrontend/blocs/application_bloc.dart';
import 'package:govoltfrontend/models/usuario.dart';
import 'package:image_picker/image_picker.dart';
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

  String email = '';
  String phoneNumber = '';
  String firstName = '';
  String lastName = '';
  String photo = '';
    static const colors = [
  Color(0xffff6767),
  Color(0xff66e0da),
  Color(0xfff5a2d9),
  Color(0xfff0c722),
  Color(0xff6a85e5),
  Color(0xfffd9a6f),
  Color(0xff92db6e),
  Color(0xff73b8e5),
  Color(0xfffd7590),
  Color(0xffc78ae5),
];

  void logout() {
    Navigator.pop(context);
  }

  Future<void> _getImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
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

  Widget circleColorCustom(String username){
    if (username != "")
    {
    String usernameLastCharacter = username.characters.first;
    final initialsNumber = usernameLastCharacter.codeUnitAt(0) % 10;
    return CircleAvatar(
                  radius: 50,
                  backgroundColor: colors[initialsNumber],
                  child: Text(
                    username.characters.first.toUpperCase(),
                    style:
                        const TextStyle(color: Colors.white, fontSize: 40),
                  ),
                );
    }
    return CircleAvatar(
                  radius: 50,
                  backgroundColor: colors[0],
                  child: Text(
                    "",
                    style:
                        const TextStyle(color: Colors.white, fontSize: 40),
                  ),
                );
  }

  Future<void> fetchProfileData() async {
    dynamic response = await applicationBloc.getCurrentUserData();

    if (response != null) {
      final userData = response as Usuario;
      email = userData.email;
      phoneNumber = userData.username;
      firstName = userData.firstName;
      lastName = userData.lastName;
      email = userData.email;
      setState(() {
        if (userData.email != "") emailController.text = userData.email;
        if (userData.phoneNumber != "") {
          phoneNumberController.text = userData.username;
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
  void initState(){
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
                    circleColorCustom(phoneNumber)
                  ],
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phoneNumber,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,),
                    ),
                    Text(
                      email,
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '$firstName $lastName',
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
                        : Color.fromRGBO(125, 193, 165, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(edit
                      ? AppLocalizations.of(context)!.cancel
                      : AppLocalizations.of(context)!.editProfile, style: TextStyle(color: Colors.white),),
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
                  buildFormField(AppLocalizations.of(context)!.firstName, AppLocalizations.of(context)!.changeFirstName,
                      firstNameController),
                  buildFormField(
                      AppLocalizations.of(context)!.lastName, AppLocalizations.of(context)!.changeLastName, 
                      lastNameController),
                  ElevatedButton(
                    onPressed: () {
                      saveChanges();
                      setState(() {
                        edit = !edit;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(125, 193, 165, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.saveChanges, style: TextStyle(color: Colors.white),),
                  ),
                ],
              )
            else
              ListView(
                shrinkWrap: true,
                children: [
                  buildOption(AppLocalizations.of(context)!.achievements, Icons.emoji_events),
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
