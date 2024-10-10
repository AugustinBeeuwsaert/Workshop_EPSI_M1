import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  File? _selectedImage;
  String? _name;
  String? _rpps;
  String? _email;
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('Medecin')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _name = userDoc.data()?['name'] ?? 'Nom inconnu';
            _rpps = userDoc.data()?['rpps'] ?? 'RPPS non disponible';
            _email = userDoc.data()?['email'] ?? 'Email non disponible';
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Center(
              child: Text(
                'Profil',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 80.0,
                backgroundColor: Colors.grey,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : const NetworkImage(
                            'https://th.bing.com/th/id/OIP.hwS9XdMtUVpdeJCZlNbW1wAAAA?pid=ImgDet&w=184&h=184&c=7&dpr=1,3')
                        as ImageProvider,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              _name ?? 'Chargement...',
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'RPPS: ${_rpps ?? 'Chargement...'}',
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              _email ?? 'Chargement...',
              style: const TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            const SizedBox(height: 24.0),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Documents'),
              onTap: () {
                // Navigate to the document upload page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DocumentsPage(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Aide & Support'),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () {
                // Add logout functionality here
              },
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({Key? key}) : super(key: key);

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  File? _selectedCV;
  File? _selectedDiplome;

  Future<void> _pickDocument(String type) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);

      setState(() {
        if (type == 'CV') {
          _selectedCV = file;
        } else if (type == 'Diplome') {
          _selectedDiplome = file;
        }
      });

      await _uploadFileToFirebase(file, type);
    }
  }

  Future<void> _uploadFileToFirebase(File file, String documentType) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String filePath =
            'documents/${user.uid}/$documentType-${DateTime.now().millisecondsSinceEpoch}';
        Reference storageRef = FirebaseStorage.instance.ref().child(filePath);
        await storageRef.putFile(file);
        String downloadURL = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('Medecin')
            .doc(user.uid)
            .update({
          documentType: downloadURL,
        });

        print('$documentType uploaded successfully.');
      }
    } catch (e) {
      print('Error uploading $documentType: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Téléchargez vos documents',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              onPressed: () {
                _pickDocument('CV');
              },
              label: const Text('Curriculum Vitae'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 24.0),
              ),
            ),
            if (_selectedCV != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text('CV sélectionné: ${_selectedCV!.path}'),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              onPressed: () {
                _pickDocument('Diplome');
              },
              label: const Text('Diplôme et autres Documents'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 24.0),
              ),
            ),
            if (_selectedDiplome != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text('Diplôme sélectionné: ${_selectedDiplome!.path}'),
              ),
          ],
        ),
      ),
    );
  }
}
