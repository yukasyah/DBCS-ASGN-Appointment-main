CREATE PROCEDURE Doctor.GetReferralsByDoctor
    @DoctorID INT
AS
BEGIN
    SELECT 
        F.ReferralID, 
        P.PatientFullName,
        F.Date, 
        F.Time, 
        F.Status AS ReferralStatus,
        CONVERT(VARCHAR(10), F.CreatedAt, 120) AS CreatedDate,
        CONVERT(VARCHAR(8), F.CreatedAt, 108) AS CreatedTime
    FROM Doctor.FollowupReferral F
    JOIN Clerk.Appointment A ON F.AppointmentID = A.AppointmentID
    JOIN Clerk.DocTimeSlot DTS ON A.DocTimeSlotID = DTS.DocTimeSlotID
    JOIN Employee.Doctor D ON DTS.DoctorID = D.DoctorID
    JOIN Patient.Patient P ON A.PatientID = P.PatientID
    WHERE D.DoctorID = @DoctorID
    ORDER BY F.Date DESC;
END;
