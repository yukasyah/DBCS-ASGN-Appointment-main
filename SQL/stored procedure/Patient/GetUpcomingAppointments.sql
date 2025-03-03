CREATE PROCEDURE Patient.GetUpcomingAppointments
    @PatientID INT
AS
BEGIN
    SELECT 
        a.AppointmentID,
        a.Purpose,
        a.Status,
        d.DoctorName,
        ts.Date AS AppointmentDate,
        ts.Time AS AppointmentTime
    FROM Clerk.Appointment a
    JOIN Clerk.DocTimeSlot dts ON a.DocTimeSlotID = dts.DocTimeSlotID
    JOIN Employee.Doctor d ON dts.DoctorID = d.DoctorID
    JOIN Clerk.TimeSlot ts ON dts.TimeSlotID = ts.TimeSlotID
    WHERE a.PatientID = @PatientID
    AND ts.Date >= GETDATE()
    AND a.Status = 'Scheduled'
    ORDER BY ts.Date, ts.Time;
END;
