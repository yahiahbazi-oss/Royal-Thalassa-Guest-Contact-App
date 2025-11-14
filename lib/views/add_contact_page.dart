import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/crud_services.dart';

class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final _formKey = GlobalKey<FormState>();
  final CrudServices _crudServices = CrudServices();

  // Controllers for text fields
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _telephoneFixeController = TextEditingController();
  final _autreNumeroController = TextEditingController();
  final _langueController = TextEditingController();
  final _nationaliteController = TextEditingController();
  final _numeroChambreController = TextEditingController();
  final _canalReservationController = TextEditingController();
  final _historiqueSejourController = TextEditingController();
  final _pointsPositifsController = TextEditingController();
  final _pointsNegatifsController = TextEditingController();

  // Date fields
  DateTime? _dateNaissance;
  DateTime? _dateArrivee;
  DateTime? _dateDepart;

  // Dropdown values
  String _sexe = 'Homme';
  String _statutAppel = 'Non appelé';
  int _degreSatisfaction = 5;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _whatsappController.dispose();
    _telephoneFixeController.dispose();
    _autreNumeroController.dispose();
    _langueController.dispose();
    _nationaliteController.dispose();
    _numeroChambreController.dispose();
    _canalReservationController.dispose();
    _historiqueSejourController.dispose();
    _pointsPositifsController.dispose();
    _pointsNegatifsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, String field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (field == 'naissance') _dateNaissance = picked;
        if (field == 'arrivee') _dateArrivee = picked;
        if (field == 'depart') _dateDepart = picked;
      });
    }
  }

  void _saveContact() async {
    if (_formKey.currentState!.validate()) {
      if (_dateNaissance == null ||
          _dateArrivee == null ||
          _dateDepart == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner toutes les dates'),
          ),
        );
        return;
      }

      String result = await _crudServices.addNewContact(
        nom: _nomController.text,
        prenom: _prenomController.text,
        telephone: _telephoneController.text,
        whatsapp: _whatsappController.text,
        telephoneFixe: _telephoneFixeController.text,
        autreNumero: _autreNumeroController.text,
        dateNaissance: Timestamp.fromDate(_dateNaissance!),
        langue: _langueController.text,
        sexe: _sexe,
        nationalite: _nationaliteController.text,
        dateArrivee: Timestamp.fromDate(_dateArrivee!),
        dateDepart: Timestamp.fromDate(_dateDepart!),
        numeroChambre: _numeroChambreController.text,
        canalReservation: _canalReservationController.text,
        historiqueSejour: _historiqueSejourController.text,
        degreSatisfaction: _degreSatisfaction,
        pointsPositifs: _pointsPositifsController.text,
        pointsNegatifs: _pointsNegatifsController.text,
        statutAppel: _statutAppel,
      );

      if (result == "Contact added successfully") {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact ajouté avec succès')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter Contact', style: GoogleFonts.sora()),
        backgroundColor: Colors.blue,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Nom
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nom *',
                  labelStyle: GoogleFonts.sora(),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),

              // Prénom
              TextFormField(
                controller: _prenomController,
                decoration: InputDecoration(
                  labelText: 'Prénom *',
                  labelStyle: GoogleFonts.sora(),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),

              // Téléphone
              TextFormField(
                controller: _telephoneController,
                decoration: InputDecoration(
                  labelText: 'Téléphone *',
                  labelStyle: GoogleFonts.sora(),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),

              // WhatsApp
              TextFormField(
                controller: _whatsappController,
                decoration: InputDecoration(
                  labelText: 'WhatsApp',
                  labelStyle: GoogleFonts.sora(),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Téléphone Fixe
              TextFormField(
                controller: _telephoneFixeController,
                decoration: InputDecoration(
                  labelText: 'Téléphone Fixe',
                  labelStyle: GoogleFonts.sora(),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Autre Numéro
              TextFormField(
                controller: _autreNumeroController,
                decoration: InputDecoration(
                  labelText: 'Autre Numéro',
                  labelStyle: GoogleFonts.sora(),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Date Naissance
              ListTile(
                title: Text(
                  _dateNaissance == null
                      ? 'Date de Naissance *'
                      : 'Né(e) le: ${_dateNaissance!.day}/${_dateNaissance!.month}/${_dateNaissance!.year}',
                  style: GoogleFonts.sora(),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, 'naissance'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // Langue
              TextFormField(
                controller: _langueController,
                decoration: InputDecoration(
                  labelText: 'Langue',
                  labelStyle: GoogleFonts.sora(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Sexe
              DropdownButtonFormField<String>(
                value: _sexe,
                decoration: InputDecoration(
                  labelText: 'Sexe',
                  labelStyle: GoogleFonts.sora(),
                  border: const OutlineInputBorder(),
                ),
                items: ['Homme', 'Femme', 'Autre']
                    .map(
                      (sexe) =>
                          DropdownMenuItem(value: sexe, child: Text(sexe)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _sexe = value!),
              ),
              const SizedBox(height: 16),

              // Nationalité
              TextFormField(
                controller: _nationaliteController,
                decoration: InputDecoration(
                  labelText: 'Nationalité',
                  labelStyle: GoogleFonts.sora(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Date Arrivée
              ListTile(
                title: Text(
                  _dateArrivee == null
                      ? 'Date d\'Arrivée *'
                      : 'Arrivée: ${_dateArrivee!.day}/${_dateArrivee!.month}/${_dateArrivee!.year}',
                  style: GoogleFonts.sora(),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, 'arrivee'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // Date Départ
              ListTile(
                title: Text(
                  _dateDepart == null
                      ? 'Date de Départ *'
                      : 'Départ: ${_dateDepart!.day}/${_dateDepart!.month}/${_dateDepart!.year}',
                  style: GoogleFonts.sora(),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, 'depart'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // Numéro Chambre
              TextFormField(
                controller: _numeroChambreController,
                decoration: InputDecoration(
                  labelText: 'Numéro de Chambre',
                  labelStyle: GoogleFonts.sora(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Canal Réservation
              TextFormField(
                controller: _canalReservationController,
                decoration: InputDecoration(
                  labelText: 'Canal de Réservation',
                  labelStyle: GoogleFonts.sora(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Historique Séjour
              TextFormField(
                controller: _historiqueSejourController,
                decoration: InputDecoration(
                  labelText: 'Historique Séjour',
                  labelStyle: GoogleFonts.sora(),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Degré Satisfaction
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Degré de Satisfaction: $_degreSatisfaction/10',
                    style: GoogleFonts.sora(),
                  ),
                  Slider(
                    value: _degreSatisfaction.toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: _degreSatisfaction.toString(),
                    onChanged: (value) =>
                        setState(() => _degreSatisfaction = value.toInt()),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Points Positifs
              TextFormField(
                controller: _pointsPositifsController,
                decoration: InputDecoration(
                  labelText: 'Points Positifs',
                  labelStyle: GoogleFonts.sora(),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Points Négatifs
              TextFormField(
                controller: _pointsNegatifsController,
                decoration: InputDecoration(
                  labelText: 'Points Négatifs',
                  labelStyle: GoogleFonts.sora(),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Statut Appel
              DropdownButtonFormField<String>(
                value: _statutAppel,
                decoration: InputDecoration(
                  labelText: 'Statut Appel',
                  labelStyle: GoogleFonts.sora(),
                  border: const OutlineInputBorder(),
                ),
                items: ['Non appelé', 'Appelé', 'À rappeler', 'Ne pas déranger']
                    .map(
                      (statut) =>
                          DropdownMenuItem(value: statut, child: Text(statut)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _statutAppel = value!),
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _saveContact,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  textStyle: GoogleFonts.sora(fontSize: 18),
                ),
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
