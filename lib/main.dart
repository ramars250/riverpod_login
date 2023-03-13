import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_login/api.dart';
import 'package:riverpod_login/member_list.dart';
import 'package:riverpod_login/test_page.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore_for_file: avoid_print
final sharedPreferencesProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError());

final memProvider = StateProvider<String>((ref) {
  // final preferences = ref.watch(sharedPreferencesProvider);
  // final memGuid = preferences.getString('MemberGuid') ?? '';
  // ref.listenSelf((previous, memberGuid) {
  //   preferences.setString('MemberGuid', memberGuid);
  // });
  // Api().setName = memGuid;
  return '';
});

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
  late double bright;

  Future checkMem() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('MemberGuid') != '') {
      setState(() {
        Api().setName = prefs.getString('MemberGuid') ?? '';
      });
    }
  }

  checkFinish() {
    setState(() {
      checkMem().whenComplete(() => const MemberList());
    });
  }

  @override
  void initState() {
    checkFinish();
    // ScreenBrightness().setScreenBrightness(double.parse(bright));
    super.initState();
  }

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
            return Text(
              data,
              style: const TextStyle(fontSize: 20),
            );
          }),
          const MemberList(),
          TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Login2()));
            },
            child: const Text('去登入'),
          ),
          TextButton(
            onPressed: () {
              delData();
            },
            child: const Text('清除資料'),
          ),
          TextButton(
            onPressed: () {
              // currentBrightness;
              ScreenBrightness().setScreenBrightness(1.0);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TestPage(),
                ),
              );
            },
            child: const Text('TestPage'),
          ),
          FutureBuilder<double>(
            future: ScreenBrightness().current,
            builder: (context, snapshot) {
              double currentBright = 0;
              if (snapshot.hasData) {
                currentBright = snapshot.data!;
                bright = currentBright;
              }
              return Text(currentBright.toString());
            },
          ),
        ],
      ),
    );
  }

  Future delData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.clear();
      Api().setName = '';
    });
  }
}

class Login1 extends ConsumerWidget {
  Login1({Key? key}) : super(key: key);
  late String memBer;

  final nameController = TextEditingController();
  final passController = TextEditingController();
  final focus1 = FocusNode();
  final focus2 = FocusNode();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height / 10,
            width: MediaQuery.of(context).size.width * 3 / 4,
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
            height: MediaQuery.of(context).size.height / 10,
            width: MediaQuery.of(context).size.width * 3 / 4,
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
              putApiData(ref);
              checkDone(context, ref);
            },
            child: const Text('登入'),
          ),
        ],
      ),
    );
  }

  Future putApiData(ref) async {
    var url = Uri.parse(Api.Devices_login);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final headers = {
      "Content-Type": "application/json",
      "ApiKey": "aaaaaaaabbbbbbbbcccccccc"
    };

    final json = jsonEncode({
      "DeviceType": 2,
      "PushToken": "",
      "CellPhone": '0921945420',
      "Password": '435146',
    });
    http.Response response = await http.put(url, headers: headers, body: json);
    if (response.statusCode == 200) {
      var successData = jsonDecode(response.body);
      prefs.setString('MemberGuid', successData['MemberGuid']);
      ref.read(memProvider.notifier).state = successData['MemberGuid'];
      Api().setName = prefs.getString('MemberGuid').toString();
      memBer = prefs.getString('MemberGuid').toString();
    } else {
      throw Exception('Error');
    }
    return prefs.getString('MemberGuid');
  }

  checkDone(context, ref) {
    putApiData(ref).whenComplete(() {
      return goNext(ref);
    });
  }

  goNext(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TestPage(),
      ),
    );
  }
}

class Login2 extends ConsumerStatefulWidget {
  const Login2({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _Login2State();
}

class _Login2State extends ConsumerState<Login2> {
  final nameController = TextEditingController();
  final passController = TextEditingController();
  final focus1 = FocusNode();
  final focus2 = FocusNode();

  checkMem() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('MemberGuid') != '') {
      Api().setName = prefs.getString('MemberGuid').toString();
    }
  }

