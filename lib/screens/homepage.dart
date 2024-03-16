import 'package:assignment_4/screens/login.dart';
import 'package:assignment_4/screens/register_client.dart';
import 'package:assignment_4/screens/register_establishment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/blue.jpg'),
              fit: BoxFit.cover,
              alignment: Alignment.center,
              opacity: 0.6,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('TraceIT', style: Theme.of(context).textTheme.displayMedium),
              const Gap(12),
              Text(
                'A mobile application for tracing contacts on MAD 2 class.',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Gap(24),
              ElevatedButton(
                onPressed: () => open(LoginScreen(), context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Login'),
              ),
              const Gap(12),
              ElevatedButton(
                onPressed: () => open(RegisterClient(), context),
                child: const Text('Register as Client'),
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
              ),
              const Gap(12),
              ElevatedButton(
                onPressed: () => open(RegisterEstablishment(), context),
                child: const Text('Register as Establishment'),
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void open(Widget screen, BuildContext context) {
    Navigator.of(context).push(CupertinoPageRoute(builder: (_) => screen));
  }
}