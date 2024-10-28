import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/defaults/url.dart';
import 'package:okejek_flutter/models/auth/city_model.dart';
import 'package:okejek_flutter/models/auth/okeride/auto_complete_model.dart';
import 'package:okejek_flutter/models/auth/order_model.dart';
import 'package:okejek_flutter/models/base_response_model.dart';
import 'package:okejek_flutter/pages/auth/order/order_detail_page.dart';
import 'package:okejek_flutter/widgets/dialog2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';


class OkeCourierController extends GetxController {
  Dio dio = Dio();
  final note = RxString('');
  var originLat = 0.0.obs;
  var originLng = 0.0.obs;
  var originLocation = ''.obs;
  var originDetailLocation = ''.obs;
  var destinationLat = 0.0.obs;
  var destinationLng = 0.0.obs;
  var destinationLocation = ''.obs;
  var destinationDetailLocation = ''.obs;
  var isOriginSection = true.obs;
  var isLoading = false.obs;
  var isOriginPickingFromMap = false.obs;
  var isDestionationPickingFromMap = false.obs;
  var isSubmitOrigin = false.obs;
  var isSubmitDestination = false.obs;
  var willPopPage = false.obs;
  var searchOriginPlace = ''.obs;
  var searchDestinationPlace = ''.obs;
  var showSummary = false.obs;
  var preload = true.obs;
  var ongkir = 0.obs;
  var isSubmitPromo = false.obs;
  var promoCode = 'Masukkan Promo'.obs;
  var weight = 0.0.obs;
  var itemAmount = 0.0.obs;
  var cityId = 0.obs;
  var couponCode = 'Masukkan Kode Promo'.obs;
  var dropDownValue = 'Cash'.obs;
  var dropDownValueList = ['Cash', 'OkePoint'];
  final RxBool isFetchingData = false.obs;
  var errorMessage = 'Error Message'.obs;
  var couponId = 0.obs;

  void addNote(String newNote) {
    note.value = newNote;
    print(note.value);
  }

  void setPromoCode(String value) {
    promoCode.value = value;
  }

  @override
  void onInit() {
    super.onInit();
    getCurrentUserAddress();

    // Tambahkan listener untuk perubahan lokasi
    ever(originLat, (_) => _triggerPriceCheck());
    ever(originLng, (_) => _triggerPriceCheck());
    ever(destinationLat, (_) => _triggerPriceCheck());
    ever(destinationLng, (_) => _triggerPriceCheck());
  }

  void _triggerPriceCheck() {
    if (canCalculatePrice()) {
      fetchDataPayment();
    }
  }

  void delete() {
    super.onDelete();
  }

  void changeSubmitPromo(bool value) {
    isSubmitPromo.value = value;
    print('changed submit promo to ' + isSubmitPromo.value.toString());
  }


  void cancelPromo() {
    promoCode.value = '';
    update();
  }

  void resetController() {
    getCurrentUserAddress();
    preload.value = true;
    isSubmitDestination.value = false;
    showSummary.value = false;
    willPopPage.value = false;
    isOriginSection.value = true;
    originLocation.value = '';
    originDetailLocation.value = '';
    destinationLat.value = 0.0;
    destinationLng.value = 0.0;
    searchDestinationPlace.value = '';
    destinationLocation.value = '';
    destinationDetailLocation.value = '';
    isLoading.value = false;
    isOriginPickingFromMap.value = false;
    isDestionationPickingFromMap.value = false;
    ongkir.value = 0;
  }

  Future<void> checkPrice() async {
    try {
      isLoading.value = true;

      // Validasi koordinat
      if (originLat.value == 0 || originLng.value == 0 || destinationLat.value == 0 || destinationLng.value == 0) {
        throw Exception('Koordinat tidak valid');
      }

      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? session = preferences.getString("user_session");

      if (session == null) {
        throw Exception('Session tidak ditemukan');
      }

      String url = OkejekBaseURL.apiUrl('order/calculate');

      final response = await dio.post(
        url,
        queryParameters: {
          'origin': '${originLat.value}, ${originLng.value}',
          'destination': '${destinationLat.value}, ${destinationLng.value}',
          'type': 1,
          'api_token': session,
        },
        options: Options(
          headers: {'Accepts': 'application/json'},
        ),
      );

      debugPrint("Response calculate: ${response.data}");

      if (response.data['success'] == true) {
        ongkir.value = response.data['data']['calculated_request']['fee'];
        debugPrint("Ongkir updated: ${ongkir.value}");
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mendapatkan ongkir');
      }
    } catch (e) {
      debugPrint('Error calculating price: $e');
      throw e; // Re-throw
    } finally {
      isLoading.value = false;
    }
  }

  bool canCalculatePrice() {
    return originLat.value != 0 && originLng.value != 0 && destinationLat.value != 0 && destinationLng.value != 0;
  }

