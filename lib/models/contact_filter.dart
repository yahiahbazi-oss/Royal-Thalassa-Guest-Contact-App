import 'package:cloud_firestore/cloud_firestore.dart';

enum SortOrder { ascending, descending }

enum FilterType {
  dateArrivee,
  dateDepart,
  nationalite,
  nomPrenom,
  canalReservation,
  statutAppel,
  none,
}

class ContactFilter {
  final FilterType filterType;
  final SortOrder sortOrder;
  final String? nationaliteValue;
  final String? canalReservationValue;
  final String? statutAppelValue;
  final DateTime? dateArriveeValue;
  final DateTime? dateDepartValue;

  ContactFilter({
    this.filterType = FilterType.none,
    this.sortOrder = SortOrder.descending,
    this.nationaliteValue,
    this.canalReservationValue,
    this.statutAppelValue,
    this.dateArriveeValue,
    this.dateDepartValue,
  });

  ContactFilter copyWith({
    FilterType? filterType,
    SortOrder? sortOrder,
    String? nationaliteValue,
    String? canalReservationValue,
    String? statutAppelValue,
    DateTime? dateArriveeValue,
    DateTime? dateDepartValue,
  }) {
    return ContactFilter(
      filterType: filterType ?? this.filterType,
      sortOrder: sortOrder ?? this.sortOrder,
      nationaliteValue: nationaliteValue ?? this.nationaliteValue,
      canalReservationValue:
          canalReservationValue ?? this.canalReservationValue,
      statutAppelValue: statutAppelValue ?? this.statutAppelValue,
      dateArriveeValue: dateArriveeValue ?? this.dateArriveeValue,
      dateDepartValue: dateDepartValue ?? this.dateDepartValue,
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

      case FilterType.dateArrivee:
        if (dateArriveeValue != null) {
          filteredDocs = filteredDocs.where((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            if (data['dateArrivee'] == null) return false;
            DateTime docDate = (data['dateArrivee'] as Timestamp).toDate();
            return docDate.year == dateArriveeValue!.year &&
                docDate.month == dateArriveeValue!.month &&
                docDate.day == dateArriveeValue!.day;
          }).toList();
        }
        break;

      case FilterType.dateDepart:
        if (dateDepartValue != null) {
          filteredDocs = filteredDocs.where((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            if (data['dateDepart'] == null) return false;
            DateTime docDate = (data['dateDepart'] as Timestamp).toDate();
            return docDate.year == dateDepartValue!.year &&
                docDate.month == dateDepartValue!.month &&
                docDate.day == dateDepartValue!.day;
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
        case FilterType.dateArrivee:
          Timestamp? dateA = dataA['dateArrivee'] as Timestamp?;
          Timestamp? dateB = dataB['dateArrivee'] as Timestamp?;
          if (dateA == null || dateB == null) return 0;
          comparison = dateA.compareTo(dateB);
          break;

        case FilterType.dateDepart:
          Timestamp? dateA = dataA['dateDepart'] as Timestamp?;
          Timestamp? dateB = dataB['dateDepart'] as Timestamp?;
          if (dateA == null || dateB == null) return 0;
          comparison = dateA.compareTo(dateB);
          break;

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
      case FilterType.dateArrivee:
        if (dateArriveeValue != null) {
          return "Arrivée: ${dateArriveeValue!.day}/${dateArriveeValue!.month}/${dateArriveeValue!.year}";
        }
        return "Date d'arrivée";
      case FilterType.dateDepart:
        if (dateDepartValue != null) {
          return "Départ: ${dateDepartValue!.day}/${dateDepartValue!.month}/${dateDepartValue!.year}";
        }
        return "Date de départ";
      case FilterType.nationalite:
        return nationaliteValue ?? "Nationalité";
      case FilterType.nomPrenom:
        return "Nom/Prénom (A-Z)";
      case FilterType.canalReservation:
        return canalReservationValue ?? "Canal de réservation";
      case FilterType.statutAppel:
        return statutAppelValue ?? "Statut d'appel";
      case FilterType.none:
        return "Aucun filtre";
    }
  }

  bool get isActive => filterType != FilterType.none;
}
