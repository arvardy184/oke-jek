import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/auth/okefood/okefood_controller.dart';
import 'package:okejek_flutter/controller/auth/store/store_controller.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/models/auth/food/food_vendor_model.dart';

class CustomSliverDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final FoodVendor foodVendor;
  final bool hideTitleWhenExpanded;

  OkeFoodController okeFoodController = Get.find();
  StoreController storeController = Get.find();

  CustomSliverDelegate({
    required this.foodVendor,
    required this.expandedHeight,
    this.hideTitleWhenExpanded = true,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final appBarSize = expandedHeight - shrinkOffset;
    final cardTopPosition = expandedHeight / 2 - shrinkOffset;
    final proportion = 2 - (expandedHeight / appBarSize);
    final percent = proportion < 0 || proportion > 1 ? 0.0 : proportion;

    return Container(
      height: expandedHeight + expandedHeight / 2,
      child: Stack(
        children: [
          _buildAppBar(appBarSize, percent),
          _buildCard(cardTopPosition, percent),
        ],
      ),
    );
  }

  Widget _buildAppBar(double appBarSize, double percent) {
    return Container(
      height: appBarSize < SizeConfig.safeBlockHorizontal * 60 / 3.6
          ? SizeConfig.safeBlockHorizontal * 60 / 3.6
          : appBarSize,
      child: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search, color: Colors.white),
          )
        ],
        flexibleSpace: Opacity(
          opacity: percent,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Good_Food_Display_-_NCI_Visuals_Online.jpg/330px-Good_Food_Display_-_NCI_Visuals_Online.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        elevation: 0.0,
        title: Opacity(
          opacity: hideTitleWhenExpanded ? 1.0 - percent : 1.0,
          child: Text(
            foodVendor.name,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(double cardTopPosition, double percent) {
    return Positioned(
      left: 0.0,
      right: 0.0,
      top: cardTopPosition > 0 ? cardTopPosition : 0,
      bottom: 0.0,
      child: Opacity(
        opacity: percent,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.safeBlockHorizontal * 20 / 3.6,
            vertical: SizeConfig.safeBlockHorizontal * 20 / 3.6,
          ),
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodVendor.name,
                    style: TextStyle(
                      fontSize: foodVendor.name.length > 25 ? 18 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.black38),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          foodVendor.address,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Divider(color: Colors.grey[300]),
                  // SizedBox(height: 16),
                  storeController.isStoreOpen(foodVendor) ? _openHours() : _closed(),
                
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _closed() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.red,
          ),
          child: Text(
            'Closed',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        SizedBox(width: 12),
        if (!foodVendor.closed)
          Expanded(
            child: Text(
              'Opens at ${storeController.storeOpenHour.toString().padLeft(2, '0')}:${storeController.storeOpenMinutes.toString().padLeft(2, '0')}',
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
      ],
    );
  }

  Widget _openHours() {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.green,
            ),
            child: Text(
              'Open',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          SizedBox(width: 10),
          Flexible(
            child: Row(
              children: [
                Icon(Icons.access_time_outlined, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  storeController.store24Hours.value ? 'Open 24 Hours' : _getSchedule(),
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSchedule() {
    String openHour = storeController.storeOpenHour.value.toString().padLeft(2, '0');
    String openMinutes = storeController.storeOpenMinutes.value.toString().padLeft(2, '0');
    String closeHour = storeController.storeCloseHour.value.toString().padLeft(2, '0');
    String closeMinutes = storeController.storeCloseMinutes.value.toString().padLeft(2, '0');
    return '$openHour:$openMinutes - $closeHour:$closeMinutes';
  }

  @override
  double get maxExtent => expandedHeight + expandedHeight / 2;

  @override
  double get minExtent => SizeConfig.safeBlockHorizontal * 60 / 3.6;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}