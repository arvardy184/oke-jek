import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:okejek_flutter/controller/auth/okeshop/detail_order_controller.dart';
import 'package:okejek_flutter/controller/auth/okeshop/okeshop_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/widgets/shopping/detail%20shopping/shopping_destionation_address.dart';
import 'package:okejek_flutter/widgets/shopping/detail%20shopping/shopping_driver_note.dart';
import 'package:okejek_flutter/widgets/shopping/detail%20shopping/shopping_estimasi.dart';
import 'package:okejek_flutter/widgets/shopping/detail%20shopping/shopping_list_cart.dart';
import 'package:okejek_flutter/widgets/shopping/detail%20shopping/shopping_map_route.dart';
import 'package:okejek_flutter/widgets/shopping/detail%20shopping/shopping_payment_method.dart';
import 'package:okejek_flutter/widgets/shopping/detail%20shopping/shopping_pickup_address.dart';
import 'package:okejek_flutter/widgets/shopping/empty_cart_shopping.dart';

class DetailOrderShopPage extends StatelessWidget {
  final currencyFormatter = NumberFormat.currency(locale: 'ID', symbol: 'Rp', decimalDigits: 0);

  final Completer<GoogleMapController> _controller = Completer();

  CameraPosition _getInitialPosition(DetailOrderShopController detailShopController) {
    print(" getInitialPosition: ${detailShopController.originLat.value} ${detailShopController.originLng.value} ${detailShopController.destLat.value} ${detailShopController.destLng.value}");
    if(detailShopController.originLat.value != 0 && detailShopController.destLat.value != 0 && detailShopController.originLng.value != 0 && detailShopController.destLng.value != 0){
      double centerLat = (detailShopController.originLat.value + detailShopController.destLat.value) / 2;
      double centerLng = (detailShopController.originLng.value + detailShopController.destLng.value) / 2;
      return CameraPosition(
        target: LatLng(centerLat, centerLng),
        zoom: 12.0,
      );
    }else{
      return CameraPosition(
        target: LatLng(-7.9826145, 112.6286226),
        zoom: 12.0,
      );
    }
  }
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController destiController = TextEditingController();
  final TextEditingController promoController = TextEditingController();
  final TextEditingController driverNoteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    OkeShopController okeShopController = Get.find();
    DetailOrderShopController detailShopController = Get.find();

    print("dosp Building DetailOrderShopPage");
    print("dosp pickUplocation: ${detailShopController.pickUplocation.value}");
    print("dosp destLocation: ${detailShopController.destLocation.value}");
    print("dosp originLocation: ${detailShopController.originLocation.value}");
    print("dosp originLocationDetail: ${detailShopController.originLocationDetail.value}");
     
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'Detail Pesanan',
          style: TextStyle(
            fontFamily: OkejekTheme.font_family,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: SizeConfig.safeBlockHorizontal * 5,
          ),
        ),
      leading: IconButton(
          icon: Icon(Icons.arrow_back, color: OkejekTheme.primary_color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // daftar belanja
              okeShopController.dummyData.length == 0
                  ? Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: EmptyCartShopping(),
                    )
                  : listItem(context, okeShopController, detailShopController),
            ],
          ),
        ),
      ),
    );
  }
  

  Widget listItem(
      BuildContext context, OkeShopController okeShopcontroller, DetailOrderShopController detailShopController) {
        print("dospli Building listItem");
    print("dospli pickUplocation: ${detailShopController.pickUplocation.value}");
    print("dospli destLocation: ${detailShopController.destLocation.value}");
        // print(" detail shop controller: ${detailShopController.pickUplocation.value} detail shop controller: ${detailShopController.destLocation.value}");
    return Obx(
      (){  
        return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          detailShopController.pickUplocation.value.isNotEmpty && detailShopController.destLocation.value.isNotEmpty
              ? ShoppingMapRoute(kInitialPosition: _getInitialPosition(detailShopController), controller: _controller)
              : Container(),
          Padding(
            padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 20 / 3.6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // pickup
                ShoppigPickUpAddress(),

                Obx(
                  () => SizedBox(
                    height:
                        detailShopController.originLocation.value.isEmpty ? SizeConfig.safeBlockVertical * 20 / 7.2 : 0,
                  ),
                ),
                // destionation
                ShoppingDestinationAddress(),

                SizedBox(
                  height: Get.height * 0.05,
                ),
                Text(
                  'Daftar Belanja',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6,
                    color: Colors.black,
                  ),
                ),

                // item list
                ShoppingListCart(),

                // pesan untuk driver
                ShoppingDriverNote(),

                SizedBox(
                  height: SizeConfig.safeBlockHorizontal * 30 / 3.6,
                ),
                Divider(
                  thickness: 2,
                ),
                SizedBox(
                  height: SizeConfig.safeBlockHorizontal * 30 / 3.6,
                ),

                // total estimasi
                ShoppingEstimasi(currencyFormatter: currencyFormatter),

              
                // payment method
                ShoppingPaymentMethod(),
              ],
            ),
          ),
        ],
        );
      });
  }
}
