// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:smartmoneytrex/model/account.model.dart';
import 'package:smartmoneytrex/dao/account_dao.dart';
import 'package:smartmoneytrex/events.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({Key? key}) : super(key: key);

  @override
  _StatisticScreenState createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  final AccountDao _accountDao = AccountDao();
  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    loadData();

    globalEvent.on("account_update", (_) {
      debugPrint("Accounts are changed");
      loadData();
    });
  }

  void loadData() async {
    List<Account> accounts = await _accountDao.find(withSummery: true);
    setState(() {
      _accounts = accounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistics"),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Account Balances",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (_accounts.isEmpty) {
      return const Center(
        child: Text("No accounts found"),
      );
    }

    List<_ChartData> chartData = _accounts
        .map((accounts) => _ChartData(accounts.name, accounts.balance ?? 0))
        .toList();

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      series: <ChartSeries<_ChartData, String>>[
        LineSeries<_ChartData, String>(
          dataSource: chartData,
          xValueMapper: (_ChartData data, _) => data.accountName,
          yValueMapper: (_ChartData data, _) => data.balance,
        ),
      ],
    );
  }
}

class _ChartData {
  _ChartData(this.accountName, this.balance);

  final String accountName;
  final double balance;
}
