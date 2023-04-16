import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chatgptt/constants/apiConstant.dart';
import 'package:chatgptt/models/chat_model.dart';
import 'package:chatgptt/models/models_model.dart';
import 'package:http/http.dart' as http;

class ApiServices {
  static Future<List<ModelsModel>> getModels() async {
    try {
      var response = await http.get(Uri.parse("$BASEURI/models"),
          headers: {'Authorization': 'Bearer $BASEAPI'});
      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse['error'] != null) {
        throw HttpException(jsonResponse['error']['message']);
      }
      List temp = [];
      for (var i in jsonResponse['data']) {
        temp.add(i);
      }
      return ModelsModel.modelsFromSnapshot(temp);
    } catch (error) {
      print("error $error");
      rethrow;
    }
  }

//send message
  static Future<List<ChatModel>> sendMessages(
      {required String message, required String modelId}) async {
    try {
      var response = await http.post(Uri.parse("$BASEURI/chat/completions"),
          headers: {
            'Authorization': 'Bearer $BASEAPI',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({
            "model": modelId,
            "messages": [
              {"role": "user", "content": message}
            ]
          }));
      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse['error'] != null) {
        throw HttpException(jsonResponse['error']['message']);
      }
      List<ChatModel> chatList = [];
      if (jsonResponse['choices'].length > 0) {
        chatList = List.generate(
            jsonResponse['choices'].length,
            (index) => ChatModel(
                msg: jsonResponse['choices'][index]['message']['content'],
                chatIndex: 1));
      }
      return chatList;
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }
}
