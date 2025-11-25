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
            Timestamp? dateA =
                (a.data() as Map<String, dynamic>)['dateCreation']
                    as Timestamp?;
            Timestamp? dateB =
                (b.data() as Map<String, dynamic>)['dateCreation']
                    as Timestamp?;

            if (dateA == null || dateB == null) return 0;
            return dateB.compareTo(dateA); // Descending order (newest first)
          });

          return ListView.builder(
            itemCount: sortedDocs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = sortedDocs[index];
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

              // Format departure date
              String dateDepart = '';
              if (data['dateDepart'] != null) {
                DateTime date = (data['dateDepart'] as Timestamp).toDate();
                dateDepart = '${date.day}/${date.month}/${date.year}';
              }

              // Get call status color
              Color statutColor = Colors.grey;
              if (data['statutAppel'] == 'Appelé') {
                statutColor = Colors.green;
              } else if (data['statutAppel'] == 'À rappeler') {
                statutColor = Colors.orange;
              } else if (data['statutAppel'] == 'Ne pas déranger') {
                statutColor = Colors.red;
              }

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      data['contactId']?.toString() ?? '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  title: Text(
                    '${data['nom'] ?? ''} ${data['prenom'] ?? ''}',
                    style: GoogleFonts.sora(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_callback,
                            size: 16,
                            color: statutColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            data['statutAppel'] ?? 'Non appelé',
                            style: GoogleFonts.sora(
                              fontSize: 14,
                              color: statutColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.flight_takeoff,
                            size: 16,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Départ: $dateDepart',
                            style: GoogleFonts.sora(fontSize: 14),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          SizedBox(width: 4),
                          Text(
                            'Satisfaction: ${data['degreSatisfaction'] ?? 0}/10',
                            style: GoogleFonts.sora(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ContactDetailsPage(
                              contactData: data,
                              documentId: document.id,
                            ),
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
