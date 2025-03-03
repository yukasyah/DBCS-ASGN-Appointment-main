import express from 'express';
import { isAuthenticated, isClerk } from '../middlewares/authMiddleware.js';
import * as clerkController from '../Controllers/clerkController.js';

const router = express.Router();

router.get('/clerk/dashboard', isAuthenticated, isClerk, (req, res) => {
    res.render('clerk/dashboard/index', {
        username: req.session.user.username,
        error: null
    });
});

router.get('/clerk/dashboard/data', isAuthenticated, isClerk, async (req, res) => {
    try {
        const clerkId = req.session.user.id;
        const clerkDetails = await clerkController.getClerkDetails(clerkId);
        const pendingAppointments = await clerkController.getPendingAppointments();
        const stats = await clerkController.getDashboardStats();

        const response = {
            clerkName: clerkDetails[0].ClerkName,
            pendingAppointments: pendingAppointments.map(apt => ({
                patientName: apt.PatientName,
                time: apt.AppointmentTime,
                doctor: apt.DoctorName
            })),
            stats: {
                totalAppointments: stats.totalAppointments,
                totalPatients: stats.totalPatients,
                availableDoctors: stats.availableDoctors,
                emergencyCases: stats.emergencyCases
            }
        };

        res.json(response);
    } catch (err) {
        res.status(500).json({ error: 'Error fetching dashboard data' });
    }
});

router.get('/clerk/appointments/schedule', isAuthenticated, isClerk, async (req, res) => {
    try {
        const [doctors, patients] = await Promise.all([
            clerkController.getAvailableDoctorsList(),
            clerkController.searchPatients('')
        ]);
        
        res.render('clerk/appointments/schedule', {
            username: req.session.user.username,
            doctors: doctors,
            patients: patients
        });
    } catch (error) {
        res.status(500).send('Error loading schedule page');
    }
});

router.get('/clerk/appointments/view', isAuthenticated, isClerk, async (req, res) => {
    try {
        const result = await clerkController.getScheduleView();
        console.log('Schedule view data:', result);
        res.render('clerk/appointments/view', { 
            username: req.session.user.username,
            appointments: result || []
        });
    } catch (error) {
        res.status(500).send('Error viewing schedule');
    }
});

router.get('/clerk/doctors', isAuthenticated, isClerk, async (req, res) => {
    try {
        const doctors = await clerkController.getAvailableDoctorsList();
        res.json(doctors);
    } catch (err) {
        res.status(500).json({ error: 'Error getting doctors' });
    }
});

router.get('/clerk/timeslots', isAuthenticated, isClerk, async (req, res) => {
    const { doctorId, date } = req.query;

    if (!doctorId || !date) {
        return res.status(400).json({ error: 'Doctor ID and date are required' });
    }

    // Validate date format
    const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
    if (!dateRegex.test(date)) {
        return res.status(400).json({ error: 'Invalid date format. Use YYYY-MM-DD' });
    }

    try {
        const slots = await clerkController.getDoctorTimeSlots(doctorId, date);
        res.json(slots);
    } catch (err) {
        res.status(500).json({ error: 'Error getting time slots' });
    }
});

router.post('/clerk/appointments/new', isAuthenticated, isClerk, async (req, res) => {
    const { patientId, doctorId, timeSlotId, appointmentDate, purpose } = req.body;
    const clerkId = req.session.user.id;

    if (!patientId || !doctorId || !timeSlotId || !appointmentDate || !purpose || !clerkId) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    try {
        const appointmentId = await clerkController.scheduleAppointment(
            patientId,
            doctorId,
            timeSlotId,
            appointmentDate,
            purpose,
            clerkId
        );

        if (!appointmentId) {
            return res.status(400).json({ error: 'Failed to schedule appointment - no appointment ID returned' });
        }

        res.json({
            message: 'Appointment scheduled successfully',
            appointmentId: appointmentId
        });
    } catch (err) {
        console.error('Error scheduling appointment:', err);
        
        // Handle SQL Server error messages
        if (err.precedingErrors && err.precedingErrors.length > 0) {
            return res.status(400).json({ error: err.precedingErrors[0].message });
        }
        
        // Handle other specific error messages
        if (err.message.includes('Selected time slot is not available') || 
            err.message.includes('Invalid doctor ID')) {
            return res.status(400).json({ error: err.message });
        }
        
        // For unexpected errors
        res.status(500).json({ 
            error: 'An unexpected error occurred while scheduling the appointment',
            details: err.message
        });
    }
});

router.delete('/clerk/appointments/:id', isAuthenticated, isClerk, async (req, res) => {
    try {
        const appointmentId = parseInt(req.params.id);
        if (!appointmentId) {
            return res.status(400).json({ error: 'Invalid appointment ID' });
        }

        await clerkController.deleteAppointment(appointmentId);
        res.json({ message: 'Appointment deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Error deleting appointment' });
    }
});

router.get('/patients/search', isAuthenticated, isClerk, async (req, res) => {
    const { query } = req.query;

    if (!query) {
        return res.status(400).send('Search query is required');
    }

    try {
        const results = await clerkController.searchPatients(query);
        res.json(results);
    } catch (err) {
        res.status(500).send('Error searching patients');
    }
});

router.get('/clerk/referrals/view', isAuthenticated, isClerk, async (req, res) => {
    try {
        const referrals = await clerkController.getReferralView();
        res.render('clerk/referrals/view', { 
            username: req.session.user.username,
            referrals: referrals
        });
    } catch (error) {
        res.status(500).send('Error viewing referrals');
    }
});

export default router;
