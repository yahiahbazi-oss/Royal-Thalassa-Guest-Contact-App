import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrudServices {
  User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference contactsCollection = FirebaseFirestore.instance
      .collection('contacts');

  // Add new contact
  Future<String> addNewContact({
    required String nom,
    required String prenom,
    required String telephone,
    required String whatsapp,
    required String telephoneFixe,
    required String autreNumero,
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
      await contactsCollection.add({
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'whatsapp': whatsapp,
        'telephoneFixe': telephoneFixe,
        'autreNumero': autreNumero,
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
        'dateCreation': FieldValue.serverTimestamp(),
        'statutAppel': statutAppel,
        'resultatsAppels': resultatsAppels ?? [],
        'userId': user?.uid,
      });
      return "Contact added successfully";
    } catch (e) {
      return e.toString();
    }
  }
}
