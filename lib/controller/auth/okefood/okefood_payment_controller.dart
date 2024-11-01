import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
// import 'package:device_apps/device_apps.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide FormData;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:okejek_flutter/controller/auth/okefood/detail_outlet_controller.dart';
import 'package:okejek_flutter/controller/landing_controller.dart';
import 'package:okejek_flutter/defaults/url.dart';
import 'package:okejek_flutter/models/auth/city_model.dart';
import 'package:okejek_flutter/models/auth/food/food_vendor_model.dart';
import 'package:okejek_flutter/models/auth/food/menu_model.dart';
import 'package:okejek_flutter/models/auth/okeride/auto_complete_model.dart';
import 'package:okejek_flutter/models/auth/order_model.dart';
import 'package:okejek_flutter/models/base_response_model.dart';
import 'package:okejek_flutter/pages/auth/bottom_navigation_bar.dart';
import 'package:okejek_flutter/pages/auth/order/order_detail_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OkefoodPaymentController extends GetxController {
  List<Marker> markers = [];
  Dio dio = Dio();
  DetailOutletController outletController = Get.put(DetailOutletController());
  LandingController landingController = Get.put(LandingController());

  int totalBelanja;
  double outletLat;
  double outletLng;

  OkefoodPaymentController({
    required this.outletLat,
    required this.outletLng,
    required this.totalBelanja,
  });

  var driverNote = ''.obs;
  var destLocation = ''.obs;
  var destinationAddress = ''.obs;
  var promoCode = 'Masukkan Promo'.obs;
  var price = 0.obs;
  var originPrice = 0.obs;
  var cityId = 0.obs;
  var ongkir = 0.obs;
  var jarak = 2.obs;
  var totalPembayaran = 0.obs;

  var isSubmitPromo = false.obs;
  var fetchSucess = false.obs;
  var isFecthingData = false.obs;

 var dropDownValue = 'Cash'.obs;
  var dropDownValueList = ['Cash', 'OkePoint'];

  var pickUpLat = 0.0.obs;
  var pickUpLng = 0.0.obs;
  var destLat = 0.0.obs;
  var destLng = 0.0.obs;
  var errorMessage = ''.obs;
  var isSubmitOrder = false.obs;
  var isLoading = false.obs;
  var isAppInstalled = true.obs;
  var couponId = 0.obs;
  void onInit() {
    super.onInit();
    test();
  }

  void delete() {
    super.onDelete();
    resetController();
  }

  void test() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? currentAddress = preferences.getString('current_geocode_address');
    double? currentLat = preferences.getDouble('current_geocode_lat');
    double? currentLng = preferences.getDouble('current_geocode_lng');

    destLocation.value = currentAddress!;
    destLat.value = currentLat!;
    destLng.value = currentLng!;

    print('detect current lat lng');
    print(destLocation);
    print('${destLat.value}, ${destLng.value}');
  }

  void resetController() {
    driverNote.value = '';
    destLocation.value = '';
    promoCode.value = '';
    isSubmitPromo.value = false;
    isSubmitOrder.value = false;
  }


    void cancelPromo(){
    promoCode.value = '';
    price.value = totalPembayaran.value;
    update();
  }


  String cartToJSON() {
    List shoppingItems = [];

    // convert items to JSON
    for (var i = 0; i < outletController.cartQtyMap.length; i++) {
      Menu menu = outletController.itemMap[outletController.indexList[i]];
      int qty = outletController.cartQtyMap[outletController.indexList[i]];
      shoppingItems.add({
        'foodVendorMenuId': menu.id,
        'name': menu.name,
        'detail': '',
        'qty': qty,
        'price': menu.price,
      });
    }

    var shoppingItemsJSON = jsonEncode(shoppingItems);

    return shoppingItemsJSON;
  }

  Future<bool> queryAppsinstalled() async {
    String payment = dropDownValue.value;

    String appPackages = '';
    if (payment == 'Shopee Pay') {
      appPackages = 'com.shopee.id';
    } else if (payment == 'Link Aja') {
      appPackages = 'com.telkom.mwallet';
    }
    //  else if (payment == 'Faspay') {
    //   appPackages = 'ovo.id';
    // }
     else {
      appPackages = '';
    }
    // payment == 'Shopee Pay'
    //     ? appPackages = 'com.shopee.id.int'
    //     : payment == 'Link Aja'
    //         ? appPackages = 'com.telkom.mwallet'
    //         : payment == 'Faspay'
    //             ? appPackages = 'ovo.id'
    //             : appPackages = '';

    if (appPackages.isEmpty) {
      isAppInstalled.value = true;
    } else {
      try {
        List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true);
        print('is app installed ${apps.any((app) => app.packageName == appPackages)}');
        //    print("is app installed ${apps.any((app) => app.packageName == appPackages)}");
        isAppInstalled.value = apps.any((app) => app.packageName == appPackages); //
      } on PlatformException catch (e) {
        print('Failed to get installed apps: $e');
        isAppInstalled.value = false;
      }
    }
    // bool isInstalled = appPackages == '' ? true : await DeviceApps.isAppInstalled(appPackages);
    print('is application packages $appPackages installed : ${isAppInstalled.value}');

    return isAppInstalled.value;
  }

  void testingorder() {
    print('======testing=======');
    isSubmitOrder.value = true;
    Future.delayed(Duration(seconds: 2), () {
      isSubmitOrder.value = false;
    });
  }


  Future<void> createOrder(
      DetailOutletController outletController, FoodVendor foodVendor, int orderType, Function dialogError) async {
    isSubmitOrder.value = true;
    isLoading.value = true;
    print('is submit order ${isSubmitOrder.value}');
    String shoppingJSON = cartToJSON();
    print(shoppingJSON);

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appVersion = packageInfo.buildNumber;

    // String url = OkejekBaseURL.createOrder;
    String url = OkejekBaseURL.apiUrl('orders/new');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? session = preferences.getString("user_session");
    String originLatLng = outletLat.toString() + ',' + outletLng.toString();
    String destinationLatLng = destLat.value.toString() + ',' + destLng.value.toString();

    try {
      var queryParams = {
        'api_token': session,
      };

      var data = {
        'payment_provider': '${dropDownValue.value}',
        'creation_code': '',
        'origin_latlng': originLatLng,
        'origin_address': '${foodVendor.name}',
        'origin_address_detail': '${foodVendor.address}',
        'destination_latlng': destinationLatLng,
        'destination_address': '${destLocation.value}',
        'destination_address_detail': '${destinationAddress.value}',
        'type': orderType.toString(),
        'food_vendor_id': '${foodVendor.id}',
        'info': driverNote.value,
        'coupon_id': couponId.value,
        'shopping_items': shoppingJSON,
        'app_platform': 'android',
        'app_version': appVersion,
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
      debugPrint("res form data ${formData.boundary} ${formData.fields} ${formData.fields} ${formData.files}");
      debugPrint("res di okefood payment controller orders/new $response");

      //  Http status error [500] dikarenakan masih menunggu merchant
      var responseBody = response.data;
      print("Full response: $responseBody");
      print("Data: ${responseBody['data']}");
      // print("Order: ${responseBody['data']['order']}");

      print(responseBody);

      isSubmitOrder.value = false;

      if (response.statusCode == 200) {
        if (responseBody['success']) {
          // Get.back();
          var orderResponse = responseBody['data']['order'];
          // Order order = Order.fromJson(orderResponse);
          print("res di okefood order $orderResponse");
          isLoading.value = false;
          if (orderResponse != null) {
            Order order = Order.fromJson(orderResponse);
            print("res di okefood order $order");
            Get.off(() => OrderDetailPage(order: order,driverData: order.driver != null ? order.driver!.toJson() : {},));
          } else {
            Get.off(() => BottomNavigation(), transition: Transition.rightToLeft);
          }
          // reset controller
          // outletController.resetController();
          // resetController();

          // Get.off(OrderDetailPage(order: order));

          // changing tab view to history page
          landingController.changeTab(1);
        } else if (!responseBody['success']) {
          isLoading.value = false;
          print("error message: ${responseBody['error']}");
          dialogError(Get.context, errorMessage.value);
          errorOrder(responseBody);
        }
      }
      print('is submit order ${isSubmitOrder.value}');
    } on DioException catch (e) {
      print(e.message);
      isSubmitOrder.value = false;
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
        'service': 3,
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
        price.value = 0;
      } else {
        setPromoCode(couponCode);
        price.value = totalPembayaran.value - baseResponse.data.coupon!.discountFee!;
        couponId.value = baseResponse.data.coupon!.id!;
        print("price: ${price.value} ${originPrice.value} ${baseResponse.data.coupon!.discountFee} ${totalPembayaran.value} ");
        Fluttertoast.showToast(msg: 'Kode berhasil dipakai', fontSize: 12);
      }
    } on DioException catch (e) {
      print(e.message);
    }
  }

  void errorOrder(var responseBody) {
    if (responseBody['error'] == 'order_driver_not_available') {
      errorMessage.value = 'Tidak ada driver di sekitar area penjemputan';
    } else if (responseBody['error'] == 'user_banned') {
      errorMessage.value = 'Pengguna telah dibanned dari aplikasi';
    } else if (responseBody['error'] == 'user_phone_not_valid') {
      errorMessage.value = 'No.HP Pengguna tidak valid';
    } else if (responseBody['error'] == 'order_limit_reached') {
      errorMessage.value = 'Pengguna mempunyai beberapa order yang masih dalam proses';
    } else if (responseBody['error'] == 'create_order_request_not_valid') {
      errorMessage.value = 'Format Order tidak valid';
    } else if (responseBody['error'] == 'outside_service_area') {
      errorMessage.value = 'Order berada diluar area layanan Okejek';
    } else if (responseBody['error'] == 'service_disabled') {
      errorMessage.value = 'Layanan yang dipilih sedang dinonaktifkan';
    } else if (responseBody['error'] == 'max_distance_motorcycle') {
      errorMessage.value = 'Jarak yang ditempuh terlalu jauh';
    } else {
      errorMessage.value = 'Jarak yang ditempuh terlalu jauh';
    }

    print(responseBody);
    print('failed to create an order');
  }

  void autoCompleteDestination(String place) async {
    List<AutoCompletePlace> listofPlace = [];
    // String url = OkejekBaseURL.autoComplete(destLat.value, destLng.value, place);
    String url = OkejekBaseURL.apiUrl('geo/autocomplete');

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? session = preferences.getString("user_session");

    try {
      var queryParams = {
        'lat': '${destLat.value}',
        'lng': '${destLng.value}',
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

      debugPrint("res di okefood payment controller geo/autocomplete $response");

      var responseBody = response.data;
      print(responseBody);
      BaseResponse baseResponse = BaseResponse.fromJson(responseBody);
      listofPlace.addAll(baseResponse.data.autoComplete!.places);

      if (listofPlace.length != 0) {
        destLocation.value = listofPlace[0].name;
        destinationAddress.value = listofPlace[0].address;
        destLat.value = listofPlace[0].location.lat;
        destLng.value = listofPlace[0].location.lng;
      } else {
        print('search autocomplete not found');
      }
    } on DioException catch (e) {
      print(e.message);
    }
  }

  void getPrice() async {
    isFecthingData.value = true;
    fetchSucess.value = false;
    // String url = OkejekBaseURL.getHarga(outletLat, outletLng, destLat.value, destLng.value, 3);

    String url = OkejekBaseURL.apiUrl('order/calculate');

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? session = preferences.getString("user_session");

    var queryParams = {
      'origin': '$outletLat,$outletLng',
      'destination': '${destLat.value},${destLng.value}',
      'type': 3,
      'api_token': session,
    };

    try {
      var response = await dio.post(
        url,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Accepts': 'application/json',
          },
        ),
      );

      debugPrint("res di okefood payment controller order/calculate $response");

      var responseBody = response.data;
      print('********');
      print(responseBody);
      BaseResponse baseResponse = BaseResponse.fromJson(responseBody);
      ongkir.value = baseResponse.data.calculateRequest!.fee;
      fetchSucess.value = true;

      // set a net totalPembayaran
      totalPembayaran.value = totalBelanja + ongkir.value;
      fetchSucess.value = true;
      isFecthingData.value = false;
    } on DioException catch (e) {
      // showing failure text
      print(e.message);
    }
  }

  void setDriverNote(String value) {
    driverNote.value = value;
  }

  void changeSubmitPromo(bool value) {
    isSubmitPromo.value = value;
    print('changed submit promo to ' + isSubmitPromo.value.toString());
  }

  void setPromoCode(String value) {
    promoCode.value = value;
  }

  void setTotalPembayaran(int totalBelanja) {
    totalPembayaran.value = ongkir.value + totalBelanja;
    print('total pembayaran : ' + totalPembayaran.value.toString());
  }

  void setDropdownValue(var value) {
    dropDownValue.value = value;
    queryAppsinstalled();
    print('dropdownvalue changed to : ' + dropDownValue.value.toString());
  }

  void setDestCoordinates(double lat, double lng) {
    destLat.value = lat;
    destLng.value = lng;

    addMarker('destination', destLat.value, destLng.value);
  }

  void setDestLocation(String value) {
    destLocation.value = value;
  }

  void setPickupCoordinates(double lat, double lng) {
    pickUpLat.value = lat;
    pickUpLng.value = lng;
    addMarker('pickup', pickUpLat.value, pickUpLng.value);
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
    destLat.value = lat;
    destLng.value = lng;
    print(markers);
  }

  Future<bool> fetchDataPayment(int totalBelanja) => Future.delayed(
        Duration(milliseconds: 500),
        () {
          setTotalPembayaran(totalBelanja);
          getPrice();

          return isFecthingData.value;
        },
      );
}
