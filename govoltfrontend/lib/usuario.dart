class Usuario {
  String username;
  String password;
  String token;

  Usuario({
    required this.username,
    required this.password,
    required this.token,
  });

  factory Usuario.fromJson(Map json) {
    return Usuario(
      username: json["username"],
      password: json["password"],
      token: json["token"],
    );
  }
}