import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/okecar_controller.dart';
import 'package:okejek_flutter/defaults/size_config.dart';

/// Widget untuk melihat beberapa layanan yang tersedia pada okeCar.
/// 1. RIDE
/// 2. CAR
/// 3. TRIKE
class ServiceFloatingButton extends StatelessWidget {
  final OkeCarController okeCarController = Get.find();

  @override
  Widget build(BuildContext context) {
     
    return Obx(() {
      print(okeCarController.preload);
      Future.delayed(Duration(milliseconds: 1800), () {
        okeCarController.preload.value = false;
      });
      return AnimatedPositioned(
        duration: Duration(milliseconds: 500),
        bottom: okeCarController.preload.value ? -350 : 0,
        right: 10, // top: 10,
        child: Padding(
          padding: EdgeInsets.only(
            right: SizeConfig.safeBlockVertical * 1.5,
            bottom: okeCarController.originLocation.isNotEmpty && okeCarController.destLocation.isNotEmpty
                ? Get.height * 0.68
                : Get.height * 0.3,
          ),
          child: SpeedDial(
            backgroundColor: Colors.white,
            visible: true,
            overlayColor: Colors.black,
            overlayOpacity: 0.4,
            spacing: SizeConfig.safeBlockHorizontal * 10 / 3.6,
            // buttonSize: SizeConfig.safeBlockHorizontal * 50 / 3.6,
            buttonSize: Size(SizeConfig.safeBlockHorizontal * 11.11, SizeConfig.safeBlockHorizontal * 11.11),
            child: Obx(
              () => Container(
                height: SizeConfig.safeBlockVertical * 11.11,
                width: SizeConfig.safeBlockVertical * 11.11,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: okeCarController.currentService.value == 'Mobil'
                      ? AssetImage('assets/icons/10-2021/car.png')
                       
                        : okeCarController.currentService.value == 'Ojek'
                            ? AssetImage('assets/icons/10-2021/ride.png')
                            : AssetImage('assets/icons/10-2021/trike.png'),
                  ),
                ),
              ),
            ),
            children: [
              // ojek
              SpeedDialChild(
                child: Container(
                  height: SizeConfig.safeBlockVertical * 11.11,
                  width: SizeConfig.safeBlockVertical * 11.11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/icons/10-2021/ride.png'),
                    ),
                  ),
                ),
                backgroundColor: Colors.white,
                onTap: () {
                  okeCarController.changeService('Ojek');
                  okeCarController.orderType.value = 0;
                  okeCarController.getNearestDriver();
                },
                label: 'Ojek',
                labelStyle: TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.black, fontSize: SizeConfig.safeBlockHorizontal * 3.3),
                labelBackgroundColor: Colors.white,
              ),
              // car
              SpeedDialChild(
                child: Container(
                  height: SizeConfig.safeBlockVertical * 11.11,
                  width: SizeConfig.safeBlockVertical * 11.11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/icons/10-2021/car.png'),
                    ),
                  ),
                ),
                backgroundColor: Colors.white,
                onTap: () {
                  okeCarController.changeService('Mobil');
                  okeCarController.orderType.value = 4;
                  okeCarController.getNearestDriver();
                },
                label: 'Mobil',
                labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.black, fontSize: 12.0),
                labelBackgroundColor: Colors.white,
              ),

              //roda tiga
              // SpeedDialChild(
              //   child: Container(
              //     height: SizeConfig.safeBlockVertical * 11.11,
              //     width: SizeConfig.safeBlockVertical * 11.11,
              //     decoration: BoxDecoration(
              //       shape: BoxShape.circle,
              //       image: DecorationImage(
              //         image: AssetImage('assets/icons/10-2021/trike.png'),
              //       ),
              //     ),
              //   ),
              //   backgroundColor: Colors.white,
              //   onTap: () {
              //     okeCarController.changeService('Roda 3');
              //     okeCarController.orderType.value = 102;
              //     okeCarController.getNearestDriver();
              //   },
              //   label: 'Roda 3',
              //   labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.black, fontSize: 12.0),
              //   labelBackgroundColor: Colors.white,
              // ),
            ],
          ),
        ),
      );
    });
  }
}
