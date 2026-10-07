const mongoose = require('mongoose');
const logger = require('./logger');
const dbConfig = require('./database');

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(dbConfig.uri);
    logger.info(`MongoDB Connected: ${conn.connection.host}`);
  } catch (error) {
    logger.error(`Database Connection Error: ${error.message}`);
    process.exit(1);
  }
};

module.exports = connectDB;
