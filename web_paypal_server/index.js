import express from 'express';
import fetch from 'node-fetch';
import 'dotenv/config';
import cors from 'cors';

const app = express();

// Enable CORS for all routes
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const port = process.env.PORT || 3000;
const environment = process.env.ENVIRONMENT || 'sandbox';
const client_id = process.env.CLIENT_ID;
const client_secret = process.env.CLIENT_SECRET;
const endpoint_url = environment === 'sandbox' ? 'https://api-m.sandbox.paypal.com' : 'https://api-m.paypal.com';

let orderStatus = {}; // Global object to store status of each order (could be stored in DB for production)

/**
 * Creates an order and returns the PayPal approval link as a JSON response.
 */
app.post('/create_order', (req, res) => {
  const price = req.body.price || req.body.amount;
  const description = req.body.description || 'No description provided';
  const intent = req.body.intent || 'CAPTURE';

  if (!price) {
    return res.status(400).json({ error: 'Price is required' });
  }

  get_access_token()
    .then(access_token => {
      const order_data_json = {
        'intent': intent.toUpperCase(),
        'purchase_units': [{
          'amount': {
            'currency_code': 'USD',
            'value': price
          },
          'description': description
        }],
        'application_context': {
          'return_url': 'http://localhost:3000/return',
          'cancel_url': 'http://localhost:3000/cancel'
        }
      };

      fetch(endpoint_url + '/v2/checkout/orders', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${access_token}`
        },
        body: JSON.stringify(order_data_json)
      })
      .then(response => response.json())
      .then(json => {
        // Check if the approval link and id are present in the response
        const approvalLink = json.links.find(link => link.rel === 'approve')?.href;
        const orderID = json.id;

        if (approvalLink && orderID) {
          res.json({ approvalLink, id: orderID });
        } else {
          res.status(500).json({ error: 'No approval link or orderID returned from PayPal' });
        }
      })
      .catch(err => {
        console.error('Error creating PayPal order:', err);
        res.status(500).send('Failed to create PayPal order.');
      });
    })
    .catch(err => {
      console.error('Error getting access token:', err);
      res.status(500).send('Failed to retrieve PayPal access token.');
    });
});

/**
 * PayPal Return URL Handler
 * After the user approves the payment, PayPal redirects to this endpoint.
 */
app.get('/return', (req, res) => {
    const orderID = req.query.token; // PayPal sends the order ID as 'token'

    if (!orderID) {
        return res.status(400).json({ error: 'Order ID is required to capture payment' });
    }

    // Mark the order as approved in memory
    orderStatus[orderID] = 'APPROVED';

    // After approval, redirect to capture the order
    res.redirect(`/capture_order?orderID=${orderID}`);
});

/**
 * Cancel URL handler if the user cancels the payment.
 */
app.get('/cancel', (req, res) => {
    const orderID = req.query.token; // PayPal sends the order ID as 'token'

    if (!orderID) {
        return res.status(400).json({ error: 'Order ID is required to cancel payment' });
    }

    // Mark the order as canceled in memory
    orderStatus[orderID] = 'CANCELLED';

    res.status(200).json({ success: false, message: 'Payment was cancelled by the user.' });
});

/**
 * Captures an order payment after approval by the user.
 * This is the final step in the PayPal flow to capture the payment.
 */
app.get('/capture_order', (req, res) => {
  const orderID = req.query.orderID;

  if (!orderID) {
    return res.status(400).json({ error: 'Order ID is required' });
  }

  get_access_token()
    .then(access_token => {
      fetch(endpoint_url + `/v2/checkout/orders/${orderID}`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${access_token}`
        }
      })
      .then(response => response.json())
      .then(order => {
        if (order.status === 'COMPLETED') {
          // Payment successful, close the tab
          res.send(`
            <html>
              <body>
                <script>
                  window.opener.postMessage({ success: true, orderID: '${orderID}' }, '*');
                  window.close();  // Automatically close the window after capture
                </script>
              </body>
            </html>
          `);
        } else {
          // Capture the order if it hasn't been captured yet
          fetch(endpoint_url + `/v2/checkout/orders/${orderID}/capture`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${access_token}`
            }
          })
          .then(response => response.json())
          .then(json => {
            if (json.status === 'COMPLETED') {
              // Payment successful, close the tab
              res.send(`
                <html>
                  <body>
                    <script>
                      window.opener.postMessage({ success: true, orderID: '${orderID}' }, '*');
                      window.close();  // Automatically close the window after capture
                    </script>
                  </body>
                </html>
              `);
            } else {
              res.status(500).json({ success: false, message: 'Failed to capture payment', data: json });
            }
          })
          .catch(err => {
            console.error('Error capturing PayPal order:', err);
            res.status(500).json({ success: false, message: 'Error capturing order', error: err });
          });
        }
      })
      .catch(err => {
        console.error('Error retrieving PayPal order:', err);
        res.status(500).json({ success: false, message: 'Error retrieving order details', error: err });
      });
    })
    .catch(err => {
      console.error('Error getting access token:', err);
      res.status(500).json({ success: false, message: 'Failed to retrieve PayPal access token', error: err });
    });
});


/**
 * Polling route to check order status.
 */
app.get('/order_status/:orderID', (req, res) => {
    const { orderID } = req.params;

    if (!orderStatus[orderID]) {
        return res.status(404).json({ success: false, message: 'Order not found' });
    }

    res.status(200).json({ success: true, status: orderStatus[orderID] });
});

/**
 * Retrieve PayPal Access Token
 */
function get_access_token() {
    const auth = `${client_id}:${client_secret}`;
    const data = 'grant_type=client_credentials';

    return fetch(endpoint_url + '/v1/oauth2/token', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': `Basic ${Buffer.from(auth).toString('base64')}`
        },
        body: data
    })
    .then(res => res.json())
    .then(json => json.access_token)
    .catch(err => {
        console.error('Error fetching access token:', err);
        throw new Error('Failed to fetch access token');
    });
}

app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});
