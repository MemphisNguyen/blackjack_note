import 'dart:convert';

import 'package:blackjack_note/constants.dart';
import 'package:blackjack_note/helper.dart';
import 'package:blackjack_note/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  bool isLoading = true;
  List<_Transfer> transferList = [];
  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  @override
  void initState() {
    super.initState();

    _pref.then((prefs) {
      if (prefs.containsKey(Constants.userPrefName)) {
        String userData = prefs.getString(Constants.userPrefName)!;
        List<UserModel> users = (json.decode(userData) as List)
            .map((value) => UserModel.parse(value))
            .toList();
        List<UserModel> winners =
            users.where((user) => user.amount > 0).toList();
        List<UserModel> losers =
            users.where((user) => user.amount < 0).toList();

        setState(() {
          isLoading = false;
          transferList = _calculateTransfer(winners, losers);
        });
      }
    });
  }

  List<_Transfer> _calculateTransfer(
    List<UserModel> winnerList,
    List<UserModel> loserList,
  ) {
    List<_Transfer> transferList = [];

    while (loserList.isNotEmpty) {
      winnerList.sort((a, b) => (b.amount.compareTo(a.amount)));
      loserList.sort((a, b) => (a.amount.compareTo(b.amount)));

      UserModel winner = winnerList[0];
      UserModel loser = loserList[0];
      double winAmount = winner.amount.abs();
      double loserAmount = loser.amount.abs();
      double transferAmount = winAmount < loserAmount ? winAmount : loserAmount;
      transferList.add(
        _Transfer(loser.name, winner.name, transferAmount, winner.phoneNumber),
      );
      loser.amount += transferAmount;
      winner.amount -= transferAmount;

      if (winner.amount == 0) {
        winnerList.removeAt(0);
      }

      if (loser.amount == 0) {
        loserList.removeAt(0);
      }
    }

    transferList.sort((a, b) => a.from.compareTo(b.from));
    return transferList;
  }

  TableCell _tableCell({
    required Widget child,
    Color? color,
    EdgeInsets padding = const EdgeInsets.symmetric(
      vertical: 10,
      horizontal: 5,
    ),
  }) {
    return TableCell(
      child: Container(
        color: color,
        padding: padding,
        child: child,
      ),
    );
  }

  Future<void> _showQrDialog(
      String name, String phoneNumber, double amount) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Momo QR code',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(phoneNumber),
                        GestureDetector(
                          child: const Icon(Icons.copy),
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: phoneNumber),
                            ).then((value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Số điện thoại đã được lưu vào bộ nhớ tạm.'),
                                ),
                              );
                            });
                          },
                        )
                      ],
                    ),
                    Text(
                      CurrencyHelper.format(amount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: QrImageView(
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                        data:
                            '2|99|$phoneNumber|$name||0|0|${amount.toStringAsFixed(0)}||transfer_myqr',
                        version: QrVersions.auto,
                        size: 200.0,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          actions: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  child: const Text('Xong'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tổng kết')),
      body: ListView(children: [
        Container(
            margin: const EdgeInsets.all(10),
            child: isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [CircularProgressIndicator()],
                      )
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Table(
                        border: TableBorder.all(),
                        children: [
                          TableRow(children: [
                            _tableCell(
                              child: const Text(
                                'Thua',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              color: Colors.red,
                            ),
                            _tableCell(
                              child: const Text(
                                'Thắng',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              color: Colors.green,
                            ),
                            _tableCell(
                              child: const Text(
                                'Số tiền',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              color: Theme.of(context).primaryColor,
                            ),
                            _tableCell(
                              child: const Text(
                                'Momo QR',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ]),
                          ...transferList.map((transfer) {
                            return TableRow(children: [
                              _tableCell(
                                child: Text(transfer.from),
                                color: Colors.red.withOpacity(0.3),
                              ),
                              _tableCell(
                                child: Text(transfer.to),
                                color: Colors.green.withOpacity(0.3),
                              ),
                              _tableCell(
                                child: Text(
                                  CurrencyHelper.format(transfer.amount),
                                  textAlign: TextAlign.right,
                                ),
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.3),
                              ),
                              _tableCell(
                                  child: transfer.phoneNumber.isNotEmpty
                                      ? GestureDetector(
                                          onTap: () {
                                            _showQrDialog(
                                                transfer.to,
                                                transfer.phoneNumber,
                                                transfer.amount);
                                          },
                                          child: Icon(
                                            Icons.qr_code,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        )
                                      : const Text('No phone'),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 7,
                                    horizontal: 5,
                                  ))
                            ]);
                          }),
                        ],
                      )
                    ],
                  )),
      ]),
    );
  }
}

class _Transfer {
  final String from;
  final String to;
  final double amount;
  final String phoneNumber;

  const _Transfer(this.from, this.to, this.amount, this.phoneNumber);
}
