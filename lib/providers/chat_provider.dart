import 'package:flutter/cupertino.dart';

import '../models/chat_model.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  List<ChatModel> chatList = [];
  List<ChatModel> get geChatList {
    return chatList;
  }

  void addUserMess({required String msg}) {
    chatList.add(ChatModel(msg: msg, chatIndex: 0));
    notifyListeners();
  }

  Future<void> addBotMess({required String msg, required String model}) async {
    chatList
        .addAll(await ApiServices.sendMessages(message: msg, modelId: model));
    notifyListeners();
  }
}
