
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/landing_controller.dart';
import 'package:okejek_flutter/controller/okeride_controller.dart';

class ShopeePaymentHandler extends GetxController {
  final LandingController landingController = Get.find();
  final OkeRideController okeRideController = Get.find();

  void handleDeepLink(Uri uri) {
    if (uri.host == 'payment_callback') {
      String orderId = uri.queryParameters['order'] ?? '';
      String status = uri.queryParameters['status'] ?? '';
      
      if (orderId.isNotEmpty) {
        if (status == 'success') {
          // Pembayaran berhasil
          _handleSuccessfulPayment(orderId);
        } else if (status == 'failed') {
          // Pembayaran gagal
          _handleFailedPayment(orderId);
        } else if (status == 'pending') {
          // Pembayaran masih dalam proses
          _handlePendingPayment(orderId);
        } else {
          // Status tidak dikenali
          _handleUnknownStatus(orderId);
        }
      }
    }
  }

  void _handleSuccessfulPayment(String orderId) async {
    // Verifikasi pembayaran dengan server
    bool isVerified = await okeRideController.verifyPayment(orderId);
    if (isVerified) {
      // Update status pesanan
      await okeRideController.updateOrderStatus(orderId, 'paid');
      print("update order status");
      // Navigasi ke halaman detail pesanan
     // Get.off(() => OrderDetailPage(order: orderId));
    } else {
      Get.snackbar('Pembayaran Gagal', 'Terjadi kesalahan saat verifikasi pembayaran');
    }
  }

  void _handleFailedPayment(String orderId) {
    Get.snackbar('Pembayaran Gagal', 'Silakan coba lagi atau pilih metode pembayaran lain');
    print("handle failed payment");
    // Navigasi kembali ke halaman pembayaran atau detail pesanan
    // Get.off(() => OrderDetailPage(orderId: orderId));
  }

  void _handlePendingPayment(String orderId) {
    Get.snackbar('Pembayaran Tertunda', 'Pembayaran Anda sedang diproses');
    // Navigasi ke halaman detail pesanan dengan status pending
   // Get.off(() => OrderDetailPage(orderId: orderId));
  }

  void _handleUnknownStatus(String orderId) {
    Get.snackbar('Status Tidak Diketahui', 'Silakan cek status pesanan Anda');
    // Navigasi ke halaman detail pesanan
    //Get.off(() => OrderDetailPage(orderId: orderId));
  }
}