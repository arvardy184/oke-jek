import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/defaults/url.dart';
import 'package:okejek_flutter/models/base_response_model.dart';
import 'package:okejek_flutter/pages/landing_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class UserController extends GetxController {
  Dio dio = Dio();

  var id = 0.obs;
  var isSessionValid = true.obs;
  var name = ''.obs;
  var email = ''.obs;
  var address = ''.obs;
  var imageUrl = ''.obs;
  var contactPhone = ''.obs;
  var activated = false.obs;
  var isValidated = false.obs;
  var contactMobile = ''.obs;
  var cityId = 0.obs;
  var balance = ''.obs;
  var isServiceAvailable = true.obs;

  void onInit() async {
    super.onInit();
    getUser();
    getCurrentLocation();
    await getCurrentAddress();
    convertBalance();
  }

  @override
  void onClose() {
    dio.close();
    super.onClose();
  }

  void delete() {
    super.onDelete();
    dio.interceptors.clear();
  }

  Future<bool> checkingUserSession() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var session = preferences.getString('user_session');

      if (session == null) {
        print("No session found.");
        return false;
      }

      String url = OkejekBaseURL.apiUrl('profile');
      var queryParams = {'api_token': session};

      var response = await dio.get(
        url,
        queryParameters: queryParams,
        options: Options(headers: {'Accepts': 'application/json'}),
      );

      debugPrint("Response in user controller profile: $response");
      var responseBody = response.data;
      return responseBody['success'] ?? false;
    } on DioException catch (e) {
      print("DioException in checkingUserSession: ${e.message}");
      return false;
    } catch (e) {
      print("Unexpected error in checkingUserSession: $e");
      return false;
    }
  }

  void convertBalance() {
    print('convert balance $balance');
    double balanceAmount = double.tryParse(balance.value) ?? 0.0;

    print('convert balance amount $balanceAmount');
    final formattedBalance = NumberFormat.currency
    (locale: 'id',
     symbol: 'Rp', 
     decimalDigits: 0
     ).format(balanceAmount);

    balance.value = formattedBalance;
  }

  Future<void> getUser() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var userJson = preferences.getString('user_data');
      var session = preferences.getString('user_session');

      if (userJson == null) {
        print("No user data found.");
        return;
      }

      var userData = jsonDecode(userJson);
      print("user : $userData");
      print('session : $session');

      if(session == null) {
        isSessionValid.value = false;
        Get.off(() => LandingPage(), transition: Transition.fade);
      }

      // user session checking
      id.value = userData['data']['user']['id'] ?? '';
      name.value = userData['data']['user']['name'] ?? '';
      email.value = userData['data']['user']['email'] ?? '';
      isValidated.value = userData['data']['user']['is_validated'] ?? false;
      contactMobile.value = userData['data']['user']['contact_phone'] ?? '';
      imageUrl.value = userData['data']['user']['image'] ?? '';

      contactPhone.value = userData['data']['user']['contact_phone'] ?? '';
      address.value = userData['data']['user']['address'] ?? '';
      balance.value = userData['data']['user']['balance'] ?? '0.00';

      print("image url : $imageUrl");
    } catch (e) {
      print("Error in get user data : $e");
    }
  }

  void getCurrentLocation() async {
    if (await Permission.location.request().isGranted) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      final queryParams = {
        'latlng': '${position.latitude},${position.longitude}',
      };
      String url = OkejekBaseURL.apiUrl('nearest-city');

      try {
        var response = await dio.get(
          url,
          queryParameters: queryParams,
          options: Options(
            headers: {
              'Accepts': 'application/json',
            },
          ),
        );

        debugPrint("res di user controller nearest city $response");
        var responseBody = response.data;
        String nearestCity = jsonEncode(BaseResponse.fromJson(responseBody));
        SharedPreferences preferences = await SharedPreferences.getInstance();

        if (responseBody['data']['city'] == null) {
          isServiceAvailable.value = false;
        } else {
          showUserDialog(responseBody);
        }

        // storing to shareprefs -> json
        preferences.setString('nearestCity', nearestCity);
      } on DioException catch (e) {
        // showing failure text
        print(e.message);
      }
    } else {
      print('location permission is not granted');
    }
  }

  Future<void> getCurrentAddress() async {
    if (await Permission.location.request().isGranted) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      // String url = OkejekBaseURL.reverseGeocoding(position.latitude, position.longitude);
      String url = OkejekBaseURL.apiUrl('geo/geocode');

      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? session = preferences.getString("user_session");

      try {
        var queryParams = {
          'subject': '${position.latitude}, ${position.longitude}',
          'is_reverse': 1,
          'api_token': session,
        };
        print("query params : $queryParams");
        var response = await dio.get(
          url,
          queryParameters: queryParams,
          options: Options(
            headers: {
              'Accepts': 'application/json',
            },
          ),
        );

        debugPrint("res di user controller geo/geocode $response");

        var responseBody = response.data;
        BaseResponse baseResponse = BaseResponse.fromJson(responseBody);

        String userAddress = baseResponse.data.geocodeResult!.places[0].name;
        double userLocationLat = baseResponse.data.geocodeResult!.places[0].location.lat;
        double userLocationLng = baseResponse.data.geocodeResult!.places[0].location.lng;

        //set shared string to current user location name and coordinate
        preferences.setString('current_geocode_address', userAddress);
        preferences.setDouble('current_geocode_lat', userLocationLat);
        preferences.setDouble('current_geocode_lng', userLocationLng);
      } on DioException catch (e) {
        print(e.message);
      }
    } else {
      print('location permission is not granted');
    }
  }

  void showUserDialog(var responseBody) async {
    String userMsgTitle = responseBody['data']['city']['configs']['user_message_title'];
    String userMsg = responseBody['data']['city']['configs']['user_message'];

    if (userMsg.isNotEmpty && userMsgTitle.isNotEmpty) {
      DateTime currentDateTime = DateTime.now();

      // get user last seen dialog
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? lastRead = preferences.getString('user_msg_last_read');

      // check last seen pref
      if (lastRead == null) {
        preferences.setString('user_msg_last_read', currentDateTime.toString());
        Get.defaultDialog(
          title: userMsgTitle,
          middleText: userMsg,
          backgroundColor: Colors.white,
          titleStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          middleTextStyle: TextStyle(color: Colors.black, fontSize: 12),
        );
      } else {
        var lstRead = DateTime.parse(lastRead);
        var nextRead = lstRead.add(Duration(hours: 2));

        print('last read $lstRead');
        print('next read $nextRead');
        print(currentDateTime.isAfter(nextRead));

        // show dialog on next 2 hours
        if (currentDateTime.isAfter(nextRead)) {
          Get.defaultDialog(
            title: "Message Title",
            middleText: "Message",
            backgroundColor: Colors.white,
            titleStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            middleTextStyle: TextStyle(color: Colors.black, fontSize: 12),
          );

          // set last seen to recent time
          preferences.setString('user_msg_last_read', currentDateTime.toString());
        }
      }
    }
  }
}
