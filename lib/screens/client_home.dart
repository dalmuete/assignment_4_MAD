import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:assignment_4/screens/homepage.dart';
import 'package:assignment_4/screens/profile_client.dart';
import 'package:assignment_4/screens/qr_scanner.dart';
import 'package:intl/intl.dart';

class ClientScreen extends StatefulWidget {
  ClientScreen({Key? key, required this.userId}) : super(key: key);

  final String userId;

  @override
  _ClientScreenState createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  final collectionPath = 'logs';
  late DateTime selectedDate;
  bool filterByDate = false;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  void signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
  }

  void _pickDate(BuildContext context) async {
    final initialDate = selectedDate;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        filterByDate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CLIENT',
        style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w700)
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => signOut(context),
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('Menu',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)
              ),
              decoration: BoxDecoration(
                color: Colors.yellow,
                image: DecorationImage(image: AssetImage('assets/images/blue.jpg'),
                fit: BoxFit.cover,
                )
              ),
            ),
            ListTile(
              title: Text('Edit Profile',),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileClientScreen(clientuid: FirebaseAuth.instance.currentUser!.uid)),
                );
              },
            ),
            ListTile(
              title: Text('Filter Visits by Date'),
              onTap: () {
                Navigator.pop(context);
                _pickDate(context);
              },
            ),
            ListTile(
              title: Text('See QR code'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => QRWidget(userId: widget.userId)),
                );
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(collectionPath)
            .where('client_uid', isEqualTo: widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No visit history available.'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final visitData = snapshot.data!.docs[index];
              final timestamp = visitData['datetime'].toDate();
              final formattedDate = DateFormat.yMMMMd().add_jm().format(timestamp);
              if (filterByDate && !isSameDate(timestamp, selectedDate)) {
                return SizedBox();
              }
              final establishmentUid = visitData['establishment_uid'];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(establishmentUid).get(),
                builder: (context, establishmentSnapshot) {
                  if (establishmentSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Loading...'),
                      subtitle: Text(formattedDate),
                    );
                  }
                  if (establishmentSnapshot.hasError || !establishmentSnapshot.hasData) {
                    return ListTile(
                      title: Text('Error loading establishment'),
                      subtitle: Text(formattedDate),
                    );
                  }
                  final establishmentData = establishmentSnapshot.data!;
                  final businessName = establishmentData['business'];
                  return ListTile(
                    title: Text(businessName),
                    subtitle: Text(formattedDate),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}