  void getCurrentUserAddress() async {
    isLoading.value = true;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    double? currentLat = preferences.getDouble('current_geocode_lat');
    double? currentLng = preferences.getDouble('current_geocode_lng');
    // set location if not null
    if (currentLat != null && currentLng != null) {
      originLat.value = currentLat;
      originLng.value = currentLng;
    }

    print('current lat lng (courier): ${originLat.value},${originLng.value}');
    isLoading.value = false;
  }

  Future<List<AutoCompletePlace>>? getCoordinatesfromPlace(String place) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    double? currentLat = preferences.getDouble('current_geocode_lat');
    double? currentLng = preferences.getDouble('current_geocode_lng');

    // String url = OkejekBaseURL.autoComplete(currentLat!, currentLng!, place);
    String url = OkejekBaseURL.apiUrl('geo/autocomplete');
    String? session = preferences.getString("user_session");
    try {
      var queryParams = {
        'lat': '$currentLat',
        'lng': '$currentLng!',
        'q': '$place',
        'api_token': session,
      };

      var response = await dio.get(
        url,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Accepts': 'application/json',
          },
        ),
      );

      debugPrint("res di okeride controller geo/autocomplete $response");

      var responseBody = response.data;
      BaseResponse baseResponse = BaseResponse.fromJson(responseBody);
      List<AutoCompletePlace> resultPlace = baseResponse.data.autoComplete!.places;

      isLoading.value = false;
      return resultPlace;
    } on DioException catch (e) {
      print(e.message);
      return [];
    }
  }

  Future<Map<String, dynamic>> createOrder({
    required String senderName,
    required String senderPhone,
    required String recipientName,
    required String recipientPhone,
    required String itemDetail,
    required double weight,
    required String itemAmount,
  }) async {
    isLoading.value = true;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appVersion = packageInfo.buildNumber;
    print("app version $appVersion");

    String url = OkejekBaseURL.apiUrl('orders/new');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? session = preferences.getString("user_session");

    print("di create order berapa $weight $itemAmount");

    String paymentProvider = dropDownValue.value == 'Cash'
        ? 'cash'
        : dropDownValue.value == 'OkePoint'
            ? 'okepoint'
            : dropDownValue.value == 'Link Aja'
                ? 'linkaja'
                : dropDownValue.value == 'Shopee Pay'
                    ? 'airpay'
                    : 'cash';

    try {
      var data = {
        'payment_provider': paymentProvider,
        'creation_code': '',
        'origin_latlng': '${originLat.value},${originLng.value}',
        'destination_latlng': '${destinationLat.value},${destinationLng.value}',
        'type': 1, //  1 is for courier service
        'origin_address': originLocation.value,
        'origin_address_detail': originDetailLocation.value,
        'destination_address': destinationLocation.value,
        'destination_address_detail': destinationDetailLocation.value,
        'food_vendor_id': 0,
        'info': note.value,
        'coupon_id': couponId.value,
        'shopping_items': "",
        'app_platform': 'android',
        'app_version': appVersion,
        'item_detail': itemDetail,
        'sender_name': senderName,
        'sender_phone': senderPhone,
        'recipient_name': recipientName,
        'recipient_phone': recipientPhone,
        'weight': weight,
        'item_amount': itemAmount,
        'package_pricing_id': 0,
      };

      print("data di create order courier $data");
      var response = await dio.post(
        url,
        data: data,
        queryParameters: {'api_token': session},
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
          sendTimeout: Duration(seconds: 30),
          receiveTimeout: Duration(seconds: 30),
        ),
      );

      print("berapa $url ");
      debugPrint("Response dari orders/new: $response");

      var responseBody = response.data;
      if (responseBody['success'] == true) {
        var orderData = responseBody['data']['order'];
        print('Order data courier $orderData');
        Order order = Order.fromJson(orderData);

        showOkejekDialog(
            title: 'Pesanan Berhasil',
            message: 'Pesanan anda berhasil dibuat',
            icon: Icons.check_circle,
            iconColor: Colors.green,
            actions: [
              TextButton(
                  onPressed: () {
                    Get.back();
                    Get.to(() =>
                        OrderDetailPage(order: order, driverData: order.driver != null ? order.driver!.toJson() : {}));
                  },
                  child: Text('Lihat Detail'))
            ]);

        print(
          "Response dari orders/new: $responseBody",
        );
        // Order berhasil dibuat
        isLoading.value = false;
        return {
          'success': true,
          'message': 'Order berhasil dibuat',
          'data': responseBody['data'],
        };
      } else {
        isLoading.value = false;

        // showOkejekDialog(title: "Gagal membuat Pesanan", message: responseBody['message'], icon: Icons.error, iconColor: Colors.red);
        print("Ada kesalahan dalam pembuatan order: $responseBody");
        // Ada kesalahan dalam pembuatan order

        return {
          'success': false,
          'message': responseBody['message'] ?? 'Gagal membuat order',
          'errors': responseBody['errors'],
        };
      }
    } on DioException catch (e) {
      isLoading.value = false;
      showOkejekDialog(
        title: 'Error',
        message: 'Terjadi kesalahan: ${e.message}',
        icon: Icons.error,
        iconColor: Colors.red,
      );
      print('Error ${e.response}');
      print('Error saat membuat order: ${e.message}');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.message}',
      };
    }
  }

  void handleError(String message) {
    showOkejekDialog(
      title: 'Error',
      message: message,
      icon: Icons.error,
      iconColor: Colors.red,
    );
    errorMessage.value = message;
  }

  Future<bool> fetchDataPayment() async {
    try {
      isFetchingData.value = true;
      await checkPrice(); // Pastikan ini dijalankan
      return true;
    } catch (e) {
      debugPrint('Error fetching payment data: $e');
      return false;
    } finally {
      isFetchingData.value = false;
    }
  }

  Future<void> getCityId() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? cityJson = preferences.getString('nearestCity');

      if (cityJson == null) {
        print('No City data found ');
        return;
      }

      var data = jsonDecode(cityJson);

      if (data['success'] != true) {
        print('Data indicates unsuccessfull response');
        return;
      }

      var cityData = data['data']['city'];

      if (cityData == null) {
        print('No City data found ');
        return;
      }

      City city = City.fromJson(data['data']['city']);

      cityId.value = city.id;
    } on DioException catch (e) {
      print("Error parsing city data $e");
    }
  }

  void getCouponCode(String couponCode) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? session = preferences.getString("user_session");

    try {
      getCityId();

      // String url = OkejekBaseURL.getPromoCoupon(couponCode, 0, cityId.value);
      String url = OkejekBaseURL.apiUrl('coupon/search');

      var queryParams = {
        'code': '$couponCode',
        'service': 1,
        'city_id': '${cityId.value}',
        'api_token': session,
      };

      var response = await dio.get(
        url,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Accepts': 'application/json',
          },
        ),
      );

      debugPrint("res di Okecar controller coupon/search $response");

      var responseBody = response.data;

      BaseResponse baseResponse = BaseResponse.fromJson(responseBody);
      if (baseResponse.data.coupon!.id == 0) {
        Fluttertoast.showToast(msg: 'Kode tidak ditemukan', fontSize: 12);
        setPromoCode('');
        ongkir.value = 0;
      } else {
        setPromoCode(couponCode);
        ongkir.value -= baseResponse.data.coupon!.discountFee! < 0 ? 0 : ongkir.value;
         couponId.value = baseResponse.data.coupon!.id!;
        // print("price: ${price.value} ${originPrice.value} ${baseResponse.data.coupon!.discountFee} ${totalPembayaran.value} ");
        Fluttertoast.showToast(msg: 'Kode berhasil dipakai', fontSize: 12);
      }
    } on DioException catch (e) {
      print(e.message);
    }
  }

  void getOriginPlacefromCoordinates(double latitude, double longitude) async {
    print('set pickup coordinates map');
    isLoading.value = true;
    originLat.value = latitude;
    originLng.value = longitude;

    // String url = OkejekBaseURL.reverseGeocoding(originLat.value, originLng.value);
    String url = OkejekBaseURL.apiUrl('geo/geocode');

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? session = preferences.getString("user_session");

    try {
      var queryParams = {
        'subject': '${originLat.value}, ${originLng.value}',
        'is_reverse': 1,
        'api_token': session,
      };

      var response = await dio.get(
        url,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Accepts': 'application/json',
          },
        ),
      );

      debugPrint("res di okecourier controller geo/geocode $response");

      var responseBody = response.data;
      BaseResponse baseResponse = BaseResponse.fromJson(responseBody);
      if (baseResponse.data.geocodeResult!.places.length != 0) {
        String place = baseResponse.data.geocodeResult!.places[0].name;
        originLocation.value = place;
        originDetailLocation.value = '';
      } else {
        print('result not found');
      }
      isLoading.value = false;
    } on DioException catch (e) {
      print(e.message);
    }
  }

  void getDestinationPlacefromCoordinates(double latitude, double longitude) async {
    print('set pickup coordinates map');
    isLoading.value = true;
    destinationLat.value = latitude;
    destinationLng.value = longitude;

    // String url = OkejekBaseURL.reverseGeocoding(originLat.value, originLng.value);
    String url = OkejekBaseURL.apiUrl('geo/geocode');

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? session = preferences.getString("user_session");

    try {
      var queryParams = {
        'subject': '${destinationLat.value}, ${destinationLng.value}',
        'is_reverse': 1,
        'api_token': session,
      };

      var response = await dio.get(
        url,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Accepts': 'application/json',
          },
        ),
      );
      debugPrint("res di okeride controller geo/geocode $response");

      var responseBody = response.data;
      BaseResponse baseResponse = BaseResponse.fromJson(responseBody);
      if (baseResponse.data.geocodeResult!.places.length != 0) {
        String place = baseResponse.data.geocodeResult!.places[0].name;
        destinationLocation.value = place;
        destinationDetailLocation.value = '';
      } else {
        print('result not found');
      }
      isLoading.value = false;
    } on DioException catch (e) {
      print(e.message);
    }
  }
}
