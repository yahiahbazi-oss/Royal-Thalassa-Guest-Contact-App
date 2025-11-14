import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
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
  final _numeroChambreController = TextEditingController();
  final _pointsPositifsController = TextEditingController();
  final _pointsNegatifsController = TextEditingController();

  // Date fields
  DateTime? _dateNaissance;
  DateTime? _dateArrivee;
  DateTime? _dateDepart;

  // Dropdown values
  String _sexe = 'Homme';
  String _langue = 'Français';
  String? _nationalite;
  String? _canalReservation;
  String _historiqueSejour = 'Nouveau client';
  String _statutAppel = 'Non appelé';
  int _degreSatisfaction = 0;
  bool _satisfactionSet = false;

  // List of languages
  final List<String> _langues = [
    'Arabe',
    'Anglais',
    'Allemand',
    'Français',
    'Italien',
    'Espagnol',
    'Russe',
    'Turc',
    'Polonais',
    'Néerlandais',
    'Ukrainien',
    'Roumain',
    'Portugais',
    'Grec',
    'Tchèque',
    'Hongrois',
    'Suédois',
    'Serbo-croate',
    'Bulgare',
    'Danois',
    'Finnois',
    'Slovaque',
    'Norvégien',
    'Lituanien',
    'Letton',
    'Slovène',
    'Estonien',
    'Albanais',
    'Macédonien',
    'Catalan',
    'Biélorusse',
  ];

  // List of nationalities
  final List<String> _nationalites = [
    'Tunisie',
    'Algérie',
    'Maroc',
    'Libye',
    'Albanie',
    'Allemagne',
    'Andorre',
    'Arménie',
    'Autriche',
    'Azerbaïdjan',
    'Belgique',
    'Biélorussie',
    'Bosnie-Herzégovine',
    'Bulgarie',
    'Chypre',
    'Croatie',
    'Danemark',
    'Espagne',
    'Estonie',
    'Finlande',
    'France',
    'Géorgie',
    'Grèce',
    'Hongrie',
    'Irlande',
    'Islande',
    'Italie',
    'Kazakhstan',
    'Kosovo',
    'Lettonie',
    'Liechtenstein',
    'Lituanie',
    'Luxembourg',
    'Malte',
    'Moldavie',
    'Monaco',
    'Monténégro',
    'Norvège',
    'Pays-Bas',
    'Pologne',
    'Portugal',
    'République tchèque',
    'Roumanie',
    'Royaume-Uni',
    'Russie',
    'Saint-Marin',
    'Serbie',
    'Slovaquie',
    'Slovénie',
    'Suède',
    'Suisse',
    'Ukraine',
    'Monde arabe',
    'Amérique du Sud',
    'Canada',
    'États-Unis',
    'Asie',
    'Australie',
    'Afrique subsaharienne',
    'Autre',
  ];

  // List of reservation channels
  final List<String> _canalsReservation = [
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

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _whatsappController.dispose();
    _telephoneFixeController.dispose();
    _autreNumeroController.dispose();
    _numeroChambreController.dispose();
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

      if (!_satisfactionSet) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez définir le degré de satisfaction'),
          ),
        );
        return;
      }

      if (_canalReservation == null || _canalReservation!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner un canal de réservation'),
          ),
        );
        return;
      }

      if (_nationalite == null || _nationalite!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une nationalité'),
          ),
        );
        return;
      }

      if (_numeroChambreController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez entrer le numéro de chambre')),
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
        langue: _langue,
        sexe: _sexe,
        nationalite: _nationalite ?? '',
        dateArrivee: Timestamp.fromDate(_dateArrivee!),
        dateDepart: Timestamp.fromDate(_dateDepart!),
        numeroChambre: _numeroChambreController.text,
        canalReservation: _canalReservation ?? '',
        historiqueSejour: _historiqueSejour,
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
              DropdownButtonFormField<String>(
                value: _langue,
                decoration: InputDecoration(
                  labelText: 'Langue',
                  labelStyle: GoogleFonts.sora(),
                  border: const OutlineInputBorder(),
                ),
                items: _langues
                    .map(
                      (langue) =>
                          DropdownMenuItem(value: langue, child: Text(langue)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _langue = value!),
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
                items: ['Homme', 'Femme']
                    .map(
                      (sexe) =>
                          DropdownMenuItem(value: sexe, child: Text(sexe)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _sexe = value!),
              ),
              const SizedBox(height: 16),

              // Nationalité
              DropdownSearch<String>(
                items: (filter, infiniteScrollProps) => _nationalites,
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      labelText: 'Rechercher...',
                      labelStyle: GoogleFonts.sora(),
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  constraints: const BoxConstraints(maxHeight: 400),
                ),
                decoratorProps: DropDownDecoratorProps(
                  decoration: InputDecoration(
                    labelText: 'Nationalité *',
                    labelStyle: GoogleFonts.sora(),
                    border: const OutlineInputBorder(),
                  ),
                ),
                selectedItem: _nationalite,
                onChanged: (value) => setState(() => _nationalite = value),
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
                  labelText: 'Numéro de Chambre *',
                  labelStyle: GoogleFonts.sora(),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),

              // Canal Réservation
              DropdownSearch<String>(
                items: (filter, infiniteScrollProps) => _canalsReservation,
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      labelText: 'Rechercher...',
                      labelStyle: GoogleFonts.sora(),
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  constraints: const BoxConstraints(maxHeight: 300),
                ),
                decoratorProps: DropDownDecoratorProps(
                  decoration: InputDecoration(
                    labelText: 'Canal de Réservation *',
                    labelStyle: GoogleFonts.sora(),
                    border: const OutlineInputBorder(),
                  ),
                ),
                selectedItem: _canalReservation,
                onChanged: (value) => setState(() => _canalReservation = value),
              ),
              const SizedBox(height: 16),

              // Historique Séjour
              DropdownButtonFormField<String>(
                value: _historiqueSejour,
                decoration: InputDecoration(
                  labelText: 'Historique Séjour',
                  labelStyle: GoogleFonts.sora(),
                  border: const OutlineInputBorder(),
                ),
                items: ['Nouveau client', 'Revenant']
                    .map(
                      (historique) => DropdownMenuItem(
                        value: historique,
                        child: Text(historique),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _historiqueSejour = value!),
              ),
              const SizedBox(height: 16),

              // Degré Satisfaction
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Degré de Satisfaction: $_degreSatisfaction/10 *',
                    style: GoogleFonts.sora(
                      color: _satisfactionSet ? Colors.black : Colors.red,
                    ),
                  ),
                  Slider(
                    value: _degreSatisfaction.toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: _degreSatisfaction.toString(),
                    onChanged: (value) => setState(() {
                      _degreSatisfaction = value.toInt();
                      _satisfactionSet = true;
                    }),
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
