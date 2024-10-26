import 'package:flutter/material.dart';
import 'package:flutter_tab_indicator_styler/flutter_tab_indicator_styler.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/pages/auth/news/coming_soon_page.dart';
import 'package:okejek_flutter/pages/auth/news/news_page.dart';

class TabbarNews extends StatelessWidget {
  final List<String> _tabTitles = ["Berita", "Notifikasi", "Promo"];
  final List<Widget> _tabPages = [
    NewsPage(),
    ComingSoonPage(icon: Icons.notifications),
    ComingSoonPage(icon: Icons.local_offer),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: _tabTitles.length,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: _buildTabBar(),
          ),
          body: TabBarView(children: _tabPages),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(child: Container()),
            TabBar(
              indicatorColor: OkejekTheme.primary_color,
              tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
              labelColor: Colors.black,
              indicator: MaterialIndicator(
                color: Colors.black,
                horizontalPadding: SizeConfig.adaptiveSize(10),
                paintingStyle: PaintingStyle.fill,
              ),
            ),
          ],
        ),
      ),
    );
  }
}