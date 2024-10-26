import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/auth/okecourier/okecourier_controller.dart';

import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/widgets/okecourier/loading_payment_shimmer.dart';
import 'package:okejek_flutter/widgets/okecourier/okecourier_payment_button.dart';
import 'package:okejek_flutter/widgets/stylish_dialog.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class OkeCourierPaymentPanel extends StatelessWidget {
  final PanelController pc;
  final TextEditingController namaPengirimController;
  final TextEditingController namaPenerimaController;
  final TextEditingController noHPPengirimController;
  final TextEditingController noHPPenerimaController;
  final TextEditingController detailBarangController;
  final TextEditingController beratBarangController;
  final TextEditingController biayaBarangController;

  OkeCourierPaymentPanel({
    Key? key,
    required this.pc,
    required this.detailBarangController,
    required this.namaPenerimaController,
    required this.namaPengirimController,
    required this.noHPPenerimaController,
    required this.noHPPengirimController,
    required this.beratBarangController,
    required this.biayaBarangController,
  }) : super(key: key);

  final OkeCourierController okeCourierController = Get.find();

  @override
  Widget build(BuildContext context) {
    print("Building OkeCourierPaymentPanel widget");
    debugPrint("note: ${okeCourierController.originLocation.value} ${okeCourierController.destinationLocation.value}");
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: SizeConfig.safeBlockVertical * 30 / 7.2,
            ),
            _buildInformation(
              color: OkejekTheme.primary_color,
              label: 'Pengirim',
              nama: namaPengirimController.text,
              noHP: noHPPengirimController.text,
              detailBarang: detailBarangController.text,
              alamat: okeCourierController.originLocation.value,
              beratBarang: double.tryParse(beratBarangController.text) ?? 0.0,
              hargaBarang: biayaBarangController.text,
            ),
            SizedBox(height: SizeConfig.safeBlockVertical * 30 / 7.2),
            _buildInformation(
              color: OkejekTheme.primary_color,
              label: 'Penerima',
              nama: namaPenerimaController.text,
              noHP: noHPPenerimaController.text,
              detailBarang: '',
              alamat: okeCourierController.destinationLocation.value,
              beratBarang: 0.0,
              hargaBarang: '',
            ),
            SizedBox(height: SizeConfig.safeBlockVertical * 10 / 7.2),
            AddNoteWidget(),
            SizedBox(
              height: SizeConfig.safeBlockVertical * 10 / 7.2,
            ),
            Divider(
              thickness: 1,
            ),
            SizedBox(
              height: SizeConfig.safeBlockVertical * 10 / 7.2,
            ),
            Obx(() => okeCourierController.isLoading.value
                ? LoadingPaymentShimmer()
                : OkeCourierPaymentButton(
                    namaPengirim: namaPengirimController.text,
                    noHPPengirim: noHPPengirimController.text,
                    noHPPenerima: noHPPenerimaController.text,
                    detailBarang: detailBarangController.text,
                    namaPenerima: namaPenerimaController.text,
                    beratBarang: double.tryParse(beratBarangController.text) ?? 0.0,
                    biayaBarang: biayaBarangController.text,
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildInformation({
    required Color color,
    required String label,
    required String nama,
    required String noHP,
    required String detailBarang,
    required String alamat,
    required double beratBarang,
    required String hargaBarang,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.location_on, color: color, size: 24),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: SizeConfig.safeBlockHorizontal * 4.5,
          ),
        ),
        subtitle: Text(
          nama,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: SizeConfig.safeBlockHorizontal * 3.8,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.phone, 'No. HP', noHP),
                SizedBox(height: 8),
                _buildInfoRow(Icons.location_city, 'Alamat', alamat),
                if (detailBarang.isNotEmpty) ...[
                  SizedBox(height: 8),
                  _buildInfoRow(Icons.inventory, 'Detail Barang', detailBarang),
                ],
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(Icons.scale, 'Berat', '${beratBarang.toStringAsFixed(1)} gr'),
                    ),
                    Expanded(
                      child: _buildInfoRow(Icons.attach_money, 'Harga', 'Rp.$hargaBarang'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: SizeConfig.safeBlockHorizontal * 3.2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: SizeConfig.safeBlockHorizontal * 3.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AddNoteWidget extends StatelessWidget {
  final OkeCourierController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        StylishDialogs.showAddNoteDialog(context, (note) {
          controller.addNote(note);
        });
      },
      child: Obx(() => Row(
            children: [
              Icon(
                controller.note.isEmpty ? Icons.add : Icons.edit_outlined,
                color: OkejekTheme.primary_color,
                size: 16,
              ),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  controller.note.isEmpty ? 'Tambah catatan' : controller.note.value,
                  style: TextStyle(
                    color: OkejekTheme.primary_color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

class PromoCodeWidget extends StatelessWidget {
  final OkeCourierController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Kode Promo : ',
          style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 3.3),
        ),
        TextButton(
          onPressed: () {
            print("masuk");
            controller.changeSubmitPromo(false);
            showPromoCodeDialog(context, controller);
          },
          child: Obx(() => Text(
                controller.promoCode.isEmpty ? 'Masukkan Kode Promo' : controller.promoCode.value,
                style: TextStyle(
                  fontSize: SizeConfig.safeBlockHorizontal * 3.3,
                  color: OkejekTheme.primary_color,
                ),
              )),
        ),
        if (controller.promoCode.value.isNotEmpty)
          IconButton(
            onPressed: () {
              controller.cancelPromo();
            },
            icon: Icon(
              Icons.close,
              size: 16,
              color: Colors.red,
            ),
          ),
      ],
    );
  }

  void showPromoCodeDialog(BuildContext context, OkeCourierController controller) {
    final promoController = TextEditingController();
    bool isLoading = false;

    showGeneralDialog(
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
                  ? Center(child: CircularProgressIndicator())
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
                            // onSubmit(promoController.text);
                            controller.changeSubmitPromo(true);
                            controller.setPromoCode(promoController.text);
                            controller.getCouponCode(promoController.text);
                            Get.back();
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
