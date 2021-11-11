// eslint-disable-next-line no-unused-vars
const functions = require("firebase-functions");

// The Firebase Admin SDK to access Firestore.
const admin = require("firebase-admin");
admin.initializeApp();



exports.onPostCreated = functions.firestore
  .document("/usersPosts/{userId}/userPost/{postId}")
  .onCreate(async (snapshot, context) => {
    const createdPost = snapshot.data();
    const postId = context.params.postId;


    admin.firestore().collection("posts").doc(postId).set(createdPost);
  });


  // NEW ADDED CODE ===============================================
  // UPDATING USER POST RELATED DATA ------------------------------
exports.onPostUpdate = functions.firestore
  .document("/usersPosts/{userId}/userPost/{postId}")
  .onUpdate(async (change, context) => {
    const updatedData = change.after.data();
    const postId = context.params.postId;

    admin.firestore()
      .collection("posts")
      .doc(postId)
      .get().then((snap) => {
        snap.ref.update({
          "userName": updatedData.userName,
          "profession": updatedData.profession,
          "category": updatedData.category,
          "searchKeywords": updatedData.searchKeywords,
          "title": updatedData.title,
          "body": updatedData.body,
        });
      });
  });

//  NEW ADDED CODE ================================================================
// UPDATING USER RELATED DATA ON UPDATE-------------------------------------------
// exports.onUpdateProfile = functions.firestore
//   .document("/users/{userId}")
//   .onUpdate(async (change, context) => {
//     const updatedData = change.after.data();
//     const userId = context.params.userId;

//     admin.firestore()
//       .collection("usersPosts")
//       .doc(userId)
//       .collection("userPost")
//       .get().then((snap) => {
//         snap.forEach((doc) => {
//             doc.ref.update({
//               "userName": updatedData.userName,
//               "profession": updatedData.profession,
//             });
//         });
//       });
//   });


// FUNCTION FOR FEEDS/NOTIFICATIONS --------------------------------
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
      if (doc.data().token != "") {

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
    } else {
      
      console.log(`-----NOT SENDED-------- ${doc.data().token}`)
    }

    });
