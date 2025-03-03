import express from 'express';
import session from 'express-session';
import cookieParser from 'cookie-parser';
import path from 'path';
import { fileURLToPath } from 'url';
import authRoutes from './routes/authRoutes.js';
import patientRoutes from './routes/patientRoutes.js';
import doctorRoutes from './routes/doctorRoutes.js';
import clerkRoutes from './routes/clerkRoutes.js';

const app = express();

// Middleware for parsing JSON bodies and urlencoded data
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Middleware for cookie parsing (required by session)
app.use(cookieParser());

// Middleware for handling sessions
app.use(
  session({
    secret: 'your-secret-key', // Change this to a strong, secret string
    resave: false,
    saveUninitialized: false,
    cookie: {
      secure: false, // Use `true` in production with HTTPS
    },
  })
);

// Setup views engine
app.set('view engine', 'ejs');
app.set('views', path.join(path.dirname(fileURLToPath(import.meta.url)), 'views'));

// Serve static files (e.g., CSS, JS, images)
app.use(express.static('public'));

// Use the routes defined in authRoutes.js
app.use(authRoutes);
app.use(patientRoutes);
app.use(doctorRoutes);
app.use(clerkRoutes);

// Root route - Landing page
app.get('/', (req, res) => {
    console.log('Handling root route');
    try {
        console.log('Attempting to render index page');
        res.render('index', { error: null });
    } catch (err) {
        console.error('Error in root route:', err);
        res.status(500).send('Internal Server Error: ' + err.message);
    }
});

// Start the server
export function startServer() {
  const port = 8000;
  app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
  });
}

// Check if this file is the main entry point
if (import.meta.url === `file://${path.resolve('server.js')}`) {
  startServer();
}
