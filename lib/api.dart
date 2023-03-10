import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_login/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {

  // final share = Provider<SharedMem>((ref) {
  //   final response = ref.watch(sharedProvider).sharedPreferences;
  //   return ;
  // });

  static String memberGuid = '';

  static const String AppToken = 'A608DDD5-8DFF-490B-93B5-348F11C688F5';

  static const String BASE_URL = 'https://www2.taimall.com.tw:8443/api';

  static const String Devices_login = '$BASE_URL/Devices/$AppToken/login';
}