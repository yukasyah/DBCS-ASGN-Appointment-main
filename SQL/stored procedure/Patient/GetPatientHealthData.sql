CREATE PROCEDURE Patient.GetPatientHealthData
    @PatientID INT
AS
BEGIN
    SELECT 
        mp.BloodType,
        mp.Height,
        mp.Weight,
        mp.Allergies,
        mp.ChronicCondition,
        cr.Medications
    FROM Patient.MedicalProfile mp
    LEFT JOIN Clerk.Appointment a ON a.PatientID = mp.PatientID
    LEFT JOIN Doctor.ClinicalRecords cr ON cr.AppointmentID = a.AppointmentID
    WHERE mp.PatientID = @PatientID;
END;
