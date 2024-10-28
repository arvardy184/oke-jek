import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' hide FormData;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:okejek_flutter/controller/landing_controller.dart';
import 'package:okejek_flutter/defaults/url.dart';
import 'package:okejek_flutter/models/auth/city_model.dart';
import 'package:okejek_flutter/models/auth/order_model.dart';
import 'package:okejek_flutter/models/base_response_model.dart';
import 'package:okejek_flutter/models/rental_model.dart';
import 'package:okejek_flutter/pages/auth/order/order_detail_page.dart';
import 'package:okejek_flutter/widgets/dialog2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OkeRentController extends GetxController {
  Set<Marker> _markers = {};
  final packages = <RentalPackage>[].obs;
  LandingController landingController = Get.put(LandingController());
  final selectedPackage = Rx<RentalPackage?>(null);
  final selectedPricingId = 0.obs;
  Dio dio = Dio();

    late Uint8List markerIcon;


   var driverLocation = [].obs;

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var cityId = 0.obs;
  var isAppInstalled = true.obs;
  var driverNote = ''.obs;
  var isSubmitDestination = false.obs;
  var promoCode = 'Masukkan Promo'.obs;
  var isSubmitPromo = false.obs;
  var isGeneratePayment = false.obs;
  var isSubmitOrder = false.obs;

  var dropDownValue = 'Cash'.obs;
  var dropDownValueList = [
    'Cash',
    'OkePoint',
  ];
  var couponId = 0.obs;

  // Lokasi penjemputan
  var originAddress = ''.obs;
  var originLat = 0.0.obs;
  var originLng = 0.0.obs;
  var originLocation = ''.obs;
  var originLocationDetail = ''.obs;
  var originAddressDetail = ''.obs;

  var destinationAddress = ''.obs;
  var destinationLatLng = ''.obs;
  var destinationAddressDetail = ''.obs;
  var destLat = 0.0.obs;
  var destLng = 0.0.obs;
  var destLocation = ''.obs;
  var destLocationDetail = ''.obs;
  var price = 0.0.obs;
  var newPrice = 0.0.obs;
  final markers = <Marker>[].obs;
  

  @override
  void onInit() {
    super.onInit();
    loadPackages();
    ever(destLat, (_) => updateMarkers());
    ever(destLng, (_) => updateMarkers());
  }

  void updateMarkers() {
    markers.clear();

    if (destLat.value != 0 && destLng.value != 0) {
      markers.add(Marker(
        markerId: MarkerId('destination'),
        position: LatLng(destLat.value, destLng.value),
        infoWindow: InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }
  }

  Set<Marker> setMarker() {
    driverLocation.forEach(
      (location) {
        List<String> locationSplit = location.split(',');

        _markers.add(
          Marker(
            markerId: MarkerId(location),
            icon: BitmapDescriptor.bytes(markerIcon),
            position: LatLng(double.parse(locationSplit[0]), double.parse(locationSplit[1])),
          ),
        );
      },
    );
    update();
    return _markers;
  }

 void getNearestDriver() async {
  driverLocation.clear();
  _markers.clear();
  print("get nearest driver called");
 
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? session = preferences.getString("user_session");

    try {
      getCityId();
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      String url = OkejekBaseURL.apiUrl('driver-location');

      var queryParams = {
        'city_id': '${cityId.value}',
        'service': '20',
        'location': '${position.latitude},${position.longitude}',
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

      debugPrint("res di oker controller drivers-locations $response");

      var responseBody = response.data;

      driverLocation.addAll(responseBody['data']['driver_locations']);
      print("driver locs after getting : $driverLocation");
      setMarker();
      isLoading.value = false;
    } on DioException catch (e) {
      print(e.message);
    }
  
}

  void getCityId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? cityJson = preferences.getString('nearestCity');

    var data = jsonDecode(cityJson!);
    City city = City.fromJson(data['data']['city']);

    cityId.value = city.id;
  }

  Future<void> loadPackages() async {
    try {
      List<RentalPackage> fetchedPackages = await getRentalPackages();
      packages.assignAll(fetchedPackages);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? cityJson = preferences.getString('nearestCity');

      var data = jsonDecode(cityJson!);
      City city = City.fromJson(data['data']['city']);
      cityId.value = city.id;
    } catch (e) {
      debugPrint(e.toString());
      errorMessage.value = e.toString();
    }
  }

  Future<List<RentalPackage>> getRentalPackages() async {
    isLoading.value = true;
    errorMessage.value = '';
    String url = OkejekBaseURL.apiUrl('order-packages');

    List<RentalPackage> rentalPackages = [];
    
    try {
      getCityId();
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? session = preferences.getString("user_session");
      debugPrint("session $session");

      var queryParams = {
        'api_token': session,
        'type': '20',
        'city_id': cityId.value.toString(),
      };

      final fullUrl = Uri.parse(url).replace(queryParameters: queryParams).toString();
      debugPrint("Full URL: $fullUrl");

      var response = await dio.get(
        url,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Accepts': 'application/json',
          },
        ),
      );

      debugPrint("res di OkeRent controller order-packages ${response.data} ${response.data}");

      var responseBody = response.data;
      BaseResponse responseData = BaseResponse.fromJson(responseBody);
      if (responseData.data.rentalPackages != null) {
        rentalPackages.addAll(responseData.data.rentalPackages!);
      }

      return rentalPackages;
    } on DioException catch (e) {
      debugPrint("DioException: ${e.message}");
      errorMessage.value = 'Terjadi kesalahan jaringan. Silakan coba lagi.';
      return [];
    } catch (e) {
      debugPrint("Unexpected error: $e");
      errorMessage.value = 'Terjadi kesalahan. Silakan coba lagi.';
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> queryAppsinstalled() async {
    String payment = dropDownValue.value;

    String appPackages;
    if (payment == 'Shopee Pay') {
      appPackages = 'com.shopee.id';
    } else if (payment == 'Link Aja') {
      appPackages = 'com.telkom.mwallet';
    } 
    // else if (payment == 'Faspay') {
    //   appPackages = 'ovo.id';
    // }
     else {
      appPackages = '';
    }

    if (appPackages.isEmpty) {
      isAppInstalled.value = true;
    } else {
      List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true);
      isAppInstalled.value = apps.any((app) => app.packageName == appPackages);
    }
    return isAppInstalled.value;
  }

  void setDropdownValue(String value) {
    dropDownValue.value = value;
    queryAppsinstalled();
    print('dropdownvalue changed to : $value');
  }

  void setSelectedPackage(RentalPackage package) {
    selectedPackage.value = package;
    print("selected package : ${selectedPackage.value?.id}");
  }

  void setPricingId(int pricingId){ 
    selectedPricingId.value = pricingId;
    price.value = selectedPricingId.value.toDouble();
    print("selected package pricing id : ${selectedPricingId.value}");
  }

  void setDriverNote(String value) {
    driverNote.value = value;
  }

  

  void addMarker(String value, double lat, double lng) {
    markers.add(
      Marker(
        markerId: MarkerId(value + ' location'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: value + ' location'),
      ),
    );

    print('added marker to ' + lat.toString() + ' ' + lng.toString());
    print(markers);
  }

  void setDestinationAddress(String address) {
    destinationAddress.value = address;
  }

  void setDestLocation(String value) {
    destLocation.value = value;
  }

  void changeGeneratePayment() {
    isGeneratePayment.value = true;
  }

  void setDestCoordinates(double lat, double lng) {
    destLat.value = lat;
    destLng.value = lng;

    addMarker('destination', destLat.value, destLng.value);
  }

  void setDestinationLatLng(String latLng) {
    destinationLatLng.value = latLng;
  }

  void setDestinationAddressDetail(String detail) {
    destinationAddressDetail.value = detail;
  }

  void changeSubmitDestination() {
    isSubmitDestination.value = true;
  }

  void resetSubmitDestination() {
    isSubmitDestination.value = false;
  }

  void changeSubmitPromo(bool value) {
    isSubmitPromo.value = value;
    print('changed submit promo to ' + isSubmitPromo.value.toString());
  }

  void cancelPromo(){
    promoCode.value = '';
  
    update();
  }
  

  void setPromoCode(String value){
    promoCode.value = value;
  }

  bool isLocationSet() {
    return destinationAddress.isNotEmpty && destinationLatLng.isNotEmpty;
  }

  void clearLocationData() {
    destinationAddress.value = '';
    destinationLatLng.value = '';
    destinationAddressDetail.value = '';
  }

    void errorOrder(Map<String, dynamic> responseBody) {
    errorMessage.value = responseBody['error'];
    print("error message: ${errorMessage.value}");
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
        'service': 0,
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

      debugPrint("res di okeride controller coupon/search $response");

      var responseBody = response.data;

      BaseResponse baseResponse = BaseResponse.fromJson(responseBody);
      if (baseResponse.data.coupon!.id == 0) {
        Fluttertoast.showToast(msg: 'Kode tidak ditemukan', fontSize: 12);
        setPromoCode('');
        price.value = 0;
      } else {
        setPromoCode(couponCode);
        // price.value = originPrice.value - baseResponse.data.coupon!.discountFee!;
       selectedPricingId.value = selectedPricingId.value - baseResponse.data.coupon!.discountFee!;
        couponId.value = baseResponse.data.coupon!.id!;
        Fluttertoast.showToast(msg: 'Kode berhasil dipakai', fontSize: 12);
        print("harga ${selectedPricingId.value} ${baseResponse.data.coupon!.discountFee} ${price.value} ${selectedPackage}");
      }
    } on DioException catch (e) {
      print(e.message);
    }
  }

