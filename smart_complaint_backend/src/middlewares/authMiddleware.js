const User = require('../models/User');
const logger = require('../config/logger');

/**
 * Authenticates user from request header (x-firebase-uid or bearer token) or query/body
 * and attaches user record to req.user
 */
const authenticateUser = async (req, res, next) => {
  try {
    let firebaseUID = req.headers['x-firebase-uid'];

    if (!firebaseUID && req.headers.authorization && req.headers.authorization.startsWith('Bearer ')) {
      // In a full production token setup, firebase admin SDK verifies token.
      // Here, token or UID is passed.
      firebaseUID = req.headers.authorization.split(' ')[1];
    }

    if (!firebaseUID) {
      firebaseUID = req.query.firebaseUID || req.body?.firebaseUID;
    }

    if (!firebaseUID) {
      const error = new Error('Authentication required: Missing x-firebase-uid header or token');
      error.status = 401;
      return next(error);
    }

    let user = await User.findOne({ firebaseUID });
    if (!user) {
      // Fallback for mis-cased MongoDB documents
      user = await User.findOne({ firebaseUid: firebaseUID });
    }

    if (!user) {
      const error = new Error('User profile not found. Please log in again.');
      error.status = 401;
      return next(error);
    }

    req.user = user;
    next();
  } catch (err) {
    logger.error('Authentication middleware error', { error: err.message });
    next(err);
  }
};

/**
 * Restricts access to specified roles
 * @param  {...string} roles
 */
const requireRole = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      const error = new Error('Authentication required');
      error.status = 401;
      return next(error);
    }

    // Case-insensitive role comparison
    const userRole = (req.user.role || '').toLowerCase();
    const allowedRoles = roles.map(r => r.toLowerCase());

    if (!allowedRoles.includes(userRole)) {
      const error = new Error(`Forbidden: Access restricted to ${roles.join(', ')}`);
      error.status = 403;
      logger.warn('Forbidden access attempt', {
        userUID: req.user.firebaseUID,
        userRole: req.user.role,
        requiredRoles: roles,
        path: req.originalUrl,
      });
      return next(error);
    }

    next();
  };
};

const requireAdmin = [authenticateUser, requireRole('Admin')];
const requireStaff = [authenticateUser, requireRole('Department Staff')];
const requireAdminOrStaff = [authenticateUser, requireRole('Admin', 'Department Staff')];

module.exports = {
  authenticateUser,
  requireRole,
  requireAdmin,
  requireStaff,
  requireAdminOrStaff,
};
