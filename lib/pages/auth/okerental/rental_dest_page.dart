import 'package:get/get.dart';
import 'package:okejek_flutter/controller/auth/okerental/okerental_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/pages/auth/okerental/map_dest_rental_page.dart';
import 'package:flutter/material.dart';

class RentalDestinationAddress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   OkeRentController  Controller = Get.find();
    return GestureDetector(
      onTap: () {
        print("on tap destination address");
        Get.to(() => MapDestinationRentalPage());
      },
      child: Row(
        children: [
          Icon(
            Icons.pin_drop_outlined,
            color: OkejekTheme.primary_color,
          ),
          SizedBox(
            width: SizeConfig.safeBlockHorizontal * 20 / 3.6,
          ),
          Obx(
            () => Container(
              height:  Controller.destLocation.value.isEmpty ? Get.height * 0.06 : Get.height * 0.12,
              width: Get.width * 0.75,
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),  offset: Offset(0, 3))],
                borderRadius: BorderRadius.circular(SizeConfig.safeBlockHorizontal * 10 / 3.6),
                color:  Controller.destLocation.value.isEmpty ? Colors.grey[50] : Colors.white,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: SizeConfig.safeBlockHorizontal * 20 / 3.6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () =>  Controller.destLocation.value.isEmpty
                          ? SizedBox()
                          : Text(
                               Controller.destLocation.value,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6,
                                color: Colors.black,
                                overflow: TextOverflow.ellipsis,
                              ),
                              softWrap: true,
                              maxLines: 1,
                              textAlign: TextAlign.start,
                            ),
                    ),
                    Obx(
                      () => Text(
                         Controller.destLocation.value.isEmpty
                            ? 'Tentukan lokasi pengantaran'
                            :  Controller.destLocationDetail.value,
                        style: TextStyle(
                          fontSize: SizeConfig.safeBlockHorizontal * 10 / 3.6,
                          color: Colors.black45,
                          overflow: TextOverflow.ellipsis,
                        ),
                        softWrap: true,
                        maxLines: 1,
                        textAlign: TextAlign.start,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => print('tambahkan catatan'),
                      child: Obx(
                        () =>  Controller.destLocationDetail.isEmpty &&
                                 Controller.destLocation.isNotEmpty
                            ? Row(
                                children: [
                                  Icon(
                                    Icons.post_add,
                                    color: Colors.grey,
                                    size: SizeConfig.safeBlockHorizontal * 15 / 3.6,
                                  ),
                                  SizedBox(
                                    width: SizeConfig.safeBlockHorizontal * 10 / 3.6,
                                  ),
                                  Text(
                                    'Tambah detail alamat',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: SizeConfig.safeBlockHorizontal * 10 / 3.6,
                                    ),
                                  )
                                ],
                              )
                            : Container(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
