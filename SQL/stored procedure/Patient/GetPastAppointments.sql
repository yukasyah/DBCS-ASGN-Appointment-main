CREATE PROCEDURE Patient.GetPastAppointments
    @PatientID INT
AS
BEGIN
    SELECT   a.AppointmentID,
             d.DoctorName,
             CONVERT (DATE, ts.Date) AS AppointmentDate,
             CONVERT (TIME, ts.Time) AS AppointmentTime,
             cr.Diagnosis
    FROM     Clerk.Appointment AS a
             INNER JOIN
             Clerk.DocTimeSlot AS dts
             ON a.DocTimeSlotID = dts.DocTimeSlotID
             INNER JOIN
             Employee.Doctor AS d
             ON dts.DoctorID = d.DoctorID
             INNER JOIN
             Clerk.TimeSlot AS ts
             ON dts.TimeSlotID = ts.TimeSlotID
             LEFT OUTER JOIN
             Doctor.ClinicalRecords AS cr
             ON a.AppointmentID = cr.AppointmentID
    WHERE    a.PatientID = @PatientID
             AND ts.Date < GETDATE()
    ORDER BY ts.Date DESC;
END;
