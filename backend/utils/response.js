/**
 * Formats a response for consistent API responses
 * @param {boolean} success - Whether the operation was successful
 * @param {any} data - Response data
 * @param {string} message - Optional message
 * @param {object} meta - Optional metadata (pagination, etc.)
 * @returns {object} - Formatted response object
 */
const formatResponse = (success, data = null, message = null, meta = null) => {
  const response = { success };
  
  if (data !== null) response.data = data;
  if (message !== null) response.message = message;
  if (meta !== null) response.meta = meta;
  
  return response;
};

/**
 * Formats an error response
 * @param {string} message - Error message
 * @param {number} statusCode - HTTP status code
 * @param {any} details - Optional error details
 * @returns {object} - Formatted error response
 */
const formatError = (message, statusCode = 500, details = null) => {
  const response = {
    success: false,
    error: message,
    statusCode
  };
  
  if (details !== null) response.details = details;
  
  return response;
};

/**
 * Formats pagination metadata
 * @param {number} page - Current page
 * @param {number} limit - Items per page
 * @param {number} total - Total items
 * @returns {object} - Pagination metadata
 */
const formatPagination = (page, limit, total) => {
  const totalPages = Math.ceil(total / limit);
  
  return {
    pagination: {
      currentPage: page,
      itemsPerPage: limit,
      totalItems: total,
      totalPages,
      hasNextPage: page < totalPages,
      hasPrevPage: page > 1
    }
  };
};

module.exports = {
  formatResponse,
  formatError,
  formatPagination
};
