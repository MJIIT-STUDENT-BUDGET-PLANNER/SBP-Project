import 'package:smartmoneytrex/bloc/cubit/app_cubit.dart';
import 'package:smartmoneytrex/screens/accounts/accounts.screen.dart';
import 'package:smartmoneytrex/screens/categories/categories.screen.dart';
import 'package:smartmoneytrex/screens/home/home.screen.dart';
import 'package:smartmoneytrex/screens/onboard/onboard_screen.dart';
import 'package:smartmoneytrex/screens/settings/settings.screen.dart';
import 'package:smartmoneytrex/screens/statistics/statistics.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatefulWidget{
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>{
  final PageController _controller = PageController(keepPage: true);
  int _selected = 0;

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state){
        AppCubit cubit = context.read<AppCubit>();
        if(cubit.state.currency == null || cubit.state.username == null){
          return OnboardScreen();
        }
        return  Scaffold(
          body: PageView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              HomeScreen(),
              AccountsScreen(),
              CategoriesScreen(),
              StatisticScreen()
            ],
            onPageChanged: (int index){
              setState(() {
                _selected = index;
              });
            },
          ),
          bottomNavigationBar: NavigationBar(
  selectedIndex: _selected,
  destinations: const [
    NavigationDestination(icon: Icon(Icons.home), label: "Home"),
    NavigationDestination(icon: Icon(Icons.wallet), label: "Accounts"),
    NavigationDestination(icon: Icon(Icons.category), label: "Categories"),
    NavigationDestination(icon: Icon(Icons.insert_chart), label: "Statistics"),
  ],
  onDestinationSelected: (int selected) {
    _controller.jumpToPage(selected);
  },
),

drawer: NavigationDrawer(
  selectedIndex: _selected,
  children: const [
    NavigationDrawerDestination(icon: Icon(Icons.home), label: Text("Home")),
    NavigationDrawerDestination(icon: Icon(Icons.wallet), label: Text("Accounts")),
    NavigationDrawerDestination(icon: Icon(Icons.category), label: Text("Categories")),
    NavigationDrawerDestination(icon: Icon(Icons.insert_chart), label: Text("Statistics")),
    NavigationDrawerDestination(icon: Icon(Icons.settings), label: Text("Settings")),
  ],
  onDestinationSelected: (int selected) {
    Navigator.pop(context);
    _controller.jumpToPage(selected);
    if (selected == 4) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
    }
  },
    ),
    );
  },
    );
  }
}