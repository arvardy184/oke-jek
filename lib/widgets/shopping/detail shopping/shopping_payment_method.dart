import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:okejek_flutter/controller/auth/okeshop/detail_order_controller.dart';
import 'package:okejek_flutter/controller/auth/okeshop/okeshop_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/widgets/loading_animation.dart';

class ShoppingPaymentMethod extends StatelessWidget {
  final currencyFormatter = NumberFormat.currency(locale: 'ID', symbol: 'Rp', decimalDigits: 0);
  final TextEditingController promoController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    print("Building ShoppingPaymentMethod widget");
    print("Get.arguments: ${Get.arguments}");

    OkeShopController okeShopcontroller = Get.find();
    DetailOrderShopController detailShopController = Get.find();
    print("OkeShopController total: ${okeShopcontroller.total.value}");
    print("DetailOrderShopController totalPembayaran: ${detailShopController.totalPembayaran}");
    print("pickUplocation: ${detailShopController.pickUplocation}");
    print("destLocation: ${detailShopController.destLocation}");
    return Obx(() {
      bool isLocationValid = detailShopController.pickUplocation.isNotEmpty && detailShopController.destLocation.isNotEmpty;
      print("Rebuilding Obx widget");
      print("pickUplocation: ${detailShopController.pickUplocation}");
      print("destLocation: ${detailShopController.destLocation}");

      // if(detailShopController.pickUplocation.isNotEmpty ||detailShopController.destLocation.isNotEmpty){
      //   print("Locations are empty, returning empty container");
      //   return Container(
      //     child: Center(child: Text("Lokasi belum diisi"),)
      //   );

      // }
      return FutureBuilder(
        future: detailShopController.fetchDataPayment(okeShopcontroller.total.value),
        builder: (context, snapshot) {
          print("FutureBuilder snapshot state: ${snapshot.connectionState}");
          if (snapshot.connectionState == ConnectionState.waiting) {
            print("Data is still loading");
            return Center(child: LoadingAnimation());
          } else if (snapshot.hasError) {
            print("Error in FutureBuilder: ${snapshot.error}");
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            print("No data in snapshot");
            return Center(child: Text("No data available"));
          }
          // if (!snapshot.hasData) {
          //   print("payment method ${snapshot.data}");
          //   return Center(
          //       child: Column(
          //     children: [
          //       SizedBox(
          //         height: SizeConfig.safeBlockHorizontal * 30 / 3.6,
          //       ),
          //       LinearProgressIndicator(),
          //       SizedBox(
          //         height: SizeConfig.safeBlockVertical * 30 / 3.6,
          //       ),
          //     ],
          //   ));
          // } else {
          print("data loaded successfully ${snapshot.data}");
          return Column(
            children: [
              SizedBox(height: SizeConfig.safeBlockVertical * 15 / 7.56),
              Divider(
                thickness: 1,
              ),
              SizedBox(height: SizeConfig.safeBlockVertical * 10 / 7.56),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Metode Pembayaran : ',
                    style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6),
                  ),

                  // dropdown
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: OkejekTheme.primary_color,
                        size: SizeConfig.safeBlockHorizontal * 15 / 3.6,
                      ),
                      SizedBox(
                        width: SizeConfig.safeBlockHorizontal * 10 / 3.6,
                      ),
                      Obx(
                        () => DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: Text(
                              'Pilih Metode',
                              style: TextStyle(
                                fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6,
                              ),
                            ),
                            iconEnabledColor: OkejekTheme.primary_color,
                            style: TextStyle(
                              color: OkejekTheme.primary_color,
                              fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6,
                            ),
                            value: detailShopController.dropDownValue.value,
                            items: <String>[
                              'Cash',
                              'OkePoint',
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              detailShopController.setDropdownValue(value);
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kode Promo : ',
                    style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6),
                  ),
                  TextButton(
                    onPressed: () {
                      detailShopController.changeSubmitPromo(false);
                      showPromoCodeDialog(context, detailShopController);
                    },
                    child: Obx(
                      () => Text(
                        detailShopController.promoCode.value.isEmpty
                            ? 'Masukkan Kode Promo'
                            : detailShopController.promoCode.value,
                        style: TextStyle(
                          fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6,
                          color: OkejekTheme.primary_color,
                        ),
                      ),
                    ),
                  ),
                  if(detailShopController.promoCode.value.isNotEmpty) 
                    IconButton(
                      onPressed: () {
                        detailShopController.cancelPromo();
                      },
                       icon: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                    ),
                ],
              ),
              SizedBox(height: SizeConfig.safeBlockVertical * 10 / 7.56),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total : ',
                    style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6),
                  ),
                  Obx(() {
                    return detailShopController.price.value != 0
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (detailShopController.promoCode.value.isNotEmpty)
                                Text(
                                  currencyFormatter.format(detailShopController.totalPembayaran.value),
                                  style: TextStyle(
                                    fontSize: SizeConfig.safeBlockHorizontal * 3,
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                  ),
                                ),
                              Text(
                                currencyFormatter.format(detailShopController.price.value),
                                style: TextStyle(
                                  fontSize: SizeConfig.safeBlockHorizontal * 3.8,
                                  fontWeight: FontWeight.bold,
                                  color: OkejekTheme.primary_color,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            currencyFormatter.format(detailShopController.totalPembayaran.value),
                            style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal * 3.89,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                  })
                ],
              ),
              SizedBox(
                height: SizeConfig.safeBlockVertical * 30 / 7.56,
              ),
              ElevatedButton(
                onPressed: (detailShopController.isLoading.value || !isLocationValid)
                    ? null
                    : () {
                        detailShopController.isLoading.value = true;
                        detailShopController.createOrder(showAlertDialog).then((_) {
                          detailShopController.isLoading.value = false;
                        });
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, SizeConfig.safeBlockVertical * 40 / 7.56),
                  backgroundColor: isLocationValid 
                    ? OkejekTheme.primary_color
                    : Colors.grey[300],
                  foregroundColor: isLocationValid 
                    ? Colors.white
                    : Colors.grey[600],
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[600],
                ),
                child: detailShopController.isLoading.value
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(isLocationValid ? Colors.white : Colors.grey[600]!),
                        ),
                      )
                    : Text(
                        'Pesan Sekarang',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: SizeConfig.safeBlockHorizontal * 14 / 3.56,
                        ),
                      ),
              )
            ],
          );
          // }
        },
      );
    } // : Container();

        );
  }

  showAlertDialog(BuildContext context, String message) {
    // set up the button
    Widget okButton = ElevatedButton(
      child: Text(
        "OK",
        style: TextStyle(
          fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6,
        ),
      ),
      onPressed: () {
        Get.back();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "Pesanan Gagal",
        style: TextStyle(
          fontSize: SizeConfig.safeBlockHorizontal * 14 / 3.6,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        "Tidak dapat melakukan pesanan saat ini dikarenakan $message",
        style: TextStyle(
          fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6,
        ),
      ),
      actions: [
        okButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static void showPromoCodeDialog(BuildContext context, DetailOrderShopController detailShopController) {
    final promoController = TextEditingController();
    bool isLoading = false;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black45,
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.transparent,
            content: Container(
              width: SizeConfig.screenWidth * 0.8,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.white.withOpacity(0.9)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Masukkan Kode Promo',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: OkejekTheme.primary_color,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: promoController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: KODEPROMO17',
                      fillColor: Colors.grey[200],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: OkejekTheme.primary_color, width: 2),
                      ),
                      prefixIcon: Icon(Icons.local_offer, color: OkejekTheme.primary_color),
                    ),
                  ),
                  SizedBox(height: 20),
                  isLoading == true
                      ? CircularProgressIndicator() // Indikator loading
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => Get.back(),
                              child: Text('Batal'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black87,
                                backgroundColor: Colors.grey[300],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // setState(() {
                                //   isLoading = true; // Mulai loading
                                // });

                                detailShopController.changeSubmitPromo(true);
                                Future.delayed(Duration(seconds: 3), () {
                                  detailShopController.changeSubmitPromo(false);
                                  detailShopController.setPromoCode(promoController.text);
                                  detailShopController.getCouponCode(promoController.text);
                                  Get.back();
                                });
                              },
                              child: Text('Terapkan'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: OkejekTheme.primary_color,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          );
        },
      ),
      transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4 * anim1.value, sigmaY: 4 * anim1.value),
        child: FadeTransition(
          opacity: anim1,
          child: child,
        ),
      ),
    );
  }

  void showSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green[400],
        content: Text(
          'Kode Promo berhasil digunakan',
          style: TextStyle(
            fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6,
          ),
        ),
        behavior: SnackBarBehavior.floating, // Add this line
      ),
    );
  }
}
