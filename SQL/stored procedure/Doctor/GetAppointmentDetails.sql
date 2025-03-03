CREATE PROCEDURE Doctor.GetAppointmentDetails
    @DoctorID INT,
    @AppointmentID INT
AS
BEGIN
    SELECT 
        a.AppointmentID,
        p.PatientFullName AS PatientFullName,
        CONVERT(VARCHAR(10), ts.Date, 120) AS AppointmentDate,
        CONVERT(VARCHAR(8), ts.Time, 108) AS AppointmentTime,
        a.Purpose AS AppointmentPurpose,
        a.Status AS AppointmentStatus,
        mp.BloodType,
        mp.Height,
        mp.Weight,
        mp.Allergies,
        mp.ChronicCondition

    FROM 
        Clerk.Appointment a
    JOIN 
        Patient.Patient p ON a.PatientID = p.PatientID
    JOIN 
        Clerk.DocTimeSlot dts ON a.DocTimeSlotID = dts.DocTimeSlotID
    JOIN 
        Clerk.TimeSlot ts ON dts.TimeSlotID = ts.TimeSlotID
    LEFT JOIN 
        Patient.MedicalProfile mp ON p.PatientID = mp.PatientID
    WHERE 
        dts.DoctorID = @DoctorID AND a.AppointmentID = @AppointmentID;
END;
