import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/api/service_controller.dart';
import 'package:okejek_flutter/controller/auth/okecourier/okecourier_controller.dart';
import 'package:okejek_flutter/controller/auth/okeexpress/oke_express_controller.dart';
import 'package:okejek_flutter/controller/landing_controller.dart';
import 'package:okejek_flutter/controller/okeride_controller.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/defaults/url.dart';
import 'package:okejek_flutter/pages/auth/okecar/okecar_page.dart';
import 'package:okejek_flutter/pages/auth/okecourier/okecourier_page.dart';
import 'package:okejek_flutter/pages/auth/okefood/okefood_page.dart';
import 'package:okejek_flutter/pages/auth/okemart/okemart_page.dart';
import 'package:okejek_flutter/pages/auth/okerental/okerental_page.dart';
import 'package:okejek_flutter/pages/auth/okeride/okeride_page.dart';
import 'package:okejek_flutter/pages/auth/okeshop/okeshop_page.dart';
import "package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart";
import 'package:url_launcher/url_launcher_string.dart';

/// Beberapa item menu pada halaman home
class MainMenu extends StatelessWidget {
  final OkeRideController okeRideController = Get.put(OkeRideController());
  final OkeRideController okeCarController = Get.put(OkeRideController());
  final OkeExpressController okeExpressController = Get.put(OkeExpressController());
  final OkeCourierController okeCourierController = Get.put(OkeCourierController());
  final ServicesController servicesController = Get.put(ServicesController());
  final LandingController landingController = Get.find();

  bool get isRideAvailable => servicesController.isRideAvailable.value;
  bool get isFoodAvailable => servicesController.isFoodAvailable.value;
  bool get isShoppingAvailable => servicesController.isShoppingAvailable.value;
  bool get isCourierAvailable => servicesController.isCourierAvailable.value;
  bool get isMartAvailable => servicesController.isMartAvailable.value;
  bool get isCarAvailable => servicesController.isCarAvailable.value;
  bool get isTrikeCourierAvailable => servicesController.isTrikeCourierAvailable.value;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        servicesController.getService();
        return Future.delayed(Duration(seconds: 1));
      },
      child: Obx(
        () => servicesController.isServicesAvailable.value ? availableService(context) : outofService(),
      ),
    );
  }

  Widget availableService(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Layanan kami',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: SizeConfig.blockSizeHorizontal * 3.3,
              ),
        ),
        SizedBox(
          height: Get.height * 0.02,
        ),
        Obx(() {
             List<Widget> availableMenus = [
            if (servicesController.isRideAvailable.value)
              menuItem('Oke Ride', Image.asset('assets/icons/10-2021/ride.png'), () {
                okeRideController.resetController();
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  withNavBar: false,
                  screen: OkeRidePage(),
                );
              }),
                 menuItem('Oke Car', Image.asset('assets/icons/10-2021/car.png'), (){
              okeCarController.resetController();
              PersistentNavBarNavigator.pushNewScreen(
                context,
                withNavBar: false,
                screen: OkeCarPage(),
              );
            }),
            if (servicesController.isFoodAvailable.value)
              menuItem('Oke Food', Image.asset('assets/icons/10-2021/food.png'), () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  withNavBar: false,
                  screen: OkeFoodPage(),
                );
              }),
            if (servicesController.isShoppingAvailable.value)
              menuItem('Belanja', Image.asset('assets/icons/10-2021/shopping.png'), () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  withNavBar: false,
                  screen: OkeShopPage(),
                );
              }),
            if (servicesController.isCourierAvailable.value)
              menuItem('Kurir', Image.asset('assets/icons/10-2021/courier.png'), () {
                okeCourierController.resetController();
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  withNavBar: false,
                  screen: OkeCourierPage(),
                );
              }),
            // if (servicesController.isCourierAvailable.value)
            //   menuItem('Express', Image.asset('assets/icons/10-2021/courier.png'), () {
            //     okeExpressController.resiNumber.clear();
            //     PersistentNavBarNavigator.pushNewScreen(
            //       context,
            //       withNavBar: false,
            //       screen: OkeExpressPage(),
            //     );
            //   }),
            // if (servicesController.isMartAvailable.value)
              menuItem('Oke Mart', Image.asset('assets/icons/10-2021/mart.png'), () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  withNavBar: false,
                  screen: OkeMartPage(),
                );
              }),
           
            menuItem('Oke Rental', Image.asset('assets/icons/10-2021/rent.png'), () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                withNavBar: false,
                screen: OkeRentalPage(),
              );
            }),
         
             if (servicesController.isTrikeAvailable.value)
              menuItem('Bentor', Image.asset('assets/icons/10-2021/trike_courier.png'), () {}),
            menuItem('Jadi Mitra', Image.asset('assets/icons/10-2021/driver.png'), () {
              gotoDriverWeb();
            }),
          ];
        return  Container(
            width: Get.width,
            height: Get.height * 0.27,
            // decoration: BoxDecoration(
            //   color: Colors.purple[50],
            //   borderRadius: BorderRadius.circular(10),
            // ),
            child: GridView.count(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 4,
              mainAxisSpacing: SizeConfig.blockSizeVertical * 3,
              children: availableMenus),
          );
       
          

          
        }),
      ],
    );
  }

