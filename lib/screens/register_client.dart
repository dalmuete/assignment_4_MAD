import 'package:assignment_4/screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class RegisterClient extends StatefulWidget {
  const RegisterClient({super.key});

  @override
  State<RegisterClient> createState() => _RegisterClientState();
}

class _RegisterClientState extends State<RegisterClient> {
  final formKey = GlobalKey<FormState>();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final middlename = TextEditingController();
  final address = TextEditingController();
  final birthdate = TextEditingController();
  final confirmPassword = TextEditingController();
  bool showPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REGISTER'),
        titleTextStyle: TextStyle(
            fontWeight: FontWeight.w700, color: Colors.amber, fontSize: 23),
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
                const Text('Please fill in the information needed.'),
                const Gap(12),
                TextFormField(
                  decoration: setTextDecoration('First Name'),
                  controller: firstName,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required. Please enter your firstname';
                    }
                  },
                ),
                const Gap(12),
                TextFormField(
                  decoration: setTextDecoration('Middle Name'),
                  controller: middlename,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required. Please enter your middle name';
                    }
                  },
                ),
                const Gap(12),
                TextFormField(
                  decoration: setTextDecoration('Last Name'),
                  controller: lastName,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required. Please enter your last name';
                    }
                  },
                ),
                const Gap(12),
                TextFormField(
                  decoration: setTextDecoration('Address'),
                  controller: address,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required. Please enter your address';
                    }
                  },
                ),
                const Gap(12),
                TextFormField(
                  decoration: setTextDecoration('Birthdate'),
                  controller: birthdate,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required. Please enter your Birthdate';
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
        registerClient();
      },
    );
  }

  void registerClient() async {
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
        'firstname': firstName.text,
        'middlename': middlename.text,
        'lastname': lastName.text,
        'address': address.text,
        'birthdate': birthdate.text,
        'email': email.text,
        'type': 'client',
      });
      Navigator.of(context).pop();
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
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
