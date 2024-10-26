import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:okejek_flutter/controller/auth/okecourier/okecourier_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';

class ImprovedLocationPicker extends StatelessWidget {
  final bool isOriginSection;
  final OkeCourierController okeCourierController;
  final VoidCallback onTap;

  ImprovedLocationPicker({
    required this.isOriginSection,
    required this.okeCourierController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isOriginSection ? "Lokasi Pengambilan" : "Lokasi Pengiriman",
          style: TextStyle(
            color: OkejekTheme.primary_color,
            fontSize: SizeConfig.safeBlockHorizontal * 3.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: SizeConfig.safeBlockVertical * 1),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.safeBlockHorizontal * 4,
              vertical: SizeConfig.safeBlockVertical * 2,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
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
                Icon(
                  Icons.location_on_outlined,
                  color: isOriginSection ? OkejekTheme.primary_color : OkejekTheme.primary_color,
                  size: SizeConfig.safeBlockHorizontal * 6,
                ),
                SizedBox(width: SizeConfig.safeBlockHorizontal * 3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => _buildLocationText()),
                      SizedBox(height: SizeConfig.safeBlockVertical * 0.5),
                      // Obx(() => _buildDetailLocationText()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: SizeConfig.safeBlockVertical * 2),
      ],
    );
  }

  Widget _buildLocationText() {
    String text = isOriginSection
        ? okeCourierController.originLocation.value.isEmpty
            ? 'Pilih lokasi pengambilan...'
            : okeCourierController.originLocation.value
        : okeCourierController.destinationLocation.value.isEmpty
            ? 'Pilih lokasi pengiriman...'
            : okeCourierController.destinationLocation.value;

    return Text(
      text,
      style: TextStyle(
        color: text.contains('Pilih') ? Colors.grey[400] : Colors.black87,
        fontWeight: text.contains('Pilih') ? FontWeight.normal : FontWeight.w600,
        fontSize: SizeConfig.safeBlockHorizontal * 3.8,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  // Widget _buildDetailLocationText() {
  //   String detailText = isOriginSection
  //       ? okeCourierController.originDetailLocation.value
  //       : okeCourierController.destinationDetailLocation.value;

  //   if (detailText.isEmpty) {
  //     return Text(
  //       isOriginSection ? 'Tambahkan detail alamat' : 'Tambahkan detail tujuan',
  //       style: TextStyle(
  //         color: Colors.grey[400],
  //         fontSize: SizeConfig.safeBlockHorizontal * 3.5,
  //         fontStyle: FontStyle.italic,
  //       ),
  //     );
  //   } else {
  //     return Text(
  //       detailText,
  //       style: TextStyle(
  //         color: Colors.black54,
  //         fontSize: SizeConfig.safeBlockHorizontal * 3.5,
  //       ),
  //       maxLines: 1,
  //       overflow: TextOverflow.ellipsis,
  //     );
  //   }
  // }
}