
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/ads_controller.dart';
import 'package:okejek_flutter/controller/auth/okemart/okemart_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/models/auth/ads_model.dart';
import 'package:okejek_flutter/pages/auth/okemart/detail_outlet_mart_page.dart';
import 'package:okejek_flutter/pages/auth/okemart/search_food_page.dart';
import 'package:okejek_flutter/widgets/mart/mart_categories.dart';
import 'package:okejek_flutter/widgets/mart/recomendation_mart.dart';

class OkeMartPage extends StatelessWidget {
  final OkeMartController okeMartController = Get.put(OkeMartController());
  final AdsController adsController = Get.find();
  final RxInt currentBannerIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Implement refresh logic
            await Future.delayed(Duration(seconds: 1));
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  SizedBox(height: SizeConfig.blockSizeVertical * 3),
                  _buildAdsCarousel(),
                  SizedBox(height: Get.height * 0.03),
                  // _buildQuickFilters(),
                  SizedBox(height: Get.height * 0.03),
                  MartCategories(),
                  RecommendationMart(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0.0,
      centerTitle: true,
      title: Text(
        'OkeMart',
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
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back,
            color: OkejekTheme.primary_color,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return InkWell(
      onTap: () => Get.to(() => SearchFoodPage()),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_outlined,
              color: Colors.grey[600],
            ),
            SizedBox(width: 12),
            Text(
              'Cari outlet...',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 3.3,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdsCarousel() {
    return FutureBuilder<List<Ads>>(
      future: adsController.getAdsBanner('mart'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCarouselShimmer();
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox();
        }

        return Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: Get.height * 0.15,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 5),
                autoPlayAnimationDuration: Duration(milliseconds: 1000),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                viewportFraction: 0.92,
                onPageChanged: (index, reason) {
                  currentBannerIndex.value = index;
                },
              ),
              items: snapshot.data!.map((item) => _buildAdsCard(item)).toList(),
            ),
            SizedBox(height: 12),
            _buildCarouselIndicator(snapshot.data!.length),
          ],
        );
      },
    );
  }

  Widget _buildCarouselShimmer() {
    return Container(
      width: Get.width,
      height: Get.height * 0.15,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(OkejekTheme.primary_color),
        ),
      ),
    );
  }

  Widget _buildAdsCard(Ads item) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: item.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(OkejekTheme.primary_color),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: Icon(Icons.error_outline, color: Colors.grey),
          ),
          imageBuilder: (context, imageProvider) => Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Get.to(() => DetailOutletPage(
                foodVendor: item.foodVendor,
                type: item.foodVendor.type == 'food' ? 3 : 100,
              )),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselIndicator(int itemCount) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentBannerIndex.value == index
                ? OkejekTheme.primary_color
                : Colors.grey[300],
          ),
        ),
      ),
    ));
  }

  Widget _buildQuickFilters() {
    return Container(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(
            label: 'Terdekat',
            icon: Icons.location_on_outlined,
            onTap: () {
              // Implement filter logic
            },
          ),
          _buildFilterChip(
            label: 'Rating Tertinggi',
            icon: Icons.star_outline,
            onTap: () {
              // Implement filter logic
            },
          ),
          _buildFilterChip(
            label: 'Promo',
            icon: Icons.local_offer_outlined,
            onTap: () {
              // Implement filter logic
            },
          ),
          _buildFilterChip(
            label: 'Open 24 Jam',
            icon: Icons.access_time,
            onTap: () {
              // Implement filter logic
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}