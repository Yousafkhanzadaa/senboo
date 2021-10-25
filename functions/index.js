// eslint-disable-next-line no-unused-vars
const functions = require("firebase-functions");

// The Firebase Admin SDK to access Firestore.
const admin = require("firebase-admin");
admin.initializeApp();


exports.onFeedCreated = functions.firestore
    .document("/feeds/{userId}/feedItems/{postId}")
    .onCreate(async (snapshot, context)  => {
      const postCreated = snapshot.data();
      const userId = context.params.userId;
      // const postId = context.params.postId;

      const usersRef = admin.firestore()
          .collection("users")
          .doc(userId);
      const doc = await usersRef.get();
      

      // const registrationToken = "YOUR_REGISTRATION_TOKEN";
      if (postCreated.type == "like") {

        const message = {
          "token": doc.data().token,
          "notification": {
            "title": postCreated.userName,
            "body": "Liked your post",
          },
        };
        admin.messaging().send(message)
      }

      if (postCreated.type == "comment") {

        const message = {
          "token": doc.data().token,
          "notification": {
            "title": postCreated.userName,
            "body": "Commented on your post.",
          },
        };
        admin.messaging().send(message)
      }

    });
