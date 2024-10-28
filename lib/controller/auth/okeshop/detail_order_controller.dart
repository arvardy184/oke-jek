import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart' hide FormData;
// import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:okejek_flutter/controller/api/user_controller.dart';
import 'package:okejek_flutter/controller/auth/okeshop/okeshop_controller.dart';
import 'package:okejek_flutter/controller/landing_controller.dart';

import 'package:okejek_flutter/defaults/url.dart';
import 'package:okejek_flutter/models/auth/city_model.dart';
import 'package:okejek_flutter/models/auth/order_model.dart';
import 'package:okejek_flutter/models/base_response_model.dart';
import 'package:okejek_flutter/pages/auth/bottom_navigation_bar.dart';
import 'package:okejek_flutter/pages/auth/order/order_detail_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailOrderShopController extends GetxController {
   final OkeShopController okeShopController = Get.find();
  final LandingController landingController = Get.find();
  final OkeShopController controller = Get.find();
  final UserController userController = Get.find();
  // List<Marker> markers = [];
  final markers = <Marker>[].obs;
  Dio dio = Dio();
  var pickUplocation = ''.obs;
  var driverNote = ''.obs;
  var promoCode = 'Masukkan Promo'.obs;
  var isLoading = false.obs;
  var isSubmitPickup = false.obs;
  var isSubmitDestination = false.obs;
  var isFecthingData = true.obs;
  var isGeneratePayment = false.obs;
  var isSubmitPromo = false.obs;
  var isSubmitOrder = false.obs;
  var price = 0.obs;
  var originPrice = 0.obs;
  var cityId = 0.obs;

  var ongkir = 0.obs;
  var jarak = 2.obs;
  var totalPembayaran = 0.obs;

  // var pickUpLat = 0.0.obs;
  // var pickUpLng = 0.0.obs;

  var originLat = 0.0.obs;
  var originLng = 0.0.obs;
  var originLocation = ''.obs;
  var originLocationDetail = ''.obs;
  var destLat = 0.0.obs;
  var destLng = 0.0.obs;
  var destLocation = ''.obs;
  var destLocationDetail = ''.obs;

  var dropDownValue = 'Cash'.obs;
  var dropDownValueList = [
    'Cash',
    'OkePoint',
  ];

  var errorMessage = ''.obs;
  var couponId = 0.obs;
  // void initState() {
  //   super.onInit();
  //   print(totalPembayaran.value);
  // }
@override
  void onInit() {
    super.onInit();
    ever(originLat, (_) => _triggerPriceCheck());
    ever(originLng, (_) => _triggerPriceCheck());
    ever(destLat, (_) => _triggerPriceCheck());
    ever(destLng, (_) => _triggerPriceCheck());
    print("initial total pembayaran: ${totalPembayaran.value}");
  }

