const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendUserNotification = onDocumentCreated(
  "users/{userId}/notifications/{notificationId}",
  async (event) => {
    const userId = event.params.userId;
    const data = event.data?.data();

    if (!data) return;

    const userDoc = await admin.firestore().collection("users").doc(userId).get();
    const tokens = userDoc.data()?.pushTokens || [];

    if (!Array.isArray(tokens) || tokens.length === 0) {
      return;
    }

    const message = {
      tokens,
      notification: {
        title: data.title || "Powerank",
        body: data.body || "Tens uma nova notificacao",
      },
      data: {
        type: String(data.type || ""),
        chatId: String(data.chatId || ""),
        otherUid: String(data.otherUid || ""),
        otherUsername: String(data.otherUsername || ""),
        workoutId: String(data.workoutId || ""),
        senderId: String(data.senderId || ""),
      },
      android: {
        priority: "high",
      },
    };

    const response = await admin.messaging().sendEachForMulticast(message);

    const invalidTokens = [];
    response.responses.forEach((result, index) => {
      if (!result.success) {
        invalidTokens.push(tokens[index]);
      }
    });

    if (invalidTokens.length > 0) {
      await admin.firestore().collection("users").doc(userId).update({
        pushTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens),
      });
    }
  }
);
