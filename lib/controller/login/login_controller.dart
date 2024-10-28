import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Response;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/defaults/url.dart';
import 'package:okejek_flutter/models/base_response_model.dart';
import 'package:okejek_flutter/pages/auth/bottom_navigation_bar.dart';
import 'package:okejek_flutter/pages/input_phone_number.dart';
import 'package:okejek_flutter/pages/landing_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController inputPhoneController = TextEditingController();

  var isLoginFailure = false.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '647667063437-3q9k9q0q5q9r9h9q7k0q6r6k3s3v8f9.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );
  var errorMessage = 'Pendaftaran akun gagal'.obs;
  String tokenId = '';
  Dio dio = Dio();

  RxBool isLoading = false.obs;

  Rx<User?> firebaseUser = Rx<User?>(null);

  void init() {
    super.onInit();
    initializeInterceptors();
  }

  void _setupDioInterceptors() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        SharedPreferences storage = Get.find<SharedPreferences>();
        final token = storage.getString('user_session');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Accept'] = 'application/json';
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        debugPrint('API Error: ${e.message}');
        if (e.response?.statusCode == 401) {
          Get.offAll(() => LandingPage());
        }
        return handler.next(e);
      },
    ));
  }

  void delete() {
    super.onDelete();
    resetController();
  }

  void resetController() {
    isLoading.value = false;
    isLoginFailure.value = false;
  }

  // Future<void> checkExistingSession()async{
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   String? userData = preferences.getString('user_data');
  //   String? session = preferences.getString('user_session');

  //   if (userData != null || session != null) {
  //     bool isSessionValid = await checkingUserSession();
  // }

  void loginViaEmail(String email, String password) async {
    isLoading.value = true;
    isLoginFailure.value = false;

    try {
      var url = OkejekBaseURL.apiUrl('login');

      var data = {
        "email": email,
        "password": password,
      };

      var response = await dio.post(url,
          options: Options(
            headers: {
              'Accepts': 'application/json',
            },
          ),
          data: data);

      debugPrint("res di login controller $response");

      var responseBody = response.data;

      // retype user activated data
      responseBody['data']['user']['activated'] == 1
          ? responseBody['data']['user']['activated'] = true
          : responseBody['data']['user']['activated'] = false;

      await handleLoginResponse(responseBody);
    } on DioException catch (e) {
      isLoginFailure.value = true;

      print(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleLoginResponse(dynamic responseData) async {
    if (responseData['success']) {
      String userData = jsonEncode(BaseResponse.fromJson(responseData));
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('user_data', userData);

      String? sessionJson = preferences.getString('user_data');
      var sessionDecode = jsonDecode(sessionJson!);
      preferences.setString('user_session', sessionDecode['data']['session']);
      Get.offAll(() => BottomNavigation());
    } else {
      errorMessage.value = responseData['message'] ?? 'Login Failed';
      isLoginFailure.value = true;
    }
  }

  bool isSigningIn = false; // Add this flag to track the sign-in process

  Future<void> loginViaGoogle(GoogleSignInAccount googleUser, String tokenIdParams) async {
    try {
      isLoading.value = true;
      var response = await dio.post(
        OkejekBaseURL.apiUrl('login/google'),
        data: {
          "name": googleUser.displayName ?? '',
          "email": googleUser.email,
          "phone": inputPhoneController.text,
          "photo": googleUser.photoUrl ?? '',
          "token_id": tokenIdParams,
        },
        options: Options(headers: {'Accepts': 'application/json'}),
      );

      print("google user $googleUser");

      var responseBody = response.data;
      print(responseBody);
      // check phone number condition
      if (!responseBody['success']) {
        errorMessage.value = responseBody['message'];
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              errorMessage.value,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        );
        isLoading.value = false;
      } else {
        String userData = jsonEncode(responseBody);
        String session = jsonDecode(jsonEncode(responseBody['data']['session']));
        SharedPreferences preferences = await SharedPreferences.getInstance();
        // storing to shareprefs -> json
        preferences.setString('user_data', userData);
        preferences.setString('user_session', session);

        print("google user data $userData");
        // preferences.setString('user_session', sessionDecode['data']['session']);

        Get.offAll(() => BottomNavigation());
        isLoading.value = false;
      }
      tokenId = tokenIdParams;
    } catch (e) {
      print("Login via google failed: ${e.toString()}");
      isLoginFailure.value = true;
      errorMessage.value = 'Gagal login. Silahkan coba lagi';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getGoogleAccount() async {
    if (isSigningIn) {
      print('Sign-in already in progress');
      return;
    }

    debugGoogleSignIn();

    isSigningIn = true; // Set the flag to true to indicate sign-in is in progress
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        print('Sign in failed, no user selected.');
        return;
      }

      final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

      if (googleAuth == null) {
        print('Authentication failed.');
        return;
      }

      tokenId = googleAuth.idToken!;

      // Add token log for debugging
      print('Google Token ID: $tokenId');

      await checkIfAccountExist(googleUser, tokenId);
    } on PlatformException catch (e) {
      print("Platform Exception during Google sign-in: ${e.code} - ${e.message}");
    } on DioException catch (e) {
      print('An error occurred: $e');
    } finally {
      isSigningIn = false; // Reset the flag after the sign-in attempt finishes
    }
  }

  Future<void> debugGoogleSignIn() async{
    try{
      print('DEBUGGING GOOGLE SIGN IN');

      final GoogleSignIn googleSignIn = GoogleSignIn();
      final isAvailable = await GoogleSignIn().canAccessScopes(['email']);
      print("Google sign in available: $isAvailable");

      final currentUser = await googleSignIn.signInSilently();

      print("Current user: $currentUser");

      final clientId = await googleSignIn.clientId;

      print("Client ID: $clientId");

      final firebaseApp = Firebase.app();
      print("Firebase App: $firebaseApp");
      print("Firebase Options");


    } catch (e){
      print(" debug error $e");
    }
  }

  Future<void> checkIfAccountExist(GoogleSignInAccount googleUser, String tokenIdParams) async {
    String url = OkejekBaseURL.apiUrl('account-check');

    var data = {
      "email": googleUser.email,
    };

    try {
      var response = await dio.post(url,
          options: Options(
            headers: {
              'Accepts': 'application/json',
            },
          ),
          data: data);

      debugPrint("res di login controller account-check $response");

      var responseBody = response.data;
      print("response body login: $responseBody['data']['existing_account']");

      responseBody['data']['existing_account'] == true
          // ? loginGoogleAccount(googleUser, tokenIdParams)
          ? loginViaGoogle(googleUser, tokenIdParams)
          : navigateToInputPhone(googleUser);
    } on DioException catch (e) {
      print(e.message);
    }
  }

  navigateToInputPhone(GoogleSignInAccount googleUser) async {
    print('REGISTERED NEW USER');
    Get.offAll(
      () => InputPhoneNumberPage(
        googleUser: googleUser,
        tokenId: tokenId,
      ),
    );
  }

  // loginGoogleAccount(GoogleSignInAccount googleUser, String tokenIdParams) async {
  //   isLoading.value = true;

  //   String url = OkejekBaseURL.apiUrl('login/google');

  //   var data = {
  //     "name": googleUser.displayName,
  //     "email": googleUser.email,
  //     "phone": inputPhoneController.text,
  //     "token_id": tokenIdParams,
  //   };

  //   print(googleUser.displayName);
  //   print(googleUser.email);
  //   print(inputPhoneController.text);
  //   print(tokenIdParams);

  //   try {
  //     var response = await dio.post(
  //       url,
  //       data: data,
  //       options: Options(
  //         headers: {
  //           'Accepts': 'application/json',
  //         },
  //       ),
  //     );

  //     var responseBody = response.data;
  //     print("maaf login $responseBody");
  //     // check phone number condition
  //     if (!responseBody['success']) {
  //       errorMessage.value = responseBody['message'];
  //       ScaffoldMessenger.of(Get.context!).showSnackBar(
  //         SnackBar(
  //           backgroundColor: Colors.red,
  //           content: Text(
  //             errorMessage.value,
  //             style: TextStyle(
  //               fontSize: 12,
  //               color: Colors.white,
  //             ),
  //           ),
  //         ),
  //       );
  //       isLoading.value = false;
  //     } else {
  //       String userData = jsonEncode(responseBody);
  //       String session = jsonDecode(jsonEncode(responseBody['data']['session']));
  //       SharedPreferences preferences = await SharedPreferences.getInstance();
  //       // storing to shareprefs -> json
  //       preferences.setString('user_data', userData);
  //       preferences.setString('user_session', session);

  //       // preferences.setString('user_session', sessionDecode['data']['session']);

  //       Get.offAll(() => BottomNavigation());
  //       isLoading.value = false;
  //     }
  //   } on DioException catch (e) {
  //     isLoading.value = false;
  //     failedSnackbar();
  //     print(e.message);
  //   }
  // }

  void failedSnackbar() {
    final snackBar = SnackBar(
      backgroundColor: OkejekTheme.primary_color,
      content: Text(
        'Login Gagal',
        style: TextStyle(color: Colors.white, fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6),
      ),
    );

    ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
  }

  getUser() async {
    print('USER ALREADY REGISTERED');
  }

  initializeInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (e, handler) {
          print(e.response);
        },
        onRequest: (options, request) {
          print('on request');

          request.next(options);
        },
        onResponse: (response, handler) {
          print('on response');

          handler.next(response);
        },
      ),
    );
    return dio;
  }
}
