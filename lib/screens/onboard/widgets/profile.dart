import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartmoneytrex/bloc/cubit/app_cubit.dart';
import 'package:smartmoneytrex/helpers/color.helper.dart';

class ProfileWidget extends StatelessWidget {
  final VoidCallback onGetStarted;

  const ProfileWidget({Key? key, required this.onGetStarted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppCubit cubit = context.read<AppCubit>();
    TextEditingController controller =
        TextEditingController(text: cubit.state.username);

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Image.asset('assets/img/logo2.png'),
                ),
              ),
              const SizedBox(height: 25),
              Text(
                "Hi! Welcome to Smart Moneytrex",
                style: theme.textTheme.titleLarge!.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "What should we call you?",
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: ColorHelper.darken(theme.textTheme.bodyLarge!.color!),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  prefixIcon: const Icon(Icons.account_circle),
                  hintText: "Enter your name",
                  labelText: "Name",
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (controller.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter your name")),
                      );
                    } else {
                      cubit.updateUsername(controller.text).then((value) {
                        onGetStarted();
                      });
                    }
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text("Next"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
