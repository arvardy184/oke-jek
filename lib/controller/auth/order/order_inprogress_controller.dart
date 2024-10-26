import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:okejek_flutter/controller/okeride_controller.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/defaults/url.dart';
import 'package:okejek_flutter/models/auth/order_model.dart';
import 'package:okejek_flutter/models/base_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderInProgressController extends GetxController {
  Set<Marker> _markers = {};
  OkeRideController orderController = Get.put(OkeRideController());

  Timer? _pollingTimer;
  final RxInt orderStatus = 0.obs;

  Dio dio = Dio();
  var showMore = false.obs;

@override
  void onInit() {
    super.onInit();
  }

  void onDispose() {
    super.onClose();
  }

  void delete() {
    super.onDelete();
    print('close on delete');
  }


Future<Order> getOrderDetails(int orderId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? session = preferences.getString("user_session");

    try {
      String url = OkejekBaseURL.apiUrl('orders/view/$orderId');

      var queryParams = {
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

      var responseBody = response.data;
      BaseResponse responseData = BaseResponse.fromJson(responseBody);
      Order order = responseData.data.orders!;
orderStatus.value = order.status;
      print("response order details $order");
      return order;
    } catch (e) {
      print('Error fetching order details: $e');
      throw e;
    }
  }
  
  // void startPolling() {
  //   _pollingTimer = Timer.periodic(Duration(seconds: 30), (_) => );
  // }

  Set<Marker> setMarker() {
    _markers.clear(); // Clear existing markers
    print(
        "berapa marker set : ${orderController.originLat.value} ${orderController.originLng.value} ${orderController.destinationLat.value} ${orderController.destinationLng.value}");
    // Add origin marker
    _markers.add(
      Marker(
        markerId: MarkerId('pickup location'),
        position: LatLng(orderController.originLat.value, orderController.originLng.value),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );

    // Add destination marker
    _markers.add(
      Marker(
        markerId: MarkerId('destination location'),
        position: LatLng(orderController.destinationLat.value, orderController.destinationLng.value),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    return _markers;
  }

  void cancelOrder(int id) async {
    // show loading process
    Get.back();
    showLoading();

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? session = preferences.getString("user_session");

    try {
      // String url = OkejekBaseURL.cancelOrder(id);
      String url = OkejekBaseURL.apiUrl('orders/cancel/$id');

      var queryParams = {
        'api_token': session,
      };

      await dio.get(
        url,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Accepts': 'application/json',
          },
        ),
      );

      debugPrint('cancel success');

      successCancel();
    } on DioException catch (e) {
      print(e.message);
      failedToCancel();
    }
  }

  void showLoading() {
    Get.dialog(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 100,
            width: 100,
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }

   void listenToFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // if (message.data['type'] == 'order_update' && 
      //     message.data['order_id'] == orderController.currentOrder.value.id.toString()) {
      //   checkOrderStatus();
      // }
    });
  }

  successCancel() {
    final snackBar = SnackBar(
      content: Text(
        'Pesanan telah dibatalkan',
        style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6),
      ),
    );

    ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);

    Get.close(2);
  }

  failedToCancel() {
    final snackBar = SnackBar(
      content: Text(
        'Pesanan tidak bisa dibatalkan',
        style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6),
      ),
      backgroundColor: Colors.red,
    );

    ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
    Get.close(2);
  }
}