  @override
  void initState() {
    checkMem();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final data = ref.watch(memProvider);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height / 10,
            width: MediaQuery.of(context).size.width * 3 / 4,
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
            height: MediaQuery.of(context).size.height / 10,
            width: MediaQuery.of(context).size.width * 3 / 4,
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
              putApiData(ref);
              checkDone(context, ref);
            },
            child: const Text('登入'),
          ),
        ],
      ),
    );
  }

  Future putApiData(ref) async {
    var url = Uri.parse(Api.Devices_login);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final headers = {
      "Content-Type": "application/json",
      "ApiKey": "aaaaaaaabbbbbbbbcccccccc"
    };

    final json = jsonEncode({
      "DeviceType": 2,
      "PushToken": "",
      "CellPhone": '0921945420',
      "Password": '435146',
    });
    http.Response response = await http.put(url, headers: headers, body: json);
    if (response.statusCode == 200) {
      var successData = jsonDecode(response.body);
      prefs.setString('MemberGuid', successData['MemberGuid']);
      ref.read(memProvider.notifier).state = successData['MemberGuid'];
      setState(() {
        Api().setName = ref.read(memProvider.notifier).state;
      });
    } else {
      throw Exception('Error');
    }
    return prefs.getString('MemberGuid');
  }

  checkDone(context, ref) {
    putApiData(ref).whenComplete(() {
      return goNext(ref);
    });
  }

  goNext(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TestPage(),
      ),
    );
  }

  Future delData2() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    ref.read(memProvider.notifier).state = '';
    setState(() {
      Api().setName = ref.read(memProvider.notifier).state;
    });
  }
}

// class Login extends StatefulWidget {
//   const Login({Key? key}) : super(key: key);
//
//   @override
//   State<Login> createState() => _LoginState();
// }
//
// class _LoginState extends State<Login> {
//   final nameController = TextEditingController();
//   final passController = TextEditingController();
//   final focus1 = FocusNode();
//   final focus2 = FocusNode();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             alignment: Alignment.center,
//             height: MediaQuery
//                 .of(context)
//                 .size
//                 .height / 10,
//             width: MediaQuery
//                 .of(context)
//                 .size
//                 .width * 3 / 4,
//             color: Colors.lightBlueAccent,
//             child: TextField(
//               keyboardType: TextInputType.number,
//               autofocus: true,
//               focusNode: focus1,
//               obscureText: true,
//               decoration: const InputDecoration(
//                 labelText: "請輸入手機號碼",
//                 hintText: "請輸入手機號碼",
//                 prefixIcon: Icon(Icons.phone_android),
//               ),
//               controller: nameController,
//             ),
//           ),
//           Container(
//             height: MediaQuery
//                 .of(context)
//                 .size
//                 .height / 10,
//             width: MediaQuery
//                 .of(context)
//                 .size
//                 .width * 3 / 4,
//             color: Colors.lightBlueAccent,
//             child: TextField(
//               controller: passController,
//               focusNode: focus2,
//               obscureText: true,
//               decoration: const InputDecoration(
//                 labelText: "密碼",
//                 hintText: "請輸入密碼",
//                 prefixIcon: Icon(Icons.lock),
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               putApiData();
//               checkDone();
//             },
//             child: const Text('登入'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future putApiData() async {
//     var url = Uri.parse(Api.Devices_login);
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final headers = {
//       "Content-Type": "application/json",
//       "ApiKey": "aaaaaaaabbbbbbbbcccccccc"
//     };
//
//     final json = jsonEncode({
//       "DeviceType": 2,
//       "PushToken": "",
//       "CellPhone": nameController.text,
//       "Password": passController.text,
//     });
//     http.Response response = await http.put(url, headers: headers, body: json);
//     if (response.statusCode == 200) {
//       var successData = jsonDecode(response.body);
//       prefs.setString('MemberGuid', successData['MemberGuid']);
//     } else {
//       throw Exception('Error');
//     }
//     return Future.delayed(const Duration(seconds: 2), () {
//       prefs.getString('MemberGuid');
//     });
//   }
//
//   checkDone() {
//     putApiData().whenComplete(() {
//       return goNext();
//     });
//   }
//
//   goNext() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const TestPage(),
//       ),
//     );
//   }
// }
