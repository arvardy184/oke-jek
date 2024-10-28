import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:okejek_flutter/controller/auth/okemart/okemart_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/models/auth/food/food_vendor_model.dart';
import 'package:okejek_flutter/pages/auth/okemart/detail_outlet_mart_page.dart';

class OkeMartListOutletPage extends StatefulWidget {
  @override
  State<OkeMartListOutletPage> createState() => _OkeMartListOutletPageState();
}

class _OkeMartListOutletPageState extends State<OkeMartListOutletPage> {
  final OkeMartController okeMartController = Get.find();

  @override
  void initState() {
    super.initState();
    okeMartController.resetPagination();
    okeMartController.getMartVendor('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
        title: const Text(
          'Daftar Toko',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (okeMartController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: OkejekTheme.primary_color,
            ),
          );
        }

        if (okeMartController.foodVendors.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.store_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada toko tersedia',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: okeMartController.foodVendors.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: Colors.grey[200],
          ),
          itemBuilder: (context, index) {
            return _buildFoodVendorItem(okeMartController.foodVendors[index]);
          },
        );
      }),
    );
  }

  Widget _buildFoodVendorItem(FoodVendor foodVendor) {
    return InkWell(
      onTap: () => Get.to(() => DetailOutletPage(foodVendor: foodVendor, type: 100)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVendorImage(foodVendor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodVendor.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    foodVendor.address,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _buildVendorInfo(foodVendor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorImage(FoodVendor foodVendor) {
    return Hero(
      tag: 'mart-${foodVendor.id}',
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: foodVendor.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: foodVendor.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildImagePlaceholder(),
                  errorWidget: (context, url, error) => _buildImagePlaceholder(),
                )
              : _buildImagePlaceholder(),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.store,
          size: 40,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildVendorInfo(FoodVendor foodVendor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: OkejekTheme.primary_color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(
                Icons.star,
                size: 16,
                color: OkejekTheme.primary_color,
              ),
              const SizedBox(width: 4),
              Text(
                '4.5',
                style: TextStyle(
                  color: OkejekTheme.primary_color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: Colors.blue[700],
              ),
              const SizedBox(width: 4),
              Text(
                '0.8 km',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}