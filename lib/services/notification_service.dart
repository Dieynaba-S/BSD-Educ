import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_gestionsupportdecours/app_state.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'notifications';

  // Envoyer une notification à tous les utilisateurs
  Future<void> envoyerNotification({
    required String titre,
    required String message,
    required String documentId,
  }) async {
    try {
      await _firestore.collection(_collection).add({
        'titre': titre,
        'message': message,
        'documentId': documentId,
        'dateCreation': DateTime.now().toIso8601String(),
        'lu': false,
      });
    } catch (e) {
      print("Erreur envoi notification : $e");
    }
  }

  // Écouter les nouvelles notifications en temps réel
  Stream<QuerySnapshot> ecouterNotifications() {
    return _firestore
        .collection(_collection)
        .orderBy('dateCreation', descending: true)
        .limit(20)
        .snapshots();
  }

  // Marquer une notification comme lue
  Future<void> marquerCommeLue(String notificationId) async {
    await _firestore
        .collection(_collection)
        .doc(notificationId)
        .update({'lu': true});
  }

  // Compter les notifications non lues
  Stream<int> compterNonLues() {
    return _firestore
        .collection(_collection)
        .where('lu', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }
}