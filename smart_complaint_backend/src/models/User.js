const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    firebaseUID: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    role: {
      type: String,
      required: true,
      enum: ['Student', 'Department Staff', 'Admin'],
    },
    name: {
      type: String,
      required: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    emailVerified: {
      type: Boolean,
      default: false,
    },
    isProfileCompleted: {
      type: Boolean,
      default: false,
    },
    phone: {
      type: String,
    },
    profileImage: {
      type: String,
      default: '',
    },
    department: {
      type: String,
      default: 'Not Assigned',
    },
    // Student specific fields (optional at creation, validated during completion)
    registerNumber: {
      type: String,
      unique: true,
      sparse: true,
      index: true,
    },
    year: {
      type: String,
    },
    // Staff specific fields (optional at creation, validated during completion)
    employeeId: {
      type: String,
      unique: true,
      sparse: true,
      index: true,
    },
    designation: {
      type: String,
    },
  },
  {
    timestamps: true,
  }
);

const User = mongoose.model('User', userSchema);

module.exports = User;
