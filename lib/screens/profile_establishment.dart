import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String establishmentUid;

  const ProfileScreen({Key? key, required this.establishmentUid})
      : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController nameController;
  late final TextEditingController contactController;
  late final TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    contactController = TextEditingController();
    addressController = TextEditingController();

    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.establishmentUid)
        .get()
        .then((docSnapshot) {
      if (docSnapshot.exists) {
        if (docSnapshot.data()!.containsKey('type') &&
            docSnapshot.data()!['type'] == 'establishment') {
          setState(() {
            nameController.text = docSnapshot['business'];
            contactController.text = docSnapshot['contactName'];
            addressController.text = docSnapshot['address'];
          });
        } else {
          print('Document type is not establishment');
        }
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching establishment data: $error'),
        ),
      );
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    contactController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.establishmentUid)
        .update({
      'contactName': contactController.text,
      'business': nameController.text,
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
                controller: nameController,
                decoration: InputDecoration(labelText: 'Establishment Name'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: contactController,
                decoration: InputDecoration(labelText: 'Contact Person'),
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
