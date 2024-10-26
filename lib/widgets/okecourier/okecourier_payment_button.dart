
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:okejek_flutter/controller/auth/okecourier/okecourier_controller.dart';
import 'package:okejek_flutter/controller/okeride_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/widgets/okecourier/okecourier_payment_panel.dart';

class OkeCourierPaymentButton extends StatelessWidget {
  final String namaPengirim;
  final String noHPPengirim;
  final String namaPenerima;
  final String noHPPenerima;
  final String detailBarang;
  final double beratBarang;
  final String biayaBarang;

  OkeCourierPaymentButton({
    Key? key,
    required this.namaPengirim,
    required this.noHPPengirim,
    required this.namaPenerima,
    required this.noHPPenerima,
    required this.detailBarang,
    required this.beratBarang,
    required this.biayaBarang,
  }): super(key: key);


  final OkeRideController okeRideController = Get.put(OkeRideController());
  final OkeCourierController okeCourierController = Get.find();
  final currencyFormatter = NumberFormat.currency(locale: 'ID', symbol: 'Rp', decimalDigits: 0);
  @override
  Widget build(BuildContext context) {
     
    return Column(
      children: [
        SizedBox(height: SizeConfig.safeBlockVertical * 20 / 7.2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ongkir : ',
              style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 3.3),
            ),
            Text(
              currencyFormatter.format(okeCourierController.ongkir.value),
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 3.89,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(
          height: SizeConfig.safeBlockVertical * 20 / 7.2,
        ),
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
                      value: okeRideController.dropDownValue.value,
                       items: okeRideController.dropDownValueList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
                      onChanged: (value) {
                        okeRideController.setDropdownValue(value);
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
          () => FutureBuilder<bool>(
            future: okeRideController.queryAppsinstalled(),
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if(snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                bool isInstalled = snapshot.data ?? false;
                return isInstalled ? SizedBox() : _buildWarning();
              }
         
            },
          ),
        ),
        PromoCodeWidget(),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Text(
        //       'Kode Promo : ',
        //       style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 3.3),
        //     ),
        //      TextButton(
        //                               onPressed: () {
        //                                 okeCourierController.changeSubmitPromo(false);
        //                                 dialog(okeCourierController, context);
        //                               },
        //                               child: Obx(
        //                                 () => Text(
        //                                 okeCourierController.promoCode.value.isEmpty
        //                                       ? 'Masukkan Kode Promo'
        //                                       : okeCourierController.promoCode.value,
        //                                   style: TextStyle(
        //                                     fontSize: SizeConfig.safeBlockHorizontal * 3.3,
        //                                     color: OkejekTheme.primary_color,
        //                                   ),
        //                                 ),
        //                               ),
        //                             ),
        //   ],
        // ),
        SizedBox(height: SizeConfig.safeBlockVertical * 1.3),
        ElevatedButton(
          onPressed: () {
            // okeCourierController.createOrder(senderName: okeCourierController., senderPhone: senderPhone, recipientName: recipientName, recipientPhone: recipientPhone, itemDetail: itemDetail, weight: weight, itemAmount: itemAmount)
            print(okeCourierController.originLat);
            print(okeCourierController.originLng);
            print(okeCourierController.originLocation);
            print(okeCourierController.destinationLat);
            print(okeCourierController.destinationLng);
            print(okeCourierController.destinationLocation);
            print("berapa oke courier ${namaPenerima} ${noHPPenerima} ${namaPengirim} ${noHPPengirim} ${detailBarang} ${beratBarang} ${biayaBarang}");
            okeCourierController.createOrder(senderName: namaPengirim, senderPhone: noHPPengirim, recipientName: namaPenerima, recipientPhone: noHPPenerima, itemDetail: detailBarang,weight: beratBarang, itemAmount: biayaBarang);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, SizeConfig.safeBlockVertical * 5.2), backgroundColor: OkejekTheme.primary_color,
          ),
          child: Text(
            'Pesan Sekarang',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: SizeConfig.safeBlockHorizontal * 3.8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarning(){
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: OkejekTheme.primary_color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Icon(Icons.warning,size: 20, color: OkejekTheme.primary_color),
        SizedBox(width: 8),
        Expanded(child: 
        Text(
          "Aplikasi ${okeRideController.dropDownValue.value} belum terinstall",
          style: TextStyle(
            color: OkejekTheme.primary_color,
          )
        ))
      ],),
    );
  }
    Future<dynamic> dialog(OkeCourierController okeCourierController, BuildContext context) {
      TextEditingController promoController = TextEditingController();
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
              () => okeCourierController.isSubmitPromo.value
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
                           okeCourierController.changeSubmitPromo(true);
                            Future.delayed(Duration(seconds: 3), () {
                              okeCourierController.changeSubmitPromo(false);
                              okeCourierController.setPromoCode(promoController.text);
                              Get.back();
                              // showSnackbar(context);
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
  
  // showSnackbar(BuildContext context) {
  //   ScaffoldMessenger.of(Get.context!).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         'Rating telah diberikan',
  //         style: TextStyle(
  //           fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6,
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
