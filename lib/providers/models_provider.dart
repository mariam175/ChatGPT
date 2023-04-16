import 'package:chatgptt/models/models_model.dart';
import 'package:chatgptt/services/api_service.dart';
import 'package:flutter/cupertino.dart';

class ModelsProvider with ChangeNotifier {
  String currModel = "gpt-3.5-turbo-0301";
  String get getCurrModel {
    return currModel;
  }

  void setCurrModel(String newCurr) {
    currModel = newCurr;
    notifyListeners();
  }

  List<ModelsModel> modelList = [];
  List<ModelsModel> get getModelList {
    return modelList;
  }

  Future<List<ModelsModel>> getAllModels() async {
    modelList = await ApiServices.getModels();
    return modelList;
  }
}
