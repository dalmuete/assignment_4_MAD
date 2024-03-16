import 'package:assignment_4/screens/client_home.dart';
import 'package:assignment_4/screens/establishment_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gap/gap.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var emailCon = TextEditingController();
  var passCon = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool hidePass = true;

  void togglePassword() {
    setState(() {
      hidePass = !hidePass;
    });
  }

  void login() async {
    if (formKey.currentState!.validate()) {
      EasyLoading.show(status: 'Processing...');
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailCon.text, password: passCon.text)
          .then((userCredential) async {
        EasyLoading.dismiss();
        String userId = userCredential.user!.uid;
        final document = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        var data = document.data()!;
        Widget landingScreen;
        if (data['type'] == 'client') {
          landingScreen = ClientScreen(userId: userId);
        } else {
          landingScreen = EstablishmentScreen();
        }
        print(document.data());
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (_) => landingScreen,
          ),
        );
      }).catchError((error) {
        print('ERROR $error');
        EasyLoading.showError('Incorrect Username and/or Password');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LOGIN'),
        titleTextStyle:
            TextStyle(fontWeight: FontWeight.w700, color: Colors.amber, fontSize: 23),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/blue.jpg'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
            opacity: 0.5
          ),
        ),
        constraints: BoxConstraints.expand(),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Gap(32),
                const Text('Please enter your email and password.'),
                const Gap(10),
                TextFormField(
                  controller: emailCon,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required.';
                    }
                    if (!EmailValidator.validate(value)) {
                      return 'Invalid Email';
                    }
                    return null;
                  },
                ),
                const Gap(12),
                TextFormField(
                  controller: passCon,
                  obscureText: hidePass,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      onPressed: togglePassword,
                      icon: Icon(
                        hidePass ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required.';
                    }
                    return null;
                  },
                ),
                const Gap(12),
                ElevatedButton(
                  onPressed: login,
                  child: Text(
                    'Login',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
