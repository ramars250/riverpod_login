import 'package:flutter/material.dart';
import 'package:riverpod_login/api.dart';

// ignore_for_file: avoid_print
class MemberList extends StatefulWidget {
  const MemberList({Key? key}) : super(key: key);

  @override
  State<MemberList> createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  @override
  void initState() {
    // print(Api.Members_summary1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          Api.Members_summary1,
          style: const TextStyle(fontSize: 20),
        ),
      ],
    );
  }
}
