import 'package:chatgptt/providers/models_provider.dart';
import 'package:chatgptt/services/api_service.dart';
import 'package:chatgptt/widgets/textWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';

class ModelDropDownMenu extends StatefulWidget {
  const ModelDropDownMenu({super.key});

  @override
  State<ModelDropDownMenu> createState() => _ModelDropDownMenuState();
}

class _ModelDropDownMenuState extends State<ModelDropDownMenu> {
  // ignore: non_constant_identifier_names
  String? currModel;
  @override
  Widget build(BuildContext context) {
    final modelProvider = Provider.of<ModelsProvider>(context, listen: false);
    currModel = modelProvider.getCurrModel;
    return FutureBuilder(
        future: modelProvider.getAllModels(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: TextWidget(text: snapshot.error.toString()),
            );
          }
          return snapshot.data == null || snapshot.data!.isEmpty
              ? const SizedBox.shrink()
              : FittedBox(
                  child: DropdownButton(
                      dropdownColor: scaffoldBackgroundColor,
                      items: List<DropdownMenuItem<String>>.generate(
                          snapshot.data!.length,
                          (index) => DropdownMenuItem(
                              value: snapshot.data![index].id,
                              child: TextWidget(
                                text: snapshot.data![index].id,
                                fontSize: 15,
                              ))),
                      value: currModel,
                      onChanged: ((value) {
                        setState(() {
                          currModel = value.toString();
                        });
                        modelProvider.setCurrModel(value.toString());
                      })),
                );
        });
  }
}

/*DropdownButton(
      dropdownColor: scaffoldBackgroundColor,
      items: getModelsItem, 
    onChanged: ((value) {
      setState(() {
        CurrModel = value.toString();
      });
    })); */