import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/Widget/MessageBubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Chat extends StatelessWidget {
  const Chat({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No message here'),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong....'),
          );
        }
        final loadedmessages = snapshot.data!.docs;

        return ListView.builder(
            reverse: true,
            padding: const EdgeInsets.only(bottom: 40, left: 14, right: 14),
            itemCount: loadedmessages.length,
            itemBuilder: (context, index) {
              final chatmessage = loadedmessages[index].data();
              final nextchatmessage = index + 1 < loadedmessages.length
                  ? loadedmessages[index + 1].data()
                  : null;
              final currentMessageUserId = chatmessage['userID'];
              final nextMessageUserId =
                  nextchatmessage != null ? nextchatmessage['userID'] : null;
              final nextUserIsSame = currentMessageUserId == nextMessageUserId;

              if (nextUserIsSame) {
                return MessageBubble.next(
                    message: chatmessage['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId);
              } else {
                return MessageBubble.first(
                    userImage: chatmessage['UserImage'],
                    username: chatmessage['username'],
                    message: chatmessage['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId);
              }
            });
      },
    );
  }
}
