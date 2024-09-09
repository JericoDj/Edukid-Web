    // Helper / Utility functions
    let url_to_head = (url) => {
        return new Promise(function(resolve, reject) {
            var script = document.createElement('script');
            script.src = url;
            script.onload = function() {
                resolve();
            };
            script.onerror = function() {
                reject('Error loading script.');
            };
            document.head.appendChild(script);
        });
    };

    // Close alerts
    let handle_close = (event) => {
        event.target.closest(".ms-alert").remove();
    };

    // Event listener for closing alerts
    let handle_click = (event) => {
        if (event.target.classList.contains("ms-close")) {
            handle_close(event);
        }
    };

    // Add the click event listener to handle alert closing
    document.addEventListener("click", handle_click);

    // PayPal SDK settings
    const paypal_sdk_url = "https://www.paypal.com/sdk/js";
    const client_id = "AUcSIsOjCP7B4fPuxWzeSEi6NSYBGspr-pxMblGXts6D01cmrc19NgB8DR7UhHUSDp71AO3XpL8S77Uh";  // Replace with your PayPal client ID
    const currency = "USD";
    const intent = "capture";
    let alerts = document.getElementById("alerts");

    // Load PayPal SDK
    url_to_head(paypal_sdk_url + "?client-id=" + client_id + "&enable-funding=venmo&currency=" + currency + "&intent=" + intent)
    .then(() => {
        // Handle loading spinner
        document.getElementById("loading").classList.add("hide");
        document.getElementById("content").classList.remove("hide");

        // Initialize PayPal buttons
        let paypal_buttons = paypal.Buttons({
            style: {
                shape: 'rect',
                color: 'gold',
                layout: 'vertical',
                label: 'paypal'
            },

            createOrder: function(data, actions) {
                return fetch("http://localhost:3000/create_order", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json; charset=utf-8"
                    },
                    body: JSON.stringify({ price: '1.00', intent: intent })  // Replace with dynamic price if needed
                })
                .then((response) => response.json())
                .then((order) => {
                    return order.id;  // Use the order ID for further processing
                })
                .catch((error) => {
                    console.error("Error creating order:", error);
                    alerts.innerHTML = `<div class="ms-alert ms-action2">Error creating PayPal order. Please try again later.</div>`;
                });
            },

            onApprove: function(data, actions) {
                let order_id = data.orderID;
                return fetch("http://localhost:3000/complete_order", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json; charset=utf-8"
                    },
                    body: JSON.stringify({
                        "intent": intent,
                        "order_id": order_id
                    })
                })
                .then((response) => response.json())
                .then((order_details) => {
                    let intent_object = intent === "authorize" ? "authorizations" : "captures";
                    alerts.innerHTML = `<div class='ms-alert ms-action'>Thank you ${order_details.payer.name.given_name} ${order_details.payer.name.surname} for your payment of ${order_details.purchase_units[0].payments[intent_object][0].amount.value} ${order_details.purchase_units[0].payments[intent_object][0].amount.currency_code}!</div>`;
                    paypal_buttons.close();
                })
                .catch((error) => {
                    console.error("Error completing order:", error);
                    alerts.innerHTML = `<div class="ms-alert ms-action2 ms-small"><span class="ms-close"></span><p>An Error Occurred!</p></div>`;
                });
            },

            onCancel: function(data) {
                alerts.innerHTML = `<div class="ms-alert ms-action2 ms-small"><span class="ms-close"></span><p>Order cancelled!</p></div>`;
            },

            onError: function(err) {
                console.error("PayPal Error:", err);
                alerts.innerHTML = `<div class="ms-alert ms-action2 ms-small"><span class="ms-close"></span><p>Payment error occurred!</p></div>`;
            }
        });

        // Render PayPal buttons
        paypal_buttons.render('#payment_options');
    })
    .catch((error) => {
        console.error("Error loading PayPal SDK:", error);
    });
