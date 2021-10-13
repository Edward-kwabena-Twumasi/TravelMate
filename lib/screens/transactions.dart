import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart ' as http;

void main() {}

class Translist extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(home: YourTransactions());
  }
}


class YourTransactions extends StatefulWidget {
  const YourTransactions({ Key? key }) : super(key: key);

  @override
  _YourTransactionsState createState() => _YourTransactionsState();
}

class _YourTransactionsState extends State<YourTransactions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        
      ),
    );
  }
}

class Transactions {
  String message;
  Map<String, dynamic> data;
  bool status;
  Transactions(
      {required this.message, required this.data, required this.status});

  factory Transactions.fromJson(Map<String, dynamic> json) {
    return Transactions(
        message: json["message"], data: json["data"], status: json["status"]);
  }
}

Future<Transactions> transactionlist(String key) async {
  final response = await http.get(
    Uri.parse("https://api.paystack.co/transaction"),
    headers: {
      HttpHeaders.authorizationHeader: 'Bearer $key',
    },
  );

  if (response.statusCode == 200) {
// If the server did return a 200 ok response,
// then parse the JSON.
    return Transactions.fromJson(jsonDecode(response.body));
  } else {
// If the server did not return a 201 CREATED response,
// then throw an exception.
    throw Exception('Failed to initialise transaction.');
  }
}
