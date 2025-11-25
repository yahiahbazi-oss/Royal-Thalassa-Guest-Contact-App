import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/crud_services.dart';

class ContactDetailsPage extends StatefulWidget {
  final Map<String, dynamic> contactData;
  final String documentId;

  const ContactDetailsPage({
    super.key,
    required this.contactData,
    required this.documentId,
  });

  @override
  State<ContactDetailsPage> createState() => _ContactDetailsPageState();
}

class _ContactDetailsPageState extends State<ContactDetailsPage> {
  late Map<String, dynamic> contactData;
  final CrudServices _crudServices = CrudServices();

  final List<String> _resultatsAppelOptions = [
    "N'a pas répondu",
    "Pas satisfait",
    "Ne veut pas faire d'avis",
    "0 étoiles",
    "1 étoile",
    "2 étoiles",
    "3 étoiles",
    "4 étoiles",
    "5 étoiles",
  ];

  @override
  void initState() {
    super.initState();
    contactData = Map.from(widget.contactData);
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    if (date is Timestamp) {
      DateTime dateTime = date.toDate();
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    }
    return 'N/A';
  }

  String _formatDateTime(dynamic date, String? heure) {
    if (date == null) return 'N/A';
    if (date is Timestamp) {
      DateTime dateTime = date.toDate();
      String formattedDate = '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
      if (heure != null && heure.isNotEmpty) {
        return '$formattedDate à $heure';
      }
      return formattedDate;
    }
    return 'N/A';
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.sora(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'N/A',
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: GoogleFonts.sora(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  void _showQualificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Qualification de fiche',
            style: GoogleFonts.sora(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.phone_callback, color: Colors.blue),
                title: Text(
                  "Résultat d'appel",
                  style: GoogleFonts.sora(fontWeight: FontWeight.w600),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _showResultatAppelDialog();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Fermer', style: GoogleFonts.sora()),
            ),
          ],
        );
      },
    );
  }

  void _showResultatAppelDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Résultat d'appel",
            style: GoogleFonts.sora(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _resultatsAppelOptions.map((option) {
                bool isSelected = contactData['statutAppel'] == option;
                return ListTile(
                  leading: Icon(
                    _getIconForResultat(option),
                    color: _getColorForResultat(option),
                  ),
                  title: Text(
                    option,
                    style: GoogleFonts.sora(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.blue : null,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () async {
                    Navigator.pop(context);
                    await _updateResultatAppel(option);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showHistoriqueResultats();
              },
              child: Text(
                'Voir historique',
                style: GoogleFonts.sora(color: Colors.orange),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Fermer', style: GoogleFonts.sora()),
            ),
          ],
        );
      },
    );
  }

  IconData _getIconForResultat(String resultat) {
    if (resultat.contains('étoile')) {
      return Icons.star;
    } else if (resultat == "N'a pas répondu") {
      return Icons.phone_missed;
    } else if (resultat == "Pas satisfait") {
      return Icons.sentiment_dissatisfied;
    } else if (resultat == "Ne veut pas faire d'avis") {
      return Icons.do_not_disturb;
    }
    return Icons.phone_callback;
  }

  Color _getColorForResultat(String resultat) {
    if (resultat == "5 étoiles") return Colors.green;
    if (resultat == "4 étoiles") return Colors.lightGreen;
    if (resultat == "3 étoiles") return Colors.amber;
    if (resultat == "2 étoiles") return Colors.orange;
    if (resultat == "1 étoile") return Colors.deepOrange;
    if (resultat == "0 étoiles") return Colors.red;
    if (resultat == "N'a pas répondu") return Colors.grey;
    if (resultat == "Pas satisfait") return Colors.red;
    if (resultat == "Ne veut pas faire d'avis") return Colors.blueGrey;
    return Colors.blue;
  }

  Future<void> _updateResultatAppel(String newResultat) async {
    List<Map<String, dynamic>> currentResultats = [];
    if (contactData['resultatsAppels'] != null) {
      currentResultats = List<Map<String, dynamic>>.from(
        (contactData['resultatsAppels'] as List).map((e) => Map<String, dynamic>.from(e)),
      );
    }

    String result = await _crudServices.updateResultatAppel(
      documentId: widget.documentId,
      newStatutAppel: newResultat,
      currentResultats: currentResultats,
    );

    if (mounted) {
      DateTime now = DateTime.now();
      setState(() {
        contactData['statutAppel'] = newResultat;
        if (contactData['resultatsAppels'] == null) {
          contactData['resultatsAppels'] = [];
        }
        (contactData['resultatsAppels'] as List).add({
          'resultat': newResultat,
          'date': Timestamp.fromDate(now),
          'heure': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result, style: GoogleFonts.sora()),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showHistoriqueResultats() {
    List<dynamic> resultats = contactData['resultatsAppels'] ?? [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Historique des résultats d'appel",
            style: GoogleFonts.sora(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: resultats.isEmpty
                ? Center(
                    child: Text(
                      'Aucun historique disponible',
                      style: GoogleFonts.sora(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: resultats.length,
                    itemBuilder: (context, index) {
                      var item = resultats[resultats.length - 1 - index];
                      String resultat = item['resultat'] ?? '';
                      String dateStr = _formatDateTime(item['date'], item['heure']);

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getColorForResultat(resultat).withOpacity(0.2),
                            child: Icon(
                              _getIconForResultat(resultat),
                              color: _getColorForResultat(resultat),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            resultat,
                            style: GoogleFonts.sora(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            dateStr,
                            style: GoogleFonts.sora(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: index == 0
                              ? Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Actuel',
                                    style: GoogleFonts.sora(
                                      fontSize: 10,
                                      color: Colors.green.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Fermer', style: GoogleFonts.sora()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du Contact', style: GoogleFonts.sora()),
        backgroundColor: Colors.blue,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showQualificationDialog,
        backgroundColor: Colors.blue,
        icon: Icon(Icons.edit_note),
        label: Text(
          'Qualification de fiche',
          style: GoogleFonts.sora(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatar and name
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue,
                    child: Text(
                      '${contactData['nom']?[0] ?? ''}${contactData['prenom']?[0] ?? ''}'
                          .toUpperCase(),
                      style: TextStyle(color: Colors.white, fontSize: 36),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '${contactData['nom'] ?? ''} ${contactData['prenom'] ?? ''}',
                    style: GoogleFonts.sora(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (contactData['contactId'] != null)
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Contact #${contactData['contactId']}',
                        style: GoogleFonts.sora(
                          fontSize: 14,
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Divider(),

            // Contact Information Section
            _buildSectionTitle('Informations de Contact'),
            _buildDetailRow(
              'Téléphone',
              contactData['telephone'] ?? '',
              Icons.phone,
            ),
            _buildDetailRow(
              'WhatsApp',
              contactData['whatsapp'] ?? '',
              Icons.chat,
            ),
            _buildDetailRow(
              'Téléphone Fixe',
              contactData['telephoneFixe'] ?? '',
              Icons.phone_android,
            ),
            _buildDetailRow(
              'Autre Numéro',
              contactData['autreNumero'] ?? '',
              Icons.phone_in_talk,
            ),
            _buildDetailRow('Email', contactData['email'] ?? '', Icons.email),

            Divider(),

            // Personal Information Section
            _buildSectionTitle('Informations Personnelles'),
            _buildDetailRow(
              'Date de Naissance',
              _formatDate(contactData['dateNaissance']),
              Icons.cake,
            ),
            _buildDetailRow('Sexe', contactData['sexe'] ?? '', Icons.person),
            _buildDetailRow(
              'Nationalité',
              contactData['nationalite'] ?? '',
              Icons.flag,
            ),
            _buildDetailRow(
              'Langue',
              contactData['langue'] ?? '',
              Icons.language,
            ),

            Divider(),

            // Stay Information Section
            _buildSectionTitle('Informations de Séjour'),
            _buildDetailRow(
              'Date d\'Arrivée',
              _formatDate(contactData['dateArrivee']),
              Icons.flight_land,
            ),
            _buildDetailRow(
              'Date de Départ',
              _formatDate(contactData['dateDepart']),
              Icons.flight_takeoff,
            ),
            _buildDetailRow(
              'Numéro de Chambre',
              contactData['numeroChambre'] ?? '',
              Icons.hotel,
            ),
            _buildDetailRow(
              'Canal de Réservation',
              contactData['canalReservation'] ?? '',
              Icons.book_online,
            ),
            _buildDetailRow(
              'Historique Séjour',
              contactData['historiqueSejour'] ?? '',
              Icons.history,
            ),

            Divider(),

            // Satisfaction Section
            _buildSectionTitle('Satisfaction et Feedback'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.star, size: 20, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Degré de Satisfaction',
                          style: GoogleFonts.sora(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${contactData['degreSatisfaction'] ?? 0}/10',
                              style: GoogleFonts.sora(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(width: 8),
                            ...List.generate(
                              10,
                              (index) => Icon(
                                Icons.star,
                                size: 16,
                                color:
                                    index <
                                        (contactData['degreSatisfaction'] ?? 0)
                                    ? Colors.amber
                                    : Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (contactData['pointsPositifs'] != null &&
                contactData['pointsPositifs'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.thumb_up, size: 20, color: Colors.green),
                        SizedBox(width: 12),
                        Text(
                          'Points Positifs',
                          style: GoogleFonts.sora(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        contactData['pointsPositifs'] ?? '',
                        style: GoogleFonts.sora(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

            if (contactData['pointsNegatifs'] != null &&
                contactData['pointsNegatifs'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.thumb_down, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text(
                          'Points Négatifs',
                          style: GoogleFonts.sora(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        contactData['pointsNegatifs'] ?? '',
                        style: GoogleFonts.sora(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

            Divider(),

            // Call Status Section
            _buildSectionTitle('Statut d\'Appel'),
            InkWell(
              onTap: _showResultatAppelDialog,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getColorForResultat(contactData['statutAppel'] ?? '').withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getColorForResultat(contactData['statutAppel'] ?? '').withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIconForResultat(contactData['statutAppel'] ?? ''),
                      color: _getColorForResultat(contactData['statutAppel'] ?? ''),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statut actuel',
                            style: GoogleFonts.sora(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            contactData['statutAppel'] ?? 'Non défini',
                            style: GoogleFonts.sora(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _getColorForResultat(contactData['statutAppel'] ?? ''),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit, color: Colors.grey),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            if ((contactData['resultatsAppels'] as List?)?.isNotEmpty ?? false)
              TextButton.icon(
                onPressed: _showHistoriqueResultats,
                icon: Icon(Icons.history, size: 18),
                label: Text(
                  'Voir l\'historique des modifications (${(contactData['resultatsAppels'] as List).length})',
                  style: GoogleFonts.sora(fontSize: 12),
                ),
              ),

            Divider(),

            // Creation Info Section
            _buildSectionTitle('Informations de Création'),
            if (contactData['dateCreation'] != null)
              _buildDetailRow(
                'Date de Création',
                '${_formatDate(contactData['dateCreation'])} à ${contactData['heureCreation'] ?? ''}',
                Icons.access_time,
              ),

            SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }
}
