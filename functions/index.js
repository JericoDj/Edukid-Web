const functions = require('firebase-functions');
const express = require('express');
const fetch = require('node-fetch');
const cors = require('cors');

// Initialize the app
const app = express();

// Enable CORS for production
const corsOptions = {
    origin: '*', // Allow all origins
    methods: ['GET', 'POST', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true // If you need credentials to be passed along with requests, otherwise set it to false
};

app.use(cors(corsOptions));
app.options('*', cors(corsOptions)); // Preflight requests for CORS


app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Environment variables for PayPal credentials (Firebase functions)
const environment = functions.config().paypal.environment || 'sandbox';
const client_id = functions.config().paypal.client_id;
const client_secret = functions.config().paypal.client_secret;
const endpoint_url = environment === 'sandbox' ? 'https://api-m.sandbox.paypal.com' : 'https://api-m.paypal.com';

let orderStatus = {}; // To store order statuses

// Function to retrieve PayPal access token
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

// Create an order and return PayPal approval link
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
                'return_url': `https://${req.hostname}/return`,
                'cancel_url': `https://${req.hostname}/cancel`
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

// Capture PayPal order
app.get('/capture_order', (req, res) => {
    const orderID = req.query.orderID;

    if (!orderID) {
        return res.status(400).json({ error: 'Order ID is required' });
    }

    get_access_token()
    .then(access_token => {
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
                res.json({ success: true, message: 'Payment captured successfully', orderID });
            } else {
                res.status(500).json({ success: false, message: 'Failed to capture payment', data: json });
            }
        })
        .catch(err => {
            console.error('Error capturing PayPal order:', err);
            res.status(500).json({ success: false, message: 'Error capturing order', error: err });
        });
    })
    .catch(err => {
        console.error('Error getting access token:', err);
        res.status(500).json({ success: false, message: 'Failed to retrieve PayPal access token', error: err });
    });
});

// Poll order status
app.get('/order_status/:orderID', (req, res) => {
    const { orderID } = req.params;

    if (!orderStatus[orderID]) {
        return res.status(404).json({ success: false, message: 'Order not found' });
    }

    res.status(200).json({ success: true, status: orderStatus[orderID] });
});

// Export the app as a Firebase function
exports.api = functions.https.onRequest(app);
