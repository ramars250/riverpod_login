import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_login/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {

  set setName(String name) {
    memberGuid = name;
  }

  static String memberGuid = '';

  static String Devices_login = '$BASE_URL/Devices/$AppToken/login';

  static String get Members_summary => '$BASE_URL/Members/$memberGuid/summary';

  static String get Members_summary1 => '$BASE_URL/Members/$memberGuid/summary';

  static const String AppToken = 'A608DDD5-8DFF-490B-93B5-348F11C688F5';

  static const String BASE_URL = 'https://www2.taimall.com.tw:8443/api';

}

class ApiMember {

}