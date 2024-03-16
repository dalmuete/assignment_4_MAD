import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:assignment_4/screens/profile_establishment.dart';
import 'package:assignment_4/screens/homepage.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:gap/gap.dart';

class EstablishmentScreen extends StatefulWidget {
  const EstablishmentScreen({Key? key}) : super(key: key);

  @override
  _EstablishmentScreenState createState() => _EstablishmentScreenState();
}

class _EstablishmentScreenState extends State<EstablishmentScreen> {
  final collectionPath = 'logs';
  late DateTime selectedDate;
  late bool showAllData;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    showAllData = true;
  }

  void scanQR(BuildContext context) async {
    final lineColor = '#ffffff';
    final cancelButtonText = 'CANCEL';
    final isShowFlashIcon = true;
    final scanMode = ScanMode.DEFAULT;
    String result = await FlutterBarcodeScanner.scanBarcode(
        lineColor, cancelButtonText, isShowFlashIcon, scanMode);
    print(result);

    if (result != '-1') {
      if (result.contains('//')) {
        print('Invalid document ID: $result');
        return;
      }
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(result)
          .get();
      if (userSnapshot.exists) {
        await FirebaseFirestore.instance.collection(collectionPath).add({
          'client_uid': result,
          'establishment_uid': FirebaseAuth.instance.currentUser!.uid,
          'datetime': DateTime.now(),
        });
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Invalid QR Code'),
              content: Text('The scanned QR code is not registered.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat.yMMMd().add_jm().format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESTABLISHMENT'),
        titleTextStyle: TextStyle(
            fontWeight: FontWeight.w700, color: Colors.amber, fontSize: 22),
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
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/blue.jpg'),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      opacity: 0.5),
                )),
            ListTile(
              title: Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                          establishmentUid:
                              FirebaseAuth.instance.currentUser!.uid)),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () => scanQR(context),
                child: Text('Scan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                ),
              ),
              Gap(12),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(DateTime.now().year - 1),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                      showAllData = false;
                    });
                  }
                },
                child: Text('Select Date'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                ),
              ),
              SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(collectionPath)
                      .where('establishment_uid',
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (_, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final documents = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (_, int index) {
                        final documentDate =
                            documents[index]['datetime'].toDate();
                        if (!showAllData &&
                            !isSameDate(documentDate, selectedDate)) {
                          return SizedBox();
                        }
                        return ListTile(
                          title: FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(documents[index]['client_uid'])
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasError || snapshot.data == null) {
                                return Text('Error retrieving data');
                              }
                              final document = snapshot.data!.data();
                              if (document == null) {
                                return Text('Document not found');
                              }
                              if (!document.containsKey('firstname')) {
                                return Text('Firstname not found in document');
                              }
                              return Text(
                                  '${document['firstname']} ${document['middlename']} ${document['lastname']}');
                            },
                          ),
                          subtitle: Text(
                            _formatDateTime(
                                documents[index]['datetime'].toDate()),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
