import 'dart:convert';

import 'package:blackjack_note/constants.dart';
import 'package:blackjack_note/models/log.dart';
import 'package:blackjack_note/models/user_model.dart';
import 'package:blackjack_note/widgets/user.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool isLoading = true;
  List<UserModel> users = [];
  List<Log> logs = [];
  bool isShowAmount = true;
  UserModel? dealer;

  @override
  void initState() {
    super.initState();
    _prefs.then((prefs) {
      if (prefs.containsKey(Constants.userPrefName)) {
        String userData = prefs.getString(Constants.userPrefName)!;
        List<UserModel> savedUsers = (json.decode(userData) as List)
            .map((value) => UserModel.parse(value))
            .toList();
        for (var user in savedUsers) {
          if (user.isDealer) {
            if (dealer == null) {
              dealer = user;
            } else {
              user.setAsPlayer();
            }
          }
        }

        setState(() {
          users = savedUsers;
          List<UserModel> foundDealer =
              savedUsers.where((user) => user.isDealer).toList();

          if (foundDealer.isNotEmpty) {
            dealer = foundDealer[0];
          }

          isLoading = false;
        });
      }

      if (prefs.containsKey(Constants.logPrefName)) {
        String logData = prefs.getString(Constants.logPrefName)!;

        setState(() {
          logs = (json.decode(logData) as List).map((data) {
            if (data['dealer'] != null) {
              return ChangeLog.parse(data);
            }

            return EndLog();
          }).toList();
        });
      }

      setState(() {
        isLoading = false;
      });
    });
  }

  void saveToPref() async {
    SharedPreferences prefs = await _prefs;
    prefs.setString(Constants.userPrefName, json.encode(users));
    prefs.setString(Constants.logPrefName, json.encode(logs));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _showAddUserDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thêm người chơi '),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextField(
                  decoration: InputDecoration(
                    label: Row(
                      children: const [
                        Text('Tên người chơi'),
                        Text(
                          '*',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  autofocus: true,
                  controller: _nameController,
                ),
                TextField(
                  decoration: const InputDecoration(
                    label: Text('Số điện thoại dùng Momo'),
                  ),
                  autofocus: true,
                  controller: _phoneNumberController,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Huỷ'),
              onPressed: () {
                _nameController.clear();
                _phoneNumberController.clear();
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Thêm'),
              onPressed: () {
                setState(() {
                  users.add(UserModel(
                      name: _nameController.text,
                      phoneNumber: _phoneNumberController.text));
                });
                saveToPref();
                _nameController.clear();
                _phoneNumberController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showResetDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xoá dữ liệu'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const [
                Text(
                    'Bạn có chắc chắn muốn xoá tất cả dữ liệu bao gồm người chơi, số ghi nợ và nhật ký?'),
                Text(
                  'Lưu ý: Thao tác này không thể hoàn tác,',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Xoá tất cả'),
                  onPressed: () {
                    setState(() {
                      users = [];
                      logs = [];
                      saveToPref();
                    });

                    Navigator.of(context).pop();
                  },
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Chỉ xoá ghi nợ và nhật ký'),
                  onPressed: () {
                    setState(() {
                      logs = [];
                      for (UserModel user in users) {
                        user.amount = 0;
                      }
                      saveToPref();
                    });

                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Huỷ'),
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

  int getGridColumn(double screenWidth) {
    if (screenWidth > 991) {
      return 4;
    }

    if (screenWidth > 500) {
      return 3;
    }

    return 2;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 30;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sổ Xì Dzách'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('log');
            },
            icon: const Icon(Icons.note_alt_outlined),
          ),
          IconButton(
            onPressed: () {
              _showResetDialog();
            },
            icon: const Icon(Icons.delete_forever_outlined),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (logs.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('summary');
                },
                child: const Text('Tổng kết'),
              ),
            if (logs.isNotEmpty && logs[logs.length - 1].name != 'EndLog')
              OutlinedButton(
                style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () {
                  setState(() {
                    logs.add(EndLog());
                    saveToPref();
                  });
                },
                child: const Text('Kết thúc vòng'),
              )
          ],
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Switch(
                value: isShowAmount,
                onChanged: (value) {
                  setState(() {
                    isShowAmount = value;
                  });
                }),
            title: const Text('Hiện số tiền'),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              children: isLoading
                  ? const [
                      CircularProgressIndicator(),
                    ]
                  : [
                      GridView.builder(
                          primary: false,
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            crossAxisCount: getGridColumn(width),
                          ),
                          itemCount: users.length + 1,
                          itemBuilder: ((context, index) {
                            if (index == users.length) {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () {
                                  _showAddUserDialog();
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.add,
                                      size: 50,
                                    ),
                                    Text('Thêm người chơi'),
                                  ],
                                ),
                              );
                            }

                            UserModel user = users[index];
                            return UserWidget(
                              user: user,
                              isShowAmount: isShowAmount,
                              onWin: (amount) {
                                if (dealer != null) {
                                  setState(() {
                                    user.increase(amount);
                                    dealer!.decrease(amount);
                                    logs.add(
                                      ChangeLog(
                                        dealer: dealer!.name,
                                        player: user.name,
                                        isPlayerWin: true,
                                        amount: amount,
                                      ),
                                    );
                                    saveToPref();
                                  });
                                }
                              },
                              onLose: (amount) {
                                if (dealer != null) {
                                  setState(() {
                                    user.decrease(amount);
                                    dealer!.increase(amount);
                                    logs.add(
                                      ChangeLog(
                                        dealer: dealer!.name,
                                        player: user.name,
                                        isPlayerWin: false,
                                        amount: amount,
                                      ),
                                    );
                                    saveToPref();
                                  });
                                }
                              },
                              onSetAsDealer: () {
                                if (!user.isDealer) {
                                  setState(() {
                                    if (dealer != null) {
                                      dealer!.setAsPlayer();
                                    }
                                    user.setAsDealer();
                                    dealer = user;
                                    saveToPref();
                                    // users = [...users];
                                  });
                                }
                              },
                              onEditName: (newName, newPhoneNumber) {
                                setState(() {
                                  user.name = newName;
                                  user.phoneNumber = newPhoneNumber;
                                });
                                saveToPref();
                              },
                              onDelete: () {
                                setState(() {
                                  users.removeAt(index);
                                });
                              },
                            );
                          })),
                      const SizedBox(height: 70)
                    ],
            ),
          )
        ],
      ),
    );
  }
}
