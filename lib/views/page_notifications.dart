import 'package:app_gestionsupportdecours/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PageNotifications extends StatefulWidget {
  const PageNotifications({super.key});

  @override
  State<PageNotifications> createState() => _PageNotificationsState();
}

class _PageNotificationsState extends State<PageNotifications> {
  final NotificationService _notifService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          // Marquer tout comme lu
          TextButton(
            onPressed: _marquerToutCommeLu,
            child: const Text(
              'Tout lire',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notifService.ecouterNotifications(),
        builder: (context, snapshot) {
          // Chargement
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Erreur
          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur : ${snapshot.error}'),
            );
          }

          // Aucune notification
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune notification',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final data = notif.data() as Map<String, dynamic>;
              final estLue = data['lu'] ?? false;

              return _buildNotificationCard(
                context,
                notifId: notif.id,
                titre: data['titre'] ?? '',
                message: data['message'] ?? '',
                date: data['dateCreation'] ?? '',
                estLue: estLue,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context, {
    required String notifId,
    required String titre,
    required String message,
    required String date,
    required bool estLue,
  }) {
    return Card(
      color: estLue
          ? null
          : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: estLue
              ? Colors.grey.shade200
              : Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.notifications,
            color: estLue
                ? Colors.grey
                : Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          titre,
          style: TextStyle(
            fontWeight: estLue ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(message, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            Text(
              _formaterDate(date),
              style: TextStyle(
                  fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: !estLue
            ? Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () => _notifService.marquerCommeLue(notifId),
      ),
    );
  }

  Future<void> _marquerToutCommeLu() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('lu', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      await _notifService.marquerCommeLue(doc.id);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Toutes les notifications marquées comme lues ✅'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formaterDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final maintenant = DateTime.now();
      final difference = maintenant.difference(date);

      if (difference.inMinutes < 1) return 'À l\'instant';
      if (difference.inMinutes < 60) return 'Il y a ${difference.inMinutes} min';
      if (difference.inHours < 24) return 'Il y a ${difference.inHours}h';
      if (difference.inDays < 7) return 'Il y a ${difference.inDays} jour(s)';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}