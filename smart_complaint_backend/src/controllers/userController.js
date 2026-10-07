const User = require('../models/User');
const logger = require('../config/logger');

// @desc    Register or Sync basic User Auth Info
// @route   POST /api/users/sync
// @access  Public
const syncUser = async (req, res, next) => {
  const { firebaseUID, email, role, name, emailVerified, registerNumber, employeeId, department } = req.body;

  // Structured Logging for Sync Requests
  logger.info('Received user sync request', {
    action: 'syncUser',
    firebaseUID,
    email,
    role,
    name,
    emailVerified,
    registerNumber: registerNumber || null,
    employeeId: employeeId || null,
    department: department || null,
  });

  try {
    if (!firebaseUID || !email) {
      const error = new Error('Missing required fields: firebaseUID and email are required');
      error.status = 400;
      logger.warn('Validation failed for syncUser', { firebaseUID, email });
      return next(error);
    }

    if (role && !['Student', 'Department Staff'].includes(role)) {
      const error = new Error('Invalid role specified. Allowed values: Student, Department Staff');
      error.status = 400;
      return next(error);
    }

    // Check if user already exists
    let user = await User.findOne({ firebaseUID });
    logger.debug('Database query completed', { action: 'findOne', query: { firebaseUID }, found: !!user });

    if (user) {
      // Idempotent update: sync verification status and basic details
      if (emailVerified !== undefined) {
        user.emailVerified = emailVerified;
      }
      if (name) {
        user.name = name;
      }
      if (department && department !== 'Not Assigned') {
        user.department = department;
      }

      // Allow overriding existing role if explicitly provided in sync request
      // This helps users recover from accidental incorrect role selections
      if (role && ['Student', 'Department Staff'].includes(role)) {
        user.role = role;
      }
      // Update registerNumber for Student if provided
      if (user.role === 'Student' && registerNumber && registerNumber.trim() && !user.registerNumber) {
        const regNumClean = registerNumber.trim();
        const existingRegNum = await User.findOne({ registerNumber: regNumClean });
        if (existingRegNum && existingRegNum.firebaseUID !== firebaseUID) {
          const error = new Error(`Register number ${regNumClean} is already registered by another user`);
          error.status = 409;
          logger.warn('Duplicate registerNumber conflict during sync update', { firebaseUID, registerNumber: regNumClean });
          return next(error);
        }
        user.registerNumber = regNumClean;
      }

      // Update employeeId for Staff if provided
      if (user.role === 'Department Staff' && employeeId && employeeId.trim() && !user.employeeId) {
        const empIdClean = employeeId.trim();
        const existingEmpId = await User.findOne({ employeeId: empIdClean });
        if (existingEmpId && existingEmpId.firebaseUID !== firebaseUID) {
          const error = new Error(`Employee ID ${empIdClean} is already registered by another user`);
          error.status = 409;
          logger.warn('Duplicate employeeId conflict during sync update', { firebaseUID, employeeId: empIdClean });
          return next(error);
        }
        user.employeeId = empIdClean;
      }

      const updatedUser = await user.save();
      logger.info('User updated in database via sync', { firebaseUID: updatedUser.firebaseUID, email: updatedUser.email });

      return res.status(200).json({
        success: true,
        message: 'User synced successfully',
        data: updatedUser,
      });
    }

    // Construct new user fields
    const userFields = {
      firebaseUID,
      email,
      role: role || 'Student',
      name: name || 'New User',
      emailVerified: emailVerified || false,
      department: department || 'Not Assigned',
    };

    if (userFields.role === 'Student') {
      if (registerNumber && registerNumber.trim()) {
        const regNumClean = registerNumber.trim();
        const existingRegNum = await User.findOne({ registerNumber: regNumClean });
        if (existingRegNum) {
          const error = new Error(`Register number ${regNumClean} is already registered`);
          error.status = 409;
          logger.warn('Duplicate registerNumber conflict during sync creation', { firebaseUID, registerNumber: regNumClean });
          return next(error);
        }
        userFields.registerNumber = regNumClean;
      }
      userFields.year = 'I Year'; // Default placeholder
    } else if (userFields.role === 'Department Staff') {
      if (employeeId && employeeId.trim()) {
        const empIdClean = employeeId.trim();
        const existingEmpId = await User.findOne({ employeeId: empIdClean });
        if (existingEmpId) {
          const error = new Error(`Employee ID ${empIdClean} is already registered`);
          error.status = 409;
          logger.warn('Duplicate employeeId conflict during sync creation', { firebaseUID, employeeId: empIdClean });
          return next(error);
        }
        userFields.employeeId = empIdClean;
      }
    }

    user = new User(userFields);
    const savedUser = await user.save();
    logger.info('New user record registered in DB successfully', { firebaseUID: savedUser.firebaseUID, email: savedUser.email });

    res.status(201).json({
      success: true,
      message: 'User registered in DB successfully',
      data: savedUser,
    });
  } catch (error) {
    logger.error('Error during syncUser operations', { error: error.message, stack: error.stack });
    next(error);
  }
};

