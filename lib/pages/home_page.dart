import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';
import '../models/transaction.dart';
import '../widgets/transactions_list.dart';
import '../widgets/new_transaction.dart';
import '../widgets/chart.dart';
// import 'firebase_options.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// final db = FirebaseFirestore.instance;
class _MyHomePageState extends State<MyHomePage> {
  // String titleInput;
  final user = FirebaseAuth.instance.currentUser!;
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  var logger = Logger();
  final List<Transaction> _userTransactions = [];
  List<Transaction> _trans = [];
  List<Transaction> get _recentTransaction {
    return _userTransactions.where((element) {
      return element.date!.isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
  }

  // Transaction _transaction = Transaction();
  void _addNewTransaction(
      String txTitle, double txAmount, DateTime date) async {
    final newTx = Transaction(
        id: DateTime.now().toString(),
        title: txTitle,
        amount: txAmount,
        date: date);
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("transactions")
        .add(newTx.toJson());
    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return NewTransaction(_addNewTransaction);
        });
  }

  void _deleteTransaction(String id) async {
    // _startAddNewTransaction(context);

    print("This is being called ");
    var idc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("transactions")
        .get()
        .then((value) {
      String? idd;
      value.docs.forEach((element) {
        if (element.data()["id"] == id) {
          idd = element.id;
        }
        logger.d(element.data());
      });
      return idd;
    });
    // .where("id", isEqualTo: "2023-02-21 23:46:36.217245")
    // .snapshots().elementAt(0).toString();
    var dell = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("transactions")
        .doc(idc)
        .delete()
        .then((value) => print("fdaf"));
    // print(idc);
    // logger.v(dell);
    setState(() {
      _userTransactions.removeWhere((element) => element.id == id);
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    getTransactions();
  }

  @override
  Widget build(BuildContext context) {
    // String brik = FirebaseAuth.instance.currentUser?.uid !=null? FirebaseAuth.instance.currentUser?.uid : "d";
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.green.shade800,
        title: Text('Expense Tracker'),
        actions: [
          // IconButton(
          //     onPressed: () {
          //       _startAddNewTransaction(context);
          //     },
          //     icon: Icon(Icons.add)),
          IconButton(onPressed: signUserOut, icon: Icon(Icons.logout))
        ],
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          // Text(FirebaseAuth.instance.currentUser?.uid ),
          // Chart(_recentTransaction),

          Flexible(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(user.uid)
                  .collection("transactions")
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  print("YES IT HAS DATA");
                  print(snapshot.data!.size);
                  // return ListView.builder(
                  //     itemCount: snapshot.data!.docs.length,
                  //     itemBuilder: (context, index) {
                  var data = snapshot.data!;
                  //       print(data!.docs[index]);

                  List<Transaction> tranny = List.from(
                      data.docs.map((e) => Transaction.fromSnapShot(e)));
                  List<Transaction> rec = tranny.where((element) {
                    return element.date!
                        .isAfter(DateTime.now().subtract(Duration(days: 7)));
                  }).toList();
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Chart(rec),
                        TransactionList(tranny, _deleteTransaction),
                      ],
                    ),
                  );
                } else {
                  return Center(
                    child: Column(
                      children: [
                        Text('No Transactions Yet'),
                        SizedBox(height: 10),
                        Container(
                            height: 150,
                            child: Image.asset('assets/images/waiting.png',
                                fit: BoxFit.cover))
                      ],
                    ),
                  );
                }
              },
            ),
          ),

          // TransactionList(_trans, _deleteTransaction),
        ],
      ),

      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        // backgroundColor: Colors.green.shade500,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onBackground,
        ),
        onPressed: () {
          _startAddNewTransaction(context);
        },
      ),
    );
  }

  Future getTransactions() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    var data = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection('transactions')
        .orderBy('date')
        .get();

    setState(() {
      _trans = List.from(data.docs.map((e) => Transaction.fromSnapShot(e)));
    });
  }
}
