import "package:govoltfrontend/api_keys.dart";

class Config {
  static const String appName = "Go Volt";
  static const String apiURL = '10.0.2.2:8000'; // api de cada ordenador
  static const productosAPI = "api/producto";
  static const clientesAPI = "api/cliente";
  static const puntosCargaAPI = "api/puntocarga";
  static const loginAPI = "api/users/login/";
  static const logoutAPI = "api/users/logout/";
  static const obtenertokenAPI = "api/users/api-token-auth/";
  static const registroAPI = "api/users/register/";
  static const allBikeStations = "api/bikestations/all";
  static const allChargers = "api/chargers/all";
  static const chargersNearest = "api/chargers/nearest";
  static const seeMyProfileAPI = "api/users/see-my-profile/";
  static const editMyProfileAPI = "api/users/edit-my-profile/";

  static const allRutas = "api/routes";
  static const myRutas = "api/routes/my_routes";
  static const participantRutas = "api/routes/my_current_routes";

  static const chatAddMessage = "api/messages/";
  static const chats = "api/messages/chats/";
  static const addParticipantToRuta = "/routes/add_participant/";

  static const achievementsAPI = "api/users/achievement/";

  //static const apiKey = "AIzaSyBisV7xClzwO5332af5dzMxo8AvZn7r4g4"; //marc
  //static const apiKey = "AIzaSyBAsdEsXKyQdZOVZYvdYCU4Vf5X6EAwMbA"; //pol
  //static const apiKey = "AIzaSyDQyP4_8RMlTgkOzV9rLIuGNB7sIcI3HLQ"; //esther
  
  static const apiKey = SecretKeys.apiKey;
  static const loginFIREBASE = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey";
  static const singupFIREBASE = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey";

  static const singupGoogleFIREBASE = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithIdp?key=$apiKey";
}
