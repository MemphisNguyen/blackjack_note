import 'package:blackjack_note/helper.dart';
import 'package:blackjack_note/models/user_model.dart';
import 'package:flutter/material.dart';

class UserWidget extends StatefulWidget {
  final UserModel user;
  final bool isShowAmount;
  final void Function(double) onWin;
  final void Function(double) onLose;
  final void Function() onSetAsDealer;
  final void Function(String, String) onEditName;
  final void Function() onDelete;

  const UserWidget({
    super.key,
    required this.user,
    required this.onWin,
    required this.onLose,
    required this.onSetAsDealer,
    required this.onEditName,
    required this.onDelete,
    this.isShowAmount = true,
  });

  @override
  State<UserWidget> createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _showChangeAmountDialog(bool isWin) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: isWin
              ? Text('${widget.user.name} đã thắng')
              : Text('${widget.user.name} đã thua'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                const Text('Số tiền đã cược'),
                TextField(
                  autofocus: true,
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                ),
                Wrap(
                  spacing: 10,
                  children: [
                    '1000',
                    '2000',
                    '5000',
                    '10000',
                    '20000',
                  ]
                      .map((v) => OutlinedButton(
                          onPressed: () {
                            _amountController.text = v;
                          },
                          child: Text(NumberHelper.format(double.parse(v)))))
                      .toList(),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Huỷ'),
              onPressed: () {
                _amountController.clear();
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Cập nhật'),
              onPressed: () {
                if (_amountController.text.isNotEmpty) {
                  if (isWin) {
                    widget.onWin(double.parse(_amountController.text));
                  } else {
                    widget.onLose(double.parse(_amountController.text));
                  }
                  _amountController.clear();
                  Navigator.of(context).pop();
                } else {}
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog() async {
    _nameController.text = widget.user.name;
    _phoneNumberController.text = widget.user.phoneNumber;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sửa tên ${widget.user.name}'),
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
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Huỷ'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Cập nhật'),
              onPressed: () {
                widget.onEditName(
                  _nameController.text,
                  _phoneNumberController.text,
                );
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

  Future<void> _showDeleteDialog() async {
    _nameController.value = TextEditingValue(text: widget.user.name);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xoá người chơi ${widget.user.name}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Bạn có chắc muốn xoá người chơi ${widget.user.name}?'),
                const Text(
                  'Lưu ý: thao tác này sẽ không thể hoàn tác.',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Huỷ'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                widget.onDelete();
                Navigator.of(context).pop();
              },
              child: const Text('Xoá'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      elevation: 5,
      child: Stack(
        children: [
          Container(
            color: widget.user.isDealer ? Colors.yellow : null,
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.user.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (widget.isShowAmount)
                        Text(
                          CurrencyHelper.format(widget.user.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                      if (widget.user.isDealer)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.bookmark_sharp),
                            Text(
                              'Nhà cái',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (!widget.user.isDealer)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GridView.count(
                        crossAxisCount: 2,
                        primary: false,
                        shrinkWrap: true,
                        childAspectRatio: 2.5,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _showChangeAmountDialog(true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text(
                              'Thắng',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _showChangeAmountDialog(false);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text(
                              'Thua',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          widget.onSetAsDealer();
                        },
                        child: const Text(
                          'Làm cái',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
          Positioned(
              top: 0,
              right: 0,
              child: PopupMenuButton(
                onSelected: (action) {
                  switch (action) {
                    case 'edit':
                      _showEditDialog();
                      break;
                    case 'delete':
                      _showDeleteDialog();
                      break;

                    default:
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Sửa thông tin'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Xoá',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
