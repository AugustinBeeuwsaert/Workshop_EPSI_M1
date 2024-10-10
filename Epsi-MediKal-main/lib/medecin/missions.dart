import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MissionsPage extends StatefulWidget {
  const MissionsPage({Key? key}) : super(key: key);

  @override
  State<MissionsPage> createState() => _MissionsPageState();
}

class _MissionsPageState extends State<MissionsPage> {
  DateTime selectedDate = DateTime.now();
  bool showAllOffers = false;

 
  List<Widget> getDaysInMonth() {
    final daysInMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    final buttons = List.generate(daysInMonth, (index) {
      final day = index + 1;
      final dayText = DateFormat.E().format(
        DateTime(selectedDate.year, selectedDate.month, day),
      );
      return Column(
        children: [
          Text(
            dayText,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                selectedDate =
                    DateTime(selectedDate.year, selectedDate.month, day);
                showAllOffers = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedDate.day == day
                  ? const Color.fromARGB(255, 115, 220, 230)
                  : const Color.fromARGB(255, 249, 250, 250),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            ),
            child: Text(
              day.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      );
    });
    return buttons;
  }

  Stream<QuerySnapshot> _getOfferStream() {
    if (showAllOffers) {
      return FirebaseFirestore.instance.collection('acceptedoffer').snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('acceptedoffer')
          .where('date',
              isEqualTo: DateFormat('dd-MM-yyyy').format(selectedDate))
          .snapshots();
    }
  }

  
  Future<void> _openInGoogleMaps(String location) async {
    if (location.isNotEmpty) {
      final Uri url = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$location');

      
      if (await canLaunchUrl(url)) {
        
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showErrorMessage('Impossible d\'ouvrir Google Maps');
      }
    } else {
      _showErrorMessage('Lieu non spécifié');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.redAccent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40), 

            const Center(
              child: Text(
                'Remplacement',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 7, 7, 7), 
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      selectedDate = DateTime(
                          selectedDate.year, selectedDate.month - 1, 1);
                      showAllOffers = false;
                    });
                  },
                  icon: const Icon(Icons.arrow_back_ios),
                  color: Colors.blueAccent,
                ),
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                        showAllOffers = false;
                      });
                    }
                  },
                  child: Text(
                    DateFormat.yMMMM().format(selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      selectedDate = DateTime(
                          selectedDate.year, selectedDate.month + 1, 1);
                      showAllOffers = false;
                    });
                  },
                  icon: const Icon(Icons.arrow_forward_ios),
                  color: Colors.blueAccent,
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (!showAllOffers)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: getDaysInMonth(),
                ),
              ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Voir toutes les offres acceptées',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  Switch(
                    value: showAllOffers,
                    onChanged: (bool value) {
                      setState(() {
                        showAllOffers = value;
                      });
                    },
                    activeColor: Colors.blueAccent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getOfferStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text('Erreur lors du chargement des données.'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Aucun Remplacement.'));
                  }

                  var offers = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: offers.length,
                    itemBuilder: (context, index) {
                      var offer = offers[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(offer['hospitalName']?[0] ?? '?'),
                          ),
                          title: Text(
                            offer['hospitalName'] ?? 'Hôpital inconnu',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                              'Date : ${offer['date']}\nHeure : ${offer['time']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.location_on),
                            color: Colors.redAccent,
                            onPressed: () {
                              _openInGoogleMaps(offer['location'] ?? '');
                            },
                          ),
                          onTap: () {
                            _showOfferDetailDialog(context, offer);
                          },
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
    );
  }

  void _showOfferDetailDialog(BuildContext context, dynamic offer) {
    var hospitalName = offer['hospitalName'] ?? 'Hôpital inconnu';
    var offerDate = offer['date'];
    var offerTime = offer['time'];
    var offerLocation = offer['location'] ?? 'Lieu non spécifié';
    var offerStatus = offer['status'] ?? 'Statut inconnu';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Détails du Remplacement'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hôpital: $hospitalName'),
              Text('Date: $offerDate'),
              Text('Heure: $offerTime'),
              Text('Lieu: $offerLocation'),
              Text('Statut: $offerStatus'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}
