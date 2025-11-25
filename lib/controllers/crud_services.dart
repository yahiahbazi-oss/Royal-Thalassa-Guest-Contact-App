import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrudServices {
  User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference contactsCollection = FirebaseFirestore.instance
      .collection('contacts');
  final CollectionReference countersCollection = FirebaseFirestore.instance
      .collection('counters');

  // Get next contact ID
  Future<int> _getNextContactId() async {
    try {
      DocumentReference counterDoc = countersCollection.doc('contactCounter');

      return await FirebaseFirestore.instance.runTransaction((
        transaction,
      ) async {
        DocumentSnapshot snapshot = await transaction.get(counterDoc);

        int newId;
        if (!snapshot.exists) {
          newId = 1;
          transaction.set(counterDoc, {'lastId': newId});
        } else {
          newId = (snapshot.data() as Map<String, dynamic>)['lastId'] + 1;
          transaction.update(counterDoc, {'lastId': newId});
        }

        return newId;
      });
    } catch (e) {
      return 1;
    }
  }

  // Add new contact
  Future<String> addNewContact({
    required String nom,
    required String prenom,
    required String telephone,
    required String whatsapp,
    required String telephoneFixe,
    required String autreNumero,
    required String email,
    required Timestamp dateNaissance,
    required String langue,
    required String sexe,
    required String nationalite,
    required Timestamp dateArrivee,
    required Timestamp dateDepart,
    required String numeroChambre,
    required String canalReservation,
    required String historiqueSejour,
    required int degreSatisfaction,
    required String pointsPositifs,
    required String pointsNegatifs,
    required String statutAppel,
    List<Map<String, dynamic>>? resultatsAppels,
  }) async {
    try {
      // Get next contact ID
      int contactId = await _getNextContactId();

      // Get current date and time
      DateTime now = DateTime.now();

      await contactsCollection.add({
        'contactId': contactId,
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'whatsapp': whatsapp,
        'telephoneFixe': telephoneFixe,
        'autreNumero': autreNumero,
        'email': email,
        'dateNaissance': dateNaissance,
        'langue': langue,
        'sexe': sexe,
        'nationalite': nationalite,
        'dateArrivee': dateArrivee,
        'dateDepart': dateDepart,
        'numeroChambre': numeroChambre,
        'canalReservation': canalReservation,
        'historiqueSejour': historiqueSejour,
        'degreSatisfaction': degreSatisfaction,
        'pointsPositifs': pointsPositifs,
        'pointsNegatifs': pointsNegatifs,
        'dateCreation': Timestamp.fromDate(now),
        'heureCreation':
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        'statutAppel': statutAppel,
        'resultatsAppels': resultatsAppels ?? [],
        'userId': user?.uid,
      });
      return "Contact added successfully";
    } catch (e) {
      return e.toString();
    }
  }

  // Read documents inside firestore - Get all contacts from all users
  Stream<QuerySnapshot> getContacts() {
    return contactsCollection.snapshots();
  }

  // Update call result for a contact
  Future<String> updateResultatAppel({
    required String documentId,
    required String newStatutAppel,
    required List<Map<String, dynamic>> currentResultats,
  }) async {
    try {
      DateTime now = DateTime.now();

      // Add new result to history
      List<Map<String, dynamic>> updatedResultats = List.from(currentResultats);
      updatedResultats.add({
        'resultat': newStatutAppel,
        'date': Timestamp.fromDate(now),
        'heure':
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      });

      await contactsCollection.doc(documentId).update({
        'statutAppel': newStatutAppel,
        'resultatsAppels': updatedResultats,
      });

      return "Résultat d'appel mis à jour avec succès";
    } catch (e) {
      return e.toString();
    }
  }
}
