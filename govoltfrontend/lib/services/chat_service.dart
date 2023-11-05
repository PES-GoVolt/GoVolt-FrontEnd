import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class ChatService {
  bool messageArrived = false;
  bool firstLoad = false;
  DateTime now = DateTime.now();
  int i = 0;

  final _messageArrivedController = StreamController<bool>.broadcast();
  Stream<bool> get onMessageArrivedChanged => _messageArrivedController.stream;

  void setMessageArrived(bool value) {
    messageArrived = value;
    _messageArrivedController.add(messageArrived);
  }

  void setupDatabaseListener() async {
    var id = ["qwerty3", "test"];
    for (int i = 0; i < id.length; ++i) {
      DatabaseReference messagesRef =
          FirebaseDatabase.instance.ref().child(id[i]);

      messagesRef.onChildAdded.listen((event) {
        if (event.snapshot.value is String) {
          print('Nuevo mensaje:$i');
        } else {
          print('old mensaje:');
        }
        ++i;
      });
    }
  }
}
