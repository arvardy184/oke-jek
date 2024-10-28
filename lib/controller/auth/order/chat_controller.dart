import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData;
import 'package:dio/dio.dart' ;
import 'package:okejek_flutter/defaults/url.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ChatController extends GetxController {
final Dio dio = Dio();
  final RxList messages = [].obs;
  final RxMap driver = {}.obs;
  final RxBool isLoading = true.obs;
  Timer? _pollingTimer;
  String? currentOrderId;
  final RxBool isActive = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
    stopPolling();
  }

void startPolling(String orderId) {
    currentOrderId = orderId;
    isActive.value = true;
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (isActive.value) {
        fetchMessages(currentOrderId!);
      }
    });
  }
 void stopPolling() {
    isActive.value = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

Future<void> fetchMessages(String orderId) async {
    if (!isActive.value) return; // Jangan fetch jika tidak aktif
    isLoading.value = true;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? session = prefs.getString('user_session');
      String url = OkejekBaseURL.apiUrl('orders/chats/$orderId/messages');
      var queryParams = {'api_token': session};
      final response = await dio.get(
        url,
        queryParameters: queryParams,
        options: Options(headers: {'Accepts': 'application/json'}),
      );

      debugPrint("res di chat controller $response");

      if (response.statusCode == 200) {
        var newMessages = response.data['data']['order_chat_messages'];
        if (messages.isEmpty || newMessages.length != messages.length) {
          messages.value = newMessages;
          if (messages.isNotEmpty && messages[0]['driver'] != null) {
            driver.value = messages[0]['driver'];
          }
        }
      }
    } catch (e) {
      print('Error fetching messages: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage(String orderId, String content) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? session = prefs.getString('user_session');
      String url = OkejekBaseURL.apiUrl('orders/chats/$orderId/submit');
      
      // Pastikan URL sesuai dengan dokumentasi API
      print("Sending message to URL: $url");

      var queryParams = {'api_token': session};
      
      // Gunakan ContentType.json untuk memastikan server memahami format data
      final response = await dio.post(
        url,
        queryParameters: queryParams,
        data: {'content': content},  // Kirim sebagai JSON, bukan FormData
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      print("Response status code: ${response.statusCode}");
      print("Response data: ${response.data}");

      if (response.statusCode == 200 || response.data['success'] == true) {
        print('Message sent successfully');
        await fetchMessages(orderId);
      } else {
        print('Error sending message. Status: ${response.statusCode}');
        print('Error details: ${response.data}');
      }
    } on DioException catch (e) {
      print('DioException occurred:');
      print('  Status code: ${e.response?.statusCode}');
      print('  Response data: ${e.response?.data}');
      print('  Error message: ${e.message}');
    } catch (e) {
      print('Unexpected error sending message: $e');
    }
  }
}
