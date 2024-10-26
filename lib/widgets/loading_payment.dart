  import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:shimmer/shimmer.dart';

Widget loadingPayment() {
    return Shimmer(
      gradient: LinearGradient(
        colors: [
          Color(0xFFE7E7E7),
          Color(0xFFF4F4F4),
          Color(0xFFE7E7E7),
        ],
        stops: [
          0.4,
          0.5,
          0.6,
        ],
        begin: Alignment(-1.0, -0.3),
        end: Alignment(1.0, 0.8),
        tileMode: TileMode.clamp,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: 3,
            itemBuilder: (context, index) => Column(
              children: [
                SizedBox(
                  height: SizeConfig.safeBlockHorizontal * 5 / 3.6,
                ),
                Divider(thickness: 1),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: Get.height * 0.02,
                      width: Get.width * 0.45,
                      color: Colors.grey,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      height: Get.height * 0.02,
                      width: Get.width * 0.1,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: Get.height * 0.06,
          ),
          Container(
            height: Get.height * 0.05,
            width: Get.width,
            color: Colors.grey[100],
          ),
        ],
      ),
    );
  }