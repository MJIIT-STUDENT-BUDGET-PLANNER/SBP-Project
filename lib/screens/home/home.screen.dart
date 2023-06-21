// ignore_for_file: unused_element, use_build_context_synchronously

import 'package:events_emitter/events_emitter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smartmoneytrex/bloc/cubit/app_cubit.dart';
import 'package:smartmoneytrex/dao/account_dao.dart';
import 'package:smartmoneytrex/dao/payment_dao.dart';
import 'package:smartmoneytrex/events.dart';
import 'package:smartmoneytrex/model/account.model.dart';
import 'package:smartmoneytrex/model/category.model.dart';
import 'package:smartmoneytrex/model/payment.model.dart';
import 'package:smartmoneytrex/screens/home/widgets/account_slider.dart';
import 'package:smartmoneytrex/screens/home/widgets/payment_list_item.dart';
import 'package:smartmoneytrex/screens/payment_form.screen.dart';
import 'package:smartmoneytrex/theme/colors.dart';
import 'package:smartmoneytrex/widgets/currency.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smartmoneytrex/utils/notification_helper.dart';

String greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Morning';
  }
  if (hour < 17) {
    return 'Afternoon';
  }
  return 'Evening';
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PaymentDao _paymentDao = PaymentDao();
  final AccountDao _accountDao = AccountDao();
  EventListener? _accountEventListener;
  EventListener? _categoryEventListener;
  EventListener? _paymentEventListener;
  List<Payment> _payments = [];
  List<Account> _accounts = [];
  double _income = 0;
  double _expense = 0;
  DateTimeRange _range = DateTimeRange(
    start: DateTime.now().subtract(Duration(days: DateTime.now().day - 1)),
    end: DateTime.now(),
  );
  Account? _account;
  Category? _category;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late NotificationHelper notificationHelper;

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Reminder',
      'Don\'t forget to use the app!',
      platformChannelSpecifics,
      payload: 'default',
    );
  }

  Future<void> _scheduleDailyNotification(TimeOfDay time) async {
    final now = DateTime.now();
    final scheduledTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);

    await notificationHelper.scheduleDailyNotification(
      id: 1,
      title: 'Reminder',
      body: 'Don\'t forget to use the app!',
      scheduledDateTime: scheduledTime,
    );
  }

  void openAddPaymentPage(PaymentType type) async {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (builder) => PaymentForm(type: type)));
  }

  void handleChooseDateRange() async {
    final selected = await showDateRangePicker(
      context: context,
      initialDateRange: _range,
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      setState(() {
        _range = selected;
        _fetchTransactions();
      });
    }
  }

  void _fetchTransactions() async {
    List<Payment> trans = await _paymentDao.find(
        range: _range, category: _category, account: _account);
    double income = 0;
    double expense = 0;
    for (var payment in trans) {
      if (payment.type == PaymentType.credit) income += payment.amount;
      if (payment.type == PaymentType.debit) expense += payment.amount;
    }

    //fetch accounts
    List<Account> accounts = await _accountDao.find(withSummery: true);

    setState(() {
      _payments = trans;
      _income = income;
      _expense = expense;
      _accounts = accounts;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchTransactions();

    _accountEventListener = globalEvent.on("account_update", (data) {
      debugPrint("accounts are changed");
      _fetchTransactions();
    });

    _categoryEventListener = globalEvent.on("category_update", (data) {
      debugPrint("categories are changed");
      _fetchTransactions();
    });

    _paymentEventListener = globalEvent.on("payment_update", (data) {
      debugPrint("payments are changed");
      _fetchTransactions();
    });

    // Initialize flutter local notifications plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    notificationHelper = NotificationHelper(flutterLocalNotificationsPlugin);
  }

  @override
  void dispose() {
    _accountEventListener?.cancel();
    _categoryEventListener?.cancel();
    _paymentEventListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: const Text(
          "Home",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Set Daily Reminder'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Choose a time to receive a daily reminder:'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (selectedTime != null) {
                            _scheduleDailyNotification(selectedTime);
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Select Time'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hi! Good ${greeting()}"),
                  BlocConsumer<AppCubit, AppState>(
                    listener: (context, state) {},
                    builder: (context, state) => Text(
                        state.username ?? "Guest",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 190,
              width: double.infinity,
              child: AccountsSlider(accounts: _accounts),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  const Text(
                    "Payments",
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                  ),
                  const Expanded(child: SizedBox()),
                  MaterialButton(
                    onPressed: () {
                      handleChooseDateRange();
                    },
                    height: double.minPositive,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                    child: Row(
                      children: [
                        Text(
                          "${DateFormat("dd MMM").format(_range.start)} - ${DateFormat("dd MMM").format(_range.end)}",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const Icon(Icons.arrow_drop_down_outlined)
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: ThemeColors.success.withOpacity(0.2),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                      text: "Income",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            CurrencyText(
                              _income,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: ThemeColors.success,
                                  fontFamily:
                                      GoogleFonts.jetBrainsMono().fontFamily),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: ThemeColors.error.withOpacity(0.2),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                      text: "Expense",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            CurrencyText(
                              _expense,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: ThemeColors.error,
                                  fontFamily:
                                      GoogleFonts.jetBrainsMono().fontFamily),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _payments.isNotEmpty
                ? ListView.separated(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return PaymentListItem(
                        payment: _payments[index], onTap: () {  },
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider(
                        height: 0,
                        thickness: 0.5,
                      );
                    },
                    itemCount: _payments.length,
                  )
                : const SizedBox(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openAddPaymentPage(PaymentType.credit);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
