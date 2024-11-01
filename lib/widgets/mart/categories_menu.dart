import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/auth/okemart/okemart_controller.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/models/auth/food/food_vendor_categories_model.dart';
import 'package:okejek_flutter/pages/auth/okefood/list_outlet_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';

/// menampilkan beberapa kategori yang ada pada food / mart
class CategoriesMenu extends StatelessWidget {
  final OkeMartController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowIndicator();
        return true;
      },
      child: FutureBuilder<List<FoodVendorCategories>>(
        future: controller.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: Get.height * 0.3,
              width: Get.width,
              child: SpinKitDoubleBounce(
                color: Color(0xFFE0675C),
                size: SizeConfig.blockSizeHorizontal * 50 / 3.6,
              ),
            );
          } else {
            List<FoodVendorCategories> categories = snapshot.data!;
            return categories.length == 0
                ? Container()
                : SizedBox(
                    width: Get.width,
                    height: Get.height * 0.4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kategori',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                          ),
                        ),
                        SizedBox(
                          height: Get.height * 0.04,
                        ),
                        Flexible(
                          child: GridView.builder(
                            itemCount: categories.length,
                            scrollDirection: Axis.horizontal,
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: SizeConfig.blockSizeHorizontal * 50,
                              childAspectRatio: 1.3 / 1,
                              crossAxisSpacing: 0,
                              mainAxisSpacing: 0,
                            ),
                            itemBuilder: (context, index) => categoryItem(categories[index]),
                          ),
                        ),
                      ],
                    ),
                  );
          }
        },
      ),
    );
  }

  Widget categoryItem(FoodVendorCategories categories) {
    return GestureDetector(
      onTap: () {
        controller.setSelectedCategoryId(categories.id);
        print(
          "category tapped: ${categories.name} with id: ${categories.id}",
        );
        Get.to(() => OkeFoodListOutletPage());
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Container(
              height: SizeConfig.blockSizeVertical * 10,
              width: SizeConfig.blockSizeHorizontal * 20,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(categories.imageUrl!),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) => Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
            SizedBox(
              height: Get.height * 0.01,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                categories.name,
                style: TextStyle(
                  fontSize: SizeConfig.safeBlockHorizontal * 2.7,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
