import { queryApptDbPat } from '../db.js';

// Get patient details
export async function getPatientDetails(patientId) {
    const query = 'EXEC Patient.GetPatientDetails @PatientID';
    return await queryApptDbPat(query, { PatientID: patientId });

}

// Get patient appointments
export async function getPatientAppointments(patientId) {
    const upcomingQuery = 'EXEC Patient.GetUpcomingAppointments @PatientID = @PatientID;';
    const pastQuery = 'EXEC Patient.GetPastAppointments @PatientID = @PatientID;';

    const [upcoming, past] = await Promise.all([
        queryApptDbPat(upcomingQuery, { PatientID: patientId }),
        queryApptDbPat(pastQuery, { PatientID: patientId })
    ]);

    return { upcoming, past };
}


// Get medical records
export async function getMedicalRecords(patientId) {
    const query = 'EXEC Patient.GetMedicalRecords @PatientID = @PatientID';
    return await queryApptDbPat(query, { PatientID: patientId });
}

// Get health data
export async function getHealthData(patientId) {
    const query = 'EXEC Patient.GetPatientHealthData @PatientID = @PatientID';
    const result = await queryApptDbPat(query, { PatientID: patientId });

    if (!result || result.length === 0) {
        return {
            bloodtype: 'N/A',
            height: 'N/A',
            weight: 'N/A',
            allergies: 'N/A',
            medications: [],
            conditions: []
        };
    }

    const profile = result[0];
    const conditions = [];
    const medications = [];

    if (profile.Allergies) {
        conditions.push({
            Type: 'Allergies',
            Description: profile.Allergies
        });
    }

    if (profile.Medications) {
        medications.push({
            Type: 'Medication',
            Description: profile.Medications
        });
    }

    if (profile.ChronicCondition) {
        conditions.push({
            Type: 'Chronic Condition',
            Description: profile.ChronicCondition
        });
    }

    return {
        bloodType: profile.BloodType || 'N/A',
        height: profile.Height || 'N/A',
        weight: profile.Weight ? `${profile.Weight} kg` : 'N/A',
        allergies: profile.Allergies || 'N/A',
        medications,
        conditions
    };
}

// // Book appointment
// export async function bookAppointment(patientId, doctorId, appointmentTime, purpose) {
//     const query = `
//         INSERT INTO Clerk.Appointment (DocTimeSlotID, PatientID, Status, Purpose)
//         VALUES (@DocTimeSlotID, @PatientID, 'Scheduled', @Purpose)
//     `;
//     return await queryApptDbPat(query, {
//         DocTimeSlotID: appointmentTime,
//         PatientID: patientId,
//         Purpose: purpose
//     });
// }


// Function to update profile using stored procedure
export async function updateProfile(patientId, phone, address, insurance) {
    try {
        const query = `
            EXEC patient.updatepatientprofile 
                @PatientID = @patientId, 
                @Phone = @phone, 
                @Address = @address, 
                @Insurance = @insurance
        `;

        // Execute the query
        await queryApptDbPat(query, {
            patientId: patientId,
            phone: phone,
            address: address,
            insurance: insurance
        });

    } catch (err) {
        console.error('Error in updateProfile controller:', err);
        throw err; // Throwing the error so it can be caught in the route handler
    }
}




// Get available doctors
export async function getAvailableDoctors() {
    const query = `
        SELECT 
            d.DoctorID,
            d.DoctorName,
            d.Department,
            dts.DocTimeSlotID,
            ts.Date,
            ts.Time
        FROM Doctor.Doctor d
        JOIN Clerk.DocTimeSlot dts ON d.DoctorID = dts.DoctorID
        JOIN Clerk.TimeSlot ts ON dts.TimeSlotID = ts.TimeSlotID
        LEFT JOIN Clerk.Appointment a ON dts.DocTimeSlotID = a.DocTimeSlotID
        WHERE ts.Date >= GETDATE()
        AND (a.AppointmentID IS NULL OR a.Status = 'Canceled')
        ORDER BY ts.Date, ts.Time
    `;
    return await queryApptDbPat(query);
}

// Get prescriptions
export async function getPrescriptions(patientId) {
    const query = `
        SELECT 
            cr.Medications,
            cr.CreatedTimestamp as PrescriptionDate,
            d.DoctorName as PrescribedBy
        FROM Doctor.ClinicalRecords cr
        JOIN Clerk.Appointment a ON cr.AppointmentID = a.AppointmentID
        JOIN Clerk.DocTimeSlot dts ON a.DocTimeSlotID = dts.DocTimeSlotID
        JOIN Doctor.Doctor d ON dts.DoctorID = d.DoctorID
        WHERE a.PatientID = @PatientID
        AND cr.Medications IS NOT NULL
        ORDER BY cr.CreatedTimestamp DESC
    `;
    return await queryApptDbPat(query, { PatientID: patientId });
}
