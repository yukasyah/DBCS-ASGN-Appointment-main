CREATE PROCEDURE Doctor.SaveClinicalRecord
    @AppointmentID INT,
    @Diagnosis NVARCHAR(255),
    @TreatmentPlan NVARCHAR(255),
    @Medications NVARCHAR(255),
    @Notes NVARCHAR(MAX)
AS
BEGIN
    INSERT INTO ClinicalRecords (AppointmentID, Diagnosis, TreatmentPlan, Medications, Notes, CreatedTimestamp)
    VALUES (@AppointmentID, @Diagnosis, @TreatmentPlan, @Medications, @Notes, SYSDATETIME());
END;
