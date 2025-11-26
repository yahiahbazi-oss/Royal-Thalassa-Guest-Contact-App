import 'package:cloud_firestore/cloud_firestore.dart';

enum SortOrder { ascending, descending }

enum FilterType {
  nationalite,
  nomPrenom,
  canalReservation,
  statutAppel,
  degreSatisfaction,
  none,
}

class ContactFilter {
  final FilterType filterType;
  final SortOrder sortOrder;
  final String? nationaliteValue;
  final String? canalReservationValue;
  final String? statutAppelValue;
  final int? degreSatisfactionValue;

  ContactFilter({
    this.filterType = FilterType.none,
    this.sortOrder = SortOrder.descending,
    this.nationaliteValue,
    this.canalReservationValue,
    this.statutAppelValue,
    this.degreSatisfactionValue,
  });

  ContactFilter copyWith({
    FilterType? filterType,
    SortOrder? sortOrder,
    String? nationaliteValue,
    String? canalReservationValue,
    String? statutAppelValue,
    int? degreSatisfactionValue,
  }) {
    return ContactFilter(
      filterType: filterType ?? this.filterType,
      sortOrder: sortOrder ?? this.sortOrder,
      nationaliteValue: nationaliteValue ?? this.nationaliteValue,
      canalReservationValue:
          canalReservationValue ?? this.canalReservationValue,
      statutAppelValue: statutAppelValue ?? this.statutAppelValue,
      degreSatisfactionValue:
          degreSatisfactionValue ?? this.degreSatisfactionValue,
    );
  }

  // Apply filter and sort to a list of documents
  List<DocumentSnapshot> apply(List<DocumentSnapshot> docs) {
    List<DocumentSnapshot> filteredDocs = List.from(docs);

    // Apply filters
    switch (filterType) {
      case FilterType.statutAppel:
        if (statutAppelValue != null && statutAppelValue!.isNotEmpty) {
          filteredDocs = filteredDocs.where((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return data['statutAppel'] == statutAppelValue;
          }).toList();
        }
        break;

      case FilterType.nationalite:
        if (nationaliteValue != null && nationaliteValue!.isNotEmpty) {
          filteredDocs = filteredDocs.where((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return data['nationalite'] == nationaliteValue;
          }).toList();
        }
        break;

      case FilterType.canalReservation:
        if (canalReservationValue != null &&
            canalReservationValue!.isNotEmpty) {
          filteredDocs = filteredDocs.where((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return data['canalReservation'] == canalReservationValue;
          }).toList();
        }
        break;

      case FilterType.degreSatisfaction:
        if (degreSatisfactionValue != null) {
          filteredDocs = filteredDocs.where((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return data['degreSatisfaction'] == degreSatisfactionValue;
          }).toList();
        }
        break;

      default:
        break;
    }

    // Apply sorting
    filteredDocs.sort((a, b) {
      Map<String, dynamic> dataA = a.data() as Map<String, dynamic>;
      Map<String, dynamic> dataB = b.data() as Map<String, dynamic>;

      int comparison = 0;

      switch (filterType) {
        case FilterType.nomPrenom:
          String nameA = '${dataA['nom'] ?? ''} ${dataA['prenom'] ?? ''}'
              .toLowerCase();
          String nameB = '${dataB['nom'] ?? ''} ${dataB['prenom'] ?? ''}'
              .toLowerCase();
          comparison = nameA.compareTo(nameB);
          break;

        case FilterType.nationalite:
          String natA = (dataA['nationalite'] ?? '').toString().toLowerCase();
          String natB = (dataB['nationalite'] ?? '').toString().toLowerCase();
          comparison = natA.compareTo(natB);
          break;

        case FilterType.canalReservation:
          String canalA = (dataA['canalReservation'] ?? '')
              .toString()
              .toLowerCase();
          String canalB = (dataB['canalReservation'] ?? '')
              .toString()
              .toLowerCase();
          comparison = canalA.compareTo(canalB);
          break;

        case FilterType.degreSatisfaction:
          int satisfactionA = (dataA['degreSatisfaction'] ?? 0) as int;
          int satisfactionB = (dataB['degreSatisfaction'] ?? 0) as int;
          comparison = satisfactionA.compareTo(satisfactionB);
          break;

        default:
          // Default sort by creation date
          Timestamp? dateA = dataA['dateCreation'] as Timestamp?;
          Timestamp? dateB = dataB['dateCreation'] as Timestamp?;
          if (dateA == null || dateB == null) return 0;
          comparison = dateA.compareTo(dateB);
          break;
      }

      return sortOrder == SortOrder.ascending ? comparison : -comparison;
    });

    return filteredDocs;
  }

  String getFilterLabel() {
    switch (filterType) {
      case FilterType.nationalite:
        return nationaliteValue ?? "Nationalité";
      case FilterType.nomPrenom:
        return "Nom/Prénom (A-Z)";
      case FilterType.canalReservation:
        return canalReservationValue ?? "Canal de réservation";
      case FilterType.statutAppel:
        return statutAppelValue ?? "Statut d'appel";
      case FilterType.degreSatisfaction:
        return "Satisfaction: ${degreSatisfactionValue ?? 0}/10";
      case FilterType.none:
        return "Aucun filtre";
    }
  }

  bool get isActive => filterType != FilterType.none;
}
