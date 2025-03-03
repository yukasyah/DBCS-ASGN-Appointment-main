CREATE PROCEDURE Patient.InsertMedicalProfile
@PatientID INT, @BloodType VARCHAR (3), @Height DECIMAL (5, 2), @Weight DECIMAL (5, 2), @Allergies NVARCHAR (255)=NULL, @ChronicCondition NVARCHAR (255)=NULL
AS
BEGIN
    INSERT INTO Patient.MedicalProfile (PatientID, BloodType, Height, Weight, Allergies, ChronicCondition)
    VALUES (@PatientID, @BloodType, @Height, @Weight, @Allergies, @ChronicCondition);
END
