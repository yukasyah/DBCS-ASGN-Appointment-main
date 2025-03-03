CREATE PROCEDURE Doctor.GetRecentCompletedAppt
    @DoctorID INT
AS
BEGIN
    SELECT 
        A.AppointmentID, 
        P.PatientFullName AS PatientName, 
        TS.Date AS AppointmentDate
    FROM 
        Clerk.Appointment A
    INNER JOIN 
        Clerk.DocTimeSlot DTS ON A.DocTimeSlotID = DTS.DocTimeSlotID
    INNER JOIN 
        Clerk.TimeSlot TS ON DTS.TimeSlotID = TS.TimeSlotID
    INNER JOIN 
        Employee.Doctor D ON DTS.DoctorID = D.DoctorID
    INNER JOIN 
        Patient.Patient P ON A.PatientID = P.PatientID
    WHERE 
        DTS.DoctorID = @DoctorID 
        AND TS.Date >= DATEADD(DAY, -7, GETDATE())
        AND A.Status = 'Completed';
END;
