import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/auth/okerental/okerental_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';

class RentalPayment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final OkeRentController okeRentalController = Get.find();
     
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          thickness: 2,
        ),
        SizedBox(
          height: SizeConfig.safeBlockVertical * 20 / 7.2,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kurir',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 10 / 3.6,
              ),
            ),
            Text(
              'Rp6.000',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 10 / 3.6,
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
              'OkeExpress',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 10 / 3.6,
              ),
            ),
            Text(
              'Rp15.000',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 10 / 3.6,
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
              'Diskon',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 10 / 3.6,
              ),
            ),
            Text(
              'Rp5.000',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 10 / 3.6,
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
              'Kupon',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 10 / 3.6,
              ),
            ),
            Text(
              'KIRIMTERUS',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 10 / 3.6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(
          height: SizeConfig.safeBlockVertical * 20 / 7.2,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: SizeConfig.safeBlockVertical * 40 / 7.2,
              width: SizeConfig.safeBlockHorizontal * 150 / 3.6,
              decoration: BoxDecoration(
                border: Border.all(
                  color: OkejekTheme.primary_color,
                ),
                borderRadius: BorderRadius.circular(SizeConfig.safeBlockHorizontal * 10 / 3.6),
              ),
              child: Center(
                child: Text(
                  'Tambahkan Kupon',
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 10 / 3.6,
                    color: OkejekTheme.primary_color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
              'Total',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 10 / 3.6,
              ),
            ),
            Text(
              'Rp16.000',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 10 / 3.6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(
          height: SizeConfig.safeBlockVertical * 20 / 7.2,
        ),
        Divider(
          thickness: 2,
        ),
        SizedBox(
          height: SizeConfig.safeBlockVertical * 20 / 7.2,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Metode Pembayaran',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 10 / 3.6,
                fontWeight: FontWeight.bold,
              ),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: Text(
                  'Pilih Metode',
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 3.3,
                  ),
                ),
                onTap: () => okeRentalController.queryAppsinstalled(),
                iconEnabledColor: OkejekTheme.primary_color,
                style: TextStyle(
                  color: OkejekTheme.primary_color,
                  fontSize: SizeConfig.safeBlockHorizontal * 3.3,
                ),
                value: okeRentalController.dropDownValue.value,
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
                  okeRentalController.setDropdownValue(value!);
                },
              ),
            ),
          ],
        ),
        SizedBox(
          height: SizeConfig.safeBlockVertical * 100 / 7.2,
        ),
      ],
    );
  }
}
