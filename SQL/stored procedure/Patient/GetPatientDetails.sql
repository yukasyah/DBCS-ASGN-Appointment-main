CREATE PROCEDURE Patient.GetPatientDetails
    @PatientID INT
AS
BEGIN
    SELECT 
        p.PatientFullName, 
        p.IC, 
        p.DOB, 
        p.Gender, 
        p.PatientPhoneNum, 
        p.Address, 
        p.MedicalInsuranceProvider
    FROM Patient.Patient p
    WHERE p.PatientID = @PatientID;
END;
