import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/defaults/url.dart';
import 'package:okejek_flutter/models/auth/food/food_vendor_categories_model.dart';
import 'package:okejek_flutter/models/auth/food/food_vendor_model.dart';
import 'package:okejek_flutter/models/base_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OkeMartController extends GetxController {
  final RxList<FoodVendor> foodVendors = RxList<FoodVendor>([]);
  var adUrl = 'https://okejek.id/'.obs;
  var selectedCategoryId = RxInt(0);
  Dio dio = Dio();
  final RxInt currentPage = 1.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;

  void onInit() {
    super.onInit();
  }

  void delete() {
    super.onDelete();
  }

  void setSelectedCategoryId(int id) {
    selectedCategoryId.value = id;
  }

  void openInBrowser() async {
    await canLaunchUrlString(adUrl.value) ? await launchUrlString(adUrl.value) : throw 'Could not launch ';
  }

  Future<List<FoodVendorCategories>> getCategories() async {
    // String url = OkejekBaseURL.getMartCategories;
    String url = OkejekBaseURL.apiUrl('vendors/categories');

    List<FoodVendorCategories> categories = [];

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? session = preferences.getString("user_session");

      var queryParams = {
        'outlet_type': 'mart',
        'api_token': session,
      };

      var response = await dio.get(
        url,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Accepts': 'application/json',
          },
        ),
      );

      debugPrint("res di okemart controller vendor/categories $response");

      var responseBody = response.data;

      BaseResponse responseData = BaseResponse.fromJson(responseBody);
      categories.addAll(responseData.data.foodVendorCategories!);
      return categories;
    } on DioException catch (e) {
      print(e.message);
      return categories;
    }
  }

  Future<List<FoodVendor>> getMartVendor(String q) async {
    // String url = OkejekBaseURL.getFoodVendor;
    String url = OkejekBaseURL.apiUrl('vendors/lists');
    
foodVendors.clear();
      print("data mart dibersihkan");
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? session = preferences.getString("user_session");
      double? currentLat = preferences.getDouble('current_geocode_lat');
      double? currentLng = preferences.getDouble('current_geocode_lng');

      var queryParams = {
        'location': '$currentLat,$currentLng',
        'outlet_type': 'mart',
        'api_token': session,
        'page': currentPage.value.toString(),
        'q': q,
        'category_id': selectedCategoryId.value,
      };

      print("params di okemart controller $queryParams");

      var response = await dio.get(
        url,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Accepts': 'application/json',
          },
        ),
      );

      debugPrint("res di okemart controller vendor/lists $response");

      var responseBody = response.data;

      BaseResponse responseData = BaseResponse.fromJson(responseBody);
      

      foodVendors.addAll(responseData.data.foodVendor!);
      print("data mart ditambahkan");
      print("cek data di okemart controller ${foodVendors}");
      print('Fetched ${foodVendors.length} vendors');
      isLoading.value = false;
      return foodVendors;
    } on DioException catch (e) {
      print(e.message);
      return foodVendors;
    }
  }

  void resetPagination() {
    currentPage.value = 1;
    hasMore.value = true;
    foodVendors.clear();
    isLoading.value = false;
  }
}
