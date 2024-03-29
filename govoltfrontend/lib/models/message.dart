class MessageVolt {
  String userid = "";
  String content = "";
  String timestamp = "";
  String roomName = "";
  String chatId = "";

  MessageVolt({
    required this.userid,
    required this.content,
    required this.timestamp,
    required this.roomName,
    required this.chatId
  });

  void clearData() {
    userid = "";
    content = "";
    timestamp = "";
    roomName = "";
  }

  String getTime() {
    return timestamp;
  }

  factory MessageVolt.fromMap(Map<String, dynamic> map) {
    return MessageVolt(
      userid: map['sender'] ?? "",
      content: map['content'] ?? "",
      timestamp: map['timestamp'].toString(),
      roomName: map['room_name'] ?? "",
      chatId: map['id_chat'] ?? ""
    );
  }
}