Future<void> createRentalOrder() async {
  print('berapaa driver loc ${driverLocation}');
  if (!validateInputs()) {
    getNearestDriver();
    Get.snackbar('Error', errorMessage.value);
    return;
  }

  // if (driverLocation.isEmpty) {
  //   showOkejekDialog(
  //     title: 'Error',
  //     message: "Tidak ada driver yang tersedia saat ini. Silakan coba lagi nanti.",
  //     icon: Icons.error,
  //     iconColor: Colors.red,
  //   );
  //   return;
  // }

  isSubmitOrder.value = true;
  isLoading.value = true;

  try {
    String url = OkejekBaseURL.apiUrl('orders/new');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? session = preferences.getString("user_session");

    var formData = FormData.fromMap({
      'payment_provider': dropDownValue.value.toLowerCase(),
      'origin_latlng': '${destLat.value},${destLng.value}',
      'destination_latlng': '${destLat.value},${destLng.value}',
      'type': '20',
      'origin_address': originLocation.value,
      'origin_address_detail': originLocationDetail.value,
      'destination_address': destLocation.value,
      'destination_address_detail': destLocationDetail.value,
      'item_amount': 0,
      'sender_name': '',
      'sender_phone': '',
      'recipient_name': '',
      'recipient_phone': '',
      'package_pricing_id': selectedPricingId.value,
      if (promoCode.value.isNotEmpty) 'coupon_id': couponId.value,
      if (driverNote.value.isNotEmpty) 'info': driverNote.value,
    });

    print("form data : ${formData.fields}");

    var response = await dio.post(
      url,
      data: formData,
      queryParameters: {'api_token': session},
      options: Options(headers: {'Accepts': 'application/json'}),
    );

    var responseBody = response.data;
    print("cek response body rental $responseBody");

    if (responseBody['success'] == true) {
      var orderResponse = responseBody['data']['order'];  // Changed from 'orders' to 'order'
      if (orderResponse != null) {
        Order order = Order.fromJson(orderResponse);
        showOkejekDialog(
          title: 'Pesanan Rental Berhasil',
          message: 'Pesanan rental Anda telah berhasil dibuat.',
          icon: Icons.check_circle,
          iconColor: Colors.green,
          actions: [
            TextButton(
              child: Text('Lihat Detail'),
              onPressed: () {
                Get.back();
                Get.off(() => OrderDetailPage(order: order, driverData: order.driver != null ? order.driver!.toJson() : {}));
              },
            ),
          ],
        );
        Get.off(() => OrderDetailPage(order: order, driverData: order.driver != null ? order.driver!.toJson() : {}));
        landingController.changeTab(1);
      } else {
        throw Exception("Data order tidak ditemukan dalam respons");
      }
    } else {
      throw Exception(responseBody['message'] ?? "Terjadi kesalahan saat membuat pesanan");
    }
  } on DioException catch (e) {
    handleError("Terjadi kesalahan jaringan: ${e.message}");
  } catch (e) {
    handleError(e.toString());
  } finally {
    isSubmitOrder.value = false;
    isLoading.value = false;
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

bool validateInputs() {
  
  if (destLat.value == 0 || destLng.value == 0) {
    errorMessage.value = 'Lokasi tujuan belum dipilih';
    return false;
  }
  if (dropDownValue.value.isEmpty) {
    errorMessage.value = 'Metode pembayaran belum dipilih';
    return false;
  }
  if (selectedPackage.value == null) {
    errorMessage.value = 'Paket rental belum dipilih';
    return false;
  }
  return true;
}

}