void _triggerPriceCheck(){
  if(canCalculatePrice()){
    checkPrice();
  }
}

 bool canCalculatePrice() {
    return originLat.value != 0 && originLng.value != 0 && 
           destLat.value != 0 && destLng.value != 0;
  }
 void updateMarkers() {
    markers.clear();
    if (originLat.value != 0 && originLng.value != 0) {
      markers.add(Marker(
        markerId: MarkerId('pickup'),
        position: LatLng(originLat.value, originLng.value),
        infoWindow: InfoWindow(title: 'Pickup Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }
    if (destLat.value != 0 && destLng.value != 0) {
      markers.add(Marker(
        markerId: MarkerId('destination'),
        position: LatLng(destLat.value, destLng.value),
        infoWindow: InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }
  }
  void delete() {
    resetController();
    super.onDelete();
  }
  
  void cancelPromo(){
    promoCode.value = '';
    price.value = totalPembayaran.value;
    update();
  }

  Future<void> createOrder(Function dialogError) async {
     try {
    isLoading.value = true;
    isSubmitOrder.value = true;
PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appVersion = packageInfo.buildNumber;
    print('is submit order ${isSubmitOrder.value}');
    String shoppingJSON = cartToJSON();
    print(shoppingJSON);

    String url = OkejekBaseURL.apiUrl('orders/new');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? session = preferences.getString("user_session");
    String originLatLng = '${originLat.value},${originLng.value}';
    String destinationLatLng = '${destLat.value},${destLng.value}';

   
      var queryParams = {
        'api_token': session,
      };

      var data = {
        'payment_provider': dropDownValue.value.toLowerCase(),
        'creation_code': '',
        'origin_latlng': originLatLng,
        'destination_latlng': destinationLatLng,
        'type': 2, // 2 - shopping order
        'origin_address': originLocation.value,
        'origin_address_detail': originLocationDetail.value,
        'destination_address': destLocation.value,
        'destination_address_detail': destLocationDetail.value,
        'food_vendor_id': 0,
        'info': driverNote.value,
        'coupon_id': couponId.value,
        'shopping_items': shoppingJSON,
        'app_platform': 'android',
        'app_version': appVersion,
        'item_detail': '',
        'sender_name': '',
        'sender_phone': '',
        'recipient_name': '',
        'recipient_phone': '',
        'weight': 0.0,
        'item_amount': 0,
        'package_pricing_id': 0,
      };

      print("data create order $data");

      FormData formData = FormData.fromMap(data);

      var response = await dio.post(
        url,
        data: formData,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Accepts': 'application/json',
          },
        ),
      );

      debugPrint("res form data ${formData.boundary} ${formData.fields} ${formData.files}");
      debugPrint("res di okeshop payment controller orders/new $response");

      var responseBody = response.data;
      print("Full response: $responseBody");

      isSubmitOrder.value = false;

      if (response.statusCode == 200) {
        if (responseBody['success']) {
          var orderResponse = responseBody['data']['order'];
          if (orderResponse != null) {
            Order order = Order.fromJson(orderResponse);
            print("res di okeshop order $order");
             Get.offAll(() => OrderDetailPage(order: order,driverData: order.driver != null ? order.driver!.toJson() : {},));
          } else {
            print("error message: ${responseBody['error']}");
            dialogError(Get.context, errorMessage.value);
            Get.off(() => BottomNavigation(), transition: Transition.rightToLeft);
          }

          // Reset controllers and change tab
          resetController();
          landingController.changeTab(1);
        } else if (!responseBody['success']) {
          print("error message: ${responseBody['error']}");
          dialogError(Get.context, errorMessage.value);
          errorOrder(responseBody);
        }
      }
      print('is submit order ${isSubmitOrder.value}');
    } on DioException catch (e) {
      print(e.message);
      isSubmitOrder.value = false;
      dialogError(Get.context, "Terjadi kesalahan: ${e.message}");
    } finally {
      isLoading.value = false;  
      isSubmitOrder.value = false;
    }
  }

  String cartToJSON() {
    List<Map<String, dynamic>> shoppingItems = [];

    for (var item in okeShopController.dummyData) {
      shoppingItems.add({
        'id': 0,
        'name': item['nama_barang'],
        'detail': item['deskripsi'] ?? '',
        'price': item['harga'].toDouble(),
        'original_price': 0.0,
        'qty': item['jumlah'],
        'item_id': 0,
        'foodVendorMenuId': 0,
      });
    }

    print(shoppingItems);

    return jsonEncode(shoppingItems);
  }
  void errorOrder(Map<String, dynamic> responseBody) {
    errorMessage.value = responseBody['error'];
    print("error message: ${errorMessage.value}");
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
      await getCityId();

      String url = OkejekBaseURL.apiUrl('coupon/search');

      var queryParams = {
        'code': couponCode,
        'service': 2, // Changed to 2 for shopping service
        'city_id': '${cityId.value}',
        'api_token': session,
      };

      var response = await dio.get(
        url,
        queryParameters: queryParams,
        options: Options(
          headers: {'Accepts': 'application/json'},
        ),
      );

      debugPrint("Coupon search response: ${response.data}");

      var responseBody = response.data;
      BaseResponse baseResponse = BaseResponse.fromJson(responseBody);
      
      if (baseResponse.data.coupon!.id == 0) {
        Fluttertoast.showToast(msg: 'Kode tidak ditemukan', fontSize: 12);
        setPromoCode('');
        price.value = totalPembayaran.value;
      } else {
        setPromoCode(couponCode);
        int discount = baseResponse.data.coupon!.discountFee!;
        price.value = totalPembayaran.value - discount;
        couponId.value = baseResponse.data.coupon!.id!;
        debugPrint("Applied discount: $discount, New price: ${price.value}");
        Fluttertoast.showToast(msg: 'Kode berhasil dipakai', fontSize: 12);
      }
    } on DioException catch (e) {
      debugPrint('Error applying coupon: ${e.message}');
      Fluttertoast.showToast(msg: 'Gagal menggunakan kode promo', fontSize: 12);
    }
  }

Future<void> checkPrice() async {
    try {
      isLoading.value = true;

      // Validasi koordinat
      if (!canCalculatePrice()) {
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
          'origin': '${originLat.value},${originLng.value}',
          'destination': '${destLat.value},${destLng.value}',
          'type': 2, // 2 for shopping order
          'api_token': session,
        },
        options: Options(
          headers: {'Accepts': 'application/json'},
        ),
      );

      debugPrint("Response calculate: ${response.data}");

      if (response.data['success'] == true) {
        // Update ongkir
 ongkir.value = response.data['data']['calculated_request']['fee'];
        debugPrint("Ongkir updated: ${ongkir.value}");
        
        // Update total pembayaran
        int currentTotal = controller.total.value;
        updateTotalPembayaran(currentTotal);
        
        // If there's an active promo, recalculate the discounted price
        if (promoCode.value.isNotEmpty) {
          price.value = totalPembayaran.value - (totalPembayaran.value - price.value);
        }
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mendapatkan ongkir');
      }
    } catch (e) {
      debugPrint('Error calculating price: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }


 void updateTotalPembayaran(int totalBelanja) {
    int newTotal = ongkir.value + totalBelanja;
    if (totalPembayaran.value != newTotal) {
      totalPembayaran.value = newTotal;
      // Set the initial price value if no promo is active
      if (promoCode.value.isEmpty) {
        price.value = totalPembayaran.value;
      }
      debugPrint('Updated total pembayaran: ${totalPembayaran.value}');
    }
  }
  void setTotalPembayaran(int totalBelanja) {
   updateTotalPembayaran(totalBelanja);
    // totalPembayaran.value = ongkir.value + totalBelanja;
   
  }

  void setPickUpLocation(String value, String detail) {
    pickUplocation.value = value;
    originLocationDetail.value = detail;
    originLocation.value = value;
    print('PickUp Location set to: ${value} ${detail}');
  }

  void setPickUpCoordinates(double lat, double lng) {
    originLat.value = lat;
    originLng.value = lng;
    addMarker('pickup',originLat.value, originLng.value);
    print(
      'PickUp Coordinates set to: ${originLat.value} ${originLng.value}',
    );
  }

  void setDestCoordinates(double lat, double lng) {
    destLat.value = lat;
    destLng.value = lng;

    addMarker('destination', destLat.value, destLng.value);
  }

  void changeSubmitPickup() {
    isSubmitPickup.value = true;
  }

  void resetSubmitPickup() {
    isSubmitPickup.value = false;
  }

  void changeSubmitDestination() {
    isSubmitDestination.value = true;
  }

  void resetSubmitDestination() {
    isSubmitDestination.value = false;
  }

  void setDestLocation(String value) {
    destLocation.value = value;
  }

  void changeGeneratePayment() {
    isGeneratePayment.value = true;
  }

  void resetController() {
    pickUplocation.value = '';
    destLocation.value = '';
    isSubmitPickup.value = false;
    isSubmitDestination.value = false;
    isGeneratePayment.value = false;
    isSubmitPromo.value = false;
    totalPembayaran.value = 0;
    dropDownValue.value = 'Cash';
    promoCode.value = 'Masukkan Promo';
    driverNote.value = '';
    originLat.value = 0.0;
    originLng.value = 0.0;
    destLat.value = 0.0;
    destLng.value = 0.0;
  }

  void setDropdownValue(var value) {
    dropDownValue.value = value;
    print('dropdownvalue changed to : ' + dropDownValue.value.toString());
  }

  void changeSubmitPromo(bool value) {
    isSubmitPromo.value = value;
    print('changed submit promo to ' + isSubmitPromo.value.toString());
  }

  void setPromoCode(String value) {
    promoCode.value = value;
  }

 Future<bool> fetchDataPayment(int totalBelanja) async {
    try {
      if (canCalculatePrice()) {
        await checkPrice();
      } else {
        updateTotalPembayaran(totalBelanja);
      }
      return true;
    } catch (e) {
      debugPrint('Error fetching payment data: $e');
      return false;
    } finally {
      isFecthingData.value = false;
    }
  }

  Future<bool> fetchDataDestination() => Future.delayed(
        Duration(seconds: 2),
        () {
          isFecthingData.value = false;
          return isFecthingData.value;
        },
      );
}
