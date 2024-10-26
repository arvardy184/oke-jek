import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:okejek_flutter/controller/api/news_controller.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/models/auth/home_news.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NewsPage extends StatelessWidget {
  final NewsApiController _newsController = Get.put(NewsApiController());
  int get newsLength => _newsController.newsList.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (_newsController.isLoading.value) {
            return _buildLoadingView();
          } else if (_newsController.newsList.isEmpty) {
            return _buildEmptyView();
          } else {
            return _buildNewsListView(_newsController.newsList);
          }
        }),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Shimmer(
      gradient: LinearGradient(colors: [
        Color(0xFFE7E7E7),
        Color(0xFFF4F4F4),
        Color(0xFFE7E7E7),
      ], stops: [
        0.4,
        0.5,
        0.6,
      ], begin: Alignment(-1.0, -0.3), end: Alignment(1.0, 0.8), tileMode: TileMode.clamp),
      child: ListView.builder(
          itemCount: 6,
          itemBuilder: (_, index) {
            return Container(
              margin: EdgeInsets.all(10),
              height: Get.height * 0.2,
              width: Get.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: Get.height * 0.2,
                    width: Get.width,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(
                    height: Get.height * 0.03,
                  ),
                  Text(
                    'Judul Berita',
                    style: TextStyle(
                      fontSize: SizeConfig.safeBlockHorizontal * 3.3,
                    ),
                  )
                ],
              ),
            );
          }),
    );
  }

  Widget _buildEmptyView() {
    return Container(
      height: Get.height,
      width: Get.width,
      child: Center(
        child: Text(
          'Tidak ada berita terbaru',
          style: TextStyle(fontSize: SizeConfig.adaptiveSize(14)),
        ),
      ),
    );
  }

  Widget _buildNewsListView(List newsItems) {
    return ListView.builder(
        padding: EdgeInsets.all(SizeConfig.adaptiveSize(10)),
        itemCount: _newsController.newsList.length,
        itemBuilder: (_, index) {
          HomeNews newsItem = _newsController.newsList[index];
          String formattedDate = DateFormat('dd-MM-yyyy').format(newsItem.date);
          return GestureDetector(
            onTap: () {
              launchUrlString(newsItem.link);
            },
            child: Container(
              margin: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                CachedNetworkImage(
  imageUrl: newsItem.jetpackFeaturedMediaUrl,
  fit: BoxFit.cover,
  progressIndicatorBuilder: (context, url, progress) {
    return Container(
      height: Get.height * 0.2,
      width: Get.width,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  },
  errorWidget: (context, url, error) {
    // Menangani error 404 atau error lain dengan widget pengganti
    return Container(
      height: Get.height * 0.2,
      width: Get.width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
      ),
    );
  },
  imageBuilder: (context, imageProvider) {
    return Container(
      height: Get.height * 0.2,
      width: Get.width,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
      ),
    );
  },
),
                  SizedBox(
                    height: Get.height * 0.02,
                  ),
                  Text(
                    newsItem.title.rendered,
                    style: TextStyle(
                        fontSize: SizeConfig.safeBlockHorizontal * 3.3,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis),
                    maxLines: 2,
                  ),
                  SizedBox(height: Get.height * 0.01),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 2.7, color: Colors.black54),
                  )
                ],
              ),
            ),
          );
        });
  }
}
