const mongoose = require('mongoose');

const deviceSchema = new mongoose.Schema(
  {
    firebaseUID: {
      type: String,
      required: true,
      index: true,
    },
    fcmToken: {
      type: String,
      required: true,
      unique: true,
    },
    platform: {
      type: String,
      enum: ['android', 'ios', 'web', 'windows', 'macos', 'linux', 'unknown'],
      default: 'unknown',
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Device', deviceSchema);
