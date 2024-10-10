import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For getting user ID

class OffresPage extends StatefulWidget {
  const OffresPage({Key? key}) : super(key: key);

  @override
  State<OffresPage> createState() => _OffresPageState();
}

class _OffresPageState extends State<OffresPage> {
  String? _selectedCity =
      'Toutes les Villes'; // Ensure initial value matches dropdown item
  String? _selectedStatus =
      'Tous les Statuts'; // Ensure initial value matches dropdown item

  // Cities and Status options
  final List<String> _cities = ['Toutes les Villes', 'Lille', 'Paris', 'Lyon'];
  final List<String> _statuses = ['Tous les Statuts', 'Disponible', 'Urgent'];

  // Retrieve current user's ID for acceptedBy field
  String? getDoctorId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Center(
              child: Text(
                'Offres',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCity,
                    items: _cities.map((city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Ville'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    items: _statuses.map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Statut'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildFilteredOffersContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredOffersContent() {
    Query query = FirebaseFirestore.instance.collection('Offer');

    if (_selectedStatus != null && _selectedStatus != 'Tous les Statuts') {
      query = query.where('status', isEqualTo: _selectedStatus);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(
              child: Text('Erreur lors du chargement des offres.'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Aucune offre disponible.'));
        }

        var offerDocs = snapshot.data!.docs;

        return ListView.builder(
          key: const ValueKey(1),
          itemCount: offerDocs.length,
          itemBuilder: (context, index) {
            var offer = offerDocs[index];

            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Hospital')
                  .doc(offer['Hospitalid'])
                  .snapshots(),
              builder: (context, hospitalSnapshot) {
                if (hospitalSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const SizedBox.shrink();
                } else if (hospitalSnapshot.hasError) {
                  return const Center(
                      child: Text(
                          'Erreur lors du chargement des détails de l\'hôpital.'));
                }

                var hospitalData = hospitalSnapshot.data;

                if (_selectedCity != null &&
                    _selectedCity != 'Toutes les Villes' &&
                    hospitalData != null &&
                    hospitalData['ville'] != _selectedCity) {
                  return Container();
                }

                var hospitalName = hospitalData?['name'] ?? 'Hôpital Inconnu';
                var offerStatus = offer['status'];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  child: ListTile(
                    leading:
                        Icon(Icons.local_hospital, color: Colors.blue.shade700),
                    title: Text(hospitalName),
                    subtitle: Text('Statut: $offerStatus'),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 18, color: Colors.blue.shade700),
                    onTap: () {
                      _showOfferDetailDialog(context, offer, hospitalData);
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showOfferDetailDialog(
      BuildContext context, QueryDocumentSnapshot offer, dynamic hospitalData) {
    var hospitalName = hospitalData?['name'] ?? 'Hôpital Inconnu';
    var hospitalRegion = hospitalData?['region'] ?? 'Région Inconnue';
    var offerDate = offer['Date'];
    var offerLocation = offer['Location'];
    var offerTime = offer['Time'];
    var offerStatus = offer['status'];

    bool isOfferAccepted = offerStatus == 'accepted';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Détails pour $hospitalName'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hôpital: $hospitalName'),
              Text('Région: $hospitalRegion'),
              Text('Date: $offerDate'),
              Text('Lieu: $offerLocation'),
              Text('Heure: $offerTime'),
              Text('Statut: $offerStatus'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: isOfferAccepted
                  ? null
                  : () {
                      _acceptOffer(offer, hospitalData);
                      Navigator.of(context).pop();
                    },
              child: Text(
                'Accepter',
                style: TextStyle(
                  color: isOfferAccepted ? Colors.grey : Colors.green,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _updateOfferStatus(String offerId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('Offer')
          .doc(offerId)
          .update({'status': newStatus});
    } catch (e) {
      print('Erreur lors de la mise à jour du statut de l\'offre: $e');
    }
  }

  void _acceptOffer(QueryDocumentSnapshot offer, dynamic hospitalData) async {
    String? doctorId = getDoctorId();

    if (doctorId == null) {
      print('Erreur : aucun ID de médecin trouvé.');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('acceptedoffer').add({
        'hospitalName': hospitalData?['name'] ?? 'Hôpital Inconnu',
        'hospitalRegion': hospitalData?['region'] ?? 'Région Inconnue',
        'date': offer['Date'],
        'location': offer['Location'],
        'time': offer['Time'],
        'status': 'accepted',
        'acceptedBy': doctorId,
        'offerId': offer.id,
      });

      _updateOfferStatus(offer.id, 'accepted');
    } catch (e) {
      print('Erreur lors de l\'acceptation de l\'offre: $e');
    }
  }
}
