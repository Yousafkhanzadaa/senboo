const functions = require("firebase-functions");

const admin = require("firebase-admin");
admin.initializeApp();

exports.onCreatePost = functions.firestore
    .document("/usersPosts/{userId}/userPost/{postId}")
    .onCreate((snapshot, context) => {
      const postCreated = snapshot.data();
      // const userId = context.params.userId;
      const postId = context.params.postId;


      // add new post to collection.
      admin.firestore()
          .collection("posts")
          .doc(postId)
          .set(postCreated);
    });

exports.onUpdatePost = functions.firestore
    .document("/usersPosts/{userId}/userPost/{postId}")
    .onUpdate((change, context) => {
      const postUpdated = change.after.data();
      const postId = context.params.postId;


      admin.firestore()
          .collection("posts")
          .doc(postId)
          .get().then((doc) => {
            if (doc.exists) {
              doc.ref.update(postUpdated);
            }
          });
    });


exports.onDeletePost = functions.firestore
    .document("/usersPosts/{userId}/userPost/{postId}")
    .onDelete((snapshot, context) => {
      const postId = context.params.postId;

      admin.firestore()
          .collection("posts")
          .doc(postId)
          .get().then((doc) => {
            if (doc.exists) {
              doc.ref.delete();
            }
          });
    });

