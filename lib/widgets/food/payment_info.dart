import 'dart:ui';
import 'package:entry/entry.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:okejek_flutter/controller/auth/okefood/detail_outlet_controller.dart';
import 'package:okejek_flutter/controller/auth/okefood/okefood_payment_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/models/auth/food/food_vendor_model.dart';
import 'package:okejek_flutter/widgets/loading_animation.dart';

/// Widget untuk menampilkan informasi terkait pembayaran pada food / mart
class PaymentSection extends StatelessWidget {
  final FoodVendor foodVendor;
  final int type;
  PaymentSection({
    required this.type,
    required this.foodVendor,
  });

  final OkefoodPaymentController foodPaymentController = Get.find();
  final DetailOutletController outletController = Get.find();
  final currencyFormatter = NumberFormat.currency(locale: 'ID', symbol: 'Rp', decimalDigits: 0);
  final TextEditingController promoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => foodPaymentController.destLocation.value.isNotEmpty
          ? FutureBuilder(
              future: foodPaymentController.fetchDataPayment(outletController.total.value),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: LoadingAnimation(),
                  );
                } else {
                  return Obx(
                    () => foodPaymentController.fetchSucess.value
                        ? Entry.all(
                            opacity: 0,
                            scale: 1,
                            yOffset: 0,
                            xOffset: 100,
                            child: Column(
                              children: [
                                SizedBox(height: SizeConfig.safeBlockVertical * 1.98),
                                Divider(
                                  thickness: 1,
                                ),
                                SizedBox(height: SizeConfig.safeBlockVertical * 1.98),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Metode Pembayaran : ',
                                      style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 3.3),
                                    ),

                                    // dropdown
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          color: OkejekTheme.primary_color,
                                          size: SizeConfig.safeBlockHorizontal * 4.1,
                                        ),
                                        SizedBox(
                                          width: SizeConfig.safeBlockHorizontal * 2.78,
                                        ),
                                        Obx(
                                          () => DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              hint: Text(
                                                'Pilih Metode',
                                                style: TextStyle(
                                                  fontSize: SizeConfig.safeBlockHorizontal * 3.3,
                                                ),
                                              ),
                                              iconEnabledColor: OkejekTheme.primary_color,
                                              style: TextStyle(
                                                color: OkejekTheme.primary_color,
                                                fontSize: SizeConfig.safeBlockHorizontal * 3.3,
                                              ),
                                              value: foodPaymentController.dropDownValue.value,
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
                                                foodPaymentController.setDropdownValue(value);
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: Get.height * 0.02,
                                ),
                                Obx(
                                  () => foodPaymentController.isAppInstalled.value
                                      ? SizedBox()
                                      : Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Icon(
                                                  Icons.warning,
                                                  color: OkejekTheme.primary_color,
                                                  size: SizeConfig.safeBlockHorizontal * 15 / 3.6,
                                                ),
                                                SizedBox(
                                                  width: SizeConfig.safeBlockHorizontal * 10 / 3.6,
                                                ),
                                                Text(
                                                  'Aplikasi belum terinstall',
                                                  style: TextStyle(
                                                    fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6,
                                                    color: OkejekTheme.primary_color,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: Get.height * 0.02,
                                            ),
                                          ],
                                        ),
                                ),
                                // Obx(
                                //   () => FutureBuilder<bool>(
                                //     future: foodPaymentController.isAppInstalled.value,
                                //     builder: (context, snapshot) {
                                //       if (!snapshot.hasData) {
                                //         return Container(
                                //           height: 10,
                                //           width: 10,
                                //           child: Center(
                                //             child: CircularProgressIndicator(),
                                //           ),
                                //         );
                                //       } else {
                                //         return snapshot.data!
                                //             ? SizedBox()
                                //             : Entry.all(
                                //                 duration: Duration(milliseconds: 500),
                                //                 xOffset: 50,
                                //                 yOffset: 0,
                                //                 scale: 1,
                                //                 opacity: 0,
                                //                 child: Column(
                                //                   children: [
                                //                     Row(
                                //                       mainAxisAlignment: MainAxisAlignment.end,
                                //                       children: [
                                //                         Icon(
                                //                           Icons.warning,
                                //                           color: OkejekTheme.primary_color,
                                //                           size: SizeConfig.safeBlockHorizontal * 15 / 3.6,
                                //                         ),
                                //                         SizedBox(
                                //                           width: SizeConfig.safeBlockHorizontal * 10 / 3.6,
                                //                         ),
                                //                         Text(
                                //                           'Aplikasi belum terinstall',
                                //                           style: TextStyle(
                                //                             fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6,
                                //                             color: OkejekTheme.primary_color,
                                //                           ),
                                //                         ),
                                //                       ],
                                //                     ),
                                //                     SizedBox(
                                //                       height: Get.height * 0.02,
                                //                     ),
                                //                   ],
                                //                 ),
                                //               );
                                //       }
                                //     },
                                //   ),
                                // ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Kode Promo : ',
                                      style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 3.3),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        foodPaymentController.changeSubmitPromo(false);
                                        // dialog(foodPaymentController, context);
                                        showPromoCodeDialog(context, foodPaymentController);
                                      },
                                      child: Obx(
                                        () => Text(
                                          foodPaymentController.promoCode.value.isEmpty
                                              ? 'Masukkan Kode Promo'
                                              : foodPaymentController.promoCode.value,
                                          style: TextStyle(
                                            fontSize: SizeConfig.safeBlockHorizontal * 3.3,
                                            color: OkejekTheme.primary_color,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (foodPaymentController.promoCode.value.isNotEmpty &&
                                        foodPaymentController.price.value != 0)
                                      IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          foodPaymentController.cancelPromo();
                                        },
                                      )
                                  ],
                                ),
                                SizedBox(height: SizeConfig.safeBlockVertical * 1.3),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total : ',
                                      style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 3.3),
                                    ),
                                    Obx(() {
                                      return foodPaymentController.price.value != 0
                                          ? Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                if (foodPaymentController.promoCode.value.isNotEmpty)
                                                  Text(
                                                    currencyFormatter.format(foodPaymentController.totalPembayaran.value),
                                                    style: TextStyle(
                                                      fontSize: SizeConfig.safeBlockHorizontal * 3,
                                                      decoration: TextDecoration.lineThrough,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                Text(
                                                  currencyFormatter.format(foodPaymentController.price.value),
                                                  style: TextStyle(
                                                    fontSize: SizeConfig.safeBlockHorizontal * 3.8,
                                                    fontWeight: FontWeight.bold,
                                                    color: OkejekTheme.primary_color,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Text(
                                              currencyFormatter.format(foodPaymentController.totalPembayaran.value),
                                              style: TextStyle(
                                                fontSize: SizeConfig.safeBlockHorizontal * 3.89,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                    })
                                  ],
                                ),
                                SizedBox(
                                  height: SizeConfig.safeBlockVertical * 3.96,
                                ),
                                Obx(() => foodPaymentController.isSubmitOrder.value
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Center(
                                            child: Container(
                                              height: SizeConfig.safeBlockHorizontal * 2.7,
                                              width: SizeConfig.safeBlockHorizontal * 2.7,
                                              child: CircularProgressIndicator(),
                                            ),
                                          ),
                                          SizedBox(
                                            height: SizeConfig.safeBlockHorizontal * 10,
                                          ),
                                        ],
                                      )
                                    : ElevatedButton(
                                        onPressed: () {
                                          // foodPaymentController.testingorder();
                                          foodPaymentController.createOrder(
                                              outletController, foodVendor, type, showAlertDialog);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(double.infinity, SizeConfig.safeBlockVertical * 5.2),
                                          backgroundColor: OkejekTheme.primary_color,
                                        ),
                                        child:
                                        foodPaymentController.isLoading.value
                                              ? CircularProgressIndicator(color: Colors.white)
                                              :
                                         Text(
                                          'Pesan Sekarang',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: SizeConfig.safeBlockHorizontal * 3.8,
                                          ),
                                        ),
                                      ))
                              ],
                            ),
                          )
                        : Center(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: SizeConfig.safeBlockVertical * 3.96,
                                ),
                                LinearProgressIndicator(),
                                SizedBox(
                                  height: SizeConfig.safeBlockVertical * 3.96,
                                ),
                              ],
                            ),
                          ),
                  );
                }
              },
            )
          : Container(),
    );
  }

  static void showPromoCodeDialog(BuildContext context, OkefoodPaymentController foodPaymentController) {
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
                  isLoading
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
                                setState(() {
                                  isLoading = true; // Mulai loading
                                });

                                Future.delayed(Duration(seconds: 3), () {
                                  setState(() {
                                    isLoading = false; // Hentikan loading
                                  });
                                  // Simpan kode promo dan close dialog
                                  foodPaymentController.setPromoCode(promoController.text);
                                  foodPaymentController.getCouponCode(promoController.text);
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

  Future<dynamic> dialog(OkefoodPaymentController foodPaymentController, BuildContext context) {
    return Get.dialog(
      AlertDialog(
        title: Text(
          'Masukkan Kode Promo',
          style: TextStyle(
            fontSize: SizeConfig.safeBlockHorizontal * 3.4,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: promoController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(
                    SizeConfig.safeBlockHorizontal * 5.56,
                    SizeConfig.safeBlockHorizontal * 2.78,
                    SizeConfig.safeBlockHorizontal * 5.56,
                    SizeConfig.safeBlockHorizontal * 2.78),
                hintText: 'Contoh : KODEPROMO17',
                hintStyle: TextStyle(
                  color: Colors.black45,
                  fontSize: SizeConfig.safeBlockHorizontal * 3.3,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 3.3,
                decoration: TextDecoration.none,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Obx(
              () => foodPaymentController.isSubmitPromo.value
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: OkejekTheme.primary_color,
                            ),
                          ),
                          child: Text(
                            'Batalkan',
                            style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal * 3.3,
                              color: OkejekTheme.primary_color,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            foodPaymentController.changeSubmitPromo(true);
                            Future.delayed(Duration(seconds: 3), () {
                              foodPaymentController.changeSubmitPromo(false);
                              foodPaymentController.setPromoCode(promoController.text);
                              Get.back();
                              showSnackbar(context);
                            });
                          },
                          child: Text(
                            'Masukkan',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
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

  void showSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green[400],
        content: Text(
          'Kode Promo berhasil digunakan',
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        behavior: SnackBarBehavior.floating, // Add this line
      ),
    );
  }
}
