const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// Define the saveCard function to handle saving the payment nonce
exports.saveCard = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") {
    return res.status(405).send("Method Not Allowed");
  }

  const {sourceId, userId} = req.body; // Removed spaces inside curly braces

  try {
    // Save the nonce to Firestore under the user's document
    await db.collection("users")
        .doc(userId)
        .collection("paymentInfo")
        .doc("cardNonce")
        .set({
          nonce: sourceId,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });

    console.log(`Nonce saved successfully for user: ${userId}`);
    res.json({
      message: "Card saved successfully",
      nonce: sourceId,
    });
  } catch (error) {
    console.error("Error saving card:", error);
    res.status(500).send("Error saving card");
  }
});
