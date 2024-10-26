import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/api/user_controller.dart';
import 'package:okejek_flutter/controller/auth/deeplink_controller.dart';
import 'package:okejek_flutter/controller/landing_controller.dart';
import 'package:okejek_flutter/controller/logout/logout_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/pages/auth/history/history_page.dart';
import 'package:okejek_flutter/pages/auth/home_page.dart';
import 'package:okejek_flutter/pages/auth/news/tabbar_news.dart';
import 'package:okejek_flutter/pages/auth/profile/profile_page.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class BottomNavigation extends StatelessWidget {
  final UserController userController = Get.put(UserController());
  final LandingController landingController = Get.put(LandingController());
  final DeeplinkController deepLinkController = Get.put(DeeplinkController());
  final LogoutController logoutController = Get.put(LogoutController());

  BottomNavigation({Key? key}) : super(key: key) {
    _checkVersionAndSession();
  }

  void _checkVersionAndSession() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (landingController.isOutdated.value) _showAlertUpdate();
      checkingSession();
    });
  }

  List<Widget> _buildScreens() {
    return [
      HomePage(),
      HistoryPage(),
      TabbarNews(),
      ProfilePage(),
    ];
  }

  PersistentBottomNavBarItem _buildNavBarItem(IconData icon, String title) {
    return PersistentBottomNavBarItem(
      icon: Icon(
        icon,
        size: SizeConfig.safeBlockHorizontal * 6,
      ),
      textStyle: TextStyle(fontFamily: OkejekTheme.font_family, fontSize: SizeConfig.blockSizeHorizontal * 2.5),
      title: (title),
      activeColorPrimary: OkejekTheme.primary_color,
      inactiveColorPrimary: Colors.grey,
    );
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      _buildNavBarItem(Icons.home_outlined, "Home"),
      _buildNavBarItem(Icons.timer_outlined, "Riwayat"),
      _buildNavBarItem(Icons.wysiwyg_outlined, "Berita"),
      _buildNavBarItem(Icons.person_outline, "Akun"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    //  
     // ignore: deprecated_member_use
     return WillPopScope(
      onWillPop: () async {
        if (landingController.controller.index != 0) {
          // If not on the home tab, switch to home tab
          landingController.controller.jumpToTab(0);
          return false;
        } else {
          // If on home tab, show double back to exit message
          return true;
        }
      },
      child: Scaffold(
        body: DoubleBack(
          message: "Tap lagi untuk keluar",
          textStyle: TextStyle(fontSize: 12, color: Colors.white),
          child: PersistentTabView(
            context,
            navBarHeight: SizeConfig.getProportionateScreenHeight(60),
            controller: landingController.controller,
            screens: _buildScreens(),
            items: _navBarsItems(),
            confineToSafeArea: true,
            
            // confineInSafeArea: true,
            backgroundColor: Colors.white, // Default is Colors.white.
            handleAndroidBackButtonPress: true, // Default is true.
            resizeToAvoidBottomInset:
                true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
            stateManagement: true, // Default is true.
            hideNavigationBarWhenKeyboardAppears: true,
            // hideNavigationBarWhenKeyboardShows:
            //     true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
            decoration: NavBarDecoration(
              borderRadius: BorderRadius.circular(10.0),
              colorBehindNavBar: Colors.white,
            ),
            popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
            
            // popAllScreensOnTapOfSelectedTab: true,
            // popActionScreens: PopActionScreensType.all,
            animationSettings: NavBarAnimationSettings(
              navBarItemAnimation: ItemAnimationSettings(
                duration: Duration(milliseconds: 250),
                curve: Curves.elasticOut,
              ),
              screenTransitionAnimation: ScreenTransitionAnimationSettings(
                animateTabTransition: true,
                curve: Curves.easeInOutCubic,
                duration: Duration(milliseconds: 350),
              ),
            ),
      
            onItemSelected: (value) {
              landingController.changeCurrentTab(value);
            },
            navBarStyle: NavBarStyle.style1, // Choose the nav bar style with this property.
          ),
        ),
      ),
    );
  }

  void checkingSession() async {
    if (!await userController.checkingUserSession()) _showSessionAlertUpdate();
  }

  void _showAlertUpdate() {
    _showDialog(
      title: "Update",
      content: "Versi terbaru telah tersedia, silakan update aplikasi Okejek di PlayStore",
      buttonText: "Update",
      onPressed: landingController.updateVersion,
    );
  }

  void _showSessionAlertUpdate() {
    _showDialog(
      title: "Sesi Habis",
      content: "Sesi anda telah berakhir. Silahkan login kembali untuk melanjutkan",
      buttonText: "Keluar",
      onPressed: logoutController.logout,
      barrierDismissible: false,
    );
  }

  void _showDialog({
    required String title,
    required String content,
    required String buttonText,
    required VoidCallback onPressed,
    bool barrierDismissible = true,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          content,
          style: TextStyle(fontSize: SizeConfig.adaptiveSize(14)),
        ),
        actions: [
          TextButton(
            child: Text(
              buttonText,
              style: TextStyle(
                fontSize: SizeConfig.adaptiveSize(14),
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: onPressed,
          ),
        ],
      ),
      barrierDismissible: barrierDismissible,
    );
  }
}

  // void showAlertUpdate() {
  //   SchedulerBinding.instance.addPostFrameCallback(
  //     (_) {
  //       // set up the button
  //       Widget okButton = TextButton(
  //         child: Text(
  //           "Update",
  //           style: TextStyle(
  //             fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         onPressed: () {
  //           landingController.updateVersion();
  //         },
  //       );

  //       // set up the AlertDialog
  //       AlertDialog alert = AlertDialog(
  //         title: Text(
  //           "Update",
  //           style: TextStyle(
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         content: Text(
  //           "Versi terbaru telah tersedia, silakan update aplikasi Okejek di PlayStore",
  //           style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6),
  //         ),
  //         actions: [
  //           okButton,
  //         ],
  //       );

  //       // show the dialog
  //       showDialog(
  //         context: Get.context!,
  //         builder: (BuildContext context) {
  //           return alert;
  //         },
  //       );
  //     },
  //   );
  // }

  // void showSessionAlertUpdate() {
  //   SchedulerBinding.instance.addPostFrameCallback(
  //     (_) {
  //       // set up the button
  //       Widget okButton = TextButton(
  //         child: Text(
  //           "Keluar",
  //           style: TextStyle(
  //             fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         onPressed: () {
  //           logoutController.logout();
  //         },
  //       );

  //       // set up the AlertDialog
  //       AlertDialog alert = AlertDialog(
  //         title: Text(
  //           "Sesi Habis",
  //           style: TextStyle(
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         content: Text(
  //           "Sesi anda telah berakhir. Silahkan login kembali untuk melanjutkan",
  //           style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6),
  //         ),
  //         actions: [
  //           okButton,
  //         ],
  //       );

  //       // show the dialog
  //       showDialog(
  //         context: Get.context!,
  //         barrierDismissible: false,
  //         builder: (BuildContext context) {
  //           return alert;
  //         },
  //       );
  //     },
  //   );
  // }