// @desc    Get user profile details
// @route   GET /api/users/profile/:firebaseUID
// @access  Public
const getUserProfile = async (req, res, next) => {
  const { firebaseUID } = req.params;
  const { email } = req.query;
  try {
    let user = await User.findOne({ firebaseUID });
    if (!user && email) {
      const emailClean = email.toLowerCase().trim();
      user = await User.findOne({ email: emailClean });
      if (user) {
        user.firebaseUID = firebaseUID;
        await user.save();
        logger.info('Auto-linked firebaseUID to existing user profile by email', { firebaseUID, email: emailClean });
      }
    }
    if (!user) {
      const error = new Error('User not found');
      error.status = 404;
      logger.warn('User profile query returned 404', { firebaseUID });
      return next(error);
    }
    res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    logger.error('Error during getUserProfile', { error: error.message, firebaseUID });
    next(error);
  }
};

// @desc    Update or Complete User Profile
// @route   PUT /api/users/profile/:firebaseUID
// @access  Public
const updateUserProfile = async (req, res, next) => {
  const { firebaseUID } = req.params;
  const {
    name,
    phone,
    department,
    profileImage,
    registerNumber,
    year,
    employeeId,
    designation,
    role,
  } = req.body;

  logger.info('Profile update request received', { firebaseUID, body: req.body });

  try {
    let user = await User.findOne({ firebaseUID });

    if (!user) {
      const error = new Error('User profile not found');
      error.status = 404;
      logger.warn('Profile update failed: User not found', { firebaseUID });
      return next(error);
    }

    // Allow setting role if not already set or if explicitly completing profile
    if (role && ['Student', 'Department Staff'].includes(role)) {
      user.role = role;
    }

    // Update common parameters
    if (name) user.name = name;
    if (phone !== undefined) user.phone = phone;
    if (department) user.department = department;
    if (profileImage !== undefined) user.profileImage = profileImage;

    // Enforce role-based validation and uniqueness checks
    if (user.role === 'Student') {
      if (registerNumber !== undefined) {
        const regNumClean = registerNumber.trim();
        if (!regNumClean) {
          const error = new Error('Register number is required for students');
          error.status = 400;
          return next(error);
        }

        const existing = await User.findOne({ registerNumber: regNumClean });
        if (existing && existing.firebaseUID !== firebaseUID) {
          const error = new Error(`Register number ${regNumClean} is already registered by another student`);
          error.status = 409;
          logger.warn('Profile update conflict: Duplicate registerNumber', { firebaseUID, registerNumber: regNumClean });
          return next(error);
        }
        user.registerNumber = regNumClean;
      } else if (!user.registerNumber) {
        const error = new Error('Register number is required for student profiles');
        error.status = 400;
        return next(error);
      }

      if (year !== undefined) {
        if (!year.trim()) {
          const error = new Error('Year of study is required for students');
          error.status = 400;
          return next(error);
        }
        user.year = year.trim();
      } else if (!user.year) {
        user.year = 'I Year'; // fallback placeholder for student year
      }

    } else if (user.role === 'Department Staff') {
      if (employeeId !== undefined) {
        const empIdClean = employeeId.trim();
        if (!empIdClean) {
          const error = new Error('Employee ID is required for department staff');
          error.status = 400;
          return next(error);
        }

        const existing = await User.findOne({ employeeId: empIdClean });
        if (existing && existing.firebaseUID !== firebaseUID) {
          const error = new Error(`Employee ID ${empIdClean} is already registered by another staff member`);
          error.status = 409;
          logger.warn('Profile update conflict: Duplicate employeeId', { firebaseUID, employeeId: empIdClean });
          return next(error);
        }
        user.employeeId = empIdClean;
      } else if (!user.employeeId) {
        const error = new Error('Employee ID is required for staff profiles');
        error.status = 400;
        return next(error);
      }

      if (designation !== undefined) {
        user.designation = designation.trim() || undefined;
      }
    }

    // Set profile completion flag
    user.isProfileCompleted = true;

    const updatedUser = await user.save();
    logger.info('Profile updated successfully in DB', { firebaseUID: updatedUser.firebaseUID });

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      data: updatedUser,
    });
  } catch (error) {
    logger.error('Error during profile update operation', { error: error.message, firebaseUID });
    next(error);
  }
};

module.exports = {
  syncUser,
  getUserProfile,
  updateUserProfile,
};
