
import 'dart:async';
import 'dart:convert';

import 'dart:ui' as ui;

import 'package:dio/dio.dart' ;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' hide Response;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:okejek_flutter/controller/api/fcm_controller.dart';
import 'package:okejek_flutter/defaults/url.dart';
import 'package:okejek_flutter/models/auth/city_model.dart';
import 'package:okejek_flutter/models/auth/order_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryController extends GetxController {
  FCMController fcmController = Get.put(FCMController());
  Dio dio = Dio();
  ScrollController scrollController = ScrollController();
 final Rx<Uint8List?> markerIcon = Rx<Uint8List?>(null);
 final RxBool isMarkerIconReady = false.obs;
 final RxBool isLoadingMarker = false.obs;
  int currentItem = 0;
  
  var maxItemPerFetch = 10.obs;
  Set<Marker> _markers = {};
  var isFetching = false.obs;
  var isLoading = false.obs;
  var allFetchData = [].obs;
  var showedList = [].obs;
   var driverLocation = [].obs;
  var cityId = 0.obs;
  var orderType = 0.obs;
  var isDataFound = false.obs;
  var isChanged = false.obs;
  var orderStatus = 0.obs;
   final RxDouble _driverLat = 0.0.obs;
  final RxDouble _driverLng = 0.0.obs;
  var sortOrder = [
    'Dalam Perjalanan',
    'Selesai',
    'Dibatalkan',
  ];

  var currentSort = 'Dalam Perjalanan'.obs;
  Future<void> _initializeMarkerIcon() async {
    try {
      isLoadingMarker.value = true;
      // Initialize default marker icon
      markerIcon.value = await getBytesFromAsset('assets/icons/markers/ride.png', 100);
      isMarkerIconReady.value = true;
    } catch (e) {
      debugPrint('Error initializing marker icon: $e');
    } finally {
      isLoadingMarker.value = false;
    }
  }

  Future<void> _updateMarkerIcon(int orderType) async {
    try {
      isLoadingMarker.value = true;
      String assetPath;
      
      switch (orderType) {
        case 0:
          assetPath = 'assets/icons/markers/ride.png';
          break;
        case 4:
          assetPath = 'assets/icons/markers/car.png';
          break;
        default:
          assetPath = 'assets/icons/markers/trike.png';
          break;
      }

      markerIcon.value = await getBytesFromAsset(assetPath, 100);
      isMarkerIconReady.value = true;
    } catch (e) {
      debugPrint('Error updating marker icon: $e');
    } finally {
      isLoadingMarker.value = false;
    }
  }

    Set<Marker> setMarker() {
    driverLocation.forEach(
      (location) {
        List<String> locationSplit = location.split(',');

        _markers.add(
          Marker(
            markerId: MarkerId(location),
            // ignore: deprecated_member_use
            icon: BitmapDescriptor.fromBytes(markerIcon.value!),
            position: LatLng(double.parse(locationSplit[0]), double.parse(locationSplit[1])),
          ),
        );
      },
    );
    update();
    return _markers;
  }

  final Completer<GoogleMapController> mapController = Completer();
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxDouble driverLat = 0.0.obs;
  final RxDouble driverLng = 0.0.obs;
  Timer? driverLocationTimer;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
    scrollConfigure();
    setMarker();
     _initializeMarkerIcon();
  }

  @override
  void onClose() {
    driverLocationTimer?.cancel();
    super.onClose();
  }

  void initializeOrderMap(Order order) async {
    try {
      // Clear existing markers
      markers.clear();

      // Make sure marker icon is initialized
      if (!isMarkerIconReady.value) {
        await _initializeMarkerIcon();
      }

      // Add markers only if initialization is successful
      if (isMarkerIconReady.value) {
        _addOriginMarker(order);
        _addDestinationMarker(order);
        await _addInitialDriverMarker(order);
        startDriverLocationUpdates(order);
      } else {
        debugPrint('Marker icon not ready');
      }
    } catch (e) {
      debugPrint('Error initializing order map: $e');
    }
  }

  Future<void> _addInitialDriverMarker(Order order) async {
    if (!isMarkerIconReady.value || markerIcon.value == null) {
      debugPrint('Marker icon not ready for driver marker');
      return;
    }

    try {
      markers.add(
        Marker(
          markerId: MarkerId('driver'),
          position: LatLng(_driverLat.value, _driverLng.value),
          icon: BitmapDescriptor.fromBytes(markerIcon.value!),
        ),
      );
    } catch (e) {
      debugPrint('Error adding driver marker: $e');
    }
  }

  void _addOriginMarker(Order order) {
    double originLat = double.parse(order.originLatlng.split(",")[0]);
    double originLng = double.parse(order.originLatlng.split(",")[1]);
    markers.add(Marker(
      markerId: MarkerId('origin'),
      position: LatLng(originLat, originLng),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ));
  }

  void _addDestinationMarker(Order order) {
    double destLat = double.parse(order.destinationLatlng.split(",")[0]);
    double destLng = double.parse(order.destinationLatlng.split(",")[1]);
    markers.add(Marker(
      markerId: MarkerId('destination'),
      position: LatLng(destLat, destLng),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));
  }

  // void _addInitialDriverMarker(Order order) {
  //   double originLat = double.parse(order.originLatlng.split(",")[0]);
  //   double originLng = double.parse(order.originLatlng.split(",")[1]);
  //   markers.add(Marker(
  //     markerId: MarkerId('driver'),
  //     position: LatLng(_driverLat.value, _driverLng.value),
  //     // ignore: deprecated_member_use
  //     icon: BitmapDescriptor.fromBytes(markerIcon.value!),
  //   ));
  // }

  void startDriverLocationUpdates(Order order) {
    driverLocationTimer?.cancel();
    driverLocationTimer = Timer.periodic(Duration(seconds: 11), (_) {
      updateDriverLocation(order);
      fcmController.refreshAndRegisterToken();
      // checkOrder(order.id);
    });
  }

  Future<void> updateDriverLocation(Order order) async {
    if (order.driver == null) {
      debugPrint('No driver assigned to this order yet.');
      return;
    }

    if (!isMarkerIconReady.value || markerIcon.value == null) {
      debugPrint('Marker icon not ready for driver location update');
      return;
    }

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? session = preferences.getString("user_session");

      if (session == null) {
        debugPrint('No session found. Please log in again.');
        return;
      }

      final response = await _fetchDriverLocation(order.id, session);
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        await _updateDriverMarker(response.data);
      }
    } catch (e) {
      debugPrint('Error updating driver location: $e');
    }
  }

    Future<void> _updateDriverMarker(Map<String, dynamic> data) async {
    try {
      var driverLocation = data['data']['driver_last_position_coordinate'];
      driverLat.value = driverLocation['lat'];
      driverLng.value = driverLocation['lng'];

      markers.removeWhere((marker) => marker.markerId.value == 'driver');

      if (isMarkerIconReady.value && markerIcon.value != null) {
        markers.add(Marker(
          markerId: MarkerId('driver'),
          position: LatLng(driverLat.value, driverLng.value),
          icon: BitmapDescriptor.fromBytes(markerIcon.value!),
        ));

        if (mapController.isCompleted) {
          final GoogleMapController controller = await mapController.future;
          await controller.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(driverLat.value, driverLng.value),
              15,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error updating driver marker: $e');
    }
  }

   Future<Response> _fetchDriverLocation(int orderId, String session) async {
    String url = OkejekBaseURL.apiUrl('orders/driver-location/$orderId');
    
    return await dio.get(
      url,
      queryParameters: {'api_token': session},
      options: Options(headers: {'Accepts': 'application/json'}),
    );
  }

  void delete() {
    super.onDelete();
    resetController();
  }

  void scrollConfigure() {
    scrollController.addListener(() {
     // if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        fetchMore();
        isFetching.value = true;
      //}
    });
  }

  fetchMore() {
    int fetchMore = showedList.length + 5;
    Future.delayed(Duration(milliseconds: 500)).then((value) {
      print("durasi fetch more : $fetchMore");
      if (allFetchData.length > showedList.length) {
        for (var i = showedList.length; i < fetchMore; i++) {
          showedList.insert(i, allFetchData[i]);
        }
      } else {
        isFetching.value = false;
      }
    });
  }

    void getNearestDriver() async {
    driverLocation.clear();
    _markers.clear();
    isLoading.value = true;

    // create a loading
    Future.delayed(Duration(seconds: 1), () async {
      // checking order type for determine the icon
      // orderCheck();

      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? session = preferences.getString("user_session");

      // get from server
      try {
        getCityId();

        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        // String url = OkejekBaseURL.nearestDriver(position, orderType.value, cityId.value);

        String url = OkejekBaseURL.apiUrl('drivers-locations');

        var queryParams = {
          'city_id': '${cityId.value}',
          'service': '${orderType.value}',
          'location': '${position.latitude},${position.longitude}',
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

        debugPrint("res di history controller drivers-locations $response");

        var responseBody = response.data;

        driverLocation.addAll(responseBody['data']['driver_locations']);
        setMarker();
        isLoading.value = false;
      } on DioException catch (e) {
        print(e.message);
      }
    });
  }

  //   Future<void> checkOrder(int id) async {
  //   isLoading.value = true;

  //   // String url = OkejekBaseURL.getDetaikOrderById(id);
  //   String url = OkejekBaseURL.apiUrl('orders/view/$id');
  //   try {
  //     SharedPreferences preferences = await SharedPreferences.getInstance();
  //     String? session = preferences.getString("user_session");

  //     var queryParams = {
  //       'api_token': session,
  //     };

  //     var response = await dio.get(
  //       url,
  //       queryParameters: queryParams,
  //       options: Options(
  //         headers: {
  //           'Accepts': 'application/json',
  //         },
  //       ),
  //     );

  //     log("res di landing controller orders view $response");
      

  //     var responseBody = response.data;

  //     print(responseBody);
  //     print(responseBody['data']['order']['user']['activated']);
  //     responseBody['data']['order']['user']['activated'] == 1
  //         ? responseBody['data']['order']['user']['activated'] = true
  //         : responseBody['data']['order']['user']['activated'] = false;
  //     BaseResponse responseData = BaseResponse.fromJson(responseBody);
  //     Order order = responseData.data.orders!;

  //     // Get.put(OrderInProgressController());

  //     /* For differentiate between inProgress and finished, create a condition with order type */
  //     // Get.to(() => OrderDetailPage(
  //     //       order: order,
  //     //       driverData: order.driver != null ? order.driver!.toJson() : {},
  //     //     ))?.then((value) {
  //     //   deeplinkUrl.value = '';
  //     //   print(deeplinkUrl.value);
  //     // });
  //     orderStatus.value = order.status;
  //     print("order type : ${order}");
  //     print("response data : ${responseBody['data']['order']}");
  //     // orderType.value = order.items
  //     isLoading.value = false;
  //   } on DioException catch (e) {
  //     print(e.message);
  //     isLoading.value = false;
  //   }
  // }

   Future<void> getCityId() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? cityJson = preferences.getString('nearestCity');

      if (cityJson == null) {
        print('No City data found ');
        return;
      }

      var data = jsonDecode(cityJson);

      if (data['success'] != true) {
        print('Data indicates unsuccessfull response');
        return;
      }

      var cityData = data['data']['city'];

      if (cityData == null) {
        print('No City data found ');
        return;
      }

      City city = City.fromJson(data['data']['city']);

      cityId.value = city.id;
    } on DioException catch (e) {
      print("Error parsing city data $e");
    }
  }


  //  void orderCheck() async {
  //   if (!isMarkerIconReady.value) {
  //     await _initMarkerIcon();
  //   }

  //   if (orderType.value == 0) {
  //     markerIcon = await getBytesFromAsset('assets/icons/markers/ride.png', 100);
  //   } else if (orderType.value == 4) {
  //     markerIcon = await getBytesFromAsset('assets/icons/markers/car.png', 100);
  //   } else {
  //     markerIcon = await getBytesFromAsset('assets/icons/markers/trike.png', 100);
  //   }
  // }
 Future<Uint8List> getBytesFromAsset(String path, int width) async {
    try {
      ByteData data = await rootBundle.load(path);
      ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(), 
        targetWidth: width
      );
      ui.FrameInfo fi = await codec.getNextFrame();
      return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
          .buffer.asUint8List();
    } catch (e) {
      debugPrint('Error loading asset: $e');
      rethrow;
    }
  }


  Future<List> fetchHistory() async {
    isLoading.value = true;
    List listOfOrder = [];
    List<Map<String, dynamic>> driversData = [];
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? session = preferences.getString("user_session");

    String status = currentSort.value == 'Dalam Perjalanan'
        ? 'progress'
        : currentSort.value == 'Selesai'
            ? 'finished'
            : 'cancel';

    // String url = OkejekBaseURL.historyUrl(status);
    String url = OkejekBaseURL.apiUrl('orders');
  
    try {
      var queryParams = {
        'status': '$status',
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

      debugPrint("res di history controller orders $response");
    
      print(url);
      print(session);

      // STATUS *SELESAI = 3 *DALAM PERJALANAN = 2  *DIBATALKAN = -1
      var responseBody = response.data;

   
       
      // print(responseBody);
      // print("response di driver ${responseBody['data']['orders']['driver']}");
      // for (var i = 0; i < responseBody['data']['orders'].length; i++) {
      //   responseBody['data']['orders'][i]['user']['activated'] == 1
      //       ? responseBody['data']['orders'][i]['user']['activated'] = true
      //       : responseBody['data']['orders'][i]['user']['activated'] = false;
      // }

      // set a max item for looping
      int maxItem = responseBody['data']['orders'].length < maxItemPerFetch.value
          ? responseBody['data']['orders'].length
          : maxItemPerFetch.value;

          showedList.clear();

 for (var i = 0; i < maxItem; i++) {
          var order = responseBody['data']['orders'][i];
          showedList.add(order);

          if(order['driver'] != null){
            driversData.add(order['driver']);
          }
          print("drivers data $driversData");
        }
      // create a list for show 10 items
      // for (var i = currentItem; i < maxItem; i++) {
      //   showedList.add(responseBody['data']['orders'][i]);
      // }

      // stored all order to a list
      allFetchData.addAll(responseBody['data']['orders']);
      isLoading.value = false;
      return listOfOrder;
    } on DioException catch (e) {
      // showing failure text
      print(e.message);
      return listOfOrder;
    }
  }

  void resetController() {
    showedList.clear();
    allFetchData.clear();
    isFetching.value = false;
    currentItem = 0;
    isLoading.value = false;
    
  }

  void resetFilter() {
    currentSort.value = 'Dalam Perjalanan';
  }

  void changeSorting(String value) {
    currentSort.value = value;
    resetController();
  }
}
