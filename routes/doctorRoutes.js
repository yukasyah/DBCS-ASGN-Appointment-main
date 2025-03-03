import express from 'express';
import { isAuthenticated, isDoctor } from '../middlewares/authMiddleware.js';
import * as doctorController from '../Controllers/doctorController.js';

const router = express.Router();

// Dashboard route
router.get('/doctor/dashboard', isAuthenticated, isDoctor, (req, res) => {
    res.render('doctor/dashboard/index', {
        username: req.session.user.username,
        error: null
    });
});

// Dashboard data route
router.get('/doctor/dashboard/data', isAuthenticated, isDoctor, async (req, res) => {
    try {
        const { email } = req.session.user;
        const doctorId = await doctorController.getDoctorIdByEmail(email);

        const completedAppointmentsThisMonth = await doctorController.getCompletedAppointmentsThisMonth(doctorId);

        res.json({
            doctorName: req.session.user.username,
            completedAppointmentsThisMonth: completedAppointmentsThisMonth
        });
    } catch (err) {
        console.error('Error fetching dashboard data:', err);
        res.status(500).json({ error: 'Error fetching dashboard data' });
    }
});

// Update Profile Page
router.get('/doctor/profile', isAuthenticated, isDoctor, async (req, res) => {
    try {
        const email = req.session.user.email;
        const doctorId = await doctorController.getDoctorIdByEmail(email);
        console.log('Doctor ID:', doctorId);

        const doctorDetails = await doctorController.getDoctorDetails(doctorId);

        if (!doctorDetails || doctorDetails.length === 0) {
            return res.status(404).send('Doctor details not found');
        }

        res.render('doctor/profile', {
            username: req.session.user.username,
            doctorDetails: doctorDetails[0],
            error: null
        });
    } catch (error) {
        console.error('Error fetching doctor profile:', error);
        res.status(500).send('Error loading profile');
    }
});

// View Doctor's Schedule Page
router.get('/doctor/schedule', isAuthenticated, isDoctor, async (req, res) => {
    try {
        const email = req.session.user.email;
        const doctorId = await doctorController.getDoctorIdByEmail(email);
        const appointments = await doctorController.getAppointmentsForDoctor(doctorId);

        res.render('doctor/schedule', {
            username: req.session.user.username,
            appointments: appointments,
            error: null
        });
    } catch (error) {
        console.error('Error fetching schedule:', error);
        res.status(500).send('Error loading schedule');
    }
});

// View doctor appointments schedule (GET)
router.get('/doctor/schedule', isAuthenticated, isDoctor, async (req, res) => {
    try {
        const email = req.session.user.email;
        const doctorId = await doctorController.getDoctorIdByEmail(email);
        const appointments = await doctorController.getDoctorSchedule(doctorId);
        res.render('doctor/schedule', { username: req.session.user.username, appointments });
    } catch (error) {
        console.error('Error fetching appointments:', error);
        res.status(500).send('Error loading appointments');
    }
});

// View appointment details (GET)
router.get('/doctor/appointment/:appointmentId', isAuthenticated, isDoctor, async (req, res) => {
    const { appointmentId } = req.params;

    try {
        const email = req.session.user.email;
        const doctorId = await doctorController.getDoctorIdByEmail(email);
        const appointmentDetails = await doctorController.getAppointmentDetails(doctorId, appointmentId);

        if (!appointmentDetails) {
            return res.status(404).send('Appointment not found');
        }

        res.render('doctor/appointmentDetails', {
            username: req.session.user.username,
            appointment: appointmentDetails
        });
    } catch (error) {
        console.error('Error fetching appointment details:', error);
        res.status(500).send('Error loading appointment details');
    }
});

// Create Follow Up Referral (GET)
router.get('/doctor/createreferral/:appointmentId', isAuthenticated, isDoctor, async (req, res) => {
    const { appointmentId } = req.params;

    try {
        const email = req.session.user.email;
        const doctorId = await doctorController.getDoctorIdByEmail(email);
        const appointmentDetails = await doctorController.getAppointmentDetails(doctorId, appointmentId);

        if (!appointmentDetails) {
            return res.status(404).send('Appointment not found');
        }

        const referralExists = await doctorController.checkIfFollowUpExists(appointmentId);

        res.render('doctor/createreferral/index', {
            username: req.session.user.username,
            appointment: appointmentDetails,
            referralExists: referralExists,
            error: null
        });
    } catch (error) {
        console.error('Error fetching appointment details:', error);
        res.status(500).send('Error loading appointment details');
    }
});

// Create Follow Up Referral (POST)
router.post('/doctor/createreferral/:appointmentId', isAuthenticated, isDoctor, async (req, res) => {
    const { appointmentId } = req.params;
    const { purpose, nextVisitDate, nextVisitTime } = req.body;

    try {
        await doctorController.createFollowUpReferral(appointmentId, purpose, nextVisitDate, nextVisitTime);

        res.redirect('/doctor/referrals');
    } catch (error) {
        console.error('Error creating follow-up referral:', error);
        res.status(500).send('Error creating follow-up referral');
    }
});

// View Doctor's Referrals Page
router.get('/doctor/referrals', isAuthenticated, isDoctor, async (req, res) => {
    try {
        const email = req.session.user.email;
        const doctorId = await doctorController.getDoctorIdByEmail(email);
        const referrals = await doctorController.getReferralsByDoctor(doctorId);
        res.render('doctor/referrals', {
            username: req.session.user.username,
            referrals: referrals || [],
            error: null
        });
    } catch (error) {
        console.error('Error fetching referrals:', error);
        res.status(500).send('Error loading referrals');
    }
});

// Route to render Clinical Record form
router.get('/doctor/createclinicalrecordform/:appointmentId', isAuthenticated, isDoctor, (req, res) => {
    const { appointmentId } = req.params;

    res.render('doctor/createclinicalrecordform/index', {
        appointmentId,
        clinicalData: {}
    });
});

// Route to save clinical record and complete appointment
router.post('/doctor/completeappointment/:appointmentId', isAuthenticated, isDoctor, async (req, res) => {
    const { appointmentId } = req.params;
    const { diagnosis, treatmentPlan, medications, notes } = req.body;
    const email = req.session.user.email;
    const doctorId = await doctorController.getDoctorIdByEmail(email);

    try {
        const saveResult = await doctorController.saveClinicalRecord(doctorId, appointmentId, {
            diagnosis,
            treatmentPlan,
            medications,
            notes
        });

        const completeResult = await doctorController.completeAppointment(doctorId, appointmentId);

        if (saveResult && completeResult) {
            res.json({ success: true });
        } else {
            res.status(500).json({ success: false, message: 'Error saving clinical record or completing appointment' });
        }
    } catch (error) {
        console.error('Error saving clinical record or completing appointment:', error);
        res.status(500).json({ success: false, message: 'Error saving clinical record or completing appointment' });
    }
});

export default router;
