const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNotificationOnFeatureUpdate = functions.firestore
  .document('features/feature_{index}')
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const oldData = change.before.data();
    const index = context.params.index; // Get the feature index from the document ID

    // Check if relevant fields (e.g., score or started) changed
    if (newData.score === oldData.score && newData.started === oldData.started) {
      console.log(`No relevant changes in feature_${index}`);
      return null;
    }

    // Fetch all users to notify (you can modify this to target specific users)
    const usersSnapshot = await admin.firestore().collection('users').get();
    const tokens = [];

    // Collect valid FCM tokens
    for (const userDoc of usersSnapshot.docs) {
      const fcmToken = userDoc.data().fcmToken;
      if (fcmToken) {
        tokens.push(fcmToken);
      }
    }

    if (tokens.length === 0) {
      console.log('No valid FCM tokens found');
      return null;
    }

    // Create the notification payload
    const payload = {
      notification: {
        title: 'Feature Update!',
        body: `The feature "${newData.name}" has been updated! Score: ${newData.score}, Started: ${newData.started}`,
      },
      data: {
        featureIndex: index,
        type: 'feature_update',
      },
    };

    // Send notifications to all valid tokens
    try {
      const response = await admin.messaging().sendMulticast({
        tokens,
        notification: payload.notification,
        data: payload.data,
      });

      console.log(`Successfully sent ${response.successCount} notifications`);
      if (response.failureCount > 0) {
        console.log(`Failed to send ${response.failureCount} notifications`);
      }
    } catch (error) {
      console.error('Error sending notifications:', error);
    }

    return null;
  });