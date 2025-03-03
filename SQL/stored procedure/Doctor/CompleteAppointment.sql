CREATE PROCEDURE Doctor.CompleteAppointment
    @AppointmentID INT
AS
BEGIN
    UPDATE Clerk.Appointment
    SET Status = 'Completed'
    WHERE AppointmentID = @AppointmentID;
END;
