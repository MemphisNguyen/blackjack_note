import 'package:blackjack_note/helper.dart';
import 'package:flutter/material.dart';

abstract class Log {
  abstract final String name;
  Widget render();
}

class ChangeLog extends Log {
  @override
  final String name = 'ChangeLog';
  String dealer;
  String player;
  bool isPlayerWin;
  double amount;

  ChangeLog({
    required this.dealer,
    required this.player,
    required this.isPlayerWin,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'dealer': dealer,
      'player': player,
      'player_win': isPlayerWin,
      'amount': amount,
    };
  }

  @override
  Widget render() {
    String dealerAmount = CurrencyHelper.format(isPlayerWin ? -amount : amount);
    String playerAmount = CurrencyHelper.format(isPlayerWin ? amount : -amount);
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text('$dealer: '),
        ),
        SizedBox(
          width: 80,
          child: Text(
            dealerAmount,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: isPlayerWin ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(
            width: 30,
            child: Text(
              '|',
              textAlign: TextAlign.center,
            )),
        SizedBox(
          width: 60,
          child: Text('$player: '),
        ),
        SizedBox(
          width: 80,
          child: Text(
            playerAmount,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: isPlayerWin ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  static ChangeLog parse(data) {
    return ChangeLog(
      dealer: data['dealer'],
      player: data['player'],
      isPlayerWin: data['player_win'],
      amount: data['amount'],
    );
  }
}

class EndLog extends Log {
  @override
  final String name = 'EndLog';

  Map toJson() => {};

  @override
  Widget render() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
