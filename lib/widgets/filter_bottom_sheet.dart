import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/contact_filter.dart';

class FilterBottomSheet extends StatefulWidget {
  final ContactFilter currentFilter;

  const FilterBottomSheet({super.key, required this.currentFilter});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late FilterType _selectedFilterType;
  late SortOrder _sortOrder;
  String? _selectedNationalite;
  String? _selectedCanal;
  String? _selectedStatutAppel;
  int _selectedDegreSatisfaction = 5;

  // Predefined nationalities list
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

  // Predefined reservation channels list
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

  // Predefined call statuses list
  final List<String> _statutsAppel = [
    'Non appelé',
    'Appelé',
    'À rappeler',
    'Ne pas déranger',
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
    _selectedFilterType = widget.currentFilter.filterType;
    _sortOrder = widget.currentFilter.sortOrder;
    _selectedNationalite = widget.currentFilter.nationaliteValue;
    _selectedCanal = widget.currentFilter.canalReservationValue;
    _selectedStatutAppel = widget.currentFilter.statutAppelValue;
    _selectedDegreSatisfaction =
        widget.currentFilter.degreSatisfactionValue ?? 5;
  }

  Widget _buildFilterOption({
    required FilterType type,
    required String title,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    bool isSelected = _selectedFilterType == type;

    return Card(
      elevation: isSelected ? 2 : 0,
      color: isSelected ? Colors.blue.shade50 : null,
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
        title: Text(
          title,
          style: GoogleFonts.sora(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue : null,
          ),
        ),
        trailing:
            trailing ??
            (isSelected ? Icon(Icons.check_circle, color: Colors.blue) : null),
        onTap:
            onTap ??
            () {
              setState(() {
                _selectedFilterType = type;
              });
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtres',
                style: GoogleFonts.sora(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Divider(),

          // Sort Order Toggle
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text(
                  'Ordre: ',
                  style: GoogleFonts.sora(fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 8),
                ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_upward, size: 16),
                      SizedBox(width: 4),
                      Text('Croissant'),
                    ],
                  ),
                  selected: _sortOrder == SortOrder.ascending,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _sortOrder = SortOrder.ascending);
                    }
                  },
                ),
                SizedBox(width: 8),
                ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_downward, size: 16),
                      SizedBox(width: 4),
                      Text('Décroissant'),
                    ],
                  ),
                  selected: _sortOrder == SortOrder.descending,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _sortOrder = SortOrder.descending);
                    }
                  },
                ),
              ],
            ),
          ),

          Divider(),

          // Filter Options
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // No Filter
                  _buildFilterOption(
                    type: FilterType.none,
                    title: 'Aucun filtre (Date de création)',
                    icon: Icons.filter_alt_off,
                  ),

                  // Nationalité
                  Card(
                    elevation: _selectedFilterType == FilterType.nationalite
                        ? 2
                        : 0,
                    color: _selectedFilterType == FilterType.nationalite
                        ? Colors.blue.shade50
                        : null,
                    child: ListTile(
                      leading: Icon(
                        Icons.flag,
                        color: _selectedFilterType == FilterType.nationalite
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      title: Text(
                        'Nationalité',
                        style: GoogleFonts.sora(
                          fontWeight:
                              _selectedFilterType == FilterType.nationalite
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _selectedFilterType == FilterType.nationalite
                              ? Colors.blue
                              : null,
                        ),
                      ),
                      trailing: DropdownButton<String>(
                        value: _selectedNationalite,
                        hint: Text('Choisir', style: GoogleFonts.sora()),
                        underline: SizedBox(),
                        items: _nationalites.map((nat) {
                          return DropdownMenuItem(
                            value: nat,
                            child: Text(nat, style: GoogleFonts.sora()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedNationalite = value;
                            _selectedFilterType = FilterType.nationalite;
                          });
                        },
                      ),
                    ),
                  ),

                  // Nom/Prénom
                  _buildFilterOption(
                    type: FilterType.nomPrenom,
                    title: 'Nom/Prénom (A-Z)',
                    icon: Icons.sort_by_alpha,
                  ),

                  // Canal de réservation
                  Card(
                    elevation:
                        _selectedFilterType == FilterType.canalReservation
                        ? 2
                        : 0,
                    color: _selectedFilterType == FilterType.canalReservation
                        ? Colors.blue.shade50
                        : null,
                    child: ListTile(
                      leading: Icon(
                        Icons.book_online,
                        color:
                            _selectedFilterType == FilterType.canalReservation
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      title: Text(
                        'Canal de réservation',
                        style: GoogleFonts.sora(
                          fontWeight:
                              _selectedFilterType == FilterType.canalReservation
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color:
                              _selectedFilterType == FilterType.canalReservation
                              ? Colors.blue
                              : null,
                        ),
                      ),
                      trailing: DropdownButton<String>(
                        value: _selectedCanal,
                        hint: Text('Choisir', style: GoogleFonts.sora()),
                        underline: SizedBox(),
                        items: _canaux.map((canal) {
                          return DropdownMenuItem(
                            value: canal,
                            child: Text(canal, style: GoogleFonts.sora()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCanal = value;
                            _selectedFilterType = FilterType.canalReservation;
                          });
                        },
                      ),
                    ),
                  ),

                  // Statut d'appel
                  Card(
                    elevation: _selectedFilterType == FilterType.statutAppel
                        ? 2
                        : 0,
                    color: _selectedFilterType == FilterType.statutAppel
                        ? Colors.blue.shade50
                        : null,
                    child: ListTile(
                      leading: Icon(
                        Icons.phone_callback,
                        color: _selectedFilterType == FilterType.statutAppel
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      title: Text(
                        "Statut d'appel",
                        style: GoogleFonts.sora(
                          fontWeight:
                              _selectedFilterType == FilterType.statutAppel
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _selectedFilterType == FilterType.statutAppel
                              ? Colors.blue
                              : null,
                        ),
                      ),
                      trailing: DropdownButton<String>(
                        value: _selectedStatutAppel,
                        hint: Text('Choisir', style: GoogleFonts.sora()),
                        underline: SizedBox(),
                        items: _statutsAppel.map((statut) {
                          return DropdownMenuItem(
                            value: statut,
                            child: Text(statut, style: GoogleFonts.sora()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatutAppel = value;
                            _selectedFilterType = FilterType.statutAppel;
                          });
                        },
                      ),
                    ),
                  ),

                  // Degré de satisfaction
                  Card(
                    elevation:
                        _selectedFilterType == FilterType.degreSatisfaction
                        ? 2
                        : 0,
                    color: _selectedFilterType == FilterType.degreSatisfaction
                        ? Colors.blue.shade50
                        : null,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color:
                                    _selectedFilterType ==
                                        FilterType.degreSatisfaction
                                    ? Colors.amber
                                    : Colors.grey,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Degré de satisfaction',
                                style: GoogleFonts.sora(
                                  fontWeight:
                                      _selectedFilterType ==
                                          FilterType.degreSatisfaction
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color:
                                      _selectedFilterType ==
                                          FilterType.degreSatisfaction
                                      ? Colors.blue
                                      : null,
                                ),
                              ),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '$_selectedDegreSatisfaction/10',
                                  style: GoogleFonts.sora(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '0',
                                style: GoogleFonts.sora(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Expanded(
                                child: Slider(
                                  value: _selectedDegreSatisfaction.toDouble(),
                                  min: 0,
                                  max: 10,
                                  divisions: 10,
                                  activeColor: Colors.amber,
                                  label: _selectedDegreSatisfaction.toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDegreSatisfaction = value
                                          .toInt();
                                      _selectedFilterType =
                                          FilterType.degreSatisfaction;
                                    });
                                  },
                                ),
                              ),
                              Text(
                                '10',
                                style: GoogleFonts.sora(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          // Star indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              10,
                              (index) => Icon(
                                Icons.star,
                                size: 20,
                                color: index < _selectedDegreSatisfaction
                                    ? Colors.amber
                                    : Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Divider(),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Reset filter
                    Navigator.pop(context, ContactFilter());
                  },
                  child: Text('Réinitialiser', style: GoogleFonts.sora()),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    ContactFilter newFilter = ContactFilter(
                      filterType: _selectedFilterType,
                      sortOrder: _sortOrder,
                      nationaliteValue: _selectedNationalite,
                      canalReservationValue: _selectedCanal,
                      statutAppelValue: _selectedStatutAppel,
                      degreSatisfactionValue: _selectedDegreSatisfaction,
                    );
                    Navigator.pop(context, newFilter);
                  },
                  child: Text(
                    'Appliquer',
                    style: GoogleFonts.sora(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
