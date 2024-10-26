import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/ads_controller.dart';
import 'package:okejek_flutter/controller/api/fcm_controller.dart';
import 'package:okejek_flutter/controller/api/service_controller.dart';
import 'package:okejek_flutter/controller/api/user_controller.dart';
import 'package:okejek_flutter/controller/auth/okefood/okefood_controller.dart';
import 'package:okejek_flutter/controller/auth/store/store_controller.dart';
import 'package:okejek_flutter/controller/landing_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/models/auth/ads_model.dart';
import 'package:okejek_flutter/pages/auth/okefood/detail_outlet_page.dart';
import 'package:okejek_flutter/widgets/home/home_page_news_widget.dart';
import 'package:okejek_flutter/widgets/home/main_menu_widget.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class HomePage extends StatelessWidget {
  // final List<int> cardList = [1, 2, 3];
  final UserController userController = Get.find();
  final LandingController landingController = Get.find();
  final OkeFoodController okefoodController = Get.put(OkeFoodController());
  final StoreController storeController = Get.put(StoreController());
  final AdsController adsController = Get.put(AdsController());
  final ServicesController servicesController = Get.put(ServicesController());
  final FCMController fcmController = Get.put(FCMController());
  final RxBool isRefreshing = false.obs;

  Future<void> _refreshData() async {
    try{
      isRefreshing.value = true;
      Get.showSnackbar(
        GetSnackBar(
          message: 'Memperbarui data...',
          duration: Duration(seconds: 1),
          backgroundColor: Colors.black54,
          borderRadius: 8,
          margin: EdgeInsets.all(8),
        ),
      );

      await Future.wait([
      userController.checkingUserSession(),
      okefoodController.getFoodVendor(),
      adsController.getAdsBanner('front'),
      
    fcmController.refreshAndRegisterToken(),
    ]);
     servicesController.getService();
   Get.showSnackbar(
        GetSnackBar(
          message: 'Data berhasil diperbarui',
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
          borderRadius: 8,
          margin: EdgeInsets.all(8),
          icon: Icon(
            Icons.check_circle,
            color: Colors.white,
          ),
        ),
      );
    } catch (e) {
      // Show error message
      Get.showSnackbar(
        GetSnackBar(
          message: 'Gagal memperbarui data',
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
          borderRadius: 8,
          margin: EdgeInsets.all(8),
          icon: Icon(
            Icons.error_outline,
            color: Colors.white,
          ),
        ),
      );
    
  } finally {
    isRefreshing.value = false;
  }
}

  @override
  Widget build(BuildContext context) {
    if (landingController.isLoading.value) showAlertDialog(context);
    // ignore: deprecated_member_use
    return WillPopScope(
        onWillPop: () async {
          print("Back button pressed");
          Get.back();
          SystemNavigator.pop();
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: RefreshIndicator(
            onRefresh: _refreshData,
            color: OkejekTheme.primary_color,
            backgroundColor: Colors.white,
            strokeWidth: 2.5,
            displacement: 40,
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                print("scrolling");
                overscroll.disallowIndicator();
                return false;
              },
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return <Widget>[
                    SliverLayoutBuilder(builder: (BuildContext context, constraints) {
                      final opacity = 1 - (constraints.scrollOffset * 100 / 11600).clamp(0.0, 1.0);
                      final whiteValue = constraints.scrollOffset / 80;
                      double whiteOpacity = whiteValue > 1 ? 1 : whiteValue;
                      return SliverAppBar(
                        shape: RoundedRectangleBorder(),
                        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
                          statusBarColor: Colors.white.withOpacity(whiteOpacity),
                        ),
                        backgroundColor: OkejekTheme.primary_color.withOpacity(opacity),
                        expandedHeight: SizeConfig.safeBlockVertical * 60 / 7.2,
                        floating: false,
                        pinned: false,
                        bottom: PreferredSize(
                          preferredSize: Size(
                            SizeConfig.safeBlockHorizontal * 30 / 3.6,
                            SizeConfig.safeBlockVertical * 20 / 7.2,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: PreferredSize(
                              preferredSize: Size(
                                SizeConfig.safeBlockHorizontal * 30 / 3.6,
                                SizeConfig.safeBlockVertical * 20 / 7.2,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                      children: [
                                        Text(
                                          // '${fcmController.latestMessage}',
                                          'Welcome To Okejek',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        // Obx(() =>
                                        //     fcmController.isInitialized ? Text('FCM Siap') : Text('Menunggu FCM...'))
                                      ],
                                    ),
                              ),
                            ),
                          ),
                        ),
                      );
                    })
                  ];
                },
                body: Stack(
                  children:[ NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overscroll) {
                      overscroll.disallowIndicator();
                      return true;
                    },
                    child: GestureDetector(
                      onTap: () {
                        print('klik');
                        print("latest message: isInitialized: ${fcmController.isInitialized}");
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                      child: SafeArea(
                        child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                              child: SingleChildScrollView(
                                physics: AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  children: [
                                    // Customer information
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Obx(() => RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'Halo, '.tr,
                                                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                            color: Colors.black87,
                                                            fontSize: SizeConfig.safeBlockHorizontal * 5),
                                                      ),
                                                      TextSpan(
                                                        text: userController.name.value,
                                                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                              color: Colors.black87,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: SizeConfig.safeBlockHorizontal * 5,
                                                            ),
                                                        recognizer: TapGestureRecognizer()..onTap = () {},
                                                      ),
                                                    ],
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                )),
                                            SizedBox(
                                              height: Get.height * 0.015,
                                            ),
                                            Obx(() => RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: userController.balance.value,
                                                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                              color: Colors.black87,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: SizeConfig.safeBlockHorizontal * 16 / 3.6,
                                                            ),
                                                      ),
                                                      TextSpan(
                                                        text: ' Oke Point',
                                                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                            color: Colors.black45,
                                                            fontSize: SizeConfig.safeBlockHorizontal * 3.3),
                                                        recognizer: TapGestureRecognizer()..onTap = () {},
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                          ],
                                        ),
                                        _buildProfileIcon()
                                      ],
                                    ),
                  
                                    SizedBox(
                                      height: Get.height * 0.05,
                                    ),
                  
                                    // layanan menu gridview
                                    MainMenu(),
                                    SizedBox(
                                      height: Get.height * 0.01,
                                    ),
                                    Divider(),
                                    SizedBox(
                                      height: Get.height * 0.01,
                                    ),
                  
                                    // Ads Carousel
                                    FutureBuilder<List<Ads>>(
                                        future: adsController.getAdsBanner('front'),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return SizedBox(
                                              width: MediaQuery.of(context).size.width * 0.9,
                                              height: MediaQuery.of(context).size.height * 0.3,
                                              child: Center(
                                                child: CircularProgressIndicator(),
                                              ),
                                            );
                                          } else {
                                            if (snapshot.data?.length == 0) {
                                              return SizedBox();
                                            } else {
                                              return CarouselSlider(
                                                options: CarouselOptions(
                                                    autoPlay: true,
                                                    autoPlayInterval: Duration(seconds: 5),
                                                    autoPlayAnimationDuration: Duration(milliseconds: 500),
                                                    autoPlayCurve: Curves.fastOutSlowIn,
                                                    pauseAutoPlayOnTouch: true,
                                                    enlargeCenterPage: false,
                                                    viewportFraction: 1,
                                                    onPageChanged: (index, reason) {}),
                                                items: snapshot.data?.map((item) {
                                                  return adsCard(context, item);
                                                }).toList(),
                                              );
                                            }
                                          }
                                        }),
                  
                                    SizedBox(
                                      height: Get.height * 0.05,
                                    ),
                  
                                    SizedBox(
                                      height: Get.height * 0.02,
                                    ),
                  
                                    //Gridview news
                                    HomePageNews(),
                                    SizedBox(
                                      height: Get.height * 0.01,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Obx(
                              () {
                                if (!userController.isServiceAvailable.value) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    _showServiceUnavailableNotification(context);
                                  });
                                }
                                return Container();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Obx(() => isRefreshing.value
                  ?Container(
                    width: double.infinity,
                    height: 2,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        OkejekTheme.primary_color,
                      ),
                    ),
                  )
                  : const SizedBox.shrink()
                  )
                  
           ]     ),
              ),
            ),
          ),
        ));
  }

  Widget _buildProfileIcon() {
    return SizedBox(
      width: 45,
      child: GestureDetector(
        onTap: () {
          landingController.changeTab(3);
        },
        child: Container(
          height: SizeConfig.blockSizeVertical * 7,
          width: SizeConfig.blockSizeHorizontal * 15,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(OkejekTheme.rounded_corner),
            image: DecorationImage(
              image: AssetImage('assets/icons/other/icon profile.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  void _showServiceUnavailableNotification(BuildContext context) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.info(
        backgroundColor: Colors.yellow,
        icon: Container(),
        message: 'Maaf, layanan kami belum tersedia di tempat anda berada saat ini',
        textStyle: TextStyle(fontSize: 12, color: Colors.black),
      ),
      displayDuration: Duration(seconds: 7),
    );
  }

  Widget adsCard(BuildContext context, Ads item) {
    return CachedNetworkImage(
      imageUrl: item.imageUrl,
      fit: BoxFit.cover,
      progressIndicatorBuilder: (context, url, progress) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: CircularProgressIndicator(),
          ),
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
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.6,
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

  showAlertDialog(BuildContext context) {
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: 100,
          height: 100,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
