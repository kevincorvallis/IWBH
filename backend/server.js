require('dotenv').config();
const express = require('express');
const https = require('https');
const fs = require('fs');
const cors = require('cors');
const helmet = require('helmet');
const chatRoutes = require('./routes/chatRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet()); // Security headers
app.use(cors()); // CORS for cross-origin requests
app.use(express.json()); // Parse JSON bodies

// Routes
app.use('/api', chatRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// For development, use HTTP
if (process.env.NODE_ENV === 'development') {
  app.listen(PORT, () => {
    console.log(`Server running in development mode on port ${PORT}`);
  });
} else {
  // For production, use HTTPS
  // You'll need to generate SSL certificates
  const options = {
    key: fs.readFileSync('path/to/private-key.pem'),
    cert: fs.readFileSync('path/to/certificate.pem')
  };

  https.createServer(options, app).listen(PORT, () => {
    console.log(`Secure server running in production mode on port ${PORT}`);
  });
}