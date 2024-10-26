import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/api/user_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServicesController extends GetxController {
  Dio dio = Dio();
  UserController userController = Get.put(UserController());

  var availableServices = {}.obs;
  var isServicesAvailable = false.obs;
  var isRideAvailable = false.obs;
  var isCourierAvailable = false.obs;
  var isShoppingAvailable = false.obs;
  var isFoodAvailable = false.obs;
  var isMartAvailable = false.obs;
  var isCarAvailable = false.obs;
  var isTrikeAvailable = false.obs;
  var isTrikeCourierAvailable = false.obs;

  void onInit() {
    super.onInit();
    
    getService();
  }

  void delete() {
    super.onDelete();
    dio.interceptors.clear();
  }

  void getService() async {
    try{
 SharedPreferences preferences = await SharedPreferences.getInstance();
    await userController.getCurrentAddress();
    String? jsonServices = preferences.getString('nearestCity');

    if (jsonServices != null) {
      Map<String,dynamic> serviceData = jsonDecode(jsonServices);
      availableServices.value = serviceData;
      // availableServices = jsonDecode(jsonServices);
      print('nearest city sharedprefs : $availableServices');

      if (availableServices['data']?['city'] != null) {
        isServicesAvailable.value = true;
        setAvailableServices();
      } else {
        SnackBar snackBar = SnackBar(
          content: Text('Services not available'),
          backgroundColor: Colors.red,
        );

        ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
        print('nearest city data : null');
      }
    } else {
      print('nearest city sharedprefs : null');
    } 
    } catch (e) {
      print(
        "Error in get service $e"
      );
    }
   
  }


  void setAvailableServices() {
    try{
      var config = availableServices['data']['city']['original_config'];
      if(config != null) {
        isRideAvailable.value = config['app_feature_ride'];
        isCourierAvailable.value = config['app_feature_courier'];
        isShoppingAvailable.value = config['app_feature_shopping'];
        isFoodAvailable.value = config['app_feature_food'];
        isMartAvailable.value = config['app_feature_market'];
        isCarAvailable.value = config['app_feature_car'];
        isTrikeAvailable.value = config['app_feature_trike'];
      } else {
        print("original config is null ");
      _showErrorSnackBar("Services not available");
      }
    } on DioException catch(e){
      print("Error in get service $e");
      _showErrorSnackBar('Error setting available Services');
    }


  }
}
   void _showErrorSnackBar(String message) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        )
      );
    }
  }