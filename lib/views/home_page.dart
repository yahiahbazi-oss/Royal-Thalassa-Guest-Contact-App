import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/crud_services.dart';
import '../models/contact_filter.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'contact_details_page.dart';
import 'tableau_de_bord_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final CrudServices _crudServices = CrudServices();
  ContactFilter _currentFilter = ContactFilter();
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) =>
            FilterBottomSheet(currentFilter: _currentFilter),
      ),
    ).then((result) {
      if (result != null && result is ContactFilter) {
        setState(() {
          _currentFilter = result;
        });
      }
    });
  }

  Color _getStatutColor(String? statut) {
    if (statut == null) return Colors.grey;
    if (statut.contains('étoile')) {
      if (statut == "5 étoiles") return Colors.green;
      if (statut == "4 étoiles") return Colors.lightGreen;
      if (statut == "3 étoiles") return Colors.amber;
      if (statut == "2 étoiles") return Colors.orange;
      if (statut == "1 étoile") return Colors.deepOrange;
      if (statut == "0 étoiles") return Colors.red;
    }
    if (statut == "N'a pas répondu") return Colors.grey;
    if (statut == "Pas satisfait") return Colors.red;
    if (statut == "Ne veut pas faire d'avis") return Colors.blueGrey;
    return Colors.grey;
  }

  List<DocumentSnapshot> _applySearch(List<DocumentSnapshot> docs) {
    if (_searchQuery.isEmpty) return docs;

    String query = _searchQuery.toLowerCase().trim();
    return docs.where((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String nom = (data['nom'] ?? '').toString().toLowerCase();
      String prenom = (data['prenom'] ?? '').toString().toLowerCase();
      String telephone = (data['telephone'] ?? '').toString().toLowerCase();
      String fullName = '$nom $prenom';

      return nom.contains(query) ||
          prenom.contains(query) ||
          telephone.contains(query) ||
          fullName.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts', style: GoogleFonts.sora(color: Colors.white)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          // Tableau de Bord button
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TableauDeBordPage(),
                ),
              );
            },
            icon: Icon(Icons.dashboard, color: Colors.white, size: 20),
            label: Text(
              'Tableau de Bord',
              style: GoogleFonts.sora(color: Colors.white, fontSize: 12),
            ),
          ),
          // Filter button
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.filter_list, color: Colors.white),
                if (_currentFilter.isActive)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(minWidth: 12, minHeight: 12),
                    ),
                  ),
              ],
            ),
            onPressed: _showFilterBottomSheet,
            tooltip: 'Filtres',
          ),
        ],
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

          // Apply filter and sort, then search
          List<DocumentSnapshot> filteredDocs = _currentFilter.apply(
            snapshot.data!.docs.toList(),
          );
          filteredDocs = _applySearch(filteredDocs);

          return Column(
            children: [
              // Search bar
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.white,
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: 'Rechercher par nom, prénom ou téléphone...',
                    hintStyle: GoogleFonts.sora(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.blue),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: GoogleFonts.sora(),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    // Keep focus on search field
                    _searchFocusNode.requestFocus();
                  },
                ),
              ),

              // Active filter chip
              if (_currentFilter.isActive)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.blue.shade50,
                  child: Row(
                    children: [
                      Icon(Icons.filter_alt, size: 18, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Filtre: ${_currentFilter.getFilterLabel()}',
                          style: GoogleFonts.sora(
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${filteredDocs.length} résultat(s)',
                        style: GoogleFonts.sora(
                          color: Colors.blue.shade600,
                          fontSize: 12,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 18, color: Colors.blue),
                        onPressed: () {
                          setState(() {
                            _currentFilter = ContactFilter();
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ),

              // Contact list
              Expanded(
                child: filteredDocs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Aucun contact trouvé',
                              style: GoogleFonts.sora(
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _currentFilter = ContactFilter();
                                });
                              },
                              child: Text('Réinitialiser le filtre'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot document = filteredDocs[index];
                          Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;

                          // Format departure date
                          String dateDepart = '';
                          if (data['dateDepart'] != null) {
                            DateTime date = (data['dateDepart'] as Timestamp)
                                .toDate();
                            dateDepart =
                                '${date.day}/${date.month}/${date.year}';
                          }

                          // Get call status color
                          Color statutColor = _getStatutColor(
                            data['statutAppel'],
                          );

                          return Card(
                            margin: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
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
                                style: GoogleFonts.sora(
                                  fontWeight: FontWeight.bold,
                                ),
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
                                      Expanded(
                                        child: Text(
                                          data['statutAppel'] ?? 'Non appelé',
                                          style: GoogleFonts.sora(
                                            fontSize: 14,
                                            color: statutColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
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
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
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
                                    builder: (context) => ContactDetailsPage(
                                      contactData: data,
                                      documentId: document.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
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
