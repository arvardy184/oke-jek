import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:okejek_flutter/controller/api/news_controller.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/models/auth/home_news.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomePageNews extends StatelessWidget {
  final NewsApiController newsApiController = Get.put(NewsApiController());
  
  int get newsLength => newsApiController.newsList.length;

  @override
  Widget build(BuildContext context) {
    return Obx(() => newsLength == 0 ? loadingNews() : newsGrid());
  }

  Widget loadingNews() {
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
      child: GridView.builder(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          childAspectRatio: 0.7,
        ),
        itemCount: 6,
        itemBuilder: (_, index) {
          return Container(
            margin: EdgeInsets.all(10),
            height: Get.height * 0.2,
            width: Get.width * 0.4,
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
                Expanded(
                  child: Text(
                    'Judul Berita',
                    style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 3.3),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget newsGrid() {
    return Column(
      children: [
        Text(
          'Berita Hari ini',
          style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: SizeConfig.safeBlockHorizontal * 5,
              ),
        ),
        SizedBox(height: 20),
        CarouselSlider.builder(
          options: CarouselOptions(
            height: Get.height * 0.4,
            aspectRatio: 16 / 9,
            viewportFraction: 0.8,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 3),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.antiAlias,
          ),
          itemCount: newsApiController.newsList.length,
          itemBuilder: (BuildContext context, int index, int realIndex) {
            HomeNews homeNews = newsApiController.newsList[index];
            String formattedDate = DateFormat('dd-MM-yyyy').format(homeNews.date);
            return GestureDetector(
              onTap: () {
                launchURL(homeNews.link);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedNetworkImage(
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    imageUrl: homeNews.jetpackFeaturedMediaUrl,
                    height: Get.height * 0.25,
                    width: double.infinity,
                 
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      height: Get.height * 0.25,
                      width: double.infinity,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  SizedBox(height: 10),
                  Text(
                    homeNews.title.rendered,
                    style: TextStyle(
                      fontSize: SizeConfig.safeBlockHorizontal * 4,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: SizeConfig.safeBlockHorizontal * 3,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void launchURL(String url) async {
    await canLaunchUrlString(url) ? await launchUrlString(url) : throw 'Could not launch $url';
  }
}
