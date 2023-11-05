import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class ChatService {
  bool messageArrived = false;
  bool firstLoad = false;
  DateTime now = DateTime.now();

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
      if (event.snapshot.value is String) {
        print('Nuevo mensaje:');
      }
    });
  }
}
