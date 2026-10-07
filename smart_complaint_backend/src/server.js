const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

// Load configurations first (failing fast if validation checks fail)
const config = require('./config');

const connectDB = require('./config/db');
const logger = require('./config/logger');
const rateLimiter = require('./middlewares/rateLimiter');
const errorHandler = require('./middlewares/errorMiddleware');
const userRoutes = require('./routes/userRoutes');
const complaintRoutes = require('./routes/complaintRoutes');
const adminRoutes = require('./routes/adminRoutes');
const staffRoutes = require('./routes/staffRoutes');
const notificationRoutes = require('./routes/notificationRoutes');

const app = express();

// Middlewares
app.use(helmet());
app.use(
  cors({
    origin: (origin, callback) => {
      // Allow requests with no origin (like mobile apps, postman, or curl)
      if (!origin) return callback(null, true);

      if (config.server.env === 'production') {
        const allowed = process.env.CLIENT_URL || '';
        if (allowed === origin) {
          return callback(null, true);
        }
        return callback(new Error('Not allowed by CORS'));
      }

      // In development, dynamically allow any requesting origin
      return callback(null, true);
    },
    credentials: true,
  })
);

// Setup Request Logger
app.use(
  morgan('combined', {
    stream: { write: (message) => logger.info(message.trim()) },
  })
);

app.use(express.json());
app.use(rateLimiter);

// Routes
const apiPrefix = '/api';
app.use(`${apiPrefix}/users`, userRoutes);
app.use(`${apiPrefix}/complaints`, complaintRoutes);
app.use(`${apiPrefix}/admin`, adminRoutes);
app.use(`${apiPrefix}/staff`, staffRoutes);
app.use(`${apiPrefix}/notifications`, notificationRoutes);

app.get('/', (req, res) => {
  res.json({ success: true, message: 'Smart Complaint Analyzer API' });
});

// Post-routing error handler middleware
app.use(errorHandler);

const PORT = config.server.port;

const { startEscalationCron } = require('./services/escalationService');

connectDB()
  .then(() => {
    app.listen(PORT, () => {
      logger.info(`Server launched in [${config.server.env}] mode on port ${PORT}`);
      startEscalationCron();
    });
  })
  .catch((error) => {
    logger.error('Failed database connection startup logic', error);
  });
