import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:okejek_flutter/controller/okeride_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/widgets/loading_animation.dart';
import 'package:shimmer/shimmer.dart';

/// Widget yang berkaitan dengan pembayaran Okeride
class PaymentSectionRide extends StatelessWidget {
  final TextEditingController promoController = TextEditingController();
  final currencyFormatter = NumberFormat.currency(locale: 'ID', symbol: 'Rp', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    OkeRideController okeRideController = Get.find();

    return Obx(
      () => okeRideController.originLocation.value.isNotEmpty && okeRideController.destLocation.value.isNotEmpty
          ? FutureBuilder(
              future: okeRideController.fetchDataPayment(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return loadingPayment();
                } else {
                  return Obx(
                    () => okeRideController.fetchSucess.value
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(thickness: 1),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Pembayaran :',
                                    style: TextStyle(
                                      fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  // Dropdown Metode Pembayaran
                                  DropdownButtonHideUnderline(
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
                                      value: okeRideController.dropDownValue.value,
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
                                        okeRideController.setDropdownValue(value!);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),

                              // FutureBuilder untuk mengecek aplikasi yang diinstall
                              Obx(() {
                                return FutureBuilder<bool>(
                                  future: okeRideController.queryAppsinstalled(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else {
                                      return snapshot.data!
                                          ? SizedBox.shrink()
                                          : Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Icon(
                                                    Icons.warning,
                                                    color: OkejekTheme.primary_color,
                                                    size: SizeConfig.safeBlockHorizontal * 4,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Aplikasi belum terinstall',
                                                    style: TextStyle(
                                                      fontSize: SizeConfig.safeBlockHorizontal * 3.3,
                                                      color: OkejekTheme.primary_color,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                    }
                                  },
                                );
                              }),

                              SizedBox(height: 16),

                              // Kode Kupon
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Kode Kupon :',
                                    style: TextStyle(
                                      fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      okeRideController.changeSubmitPromo(false);
                                      showPromoCodeDialog(context, okeRideController);
                                    },
                                    child: Obx(() {
                                      return Text(
                                        okeRideController.couponCode.value.isEmpty
                                            ? 'Masukkan Kupon'
                                            : okeRideController.couponCode.value,
                                        style: TextStyle(
                                          fontSize: SizeConfig.safeBlockHorizontal * 3.3,
                                          color: OkejekTheme.primary_color,
                                        ),
                                      );
                                    }),
                                  ),
                                  if (okeRideController.couponCode.value.isNotEmpty)
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        okeRideController.cancelPromo();
                                      },
                                    )
                                ],
                              ),

                              SizedBox(height: 16),

                              // Total Harga
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total :',
                                    style: TextStyle(
                                      fontSize: SizeConfig.safeBlockHorizontal * 4,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Obx(() {
                                    return okeRideController.price.value != 0
                                        ? Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              if (okeRideController.couponCode.value.isNotEmpty &&
                                                  okeRideController.originPrice.value != 0)
                                                Text(
                                                  currencyFormatter.format(okeRideController.originPrice.value),
                                                  style: TextStyle(
                                                    fontSize: SizeConfig.safeBlockHorizontal * 3,
                                                    decoration: TextDecoration.lineThrough,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              Text(
                                                currencyFormatter.format(okeRideController.price.value),
                                                style: TextStyle(
                                                  fontSize: SizeConfig.safeBlockHorizontal * 3.8,
                                                  fontWeight: FontWeight.bold,
                                                  color: OkejekTheme.primary_color,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            currencyFormatter.format(okeRideController.originPrice.value),
                                            style: TextStyle(
                                              fontSize: SizeConfig.safeBlockHorizontal * 3.8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                  }),
                                ],
                              ),

                              SizedBox(height: 24),

                              // Tombol Pesan Sekarang
                              Obx(() {
                                bool isAppInstalled = okeRideController.isAppInstalled.value;
                                bool isCashPayment = okeRideController.dropDownValue.value == 'Cash';
                                bool isButtonEnabled = isAppInstalled || isCashPayment;

                                return ElevatedButton(
                                  onPressed: isButtonEnabled
                                      ? () async {
                                          okeRideController.isCreatingOrder.value = true;
                                          try {
                                            await okeRideController.createOrder(showAlertDialog);
                                          } finally {
                                            okeRideController.isCreatingOrder.value = false;
                                          }
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(Get.width, Get.height * 0.06),
                                    backgroundColor: isButtonEnabled ? OkejekTheme.primary_color : Colors.grey,
                                  ),
                                  child: okeRideController.isCreatingOrder.value
                                      ? SizedBox(height: 20, width: 20, child: LoadingAnimation())
                                      : Text(
                                          'Pesan Sekarang',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: SizeConfig.safeBlockHorizontal * 3.8,
                                          ),
                                        ),
                                );
                              }),
                            ],
                          )
                        : loadingPayment(),
                  );
                }
              },
            )
          : Container(),
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

  Widget loadingPayment() {
    return Shimmer(
      gradient: LinearGradient(
        colors: [
          Color(0xFFE7E7E7),
          Color(0xFFF4F4F4),
          Color(0xFFE7E7E7),
        ],
        stops: [
          0.4,
          0.5,
          0.6,
        ],
        begin: Alignment(-1.0, -0.3),
        end: Alignment(1.0, 0.8),
        tileMode: TileMode.clamp,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: 3,
            itemBuilder: (context, index) => Column(
              children: [
                SizedBox(
                  height: SizeConfig.safeBlockHorizontal * 5 / 3.6,
                ),
                Divider(thickness: 1),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: Get.height * 0.02,
                      width: Get.width * 0.45,
                      color: Colors.grey,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      height: Get.height * 0.02,
                      width: Get.width * 0.1,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: Get.height * 0.06,
          ),
          Container(
            height: Get.height * 0.05,
            width: Get.width,
            color: Colors.grey[100],
          ),
        ],
      ),
    );
  }

  static void showPromoCodeDialog(BuildContext context, OkeRideController okeRideController) {
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
                                  okeRideController.setPromoCode(promoController.text);
                                  okeRideController.getCouponCode(promoController.text);
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

  Future<dynamic> dialog(OkeRideController okeRideController, BuildContext context) {
    return Get.dialog(
      AlertDialog(
        title: Text(
          'Masukkan Kode Kupon',
          style: TextStyle(
            fontSize: SizeConfig.safeBlockHorizontal * 3.8,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: promoController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                hintText: 'Contoh : KUPON17',
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
              height: Get.height * 0.05,
            ),
            Obx(
              () => okeRideController.isSubmitPromo.value
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
                            okeRideController.changeSubmitPromo(true);
                            Future.delayed(Duration(seconds: 3), () {
                              okeRideController.changeSubmitPromo(false);
                              okeRideController.setPromoCode(promoController.text);
                              okeRideController.getCouponCode(promoController.text);
                              Get.back();
                            });
                          },
                          child: Text(
                            'Masukkan',
                            style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal * 3.3,
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
}