Widget outofService() {
  return RefreshIndicator(
    onRefresh: () {
      servicesController.getService();
      return Future.delayed(Duration(seconds: 1));
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Layanan kami', // Mengubah 'Menu Utama' menjadi 'Layanan kami' agar konsisten
          style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: SizeConfig.blockSizeHorizontal * 3.3,
              ),
        ),
        SizedBox(
          height: Get.height * 0.02,
        ),
        Container(
          width: Get.width,
          height: Get.height * 0.27, // Menyesuaikan tinggi dengan availableService
          child: GridView.count(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 4,
            mainAxisSpacing: SizeConfig.blockSizeVertical * 3,
            children: <Widget>[
              outOfServiceMenuItem('Oke Ride', Image.asset('assets/icons/10-2021/ride.png')),
              outOfServiceMenuItem('Oke Car', Image.asset('assets/icons/10-2021/car.png')),
              outOfServiceMenuItem('Oke Food', Image.asset('assets/icons/10-2021/food.png')),
              outOfServiceMenuItem('Belanja', Image.asset('assets/icons/10-2021/shopping.png')),
              outOfServiceMenuItem('Kurir', Image.asset('assets/icons/10-2021/courier.png')),
              outOfServiceMenuItem('Oke Mart', Image.asset('assets/icons/10-2021/mart.png')),
              outOfServiceMenuItem('Oke Rental', Image.asset('assets/icons/10-2021/car.png')),
              outOfServiceMenuItem('Bentor', Image.asset('assets/icons/10-2021/trike_courier.png')),
              outOfServiceMenuItem('Jadi Mitra', Image.asset('assets/icons/10-2021/driver.png')),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget outOfServiceMenuItem(String menuLabel, Image image) {
  return GestureDetector(
    onTap: () {
      Get.snackbar(
        'Layanan Tidak Tersedia',
        'Maaf, layanan $menuLabel sedang tidak tersedia saat ini.',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 1),
      );
    },
    child: Opacity(
      opacity: 0.5,
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2, // Menyesuaikan flex dengan menuItem
                child: Container(
                  height: 500, // Menyesuaikan dengan menuItem
                  width: 500,  // Menyesuaikan dengan menuItem
                  child: image,
                ),
              ),
              Flexible(
                flex: 1,
                child: Text(
                  menuLabel,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: SizeConfig.safeBlockHorizontal * 3.2, // Menyesuaikan dengan menuItem
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.close,
                color: Colors.red,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget menuItem(String menuLabel, Image image, Function action) {
    return InkWell(
      onTap: () => action(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Container(
             //
           //
              height: 500,
              width: 500,
              child: image,
            ),
          ),
          
          Flexible(
            flex: 1,
            child: Text(
              menuLabel,
              style: TextStyle(
                color: Colors.black87,
                fontSize: SizeConfig.safeBlockHorizontal * 3.2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void gotoDriverWeb() async {
    String url = OkejekBaseURL.registerDriver;

    await canLaunchUrlString(url) ? await launchUrlString(url) : throw 'Could not launch $url';
  }
}
