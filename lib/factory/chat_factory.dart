class ChatData {
  String sender;
  String msg;

  ChatData({
    required this.sender,
    required this.msg
  });

  factory ChatData.fromJson(Map<String, dynamic> json) {
    String sender = json['sender'] ?? 'sender';
    String msg = json['msg'] ?? '';
    return ChatData(sender: sender, msg: msg);
  }


  getSender() => sender;
  setSender(value) => sender = value;

  getMsg() => msg;
  setMsg(value) => msg = value;

  toMap() => {
    'sender': sender,
    'msg': msg
  };
}

class Chat {
  String host1;
  String host2;
  ChatData messages;

  Chat({
    required this.host1,
    required this.host2,
    required this.messages
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    String host1 = json['host1'] ?? 'host1';
    String host2 = json['host2'] ?? 'host2';
    ChatData messages = ChatData.fromJson(json['messages'] ?? {});
    return Chat(
        host1: host1,
        host2: host2,
        messages: messages
    );
  }

  getHosts() => [host1, host2];
  setHosts(host1, host2) { this.host1 =  host1; this.host2 = host2; }
  getChatData() => messages;
  setChatData(ChatData data) => messages = data;
}

class ChatMap {
  final List<ChatMap> chats;
  ChatMap({required this.chats});

  factory ChatMap.fromJson(List<dynamic> json) {
    List<ChatMap> chats = [];
    for(var item in json) {
      chats.add(ChatMap.fromJson(item));
    }
    return ChatMap(chats: chats);
  }

  hasKey(index) => index < chats.length;
  getChat(index) => chats[index];
  remove(index) => chats.removeAt(index);
  length() => chats.length;
  add(ChatMap item) => chats.add(item);

  toMap() {
    Map<String, dynamic> map = {};
    for(int index = 0; index < chats.length; index++) {
      map["$index"] = chats[index].toMap();
    }
    return map;
  }
}