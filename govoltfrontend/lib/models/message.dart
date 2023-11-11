class MessageVolt {
  String userid = "";
  String content = "";
  String timestamp = "";

  void clearData() {
    userid = "";
    content = "";
    timestamp = "";
  }

  String getTime() {
    return timestamp;
  }
}
