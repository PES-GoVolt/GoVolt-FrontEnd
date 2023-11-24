import 'dart:convert';
import 'package:govoltfrontend/models/usuario.dart';
import 'package:http/http.dart' as http;
import 'package:govoltfrontend/config.dart';

class EditUserService {
  EditUserService();

  Future<dynamic> getCurrentUserData() async {
    try{
    final response =
        await http.get(Uri.http(Config.apiURL, Config.seeMyProfileAPI));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final user = Usuario();

      user.email = data['email'];
      user.phoneNumber = data['phone'];
      dynamic firstNameValue = data['first_name'];
      if (firstNameValue != null) {
        user.firstName = firstNameValue;
      }
      dynamic lastNameValue = data['last_name'];
      if (lastNameValue != null) {
        user.lastName = lastNameValue;
      }

      dynamic photoValue = data['photo'];
      if (photoValue != null) {
        user.photo = photoValue;
      }
      return user;
    }
      return null;
    }
    catch(error)
    {
      return null;
    }
    
  }

  saveChanges(String firstName, String lastName, String email,
      String phoneNumber, String photo) async {
    try {
      Map<String, dynamic> requestBody = {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phoneNumber,
        'photo_url': photo
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
      }
    } catch (error) {
      print("Error al realizar la solicitud HTTP: $error");
    }
  }

  Future<bool> logOut() async {
    try{
    final response = await http.post(
      Uri.http(Config.apiURL, Config.logoutAPI),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
  catch(error){
      return true;
  }
  }
}
