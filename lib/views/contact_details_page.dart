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

  final List<String> _canaux = [
    'OTS',
    'Easy Jet Holidays',
    'Mondial Tourism',
    'Autre TO',
    'Booking.com',
    'Expedia',
    'Autre OTA',
    'Agence Local',
    'Indiv',
  ];

  // Form controllers for nouveau séjour
  DateTime? _newDateArrivee;
  DateTime? _newDateDepart;
  String _newNumeroChambre = '';
  String? _newCanalReservation;
  int _newDegreSatisfaction = 5;
  String _newPointsPositifs = '';
  String _newPointsNegatifs = '';
  String _newStatutAppel = 'Non appelé';

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
      String formattedDate =
          '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
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
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
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
        (contactData['resultatsAppels'] as List).map(
          (e) => Map<String, dynamic>.from(e),
        ),
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
          'heure':
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
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
                      String dateStr = _formatDateTime(
                        item['date'],
                        item['heure'],
                      );

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getColorForResultat(
                              resultat,
                            ).withOpacity(0.2),
                            child: Icon(
                              _getIconForResultat(resultat),
                              color: _getColorForResultat(resultat),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            resultat,
                            style: GoogleFonts.sora(
                              fontWeight: FontWeight.w600,
                            ),
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
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

  void _showNouveauSejourDialog() {
    // Reset form values
    _newDateArrivee = null;
    _newDateDepart = null;
    _newNumeroChambre = '';
    _newCanalReservation = null;
    _newDegreSatisfaction = 5;
    _newPointsPositifs = '';
    _newPointsNegatifs = '';
    _newStatutAppel = 'Non appelé';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Nouveau Séjour',
                style: GoogleFonts.sora(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date d'arrivée
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.flight_land, color: Colors.blue),
                      title: Text("Date d'arrivée", style: GoogleFonts.sora()),
                      subtitle: Text(
                        _newDateArrivee != null
                            ? '${_newDateArrivee!.day}/${_newDateArrivee!.month}/${_newDateArrivee!.year}'
                            : 'Sélectionner',
                        style: GoogleFonts.sora(color: Colors.blue),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setDialogState(() => _newDateArrivee = date);
                        }
                      },
                    ),

                    // Date de départ
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.flight_takeoff, color: Colors.blue),
                      title: Text('Date de départ', style: GoogleFonts.sora()),
                      subtitle: Text(
                        _newDateDepart != null
                            ? '${_newDateDepart!.day}/${_newDateDepart!.month}/${_newDateDepart!.year}'
                            : 'Sélectionner',
                        style: GoogleFonts.sora(color: Colors.blue),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _newDateArrivee ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setDialogState(() => _newDateDepart = date);
                        }
                      },
                    ),

                    SizedBox(height: 8),

                    // Numéro de chambre
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Numéro de chambre',
                        labelStyle: GoogleFonts.sora(),
                        prefixIcon: Icon(Icons.hotel),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: GoogleFonts.sora(),
                      onChanged: (value) => _newNumeroChambre = value,
                    ),

                    SizedBox(height: 16),

                    // Canal de réservation
                    DropdownButtonFormField<String>(
                      value: _newCanalReservation,
                      decoration: InputDecoration(
                        labelText: 'Canal de réservation',
                        labelStyle: GoogleFonts.sora(),
                        prefixIcon: Icon(Icons.book_online),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: _canaux.map((canal) {
                        return DropdownMenuItem(
                          value: canal,
                          child: Text(canal, style: GoogleFonts.sora()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => _newCanalReservation = value);
                      },
                    ),

                    SizedBox(height: 16),

                    // Degré de satisfaction
                    Text(
                      'Degré de satisfaction: $_newDegreSatisfaction/10',
                      style: GoogleFonts.sora(fontWeight: FontWeight.w600),
                    ),
                    Slider(
                      value: _newDegreSatisfaction.toDouble(),
                      min: 0,
                      max: 10,
                      divisions: 10,
                      label: _newDegreSatisfaction.toString(),
                      onChanged: (value) {
                        setDialogState(
                          () => _newDegreSatisfaction = value.toInt(),
                        );
                      },
                    ),

                    SizedBox(height: 8),

                    // Points positifs
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Points positifs',
                        labelStyle: GoogleFonts.sora(),
                        prefixIcon: Icon(Icons.thumb_up, color: Colors.green),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: GoogleFonts.sora(),
                      maxLines: 2,
                      onChanged: (value) => _newPointsPositifs = value,
                    ),

                    SizedBox(height: 16),

                    // Points négatifs
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Points négatifs',
                        labelStyle: GoogleFonts.sora(),
                        prefixIcon: Icon(Icons.thumb_down, color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: GoogleFonts.sora(),
                      maxLines: 2,
                      onChanged: (value) => _newPointsNegatifs = value,
                    ),

                    SizedBox(height: 16),

                    // Statut d'appel
                    DropdownButtonFormField<String>(
                      value: _newStatutAppel,
                      decoration: InputDecoration(
                        labelText: "Statut d'appel",
                        labelStyle: GoogleFonts.sora(),
                        prefixIcon: Icon(Icons.phone_callback),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: ['Non appelé', ..._resultatsAppelOptions].map((
                        status,
                      ) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status, style: GoogleFonts.sora()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(
                          () => _newStatutAppel = value ?? 'Non appelé',
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Annuler', style: GoogleFonts.sora()),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (_newDateArrivee == null || _newDateDepart == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Veuillez sélectionner les dates',
                            style: GoogleFonts.sora(),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);
                    await _saveNouveauSejour();
                  },
                  child: Text(
                    'Enregistrer',
                    style: GoogleFonts.sora(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveNouveauSejour() async {
    String result = await _crudServices.addNouveauSejour(
      documentId: widget.documentId,
      currentContactData: contactData,
      dateArrivee: Timestamp.fromDate(_newDateArrivee!),
      dateDepart: Timestamp.fromDate(_newDateDepart!),
      numeroChambre: _newNumeroChambre,
      canalReservation: _newCanalReservation ?? '',
      degreSatisfaction: _newDegreSatisfaction,
      pointsPositifs: _newPointsPositifs,
      pointsNegatifs: _newPointsNegatifs,
      statutAppel: _newStatutAppel,
    );

    if (mounted) {
      DateTime now = DateTime.now();

      // Create previous séjour record
      Map<String, dynamic> previousSejour = {
        'dateArrivee': contactData['dateArrivee'],
        'dateDepart': contactData['dateDepart'],
        'numeroChambre': contactData['numeroChambre'],
        'canalReservation': contactData['canalReservation'],
        'degreSatisfaction': contactData['degreSatisfaction'],
        'pointsPositifs': contactData['pointsPositifs'],
        'pointsNegatifs': contactData['pointsNegatifs'],
        'statutAppel': contactData['statutAppel'],
        'dateUpdate': Timestamp.fromDate(now),
        'heureUpdate':
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      };

      setState(() {
        // Add to history
        if (contactData['sejoursHistory'] == null) {
          contactData['sejoursHistory'] = [];
        }
        (contactData['sejoursHistory'] as List).add(previousSejour);

        // Update current data
        contactData['dateArrivee'] = Timestamp.fromDate(_newDateArrivee!);
        contactData['dateDepart'] = Timestamp.fromDate(_newDateDepart!);
        contactData['numeroChambre'] = _newNumeroChambre;
        contactData['canalReservation'] = _newCanalReservation ?? '';
        contactData['degreSatisfaction'] = _newDegreSatisfaction;
        contactData['pointsPositifs'] = _newPointsPositifs;
        contactData['pointsNegatifs'] = _newPointsNegatifs;
        contactData['statutAppel'] = _newStatutAppel;
        contactData['lastSejourUpdate'] = Timestamp.fromDate(now);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result, style: GoogleFonts.sora()),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildSejourHistoryCard(Map<String, dynamic> sejour, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Séjour #${index + 1}',
                  style: GoogleFonts.sora(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
              if (sejour['dateUpdate'] != null)
                Text(
                  'Archivé le ${_formatDateTime(sejour['dateUpdate'], sejour['heureUpdate'])}',
                  style: GoogleFonts.sora(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),

          // Dates
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.flight_land, size: 16, color: Colors.blue),
                    SizedBox(width: 4),
                    Text(
                      'Arrivée: ${_formatDate(sejour['dateArrivee'])}',
                      style: GoogleFonts.sora(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.flight_takeoff, size: 16, color: Colors.blue),
                    SizedBox(width: 4),
                    Text(
                      'Départ: ${_formatDate(sejour['dateDepart'])}',
                      style: GoogleFonts.sora(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          // Room and channel
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.hotel, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'Chambre: ${sejour['numeroChambre'] ?? 'N/A'}',
                      style: GoogleFonts.sora(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.book_online, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        sejour['canalReservation'] ?? 'N/A',
                        style: GoogleFonts.sora(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          // Satisfaction and status
          Row(
            children: [
              Icon(Icons.star, size: 16, color: Colors.amber),
              SizedBox(width: 4),
              Text(
                '${sejour['degreSatisfaction'] ?? 0}/10',
                style: GoogleFonts.sora(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 16),
              Icon(
                _getIconForResultat(sejour['statutAppel'] ?? ''),
                size: 16,
                color: _getColorForResultat(sejour['statutAppel'] ?? ''),
              ),
              SizedBox(width: 4),
              Text(
                sejour['statutAppel'] ?? 'N/A',
                style: GoogleFonts.sora(
                  fontSize: 12,
                  color: _getColorForResultat(sejour['statutAppel'] ?? ''),
                ),
              ),
            ],
          ),

          // Points
          if ((sejour['pointsPositifs'] ?? '').toString().isNotEmpty) ...[
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.thumb_up, size: 14, color: Colors.green),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    sejour['pointsPositifs'],
                    style: GoogleFonts.sora(fontSize: 11, color: Colors.green),
                  ),
                ),
              ],
            ),
          ],
          if ((sejour['pointsNegatifs'] ?? '').toString().isNotEmpty) ...[
            SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.thumb_down, size: 14, color: Colors.red),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    sejour['pointsNegatifs'],
                    style: GoogleFonts.sora(fontSize: 11, color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ],
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

            // Stay Information Section - Current Séjour
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('Séjour Actuel'),
                ElevatedButton.icon(
                  onPressed: _showNouveauSejourDialog,
                  icon: Icon(Icons.add, size: 18),
                  label: Text(
                    'Nouveau séjour',
                    style: GoogleFonts.sora(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),

            // Current séjour in a highlighted frame
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200, width: 2),
              ),
              child: Column(
                children: [
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
                ],
              ),
            ),

            // Previous séjours history
            if ((contactData['sejoursHistory'] as List?)?.isNotEmpty ??
                false) ...[
              SizedBox(height: 16),
              _buildSectionTitle('Historique des Séjours'),
              ...List.generate((contactData['sejoursHistory'] as List).length, (
                index,
              ) {
                int reverseIndex =
                    (contactData['sejoursHistory'] as List).length - 1 - index;
                return _buildSejourHistoryCard(
                  Map<String, dynamic>.from(
                    (contactData['sejoursHistory'] as List)[reverseIndex],
                  ),
                  reverseIndex,
                );
              }),
            ],

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
                  color: _getColorForResultat(
                    contactData['statutAppel'] ?? '',
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getColorForResultat(
                      contactData['statutAppel'] ?? '',
                    ).withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIconForResultat(contactData['statutAppel'] ?? ''),
                      color: _getColorForResultat(
                        contactData['statutAppel'] ?? '',
                      ),
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
                              color: _getColorForResultat(
                                contactData['statutAppel'] ?? '',
                              ),
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
