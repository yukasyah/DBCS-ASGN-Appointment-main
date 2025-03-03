import { queryApptDbClk } from '../db.js';

export async function getClerkDetails(clerkId) {
    try {
        return [{ ClerkName: 'Clerk' }];
    } catch (error) {
        console.error('Error getting clerk details:', error);
        throw error;
    }
}

export async function getTotalAppointments() {
    try {
        const result = await queryApptDbClk('EXEC Clerk.GetTotalAppointments');
        if (!result || result.length === 0) {
            return 0;
        }
        return result[0].TotalAppointments || 0;
    } catch (error) {
        console.error('Error getting total appointments:', error);
        return 0;
    }
}

export async function getTotalRegisteredPatients() {
    try {
        const result = await queryApptDbClk('EXEC Clerk.GetTotalRegisteredPatients');
        if (!result || result.length === 0) {
            return 0;
        }
        return result[0].TotalPatients || 0;
    } catch (error) {
        console.error('Error getting total registered patients:', error);
        return 0;
    }
}

export async function getAvailableDoctorsCount() {
    try {
        const result = await queryApptDbClk('EXEC Clerk.GetAvailableDoctors');
        if (!result || result.length === 0) {
            return 0;
        }
        return result[0].AvailableDoctors || 0;
    } catch (error) {
        console.error('Error getting available doctors count:', error);
        return 0;
    }
}

export async function getAvailableDoctorsList() {
    try {
        const result = await queryApptDbClk('EXEC Clerk.GetAvailableDoctorsList');
        return result;
    } catch (error) {
        console.error('Error getting available doctors list:', error);
        throw error;
    }
}

export async function getPendingAppointments() {
    try {
        return [];
    } catch (error) {
        console.error('Error getting pending appointments:', error);
        return [];
    }
}

export async function getDashboardStats() {
    try {
        const [totalAppointments, availableDoctors, totalPatients] = await Promise.all([
            getTotalAppointments(),
            getAvailableDoctorsCount(),
            getTotalRegisteredPatients()
        ]);

        const stats = {
            totalAppointments: totalAppointments,
            availableDoctors: availableDoctors,
            totalPatients: totalPatients,
            emergencyCases: 0
        };
        return stats;
    } catch (error) {
        console.error('Error getting dashboard stats:', error);
        return {
            totalAppointments: 0,
            availableDoctors: 0,
            totalPatients: 0,
            emergencyCases: 0
        };
    }
}

export async function getDoctorTimeSlots(doctorId, date) {
    try {
        const result = await queryApptDbClk(
            'EXEC Clerk.GetDoctorTimeSlots @DoctorID = @doctorId, @Date = @date',
            { doctorId, date }
        );
        return result;
    } catch (error) {
        console.error('Error getting doctor time slots:', error);
        throw error;
    }
}

export async function scheduleAppointment(patientId, doctorId, timeSlotId, appointmentDate, purpose, clerkId) {
    try {
        const result = await queryApptDbClk(
            'EXEC Clerk.ScheduleAppointment @PatientID = @patientId, @DoctorID = @doctorId, @TimeSlotID = @timeSlotId, @AppointmentDate = @appointmentDate, @Purpose = @purpose, @ClerkID = @clerkId',
            { patientId, doctorId, timeSlotId, appointmentDate, purpose, clerkId }
        );
        
        if (!result || result.length === 0) {
            throw new Error('Failed to schedule appointment - no result returned');
        }
        return result[0].AppointmentID;
    } catch (error) {
        console.error('Error scheduling appointment:', error);
        throw error;
    }
}

export async function searchPatients(query) {
    try {
        let sql;
        if (!query) {
            sql = `
                SELECT TOP 100
                    p.PatientID,
                    p.PatientFullName as PatientName,
                    p.IC,
                    p.PatientEmail,
                    p.PatientPhoneNum
                FROM 
                    Patient.Patient p
                ORDER BY 
                    p.PatientFullName
            `;
            return await queryApptDbClk(sql);
        }

        sql = `
            SELECT 
                p.PatientID,
                p.PatientFullName as PatientName,
                p.IC,
                p.PatientEmail,
                p.PatientPhoneNum
            FROM 
                Patient.Patient p
            WHERE 
                p.PatientFullName LIKE '%' + @query + '%'
                OR p.IC LIKE '%' + @query + '%'
                OR p.PatientEmail LIKE '%' + @query + '%'
            ORDER BY 
                p.PatientFullName
        `;
        return await queryApptDbClk(sql, { query });
    } catch (error) {
        console.error('Error searching patients:', error);
        throw error;
    }
}

export async function getDashboard(req, res) {
    try {
        res.render('clerk/dashboard/index', {
            username: req.session.user.username,
            error: null
        });
    } catch (error) {
        console.error('Error in getDashboard:', error);
        res.status(500).send('Server error');
    }
}

export async function getDashboardData(req, res) {
    try {
        const [stats, pendingAppointments] = await Promise.all([
            getDashboardStats(),
            getPendingAppointments()
        ]);

        const dashboardData = {
            clerkName: req.session.user.username,
            pendingAppointments,
            stats
        };

        res.json(dashboardData);
    } catch (error) {
        console.error('Error getting dashboard data:', error);
        res.status(500).json({ error: 'Server error' });
    }
}

export async function deleteAppointment(appointmentId) {
    try {
        const result = await queryApptDbClk(
            'EXEC Clerk.DeleteAppointment @AppointmentID = @appointmentId',
            { appointmentId }
        );
        
        if (!result || result.length === 0) {
            throw new Error('No response from delete procedure');
        }

        if (result[0].Result !== 'Success') {
            throw new Error(result[0].Message || 'Failed to delete appointment');
        }
        return true;
    } catch (error) {
        console.error('Error deleting appointment:', error);
        throw error;
    }
}

export async function getScheduleView() {
    try {
        const result = await queryApptDbClk('EXEC Clerk.GetScheduleView');
        if (!result || result.length === 0) {
            return [];
        }
        return result;
    } catch (error) {
        console.error('Error getting schedule view:', error);
        throw error;
    }
}

export async function getReferralView() {
    try {
        const result = await queryApptDbClk('EXEC Clerk.GetReferralView');
        if (!result || result.length === 0) {
            return [];
        }
        return result;
    } catch (error) {
        console.error('Error getting referral view:', error);
        throw error;
    }
}
