import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/ads_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/models/auth/ads_model.dart';
import 'package:okejek_flutter/pages/auth/okefood/detail_outlet_page.dart';
import 'package:okejek_flutter/pages/auth/okefood/search_food_page.dart';
import 'package:okejek_flutter/widgets/food/categories_menu.dart';
import 'package:okejek_flutter/widgets/food/recomendation_outlet.dart';

class OkeFoodPage extends StatelessWidget {
  final AdsController adsController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'OkeFood',
          style: TextStyle(
            fontFamily: OkejekTheme.font_family,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: SizeConfig.safeBlockHorizontal * 5,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            height: SizeConfig.blockSizeVertical * 2,
            width: SizeConfig.blockSizeHorizontal * 2,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.arrow_back,
                color: OkejekTheme.primary_color,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 5),
            child: Column(
              children: [
                // searchbar
                GestureDetector(
                  onTap: (){
                    Get.to(() => SearchFoodPage());
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        hintText: 'Cari resto...',
                        hintStyle: TextStyle(
                          fontSize: SizeConfig.safeBlockHorizontal * 3.3,
                          color: Colors.black38,
                          fontStyle: FontStyle.italic,
                        ),
                        prefixIcon: Icon(
                          Icons.search_outlined,
                          color: Colors.black54,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: SizeConfig.safeBlockVertical * 2.8, horizontal: SizeConfig.safeBlockHorizontal * 2.8),
                      ),
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: SizeConfig.safeBlockHorizontal * 3.3,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 3,
                ),
                // ads
                FutureBuilder<List<Ads>>(
                    future: adsController.getAdsBanner('food'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      } else {
                        if (snapshot.data!.length == 0) {
                          return SizedBox();
                        } else {
                          return CarouselSlider(
                            options: CarouselOptions(
                                height: Get.height * 0.15,
                                autoPlay: true,
                                autoPlayInterval: Duration(seconds: 5),
                                autoPlayAnimationDuration: Duration(milliseconds: 1000),
                                autoPlayCurve: Curves.fastOutSlowIn,
                                pauseAutoPlayOnTouch: true,
                                enlargeCenterPage: false,
                                viewportFraction: 1,
                                onPageChanged: (index, reason) {}),
                            items: snapshot.data!.map((item) {
                              return adsCard(context, item);
                            }).toList(),
                          );
                        }
                      }
                    }),

                SizedBox(
                  height: Get.height * 0.05,
                ),

                // all categories menu
                CategoriesMenu(),

                // food recommendation carousel
                RecomendationOutlet(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget adsCard(BuildContext context, Ads item) {
    return CachedNetworkImage(
      imageUrl: item.imageUrl,
      fit: BoxFit.cover,
      progressIndicatorBuilder: (context, url, progress) {
        return Container(
          width: Get.width,
          height: Get.height * 0.15,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text("Loading... data"),
        );
      },
      imageBuilder: (context, imageProvider) {
        return GestureDetector(
          onTap: () {
            print('hello there');
            print(item.foodVendor);
            Get.to(
              () => DetailOutletPage(
                foodVendor: item.foodVendor,
                type: item.foodVendor.type == 'food' ? 3 : 100,
              ),
            );
          },
          child: Container(
            width: Get.width,
            height: Get.height * 0.15,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget subtitle(String subtitle, bool showMore) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: SizeConfig.safeBlockHorizontal * 3.5,
          ),
        ),
        showMore
            ? TextButton(
                onPressed: () {
                  //{TODO}
                },
                child: Text(
                  'Lihat lebih',
                  style: TextStyle(
                    color: OkejekTheme.primary_color,
                    fontSize: SizeConfig.safeBlockHorizontal * 2.8,
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}
