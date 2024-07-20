const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNotification = functions.firestore
    .document('post/{postId}')
    .onCreate(async (snap, context) => {
      const postData = snap.data();

      const tokens = [];
      const usersSnapshot = await admin.firestore().collection('users').get();
      usersSnapshot.forEach(doc => {
        if (doc.data().fcmToken) {
          tokens.push(doc.data().fcmToken);
        }
      });

      const payload = {
        notification: {
          title: postData.companyName,
          body: postData.companyDescription,
        }
      };

      try {
        await admin.messaging().sendToDevice(tokens, payload);
        console.log('Notification sent successfully');
      } catch (error) {
        console.error('Error sending notification:', error);
      }
    });
