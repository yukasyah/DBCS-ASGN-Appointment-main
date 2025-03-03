CREATE PROCEDURE Patient.GetMedicalRecords
@PatientID INT
AS
BEGIN
    SELECT   cr.RecordID,
             cr.Diagnosis AS RecordType,
             cr.TreatmentPlan AS Description,
             CONVERT(DATE, cr.CreatedTimestamp) AS RecordDate, -- Extract the date part
             CONVERT(TIME, cr.CreatedTimestamp) AS RecordTime, -- Extract the time part
             cr.CreatedTimestamp AS OriginalTimestamp
    FROM     Doctor.ClinicalRecords AS cr
             INNER JOIN
             Clerk.Appointment AS a
             ON cr.AppointmentID = a.AppointmentID
    WHERE    a.PatientID = @PatientID
    ORDER BY cr.CreatedTimestamp DESC;
END
