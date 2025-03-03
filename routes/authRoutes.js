import express from 'express';
import {
  renderPatientSignupPage,
  renderDoctorSignupPage,
  renderClerkSignupPage,
  doctorSignup,
  clerkSignup,
  patientSignup,
  EmploginHandler,
  NotEmploginHandler,
  logout
} from '../controllers/authController.js';

const router = express.Router();

// Doctor login
router.get('/doctor/login', (req, res) => {
  res.render('doctor/login/index');
});
router.post('/doctor/login', (req, res) => {
  NotEmploginHandler(req, res, 1, 'doctor');
});

// Doctor Signup
router.get('/doctor/signup', renderDoctorSignupPage);
router.post('/doctor/signup', doctorSignup);



// Clerk login
router.get('/clerk/login', (req, res) => {
  res.render('clerk/login/index');
});
router.post('/clerk/login', (req, res) => {
  NotEmploginHandler(req, res, 2, 'clerk');
});

//Clerk Signup
router.get('/clerk/signup', renderClerkSignupPage);
router.post('/clerk/signup', clerkSignup);



// Patient login
router.get('/patient/login', (req, res) => {
  res.render('patient/login/index');
});
router.post('/patient/login', (req, res) => {
  EmploginHandler(req, res, 3, 'patient');
});

// Patient signup routes
router.get('/patient/signup', renderPatientSignupPage);
router.post('/patient/signup', patientSignup);



// Logout route
router.get('/logout', logout);

export default router;
