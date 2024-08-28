const express = require('express');
const axios = require('axios');
const cors = require('cors');
require('dotenv').config({ path: '.env.sandbox' }); // Load environment variables from .env.sandbox

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

// Endpoint to handle payment processing
app.post('/process-payment', async (req, res) => {
  const { sourceId, idempotencyKey, locationId, amount_money } = req.body;

  // Debugging log to check received data
  console.log(`Received sourceId: ${sourceId}, idempotencyKey: ${idempotencyKey}, locationId: ${locationId}, amount_money: ${JSON.stringify(amount_money)}`);

  // Check if required fields are present
  if (!sourceId || !idempotencyKey || !locationId) {
    console.error('Required fields are missing');
    return res.status(400).json({ error: 'sourceId, idempotencyKey, and locationId are required.' });
  }

  try {
    // Make the request to Square's payment API
    const response = await axios.post('https://connect.squareupsandbox.com/v2/payments', {
      source_id: sourceId,
      idempotency_key: idempotencyKey,
      amount_money, // Use the amount_money object sent from the client
      location_id: locationId,
    }, {
      headers: {
        'Authorization': `Bearer ${process.env.SQUARE_ACCESS_TOKEN}`, // Correctly use the environment variable
        'Content-Type': 'application/json',
      },
    });

    // Send the response from Square's API back to the client
    res.json(response.data);
  } catch (error) {
    // Handle and log any errors from the payment process
    console.error('Error processing payment:', error.response ? error.response.data : error.message);
    res.status(500).json({ error: 'Error processing payment', details: error.response ? error.response.data : error.message });
  }
});

// Start the server and listen on the specified port
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
