import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/auth/okecourier/okecourier_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';

class OkeCourierPanelDetailAddress extends StatelessWidget {
  OkeCourierPanelDetailAddress({
    required this.isOriginSection,
    required this.okeCourierController,
  });

  final bool isOriginSection;
  final OkeCourierController okeCourierController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        height: SizeConfig.safeBlockVertical * 60 / 7.2,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isOriginSection
              ? okeCourierController.originLocation.value.isEmpty
                  ? Colors.white
                  : Colors.white
              : okeCourierController.destinationLocation.value.isEmpty
                  ? Colors.white
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
           boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
        ),
        child: Row(
          children: [
            _buildLocationIcon(),
            SizedBox(
              width: SizeConfig.safeBlockHorizontal * 10 / 3.6,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => _buildLocationText(),
                  ),
                  Obx(
                    () => isOriginSection
                        ? okeCourierController.originLocation.value.isEmpty
                            ? SizedBox()
                            : SizedBox(
                                height: SizeConfig.safeBlockVertical * 5 / 7.2,
                              )
                        : okeCourierController.destinationDetailLocation.value.isEmpty
                            ? SizedBox()
                            : SizedBox(
                                height: SizeConfig.safeBlockVertical * 5 / 7.2,
                              ),
                  ),
                  Obx(
                    () => isOriginSection
                        ? okeCourierController.originLocation.isEmpty
                            ? SizedBox()
                            : okeCourierController.originDetailLocation.value.isEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      print('tambahkan alamat detail');
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.post_add,
                                          size: 15,
                                          color: Colors.black54,
                                        ),
                                        SizedBox(
                                          width: SizeConfig.safeBlockHorizontal * 10 / 7.2,
                                        ),
                                        Text(
                                          'Tambahkan detail alamat disini',
                                          style: TextStyle(
                                            color: Colors.black45,
                                            fontSize: SizeConfig.safeBlockHorizontal * 10 / 3.6,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  )
                                : Expanded(
                                  child: Text(
                                      okeCourierController.originDetailLocation.value,
                                      style: TextStyle(
                                        color: Colors.black45,
                                        fontSize: SizeConfig.safeBlockHorizontal * 10 / 3.6,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                )
                        : okeCourierController.destinationLocation.isEmpty
                            ? SizedBox()
                            : okeCourierController.destinationDetailLocation.value.isEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      print('tambahkan tujuan alamat detail');
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.post_add,
                                          size: 15,
                                          color: Colors.black54,
                                        ),
                                        SizedBox(
                                          width: SizeConfig.safeBlockHorizontal * 10 / 7.2,
                                        ),
                                        Text(
                                          'Tambahkan detail tujuan disini',
                                          style: TextStyle(
                                            color: Colors.black45,
                                            fontSize: SizeConfig.safeBlockHorizontal * 10 / 3.6,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  )
                                : Expanded(
                                  child: Text(
                                      okeCourierController.destinationDetailLocation.value,
                                      style: TextStyle(
                                        color: Colors.black45,
                                        fontSize: SizeConfig.safeBlockHorizontal * 10 / 3.6,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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

  Widget _buildLocationText() {
    String text = isOriginSection
        ? okeCourierController.originLocation.value.isEmpty
            ? 'Pilih Lokasi...'
            : okeCourierController.originLocation.value
        : okeCourierController.destinationLocation.value.isEmpty
            ? 'Pilih Tujuan...'
            : okeCourierController.destinationLocation.value;

    return Text(
      text,
      style: TextStyle(
        color: text.contains('Pilih') ? Colors.black45 : OkejekTheme.primary_color,
        fontWeight: text.contains('Pilih') ? FontWeight.normal : FontWeight.bold,
        fontSize: SizeConfig.safeBlockHorizontal * (text.contains('Pilih') ? 10 : 12) / 3.6,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLocationIcon() {
    return Icon(
      Icons.location_on_outlined,
      color: isOriginSection ? OkejekTheme.primary_color : OkejekTheme.primary_color,
    );
  }
}
