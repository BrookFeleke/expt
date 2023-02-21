import 'package:flutter/material.dart';

class Transaction {
  String? id;
  String? title;
  double? amount;
  DateTime? date;

  Transaction(
      {required this.id,
      required this.title,
      required this.amount,
      required this.date});

  Map<String, dynamic> toJson() =>
      { 'id':id,'title': title, "amount": amount, "date": date};

  Transaction.fromSnapShot(snapshot)
      : id = snapshot.data()["id"],
        title = snapshot.data()['title'],
        amount = snapshot.data()['amount'],
        date = snapshot.data()['date'].toDate();
}
