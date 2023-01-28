import 'dart:convert';

import 'package:blackjack_note/models/log.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  static const String logPrefName = 'logs';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool isLoading = true;
  List<Log> logs = [];

  @override
  void initState() {
    super.initState();
    _prefs.then((prefs) {
      if (prefs.containsKey(logPrefName)) {
        String logData = prefs.getString(logPrefName)!;

        setState(() {
          logs = (json.decode(logData) as List).map((data) {
            if (data['dealer'] != null) {
              return ChangeLog.parse(data);
            }

            return EndLog();
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhật ký'),
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: logs
                  .asMap()
                  .map((index, logRecord) => MapEntry(
                        index,
                        Container(
                          padding: logRecord.name == 'EndLog'
                              ? null
                              : const EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 10,
                                ),
                          color: index % 2 == 0 || logRecord.name == 'EndLog'
                              ? null
                              : Colors.black12,
                          child: logRecord.render(),
                        ),
                      ))
                  .values
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
