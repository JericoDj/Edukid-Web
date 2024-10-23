const express = require('express');
const axios = require('axios');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(bodyParser.json());

const PAYPAL_CLIENT_ID = 'AUcSIsOjCP7B4fPuxWzeSEi6NSYBGspr-pxMblGXts6D01cmrc19NgB8DR7UhHUSDp71AO3XpL8S77Uh';
const PAYPAL_CLIENT_SECRET = 'EERXnEdliILVLwlZ06wrKDmU3EQk7CtlJcFbmjlsFRLN8Lv_FyGm9YQSenZm7DcOv-LJITAyG8NIwbFG';
const PAYPAL_API_BASE = 'https://api.sandbox.paypal.com'; // Use sandbox for testing

// Route to generate PayPal OAuth token
app.post('/paypal-auth', async (req, res) => {
  try {
    const response = await axios.post(`${PAYPAL_API_BASE}/v1/oauth2/token`, 'grant_type=client_credentials', {
      auth: {
        username: PAYPAL_CLIENT_ID,
        password: PAYPAL_CLIENT_SECRET
      },
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    });

    const accessToken = response.data.access_token;
    res.json({ access_token: accessToken });
  } catch (error) {
    console.error('Error getting PayPal auth token:', error.message);
    res.status(500).json({ error: 'Failed to get PayPal access token' });
  }
});

// Route to create billing agreement
app.post('/create-billing-agreement', async (req, res) => {
  const { accessToken, planId } = req.body;

  try {
    const response = await axios.post(`${PAYPAL_API_BASE}/v1/billing/subscriptions`, {
      plan_id: planId,
      application_context: {
        brand_name: 'Your Brand',
        locale: 'en-US',
        shipping_preference: 'SET_PROVIDED_ADDRESS',
        user_action: 'SUBSCRIBE_NOW',
        return_url: 'https://your-site.com/success', // Replace with your actual return URL
        cancel_url: 'https://your-site.com/cancel' // Replace with your actual cancel URL
      }
    }, {
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      }
    });

    res.json(response.data);
  } catch (error) {
    console.error('Error creating PayPal billing agreement:', error.response ? error.response.data : error.message);
    res.status(500).json({ error: 'Failed to create billing agreement' });
  }
});

// Route to charge the user using saved billing agreement
app.post('/charge-user', async (req, res) => {
  const { accessToken, billingAgreementId, amount } = req.body;

  try {
    const response = await axios.post(`${PAYPAL_API_BASE}/v1/payments/payment`, {
      intent: 'sale',
      payer: {
        payment_method: 'paypal',
        funding_instruments: [{
          billing: {
            billing_agreement_id: billingAgreementId
          }
        }]
      },
      transactions: [{
        amount: {
          total: amount,
          currency: 'USD'
        },
        description: 'Charge for booking'
      }]
    }, {
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      }
    });

    res.json(response.data);
  } catch (error) {
    console.error('Error charging user:', error.response ? error.response.data : error.message);
    res.status(500).json({ error: 'Failed to charge user' });
  }
});

// Start server
app.listen(3000, () => {
  console.log('Server is running on port 3000');
});
