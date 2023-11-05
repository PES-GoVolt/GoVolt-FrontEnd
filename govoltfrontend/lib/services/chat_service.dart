import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class ChatService {
  bool messageArrived = false;

  final _messageArrivedController = StreamController<bool>.broadcast();
  Stream<bool> get onMessageArrivedChanged => _messageArrivedController.stream;

  void setMessageArrived(bool value) {
    messageArrived = value;
    _messageArrivedController.add(messageArrived);
  }

  void setupDatabaseListener() async {
    DatabaseReference messagesRef =
        FirebaseDatabase.instance.ref().child('qwerty3');

    messagesRef.onChildAdded.listen((event) {
      // Se ejecutará cuando se agregue un nuevo mensaje
      print('Nuevo mensaje: ${event.snapshot.value}');
      messageArrived != messageArrived;
      // Actualiza la interfaz de usuario para mostrar el nuevo mensaje
    });
  }
}
