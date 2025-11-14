import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactDetailsPage extends StatelessWidget {
  final Map<String, dynamic> contactData;

  const ContactDetailsPage({super.key, required this.contactData});

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    if (date is Timestamp) {
      DateTime dateTime = date.toDate();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du Contact', style: GoogleFonts.sora()),
        backgroundColor: Colors.blue,
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
            _buildDetailRow(
              'Statut',
              contactData['statutAppel'] ?? '',
              Icons.phone_callback,
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

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
