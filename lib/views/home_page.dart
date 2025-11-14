import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/crud_services.dart';
import 'contact_details_page.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final CrudServices _crudServices = CrudServices();

    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts', style: GoogleFonts.sora()),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _crudServices.getContacts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.contacts, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucun contact',
                    style: GoogleFonts.sora(fontSize: 20, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Appuyez sur + pour ajouter un contact',
                    style: GoogleFonts.sora(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Sort contacts by creation date (newest first)
          List<DocumentSnapshot> sortedDocs = snapshot.data!.docs.toList();
          sortedDocs.sort((a, b) {
            Timestamp? dateA = (a.data() as Map<String, dynamic>)['dateCreation'] as Timestamp?;
            Timestamp? dateB = (b.data() as Map<String, dynamic>)['dateCreation'] as Timestamp?;
            
            if (dateA == null || dateB == null) return 0;
            return dateB.compareTo(dateA); // Descending order (newest first)
          });

          return ListView.builder(
            itemCount: sortedDocs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = sortedDocs[index];
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              
              // Format date and time
              String dateCreation = '';
              String heureCreation = data['heureCreation'] ?? '';
              if (data['dateCreation'] != null) {
                DateTime date = (data['dateCreation'] as Timestamp).toDate();
                dateCreation = '${date.day}/${date.month}/${date.year}';
              }

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      '${data['nom']?[0] ?? ''}${data['prenom']?[0] ?? ''}'
                          .toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${data['nom'] ?? ''} ${data['prenom'] ?? ''}',
                          style: GoogleFonts.sora(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (data['contactId'] != null)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#${data['contactId']}',
                            style: GoogleFonts.sora(
                              fontSize: 12,
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            data['telephone'] ?? '',
                            style: GoogleFonts.sora(fontSize: 14),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.hotel, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            'Chambre: ${data['numeroChambre'] ?? ''}',
                            style: GoogleFonts.sora(fontSize: 14),
                          ),
                        ],
                      ),
                      if (dateCreation.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, size: 16, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                'Créé le: $dateCreation à $heureCreation',
                                style: GoogleFonts.sora(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactDetailsPage(contactData: data),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addcontact');
        },
        child: Icon(Icons.person_add),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue,
                    child: Text(
                      FirebaseAuth.instance.currentUser?.email?[0]
                              .toUpperCase() ??
                          'U',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Menu', style: GoogleFonts.sora()),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                ' ${FirebaseAuth.instance.currentUser?.email ?? 'Unknown'}',
                style: GoogleFonts.sora(),
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sign Out', style: GoogleFonts.sora()),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
