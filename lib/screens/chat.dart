import 'dart:developer';

import 'package:chatgptt/constants/constants.dart';
import 'package:chatgptt/models/chat_model.dart';
import 'package:chatgptt/services/api_service.dart';
import 'package:chatgptt/services/assets_mangers.dart';
import 'package:chatgptt/widgets/chatwidget.dart';
import 'package:chatgptt/widgets/dropdown.dart';
import 'package:chatgptt/widgets/textWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../providers/models_provider.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  bool isTyping = false;
  late TextEditingController textEditingController;
  late FocusNode focusNode;
  late ScrollController scrollController;
  @override
  void initState() {
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    focusNode.dispose();
    scrollController.dispose();
    super.dispose();
  }

  //List<ChatModel> chatList = [];
  @override
  Widget build(BuildContext context) {
    final modelProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetsManagers.openImages),
        ),
        title: const Text("ChatGPT"),
        actions: [
          IconButton(
              onPressed: (() {
                showModalBottomSheet(
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20))),
                    backgroundColor: scaffoldBackgroundColor,
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Flexible(
                                child: TextWidget(
                              text: "Chosen Model:",
                            )),
                            Flexible(child: ModelDropDownMenu())
                          ],
                        ),
                      );
                    });
              }),
              icon: const Icon(Icons.more_vert_rounded))
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                  controller: scrollController,
                  itemCount: chatProvider.geChatList.length,
                  itemBuilder: (context, index) {
                    return ChatWidget(
                      msg: chatProvider.geChatList[index].msg,
                      chatIndex: chatProvider.geChatList[index].chatIndex,
                    );
                  }),
            ),
            if (isTyping) ...[
              const SpinKitThreeBounce(
                color: Colors.white,
                size: 17,
              )
            ],
            const SizedBox(
              height: 19,
            ),
            Material(
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: focusNode,
                        style: const TextStyle(color: Colors.white),
                        controller: textEditingController,
                        onSubmitted: (value) async {
                          await sendMess(
                              modelProvider: modelProvider,
                              chatProvider: chatProvider);
                        },
                        decoration: const InputDecoration.collapsed(
                          hintText: "How can I help you ?",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await sendMess(
                            modelProvider: modelProvider,
                            chatProvider: chatProvider);
                      },
                      icon: const Icon(Icons.send),
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void scroll_controller() {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2), curve: Curves.easeOut);
  }

  Future<void> sendMess(
      {required ModelsProvider modelProvider,
      required ChatProvider chatProvider}) async {
      if (isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            text: "You cant send multiple messages at a time",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: TextWidget(
          text: "Cannot be empty",
        ),
        backgroundColor: Colors.red,
      ));
      return;
    }
    try {
      String messg = textEditingController.text;
      setState(() {
        isTyping = true;
        //chatList.add(ChatModel(msg: textEditingController.text, chatIndex: 0));
        chatProvider.addUserMess(msg: messg);
        textEditingController.clear();
        focusNode.unfocus();
      });
      // chatList.addAll(await ApiServices.sendMessages(
      //     message: textEditingController.text,
      //     modelId: modelProvider.getCurrModel));
      await chatProvider.addBotMess(
          model: modelProvider.getCurrModel, msg: messg);
      setState(() {});
    } catch (error) {
      log("error $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: TextWidget(
          text: error.toString(),
        ),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        scroll_controller();
        isTyping = false;
      });
    }
  }
}
