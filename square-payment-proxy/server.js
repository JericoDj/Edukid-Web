const express = require('express');
const axios = require('axios');
const cors = require('cors');
require('dotenv').config({ path: '.env.sandbox' }); // Load environment variables from .env.sandbox

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

// Endpoint to create a customer and save a card
app.post('/create-customer', async (req, res) => {
  const { nonce, email, firstName, lastName, billingAddress } = req.body;

  // Validate required fields
  if (!nonce || !email || !firstName || !lastName || !billingAddress) {
    console.error('Required fields are missing');
    return res.status(400).json({ error: 'Nonce, email, firstName, lastName, and billingAddress are required to create a customer.' });
  }

  try {
    // Create a customer profile with Square
    console.log('Creating customer with Square...');
    const createCustomerResponse = await axios.post('https://connect.squareupsandbox.com/v2/customers', {
      given_name: firstName,
      family_name: lastName,
      email_address: email,
    }, {
      headers: {
        'Authorization': `Bearer ${process.env.SQUARE_ACCESS_TOKEN}`,
        'Content-Type': 'application/json',
      },
    });

    const customerId = createCustomerResponse.data.customer.id;
    console.log('Customer created with ID:', customerId);

    // Save the payment method for this customer
    console.log('Saving card for customer:', customerId);
    const createCardResponse = await axios.post(`https://connect.squareupsandbox.com/v2/customers/${customerId}/cards`, {
      card_nonce: nonce,
      billing_address: billingAddress, // Use the billing address sent from the client
      cardholder_name: `${firstName} ${lastName}`,
    }, {
      headers: {
        'Authorization': `Bearer ${process.env.SQUARE_ACCESS_TOKEN}`,
        'Content-Type': 'application/json',
      },
    });

    const cardId = createCardResponse.data.card.id;
    console.log('Card saved with ID:', cardId);

    res.json({ customerId, cardId }); // Return both customerId and cardId
  } catch (error) {
    console.error('Error creating customer:', error.response ? error.response.data : error.message);
    res.status(500).json({ error: 'Error creating customer', details: error.response ? error.response.data : error.message });
  }
});

// Endpoint to charge a customer using a stored card
app.post('/charge-customer', async (req, res) => {
  const { customerId, cardId, amount } = req.body; // Include cardId to specify which card to charge

  // Validate required fields
  if (!customerId || !cardId || !amount) {
    console.error('Customer ID, Card ID, and amount are required');
    return res.status(400).json({ error: 'Customer ID, Card ID, and amount are required to process the payment.' });
  }

  try {
    // Charge the customer using their stored card
    console.log('Charging customer:', customerId, 'using card:', cardId);
    const chargeResponse = await axios.post('https://connect.squareupsandbox.com/v2/payments', {
      customer_id: customerId,
      source_id: cardId, // Corrected to use card ID as the source ID
      amount_money: {
        amount: amount, // Amount in cents
        currency: 'USD',
      },
      idempotency_key: new Date().getTime().toString(), // Unique key to prevent duplicate charges
    }, {
      headers: {
        'Authorization': `Bearer ${process.env.SQUARE_ACCESS_TOKEN}`,
        'Content-Type': 'application/json',
      },
    });

    console.log('Charge response:', chargeResponse.data);
    res.json(chargeResponse.data);
  } catch (error) {
    console.error('Error charging customer:', error.response ? error.response.data : error.message);
    res.status(500).json({ error: 'Error charging customer', details: error.response ? error.response.data : error.message });
  }
});

// Endpoint to handle payment processing for one-time payments
app.post('/process-payment', async (req, res) => {
  const { sourceId, idempotencyKey, locationId, amount_money } = req.body;

  // Validate required fields
  if (!sourceId || !idempotencyKey || !locationId) {
    console.error('Required fields are missing');
    return res.status(400).json({ error: 'sourceId, idempotencyKey, and locationId are required.' });
  }

  try {
    // Make the request to Square's payment API
    console.log('Processing one-time payment...');
    const response = await axios.post('https://connect.squareupsandbox.com/v2/payments', {
      source_id: sourceId,
      idempotency_key: idempotencyKey,
      amount_money,
      location_id: locationId,
    }, {
      headers: {
        'Authorization': `Bearer ${process.env.SQUARE_ACCESS_TOKEN}`,
        'Content-Type': 'application/json',
      },
    });

    console.log('Payment processed successfully:', response.data);
    res.json(response.data);
  } catch (error) {
    console.error('Error processing payment:', error.response ? error.response.data : error.message);
    res.status(500).json({ error: 'Error processing payment', details: error.response ? error.response.data : error.message });
  }
});

// Start the server
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
