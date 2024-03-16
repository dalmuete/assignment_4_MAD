import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileClientScreen extends StatefulWidget {
  final String clientuid;

  const ProfileClientScreen({Key? key, required this.clientuid})
      : super(key: key);

  @override
  _ProfileClientScreenState createState() => _ProfileClientScreenState();
}

class _ProfileClientScreenState extends State<ProfileClientScreen> {
  late final TextEditingController firstController;
  late final TextEditingController middleController;
  late final TextEditingController lastController;
  late final TextEditingController contactController;
  late final TextEditingController addressController;
  late final TextEditingController birthdateController;

  @override
  void initState() {
    super.initState();
    firstController = TextEditingController();
    middleController = TextEditingController();
    lastController = TextEditingController();
    birthdateController = TextEditingController();
    addressController = TextEditingController();

    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.clientuid)
        .get()
        .then((docSnapshot) {
      if (docSnapshot.exists) {
        if (docSnapshot.data()!.containsKey('type') &&
            docSnapshot.data()!['type'] == 'client') {
          setState(() {
            firstController.text = docSnapshot['firstname'];
            middleController.text = docSnapshot['middlename'];
            lastController.text = docSnapshot['lastname'];
            birthdateController.text = docSnapshot['birthdate'];
            addressController.text = docSnapshot['address'];
          });
        } else {
          print('Document type is not client');
        }
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching client data: $error'),
        ),
      );
    });
  }

  @override
  void dispose() {
    firstController.dispose();
    lastController.dispose();
    middleController.dispose();
    birthdateController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.clientuid)
        .update({
      'firstname': firstController.text,
      'middlename': middleController.text,
      'lastname': lastController.text,
      'birthdate': birthdateController.text,
      'address': addressController.text,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile Updated'),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $error'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EDIT PROFILE'),
        titleTextStyle: TextStyle(
            fontWeight: FontWeight.w700, color: Colors.amber, fontSize: 23),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/blue.jpg'),
              fit: BoxFit.cover,
              alignment: Alignment.center,
              opacity: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: firstController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              TextFormField(
                controller: middleController,
                decoration: InputDecoration(labelText: 'Middle Name'),
              ),
              TextFormField(
                controller: lastController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: birthdateController,
                decoration: InputDecoration(labelText: 'Birthdate'),
              ),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
