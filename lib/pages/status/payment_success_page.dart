import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';

class PaymentSuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String orderId = Get.arguments ?? '';
    return Scaffold(
      appBar: AppBar(title: Text('Pembayaran Berhasil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            SizedBox(height: 20),
            Text(
              'Pembayaran Berhasil!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Order ID: $orderId'),
            SizedBox(height: 30),
            ElevatedButton(
              child: Text('Lihat Detail Pesanan'),
              onPressed: () => Get.offNamed('/order-details', arguments: orderId),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentFailedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String orderId = Get.arguments ?? '';
    return Scaffold(
      appBar: AppBar(title: Text('Pembayaran Gagal')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 100),
            SizedBox(height: 20),
            Text(
              'Pembayaran Gagal',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Order ID: $orderId'),
            SizedBox(height: 30),
            ElevatedButton(
              child: Text('Coba Lagi'),
              onPressed: () => Get.offNamed('/retry-payment', arguments: orderId),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentCanceledPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String orderId = Get.arguments ?? '';
    return Scaffold(
      appBar: AppBar(title: Text('Pembayaran Dibatalkan')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel, color: OkejekTheme.primary_color, size: 100),
            SizedBox(height: 20),
            Text(
              'Pembayaran Dibatalkan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Order ID: $orderId'),
            SizedBox(height: 30),
            ElevatedButton(
              child: Text('Kembali ke Beranda'),
              onPressed: () => Get.offAllNamed('/home'),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentUnknownPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String orderId = Get.arguments ?? '';
    return Scaffold(
      appBar: AppBar(title: Text('Status Pembayaran Tidak Diketahui')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help, color: Colors.grey, size: 100),
            SizedBox(height: 20),
            Text(
              'Status Pembayaran Tidak Diketahui',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text('Order ID: $orderId'),
            SizedBox(height: 30),
            ElevatedButton(
              child: Text('Cek Status Pesanan'),
              onPressed: () => Get.offNamed('/check-order-status', arguments: orderId),
            ),
          ],
        ),
      ),
    );
  }
}