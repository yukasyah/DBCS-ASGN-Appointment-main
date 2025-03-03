CREATE PROCEDURE Patient.UpdatePatientProfile
@patientId INT, @phone VARCHAR (15), @address VARCHAR (255), @insurance VARCHAR (100)
AS
BEGIN
    UPDATE Patient.Patient
    SET    PatientPhoneNum          = @phone,
           Address                  = @address,
           MedicalInsuranceProvider = @insurance
    WHERE  PatientID = @patientId;
END
