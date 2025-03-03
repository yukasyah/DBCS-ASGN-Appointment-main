import express from 'express';
import { isAuthenticated, isPatient } from '../middlewares/authMiddleware.js';
import * as patientController from '../Controllers/patientController.js';

const router = express.Router();

// Dashboard route
router.get('/patient/dashboard', isAuthenticated, isPatient, (req, res) => {
    res.render('patient/dashboard/index', {
        username: req.session.user.username,
        error: null
    });
});

// Dashboard data route
router.get('/patient/dashboard/data', isAuthenticated, isPatient, async (req, res) => {
    try {
        const patientId = req.session.user.id;
        const patientDetails = await patientController.getPatientDetails(patientId);
        const appointments = await patientController.getPatientAppointments(patientId);
        const medicalRecords = await patientController.getMedicalRecords(patientId);
        const healthData = await patientController.getHealthData(patientId);

        res.json({
            patientInfo: patientDetails.map(info => ({
                patientName: info.PatientFullName,
                patientIC: info.IC,
                dob: info.DOB,
                gender: info.Gender,
                phonenum: info.PatientPhoneNum,
                addr: info.Address,
                insurance: info.MedicalInsuranceProvider
            })),
            upcomingAppointments: appointments.upcoming.map(apt => ({
                doctorName: apt.DoctorName,
                date: apt.AppointmentDate,
                time: apt.AppointmentTime,
                purpose: apt.Purpose
            })),
            pastAppointments: appointments.past.map(apt => ({
                doctorName: apt.DoctorName,
                date: apt.AppointmentDate,
                time: apt.AppointmentTime,
                diagnosis: apt.Diagnosis
            })),
            medicalRecords: medicalRecords.map(record => ({
                date: record.RecordDate,
                time: record.RecordTime,
                type: record.RecordType,
                description: record.Description
            })),
            vitals: {
                'Blood Type': healthData.bloodType,
                'Height': healthData.height,
                'Weight': healthData.weight
            },
            currentMedications: healthData.medications.map(med => ({
                type: med.Type,
                description: med.Description
            })),
            allergiesConditions: healthData.conditions.map(condition => ({
                type: condition.Type,
                description: condition.Description
            }))
        });
    } catch (err) {
        console.error('Error fetching dashboard data:', err);
        res.status(500).json({ error: 'Error fetching dashboard data' });
    }
});

// Route to display the medical info form
router.get('/patient/medical-info', (req, res) => {
    // Check if the user is authenticated and has the "patient" role
    if (req.session.user && req.session.user.role === 'patient') {
        return res.render('patient/medical-info/index'); // Render the form page
    } else {
        return res.redirect('/patient/login'); // Redirect to login if not authenticated
    }
});

router.post('/patient/medical-info', isAuthenticated, isPatient, async (req, res) => {
    const { bloodType, height, weight, allergies, chronicCondition } = req.body;

    try {
        // Fetch the logged-in patient's ID from the session
        const patientId = req.session.user.id;

        // Prepare parameters for the stored procedure
        const medicalInfoParams = {
            PatientID: patientId,
            BloodType: bloodType,
            Height: height,
            Weight: weight,
            Allergies: allergies,
            ChronicCondition: chronicCondition,
        };

        // Execute the stored procedure to save medical information
        const medicalInfoQuery = `
            EXEC [Patient].[InsertMedicalInfo]
            @PatientID = @PatientID,
            @BloodType = @BloodType,
            @Height = @Height,
            @Weight = @Weight,
            @Allergies = @Allergies,
            @ChronicCondition = @ChronicCondition
        `;

        await queryApptDbPat(medicalInfoQuery, medicalInfoParams);

        // Redirect to the patient's dashboard or another appropriate page
        res.redirect('/patient/dashboard');
    } catch (err) {
        console.error('Error saving medical info:', err);
        res.render('patient/medical-info', { error: 'Error saving medical information. Please try again.' });
    }
});


// Book new appointment
router.post('/patient/appointments/book', isAuthenticated, isPatient, async (req, res) => {
    const { doctorId, appointmentTime, purpose } = req.body;
    const patientId = req.session.user.id;

    if (!doctorId || !appointmentTime || !purpose) {
        return res.status(400).send('Missing required fields');
    }

    try {
        await patientController.bookAppointment(patientId, doctorId, appointmentTime, purpose);
        res.send('Appointment booked successfully');
    } catch (err) {
        console.error('Error booking appointment:', err);
        res.status(500).send('Error booking appointment');
    }
});


// Patient Profile Update Route
router.post('/patient/profile/update', isAuthenticated, isPatient, async (req, res) => {
    const { phone, address, insurance } = req.body;
    const patientId = req.session.user.id;  // Ensure patientId is correctly extracted from the session

    if (!phone || !address || !insurance) {
        return res.status(400).send('Missing required fields');
    }

    try {
        // Update the patient's profile using the controller function
        await patientController.updateProfile(patientId, phone, address, insurance);
        // Redirect to a page
        res.redirect('/patient/dashboard');
    } catch (err) {
        console.error('Error updating profile:', err);
        res.status(500).send('Error updating profile');
    }
});


router.get('/update-profile', (req, res) => {
    res.render('patient/dashboard/update-profile');
});

// Get available doctors
router.get('/patient/doctors/available', isAuthenticated, isPatient, async (req, res) => {
    try {
        const doctors = await patientController.getAvailableDoctors();
        res.json(doctors);
    } catch (err) {
        console.error('Error fetching available doctors:', err);
        res.status(500).send('Error fetching available doctors');
    }
});

// Patient insert medical record




export default router;
