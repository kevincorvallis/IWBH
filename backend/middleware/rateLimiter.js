const rateLimit = require('express-rate-limit');
const config = require('../config/app');

const limiter = rateLimit({
  windowMs: config.rateLimitWindow,
  max: config.rateLimitMax,
  message: {
    error: 'Too many requests from this IP, please try again later.'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 50, // limit each IP to 50 requests per windowMs for API routes
  message: {
    error: 'Too many API requests from this IP, please try again later.'
  }
});

module.exports = {
  limiter,
  apiLimiter
};
