import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_login/api.dart';
import 'package:riverpod_login/main.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:screen_brightness/screen_brightness.dart';

class TestPage extends ConsumerWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  Widget build(context, WidgetRef ref) {
    final data = ref.watch(memProvider);
    // print(data);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              data,
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              Api.Members_summary1,
              style: const TextStyle(fontSize: 36),
            ),
            TextButton(
              onPressed: () {
                ScreenBrightness().setScreenBrightness(0.0);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyHomePage(),
                  ),
                );
              },
              child: const Text(
                '回首頁',
                style: TextStyle(fontSize: 30),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(memProvider.notifier).state = '';
                Api().setName = ref.read(memProvider.notifier).state;
              },
              child: const Text(
                '清資料',
                style: TextStyle(fontSize: 30),
              ),
            ),
            BarcodeWidget(
              data: '291800412659',
              barcode: Barcode.code128(),
              width: MediaQuery.of(context).size.width - 100,
              height: 100,
              padding: const EdgeInsets.only(top: 10),
            ),
            FutureBuilder<double>(
              future: ScreenBrightness().current,
              builder: (context, snapshot) {
                double currentBright = 0;
                if (snapshot.hasData) {
                  currentBright = snapshot.data!;
                }
                return Text(currentBright.toString());
              },
            ),
          ],
        ),
      ),
    );
  }
}
