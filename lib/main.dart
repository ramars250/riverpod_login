import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_login/api.dart';
import 'package:riverpod_login/test_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider =
Provider<SharedPreferences>((ref) => throw UnimplementedError());

class SharedMem {
  SharedMem({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Consumer(builder: (context, ref, child) {
            final data =
                ref.watch(sharedPreferencesProvider).getString('MemberGuid') ??
                    '';
            // print(data);
            return Text(data, style: const TextStyle(fontSize: 20),);
          }),
          TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Login()));
            },
            child: const Text('去登入'),
          ),
          TextButton(
            onPressed: () {
              delData();
            },
            child: const Text('清除資料'),
          ),
        ],
      ),
    );
  }

  Future delData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.clear();
    });
  }
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final nameController = TextEditingController();
  final passController = TextEditingController();
  final focus1 = FocusNode();
  final focus2 = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            height: MediaQuery
                .of(context)
                .size
                .height / 10,
            width: MediaQuery
                .of(context)
                .size
                .width * 3 / 4,
            color: Colors.lightBlueAccent,
            child: TextField(
              keyboardType: TextInputType.number,
              autofocus: true,
              focusNode: focus1,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "請輸入手機號碼",
                hintText: "請輸入手機號碼",
                prefixIcon: Icon(Icons.phone_android),
              ),
              controller: nameController,
            ),
          ),
          Container(
            height: MediaQuery
                .of(context)
                .size
                .height / 10,
            width: MediaQuery
                .of(context)
                .size
                .width * 3 / 4,
            color: Colors.lightBlueAccent,
            child: TextField(
              controller: passController,
              focusNode: focus2,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "密碼",
                hintText: "請輸入密碼",
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              putApiData();
              checkDone();
            },
            child: const Text('登入'),
          ),
        ],
      ),
    );
  }

  Future putApiData() async {
    var url = Uri.parse(Api.Devices_login);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final headers = {
      "Content-Type": "application/json",
      "ApiKey": "aaaaaaaabbbbbbbbcccccccc"
    };

    final json = jsonEncode({
      "DeviceType": 2,
      "PushToken": "",
      "CellPhone": nameController.text,
      "Password": passController.text,
    });
    http.Response response = await http.put(url, headers: headers, body: json);
    if (response.statusCode == 200) {
      var successData = jsonDecode(response.body);
      prefs.setString('MemberGuid', successData['MemberGuid']);
    } else {
      throw Exception('Error');
    }
    return Future.delayed(const Duration(seconds: 2), () {
      prefs.getString('MemberGuid');
    });
  }
  
  checkDone() {
    putApiData().whenComplete(() {
      return goNext();
    });
  }

  goNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TestPage(),
      ),
    );
  }
}
