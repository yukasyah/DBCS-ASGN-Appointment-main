CREATE PROCEDURE Doctor.CreateClinicalRecord
    @AppointmentID INT,
    @Diagnosis VARCHAR(255),
    @TreatmentPlan VARCHAR(255),
    @Medications VARCHAR(255),
    @Notes VARCHAR(255)
AS
BEGIN
    INSERT INTO Doctor.ClinicalRecords (
        AppointmentID,
        Diagnosis,
        TreatmentPlan,
        Medications,
        Notes,
        CreatedTimestamp,
        LastUpdatedTimestamp
    )
    VALUES (
        @AppointmentID,
        @Diagnosis,
        @TreatmentPlan,
        @Medications,
        @Notes,
        GETDATE(),
        GETDATE()
    );
END;
