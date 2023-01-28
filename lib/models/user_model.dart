class UserModel {
  String name;
  String phoneNumber;
  double amount;
  bool isDealer;

  UserModel({
    required this.name,
    this.amount = 0,
    this.isDealer = false,
    this.phoneNumber = '',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
        'is_dealer': isDealer,
        'phone_number': phoneNumber,
      };

  static UserModel parse(dynamic data) {
    return UserModel(
      name: data['name'],
      phoneNumber: data['phone_number'] ?? '',
      amount: data['amount'],
      isDealer: data['is_dealer'],
    );
  }

  void setAsDealer() {
    isDealer = true;
  }

  void setAsPlayer() {
    isDealer = false;
  }

  void increase(double amount) {
    this.amount += amount;
  }

  void decrease(double amount) {
    this.amount -= amount;
  }
}
