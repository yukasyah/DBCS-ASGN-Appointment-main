import { queryApptDbDoc } from '../db.js';

export async function getDoctorIdByEmail(email) {
    const query = `EXEC GetDoctorIdByEmail @Email = @Email`;
    const params = { Email: email };

    try {
        const result = await queryApptDbDoc(query, params);

        if (result && result.length > 0) {
            return result[0].DoctorID;
        } else {
            throw new Error('Doctor not found for this email');
        }
    } catch (error) {
        console.error('Error fetching doctorId by email from apptDb:', error);
        throw new Error('Error fetching doctorId');
    }
}

export async function getDoctorDetails(doctorId) {
    const doctorDetailsQuery = `EXEC Employee.GetDoctorDetails @DoctorID = @DoctorID`;
    const doctorDetailsParams = { DoctorID: doctorId };
    const doctorDetails = await queryApptDbDoc(doctorDetailsQuery, doctorDetailsParams);
    console.log(doctorId);
    return doctorDetails;
}


export async function getAppointmentsForDoctor(doctorId) {
    const appointmentsQuery = `EXEC Doctor.GetAppointmentsForDoctor @DoctorID = @DoctorID`;
    const appointmentsParams = { DoctorID: doctorId };
    const appointments = await queryApptDbDoc(appointmentsQuery, appointmentsParams);
    return appointments;
}

export async function getCompletedAppointmentsThisMonth(doctorId) {
    const query = `
        EXEC Doctor.GetCompletedAppointments @DoctorID = @DoctorID
    `;
    const params = { DoctorID: doctorId };

    try {
        const result = await queryApptDbDoc(query, params);
        console.log(result);

        if (!result || !result[0] || result[0].TotalCompletedAppointments === undefined || result[0].TotalCompletedAppointments === 0) {
            return '0';
        } else {
            return result[0].TotalCompletedAppointments;
        }
    } catch (error) {
        console.error("Error fetching completed appointments:", error.message);
        throw error;
    }
}

export async function getDoctorSchedule(doctorId) {
    const query = 'EXEC Doctor.GetAppointmentsForDoctor @DoctorID = @DoctorID';
    const params = { DoctorID: doctorId };

    try {
        const result = await queryApptDbDoc(query, params);
        return result.recordsets[0];
    } catch (error) {
        console.error('Error fetching doctor schedule:', error);
        throw new Error('Error fetching doctor schedule');
    }
}

export async function getAppointmentDetails(doctorId, appointmentId) {
    const query = `EXEC Doctor.GetAppointmentDetails @DoctorID = @DoctorID, @AppointmentID = @AppointmentID`;
    const params = {
        DoctorID: doctorId,
        AppointmentID: appointmentId
    };

    try {
        const result = await queryApptDbDoc(query, params) || [];

        if (Array.isArray(result) && result.length > 0) {
            const appointmentDetails = result[0];
            console.log('Appointment Details:', appointmentDetails);
            return appointmentDetails;
        } else {
            throw new Error('No appointment details found');
        }
    } catch (error) {
        console.error('Error fetching appointment details:', error);
        throw new Error('Error fetching appointment details');
    }
}

export async function createFollowUpReferral(appointmentId, purpose, nextVisitDate, nextVisitTime) {
    const query = `
        EXEC Doctor.CreateFollowUpReferral
        @AppointmentID = @AppointmentID,
        @Purpose = @Purpose,
        @VisitDate = @VisitDate,
        @VisitTime = @VisitTime
    `;

    const params = {
        AppointmentID: appointmentId,
        Purpose: purpose,
        VisitDate: nextVisitDate,
        VisitTime: nextVisitTime
    };

    try {
        await queryApptDbDoc(query, params);
    } catch (error) {
        console.error('Error creating follow-up referral:', error);
        throw new Error('Error creating follow-up referral');
    }
}

export async function getReferralsByDoctor(doctorId) {
    const query = `EXEC Doctor.GetReferralsByDoctor @DoctorID = @DoctorID`;
    const params = { DoctorID: doctorId };

    try {
        const result = await queryApptDbDoc(query, params);
        return result;
    } catch (error) {
        console.error('Error fetching referrals:', error.message);
        throw error;
    }
}

export async function checkIfFollowUpExists(appointmentId) {
    const query = `
        EXEC Doctor.CheckFollowUpReferral @AppointmentID = @AppointmentID;
    `;

    const params = {
        AppointmentID: appointmentId
    };

    const result = await queryApptDbDoc(query, params);
    return result.length > 0;
}

export async function saveClinicalRecord(doctorId, appointmentId, clinicalData) {
    const query = `
        EXEC Doctor.SaveClinicalRecord
            @AppointmentID = @AppointmentID,
            @Diagnosis = @Diagnosis,
            @TreatmentPlan = @TreatmentPlan,
            @Medications = @Medications,
            @Notes = @Notes
    `;
    const params = {
        AppointmentID: appointmentId,
        Diagnosis: clinicalData.diagnosis,
        TreatmentPlan: clinicalData.treatmentPlan,
        Medications: clinicalData.medications,
        Notes: clinicalData.notes
    };

    try {
        await queryApptDbDoc(query, params);
        return true;
    } catch (error) {
        console.error('Error saving clinical record:', error);
        throw new Error('Error saving clinical record');
    }
}

export async function completeAppointment(doctorId, appointmentId) {
    const query = `
        EXEC Doctor.CompleteAppointment @AppointmentID = @AppointmentID
    `;

    const params = {
        AppointmentID: appointmentId
    };

    try {
        await queryApptDbDoc(query, params);
        return true;
    } catch (error) {
        console.error('Error completing appointment:', error);
        throw new Error('Error completing appointment');
    }
}
