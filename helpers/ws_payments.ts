// const WebSocket = require("ws");
// const fs = require("fs");

// const wss = new WebSocket.Server({ port: 8080 });

// // It is strongly recommended to use environment variables for production.
// const MTN_CLIENT_KEY = process.env.MTN_CLIENT_KEY || "YOUR_MTN_CLIENT_KEY_HERE";
// const MTN_CLIENT_SECRET =
//   process.env.MTN_CLIENT_SECRET || "YOUR_MTN_CLIENT_SECRET_HERE";

// const ORANGE_CLIENT_KEY =
//   process.env.ORANGE_CLIENT_KEY || "YOUR_ORANGE_CLIENT_KEY_HERE";
// const ORANGE_CLIENT_SECRET =
//   process.env.ORANGE_CLIENT_SECRET || "YOUR_ORANGE_CLIENT_SECRET_HERE";

// wss.on("connection", (ws) => {
//   console.log("Client connected");

//   ws.on("message", (message) => {
//     const data = JSON.parse(message);
//     console.log("Received message:", data);

//     if (data.type === "token_request") {
//       const { phoneNumber, amount, operator } = data;
//       console.log(
//         `Processing token request for ${phoneNumber} with ${operator}...`
//       );

//       // This is where you would make the actual API call to MTN or Orange
//       // For now, we will use a mock function to simulate the process.
//       mockMomoApiCall(operator, phoneNumber, amount)
//         .then((response) => {
//           const status = response.success
//             ? "payment_successful"
//             : "payment_failed";
//           ws.send(
//             JSON.stringify({
//               type: "payment_status",
//               status: status,
//               message: response.message,
//             })
//           );
//         })
//         .catch((error) => {
//           console.error("API call failed:", error);
//           ws.send(
//             JSON.stringify({
//               type: "payment_status",
//               status: "payment_failed",
//               message: `Failed to process payment: ${error.message}`,
//             })
//           );
//         });
//     }
//   });

//   ws.on("close", () => {
//     console.log("Client disconnected");
//   });

//   ws.on("error", (error) => {
//     console.error("WebSocket error:", error);
//   });
// });

// async function mockMomoApiCall(operator, phoneNumber, amount) {
//   console.log(`Simulating a real API call to ${operator}...`);
//   // In a real-world scenario, you would replace this mock function
//   // with an actual HTTP request to the respective payment gateway.
//   // Example: using 'axios' or 'fetch' to POST data to the API endpoint.

//   let credentials;
//   let apiUrl;

//   if (operator === "MTN") {
//     credentials = { key: MTN_CLIENT_KEY, secret: MTN_CLIENT_SECRET };
//     apiUrl = "https://api.mtn.com/momo/requesttopay"; // Example endpoint
//   } else if (operator === "Orange") {
//     credentials = { key: ORANGE_CLIENT_KEY, secret: ORANGE_CLIENT_SECRET };
//     apiUrl = "https://api.orange.com/money/payment"; // Example endpoint
//   } else {
//     return Promise.reject(new Error("Invalid mobile operator."));
//   }

//   console.log(`Using credentials for ${operator}:`, credentials);
//   // Here, you would implement the HTTP request logic.
//   // For example, generating a token, setting headers, and sending the payment request.

//   return new Promise((resolve) => {
//     // Simulate a network delay and a successful API response
//     setTimeout(() => {
//       console.log(`Mock API call to ${apiUrl} successful.`);
//       resolve({
//         success: true,
//         message: `Token request for ${amount} from ${phoneNumber} via ${operator} successful.`,
//       });
//     }, 2000); // 2-second delay
//   });
// }

// console.log("WebSocket server started on port 8080");
