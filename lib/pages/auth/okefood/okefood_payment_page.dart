import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:okejek_flutter/controller/auth/okefood/detail_outlet_controller.dart';
import 'package:okejek_flutter/controller/auth/okefood/okefood_payment_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/models/auth/food/food_vendor_model.dart';
import 'package:okejek_flutter/widgets/food/food_payment.dart';
import 'package:okejek_flutter/widgets/food/cart_list.dart';
import 'package:okejek_flutter/widgets/food/detail_outlet_payment.dart';

class OkeFoodPaymentPage extends StatelessWidget {
  final int type;
  final FoodVendor foodVendor;
  final int totalBelanja;
  final currencyFormatter = NumberFormat.currency(locale: 'ID', symbol: 'Rp', decimalDigits: 0);
  final TextEditingController driverNoteController = TextEditingController();

  OkeFoodPaymentPage({
    required this.totalBelanja,
    required this.foodVendor,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    // parsing outlet lat lng to double
    final outletLatLng = foodVendor.latlng.split(",");
    double outletLat = double.parse(outletLatLng[0]);
    double outletLng = double.parse(outletLatLng[1]);

    DetailOutletController outletController = Get.find();
    OkefoodPaymentController foodPaymentController = Get.put(OkefoodPaymentController(
      outletLat: outletLat,
      outletLng: outletLng,
      totalBelanja: totalBelanja,
    ));
     
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'Rincian Pesanan',
          style: TextStyle(
            fontFamily: OkejekTheme.font_family,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: SizeConfig.safeBlockHorizontal * 5,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: SizeConfig.safeBlockVertical * 5.3,
            width: SizeConfig.safeBlockHorizontal * 11.11,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.arrow_back,
                color: OkejekTheme.primary_color,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 5.56),
            child: outletController.cartQtyMap.length == 0
                ? SizedBox()
                : itemList(outletController, foodPaymentController, context),
          ),
        ),
      ),
    );
  }

  Widget itemList(
      DetailOutletController outletController, OkefoodPaymentController foodPaymentController, BuildContext context) {
    return Column(
      children: [
        // outlet information
        Container(
          width: Get.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DetailOutletPayment(addressOutlet: foodVendor.address, nameOutlet: foodVendor.name),
              CartList(),

              // pesan driver
              Obx(
                () => ListView(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  reverse: true,
                  children: [
                    foodPaymentController.driverNote.value.isEmpty
                        ? TextButton(
                            onPressed: () {
                              driverNoteDialog(foodPaymentController, context);
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  color: OkejekTheme.primary_color,
                                  size: SizeConfig.safeBlockHorizontal * 4.1,
                                ),
                                SizedBox(
                                  width: SizeConfig.safeBlockHorizontal * 2.78,
                                ),
                                Text(
                                  'Pesan untuk driver',
                                  style: TextStyle(
                                    color: OkejekTheme.primary_color,
                                    fontSize: SizeConfig.safeBlockHorizontal * 2.78,
                                  ),
                                )
                              ],
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              driverNoteDialog(foodPaymentController, context);
                            },
                            child: Container(
                              height: Get.height * 0.07,
                              width: Get.width,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: SizeConfig.safeBlockHorizontal * 2.64),
                                      child: Obx(
                                        () => Text(
                                          foodPaymentController.driverNote.value,
                                          style: TextStyle(
                                            fontSize: SizeConfig.safeBlockHorizontal * 3.33,
                                            color: Colors.black54,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      driverNoteController.clear();
                                      foodPaymentController.setDriverNote('');
                                    },
                                    icon: Icon(
                                      Icons.close_outlined,
                                      size: SizeConfig.safeBlockHorizontal * 4.167,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                  ].reversed.toList(),
                ),
              ),
              SizedBox(
                height: SizeConfig.safeBlockVertical * 3.96,
              ),
              Divider(
                thickness: 2,
              ),
              SizedBox(
                height: SizeConfig.safeBlockVertical * 3.96,
              ),
              FoodPayment(
                type: type,
                foodVendor: foodVendor,
              ),
            ],
          ),
        ),
      ],
    );
  }
  Future<dynamic> driverNoteDialog(OkefoodPaymentController foodPaymentController, BuildContext context) {
 return  showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black45,
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) => AlertDialog(
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
                'Tambah Catatan',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: OkejekTheme.primary_color,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: driverNoteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Masukkan catatan di sini...',
                  fillColor: Colors.grey[100],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: OkejekTheme.primary_color, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: Text('Batal'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black87, backgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // onSave(noteController.text);
                   
                    if (driverNoteController.text.isBlank!) {
                      Get.back();
                    } else {
                      foodPaymentController.setDriverNote(driverNoteController.text);
                      Get.back();
                    }
                    },
                    child: Text('Simpan'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: OkejekTheme.primary_color,
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
}
