CREATE PROCEDURE Patient.InsertPatient
@PatientFullName VARCHAR (255), @Email VARCHAR (255), @IC VARCHAR (50), @DOB DATE, @Gender CHAR (1), @PatientPhoneNum VARCHAR (15), @Address VARCHAR (500), @MedicalInsuranceProvider VARCHAR (255)
AS
BEGIN
    INSERT INTO Patient.Patient (PatientFullName, PatientEmail, IC, DOB, Gender, PatientPhoneNum, Address, MedicalInsuranceProvider)
    OUTPUT INSERTED.PatientID
    VALUES (@PatientFullName, @Email, @IC, @DOB, @Gender, @PatientPhoneNum, @Address, @MedicalInsuranceProvider);
END
