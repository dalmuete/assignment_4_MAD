import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class RegisterEstablishment extends StatefulWidget {
  const RegisterEstablishment({super.key});

  @override
  State<RegisterEstablishment> createState() => _RegisterEstablishmentState();
}

class _RegisterEstablishmentState extends State<RegisterEstablishment> {
  final formKey = GlobalKey<FormState>();
  final fullname = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final businessName = TextEditingController();
  final address = TextEditingController();
  bool showPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REGISTER ESTABLISHMENT'),
        titleTextStyle: TextStyle(
            fontWeight: FontWeight.w700, color: Colors.amber, fontSize: 18),
        centerTitle: true,
      ),
      body: Container(
        height: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/blue.jpg'),
                fit: BoxFit.cover,
                alignment: Alignment.center,
                opacity: 0.5)),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                    'Please fill in the information needed.'),
                const Gap(12),
                TextFormField(
                  decoration: setTextDecoration('Contact Person Name'),
                  controller: fullname,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required. Please enter your firstname';
                    }
                  },
                ),
                const Gap(12),
                TextFormField(
                  controller: businessName,
                  decoration: setTextDecoration('Establishment Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                  },
                ),
                const Gap(12),
                TextFormField(
                  controller: address,
                  decoration: setTextDecoration('Address'),
                  maxLines: 1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                  },
                ),
                const Gap(12),
                TextFormField(
                  decoration: setTextDecoration('Email Address'),
                  controller: email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required. Please enter your Email Address';
                    }
                    if (!EmailValidator.validate(value)) {
                      return 'Invalid Email';
                    }
                  },
                ),
                const Gap(12),
                TextFormField(
                  obscureText: showPassword,
                  decoration: setTextDecoration('Password', isPassword: true),
                  controller: password,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required. Please enter your password';
                    }
                    if (value.length <= 5) {
                      return 'Please enter atleast 6 characters';
                    }
                  },
                ),
                const Gap(12),
                TextFormField(
                  obscureText: showPassword,
                  decoration: setTextDecoration('Confirm Password'),
                  controller: confirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required. Please enter your password again';
                    }
                    if (value != password.text) {
                      return 'Passowrd do not match';
                    }
                  },
                ),
                const Gap(12),
                ElevatedButton(
                  onPressed: register,
                  child: const Text(
                    'Register',
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

  InputDecoration setTextDecoration(String text, {bool isPassword = false}) {
    return InputDecoration(
      border: const OutlineInputBorder(),
      labelText: text,
      suffixIcon: isPassword
          ? IconButton(
              onPressed: toggleShowPassword,
              icon: Icon(
                showPassword ? Icons.visibility : Icons.visibility_off,
              ),
            )
          : null,
    );
  }

  void toggleShowPassword() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  void register() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Are you sure?',
      confirmBtnText: 'YES',
      cancelBtnText: 'No',
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        RegisterEstablishment();
      },
    );
  }

  void RegisterEstablishment() async {
    try {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'Loading',
        text: 'Registering your account',
      );
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email.text, password: password.text);
      String user_id = userCredential.user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(user_id).set({
        'contactName': fullname.text,
        'email': email.text,
        'business': businessName.text,
        'address': address.text,
        'type': 'establishment',
      });
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (ex) {
      Navigator.of(context).pop();
      var errorTitle = '';
      var errorText = '';
      if (ex.code == 'weak-password') {
        errorText = 'Please enter a password with more than 6 characters';
        errorTitle = 'Weak Password';
      } else if (ex.code == 'email-already-in-use') {
        errorText = 'Password is already registered';
        errorTitle = 'Please enter a new email.';
      }
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: errorTitle,
        text: errorText,
      );
    }
  }
}
