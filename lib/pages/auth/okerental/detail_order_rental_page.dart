

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/auth/okerental/okerental_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:intl/intl.dart';
import 'package:okejek_flutter/pages/auth/okerental/rental_dest_page.dart';

class DetailOrderRentalPage extends StatelessWidget {
  final OkeRentController okeRentalController = Get.find();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Pesan Rental Oke Car'),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Obx(() {
          final selectedPackage = okeRentalController.selectedPackage.value;
          
          okeRentalController.getNearestDriver();
          if (selectedPackage == null) {
            return Center(
              child: Text("Tidak ada paket yang dipilih"),
            );
          }
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPackageCard(),
                  SizedBox(height: SizeConfig.safeBlockVertical * 2),
                  Center(
                    child: Text(
                      'Info',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Center(
                    child: Text(
                      okeRentalController.selectedPackage.value?.name ?? '',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: SizeConfig.safeBlockVertical * 2),
                  Text('Lokasi Penjemputan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                 SizedBox(height: SizeConfig.safeBlockVertical * 2),
                  _buildLocationPicker(),
                  SizedBox(height: SizeConfig.safeBlockVertical * 2),
                  _buildCouponButton(context),
                  SizedBox(height: SizeConfig.safeBlockVertical * 2),
                  Text('Pilih Metode Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  _buildPaymentMethodDropdown(),
                  SizedBox(height: SizeConfig.safeBlockVertical * 4),
                  _buildOrderButton(),
                ],
              ),
            ),
          );
        }));
  }

  Widget _buildPackageCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(okeRentalController.selectedPackage.value?.name ?? '',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                      .format(okeRentalController.selectedPackage.value?.price ?? 0),
                  style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text('${okeRentalController.selectedPackage.value?.pricings?[0].duration ?? 0} Menit',
            overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPicker() {
    return RentalDestinationAddress();
  }

  Widget _buildCouponButton(BuildContext context) {
    return TextButton.icon(
      icon: Icon(Icons.local_offer, color: OkejekTheme.primary_color),
      label: Text('Tambahkan Kupon', style: TextStyle(color: OkejekTheme.primary_color)),
      onPressed: () {
        // Implementasi penambahan kupon
        okeRentalController.changeSubmitPromo(false);
        showPromoCodeDialog(context, okeRentalController);
                                      // dialog(okeRentalController, context);
           
      },
    );
  }

   static void showPromoCodeDialog(BuildContext context,OkeRentController okeRentalController) {
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

                                okeRentalController.changeSubmitPromo(true);
                            Future.delayed(Duration(seconds: 3), () {
                              okeRentalController.changeSubmitPromo(false);
                              okeRentalController.getCouponCode(promoController.text);
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


  Widget _buildPaymentMethodDropdown() {
    return Obx(() => Card(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.safeBlockHorizontal * 4),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: okeRentalController.dropDownValue.value,
                hint: Text('Pilih Metode'),
                items: <String>['Cash', 'OkePoint'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  okeRentalController.setDropdownValue(value!);
                },
              ),
            ),
          ),
        ));
  }

  Widget _buildOrderButton() {
    return SizedBox(
      width: Get.width * 0.8,
      child: ElevatedButton(
        child: okeRentalController.isLoading.value
        ? CircularProgressIndicator()
        : Text('Buat Pesanan Rental'),
        style: ElevatedButton.styleFrom(
          backgroundColor: OkejekTheme.primary_color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical * 2),
        ),
        onPressed: () {
          okeRentalController.createRentalOrder();
          // Implementasi pembuatan pesanan
          print("cek value ${okeRentalController.destLat.value},${okeRentalController.destLng.value} ${okeRentalController.destLocation.value}  ${okeRentalController.destLocation.value}");
          print('${okeRentalController.destLat.value},${okeRentalController.destLng.value}');
          print('${okeRentalController.destLocation.value}');
          print('${okeRentalController.dropDownValue.value}');
          print('${okeRentalController.selectedPackage.value?.name}');
          print('${okeRentalController.isSubmitPromo.value}');
          print('${okeRentalController.promoCode.value}');
          print('${okeRentalController.destLocationDetail.value}');
          print('${okeRentalController.destLocation.value}');
          print('${okeRentalController.driverNote.value}');
          print('${okeRentalController.destinationAddressDetail.value}');
        },
      ),
    );
  }
}
