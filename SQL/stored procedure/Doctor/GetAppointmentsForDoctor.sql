CREATE PROCEDURE Doctor.GetAppointmentsForDoctor
    @DoctorID INT
AS
BEGIN
    SELECT 
        AppointmentID,
        PatientFullName,
        CONVERT(VARCHAR(10), AppointmentDate, 120) AS AppointmentDate,
        CONVERT(VARCHAR(8), AppointmentTime, 108) AS AppointmentTime
    FROM 
        Doctor.AppointmentDetails
    WHERE 
        DoctorID = @DoctorID;
END;
