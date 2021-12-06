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

  exports.onDeletePost = functions.firestore
    .document("/usersPosts/{userId}/userPost/{postId}")
    .onDelete(async (snapshot, context) => {
      // const deletedData = snapshot.data();
      const postId = context.params.postId;

      admin.firestore()
        .collection("posts")
        .doc(postId)
        .get().then((snap) => {
          if (snap.exists) {
            snap.ref.delete();
          }
        });
      admin.firestore()
        .collection("comments")
        .doc(postId)
        .get().then((snap) => {
          if (snap.exists) {
            snap.ref.delete();
          }
        });

    });

  exports.onPublicPostCreated = functions.firestore
    .document("/posts/{postId}")
    .onCreate(async (snapshot, context) => {
      const postData = snapshot.data();
      // const postId = context.params.postId;

      admin.firestore()
        .collection("users")
        .get().then((snap) => {
          snap.forEach((doc) => {
            const interested = doc.data().interested;
            loop1: for (let c = 0; c < postData.category.length; c++) {
              loop2: for (let i = 0; i < interested.length; i++) {
                if (interested[i] === postData.category[c]) {

                  // const timeStamp = new Date();
                  // whork on this thing later...--------------------------------------------------
                  // whork on this thing later...--------------------------------------------------

                  // admin.firestore()
                  //   .collection("feeds")
                  //   .doc(doc.data().userId)
                  //   .collection('feedItems')
                  //   .doc(postId)
                  //   .set({
                  //     "type": "post",
                  //     "userName": postData.userName,
                  //     "userId": doc.data().userId,
                  //     "postId": postId,
                  //     "ownerId": postData.ownerId,
                  //     "timeStamp": timeStamp,
                  //     "photoUrl": postData.photoUrl,
                  //     });
                  if (doc.data().token != "" && doc.get('token') != null) {
            
                    const message = {
                      "token": doc.data().token,
                      "notification": {
                          "title": "New Post",
                          "body": (postData.title.length > 10) ? postData.title.slice(0, 10)+'...' : postData.title,
                      },
                    };
                    admin.messaging().send(message)
                    break loop1;
                  } else {
                    
                    console.log(`-----NOT SENDED--------`)
                    break loop1;
                  }
                  // return;
                }
              }
            }

            // interested.some(item => postData.category.include(item)).then((value) => {
            //   if (value) {
            //   }
            // });
          });
        });

    });

  exports.onPublicPostsUpdate = functions.firestore
  .document("/posts/{postId}")
  .onUpdate(async (change, context) => {
    const updatedData = change.after.data();
    const postId = context.params.postId;

    admin.firestore()
      .collection("usersPosts")
      .doc(updatedData.userId)
      .collection("userPost")
      .doc(postId)
      .get().then((snap) => {
        snap.ref.update({
          "likes": updatedData.likes,
        });
      });
  });


// FUNCTION FOR FEEDS/NOTIFICATIONS --------------------------------
exports.onFeedCreated = functions.firestore
    .document("/feeds/{userId}/feedItems/{postId}")
    .onCreate(async (snapshot, context)  => {
      const feedCreated = snapshot.data();
      const userId = context.params.userId;
      // const postId = context.params.postId;

      const usersRef = admin.firestore()
          .collection("users")
          .doc(userId);
      const doc = await usersRef.get();
      

      // const registrationToken = "YOUR_REGISTRATION_TOKEN";
      if (doc.data().token != "") {

        if (feedCreated.type == "like") {
          
        const message = {
          "token": doc.data().token,
          "notification": {
            "title": feedCreated.userName,
            "body": "Liked your post",
          },
        };
        admin.messaging().send(message)
      }

      if (feedCreated.type == "comment") {

        const message = {
          "token": doc.data().token,
          "notification": {
            "title": feedCreated.userName,
            "body": "Commented on your post.",
          },
        };
        admin.messaging().send(message)
      }
      if (feedCreated.type == "post") {

        const message = {
          "token": doc.data().token,
          "notification": {
            "title": feedCreated.userName,
            "body": "Posted in your field of interest.",
          },
        };
        admin.messaging().send(message)
      }
    } else {
      
      console.log(`-----NOT SENDED-------- ${doc.data().token}`)
    }

    });
