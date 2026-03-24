import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationMenuButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NotificationMenuButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final iconColor =
        IconTheme.of(context).color ?? theme.colorScheme.onSurface;
    final badgeBorderColor = theme.scaffoldBackgroundColor;

    if (currentUser == null) {
      return IconButton(
        onPressed: onPressed,
        icon: Icon(Icons.menu, color: iconColor),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('notifications')
          .snapshots(),
      builder: (context, snapshot) {
        final hasUnread = snapshot.data?.docs.any((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['isRead'] != true;
            }) ??
            false;

        return IconButton(
          onPressed: onPressed,
          icon: SizedBox(
            width: 28,
            height: 28,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Icon(Icons.menu, color: iconColor),
                ),
                if (hasUnread)
                  Positioned(
                    left: 1,
                    bottom: 1,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7DD3FC),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: badgeBorderColor, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
