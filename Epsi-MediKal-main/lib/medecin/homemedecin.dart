import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:medzair_app/medecin/missions.dart';
import 'bar_chart.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final Color primaryColor = const Color(0xFF3BABB5);
  final Color secondaryColor = const Color(0xFF82DBD9);
  final Color accentColor = const Color(0xFF2F8F9D);
  final Color backgroundColor = const Color(0xFFB4E8E4);

  String? _userName;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userData =
            await _firestore.collection('Medecin').doc(user.uid).get();
        if (userData.exists) {
          setState(() {
            _userName = userData['name'];
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<List<DocumentSnapshot>> _fetchNearestAcceptedOffers() async {
    try {
      String todayDateString = DateFormat('dd-MM-yyyy').format(DateTime.now());

      QuerySnapshot querySnapshot =
          await _firestore.collection('acceptedoffer').get();

      List<DocumentSnapshot> filteredOffers = querySnapshot.docs.where((doc) {
        var dateField = doc['date'];

        if (dateField is String) {
          return dateField.compareTo(todayDateString) >= 0;
        }
        return false;
      }).toList();

      filteredOffers.sort((a, b) {
        return (a['date'] as String).compareTo(b['date'] as String);
      });

      return filteredOffers.take(2).toList();
    } catch (e) {
      print('Error fetching nearest accepted offers: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(
            top: 50.0, left: 16.0, right: 16.0, bottom: 16.0),
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('images/medecin.png'),
                backgroundColor: Color(0xFF3BABB5),
              ),
              const SizedBox(width: 8),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.timer),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Bienvenue, Dr. ${_userName ?? 'Utilisateur'}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Prochaines Offres Acceptées',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MissionsPage(),
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: primaryColor),
                child: const Text('Voir Tout'),
              ),
            ],
          ),
          FutureBuilder<List<DocumentSnapshot>>(
            future: _fetchNearestAcceptedOffers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Erreur de chargement.'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Aucune offre acceptée.'));
              }

              var offers = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  var offer = offers[index];
                  var offerDate = offer['date'] as String;
                  var hospitalName = offer['hospitalName'] ?? 'Hôpital Inconnu';

                  return Card(
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(child: Text(hospitalName[0])),
                      title: Text(hospitalName),
                      subtitle: Text('Date: $offerDate'),
                      onTap: () {},
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),
          const BarChart(),
        ],
      ),
    );
  }
}
