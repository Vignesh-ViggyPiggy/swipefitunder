import 'package:flutter/material.dart';
import 'package:swipefit/resources/auth_methods.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Settingspage extends ConsumerStatefulWidget {
  const Settingspage({super.key});

  @override
  ConsumerState<Settingspage> createState() => _SettingspageState();
}

class _SettingspageState extends ConsumerState<Settingspage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Settings Page'),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color.fromARGB(255, 42, 42, 42), // background color
                foregroundColor:
                    const Color.fromARGB(255, 255, 52, 52), // text color
              ),
              onPressed: () {
                // Add logout logic here
                print('Logout button pressed');
                AuthMethods().logOut(context, ref);
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
