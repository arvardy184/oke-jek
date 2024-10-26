
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/defaults/url.dart';
import 'package:okejek_flutter/models/auth/food/food_vendor_categories_model.dart';
import 'package:okejek_flutter/models/auth/food/food_vendor_model.dart';
import 'package:okejek_flutter/models/base_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OkeFoodController extends GetxController {
  var selectedCategoryId = RxInt(0);
  Dio dio = Dio();
  final RxList<FoodVendor> foodVendors = RxList<FoodVendor>([]);
  final RxInt currentPage = 1.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;

  List<Map<String, dynamic>> dummyData = [
    {
      'nama_makanan': 'Nasi Goreng Seafood',
      'harga': 'Rp19.000',
      'potongan': '0',
      'harga_potongan': 'Rp19.000',
      'jarak': '2.3 km',
      'imageUrl':
          'https://www.masakapahariini.com/wp-content/uploads/2018/04/cara-membuat-nasi-goreng-seafood-500x300.jpg'
    },
    {
      'nama_makanan': 'Salad',
      'harga': 'Rp35.000',
      'potongan': 'Rp5.000',
      'harga_potongan': 'Rp30.000',
      'jarak': '0.4 km',
      'imageUrl':
          'https://awsimages.detik.net.id/community/media/visual/2021/05/12/resep-salad-buah-thai_43.jpeg?w=700&q=90',
    },
    {
      'nama_makanan': 'Bakmi Aceh',
      'harga': 'Rp20.000',
      'potongan': 'Rp5.000',
      'harga_potongan': 'Rp15.000',
      'jarak': '2.1 km',
      'imageUrl':
          'https://asset.kompas.com/crops/S-qPoLB89t3T-R8pqe0kSyGTbNY=/26x0:926x600/750x500/data/photo/2019/11/27/5dddef90a93b3.jpg',
    },
  ].obs;

  List<Map<String, dynamic>> nearbyEateries = [
    {
      'nama_makanan': 'Restoran Mie Rasa cab. Asia Afrika',
      'harga': 'Rp15.000',
      'jarak': '0.2 km',
      'imageUrl':
          'https://selerasa.com/wp-content/uploads/2015/05/images_mie_Mie_ayam_14-mie-ayam-kampung-1200x798.jpg',
    },
    {
      'nama_makanan': 'Mie Gacoan',
      'harga': 'Rp20.000',
      'jarak': '0.1 km',
      'imageUrl':
          'https://d1sag4ddilekf6.azureedge.net/compressed/merchants/IDGFSTI00003m4d/hero/977a9a87d67c4e9e95e1dcadbac41225_1593147160597014795.jpeg',
    },
    {
      'nama_makanan': 'Jank Jank Delivery Wings',
      'harga': 'Rp20.000',
      'jarak': '0.3 km',
      'imageUrl':
          'https://d1sag4ddilekf6.azureedge.net/compressed/merchants/IDGFSTI00000xpp/hero/13_d177eaa3c42e4540bd240bbde5f8363f_1551851079280275748.jpg',
    },
  ].obs;

  var adUrl = 'https://okejek.id/'.obs;

  @override
  void onInit() {
    super.onInit();
    getCategories();
  }

  void delete() {
    super.onDelete();
  }

  void openInBrowser() async {
    await canLaunchUrlString(adUrl.value) ? await launchUrlString(adUrl.value) : throw 'Could not launch ';
  }

  void setSelectedCategoryId(int id) {
    selectedCategoryId.value = id;
  }

  Future<List<FoodVendorCategories>> getCategories() async {

    
    // String url = OkejekBaseURL.getFoodCategories;
    String url = OkejekBaseURL.apiUrl('vendors/categories');

    List<FoodVendorCategories> categories = [];

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? session = preferences.getString("user_session");

      var queryParams = {
        'outlet_type': 'food',
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

      debugPrint("res di okefood controller vendor/categories $response");

      var responseBody = response.data;

      BaseResponse responseData = BaseResponse.fromJson(responseBody);
      categories.addAll(responseData.data.foodVendorCategories!);
      return categories;
    } on DioException catch (e) {
      print(e.message);
      return categories;
    }
  }

  Future<void> getFoodVendor({bool loadMore = false}) async {
    
    if(loadMore && !hasMore.value) return;
    

    isLoading.value = true;
    // String url = OkejekBaseURL.getFoodVendor;
    String url = OkejekBaseURL.apiUrl('vendors/lists');
    // List<FoodVendor> foodVendors = [];

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? session = preferences.getString("user_session");
      double? currentLat = preferences.getDouble('current_geocode_lat');
      double? currentLng = preferences.getDouble('current_geocode_lng');

      var queryParams = {
        'location': '$currentLat,$currentLng',
        'outlet_type': 'food',
        'api_token': session,
        'page':currentPage.value.toString(),
        'q': '',
        'category_id': selectedCategoryId.value,
      };
        
      print("params di okefood controller $queryParams");

      var response = await dio.get(
        url,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Accepts': 'application/json',
          },
        ),
      );

      debugPrint("res di okefood controller vendor/lists $response");

      var responseBody = response.data;

      BaseResponse responseData = BaseResponse.fromJson(responseBody);

       List<FoodVendor> newVendors = responseData.data.foodVendor ?? [];

      if(loadMore) {
        foodVendors.addAll(newVendors);
      } else{
        foodVendors.assignAll(newVendors);
      }

      hasMore.value = newVendors.isNotEmpty;
      if(hasMore.value) {
        currentPage.value++;
      }

      // foodVendors.addAll(responseData.data.foodVendor!);

      // return foodVendors;
    } on DioException catch (e) {

      print("Error fetching vendors: $e");
      // return foodVendors;
    }finally{
      isLoading.value = false;
    }
  }


  Future<void> searchFoodVendor(String q) async {


    isLoading.value = true;
    // String url = OkejekBaseURL.getFoodVendor;
    String url = OkejekBaseURL.apiUrl('vendors/lists');
    // List<FoodVendor> foodVendors = [];

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? session = preferences.getString("user_session");
      double? currentLat = preferences.getDouble('current_geocode_lat');
      double? currentLng = preferences.getDouble('current_geocode_lng');

      var queryParams = {
        'location': '$currentLat,$currentLng',
        'outlet_type': 'food',
        'api_token': session,
        'page':currentPage.value.toString(),
        'q': q,
      };
        
      print("params di okefood controller $queryParams");

      var response = await dio.get(
        url,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Accepts': 'application/json',
          },
        ),
      );

      debugPrint("res di okefood controller vendor/lists $response");

      var responseBody = response.data;

      BaseResponse responseData = BaseResponse.fromJson(responseBody);

       List<FoodVendor> newVendors = responseData.data.foodVendor ?? [];

    
        foodVendors.addAll(newVendors);
        for (var element in newVendors) {
          print('${element.name}' );
        }
   
        foodVendors.assignAll(newVendors);
      

      hasMore.value = newVendors.isNotEmpty;
    

      // foodVendors.addAll(responseData.data.foodVendor!);

      // return foodVendors;
    } on DioException catch (e) {

      print("Error fetching vendors: $e");
      // return foodVendors;
    }finally{
      isLoading.value = false;
    }
  }

  void resetPagination(){
    currentPage.value = 1;
    hasMore.value = true;
    foodVendors.clear();
  }
}
