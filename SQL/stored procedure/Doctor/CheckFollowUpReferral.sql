CREATE PROCEDURE Doctor.CheckFollowUpReferral
    @AppointmentID INT
AS
BEGIN
    SELECT 1
    FROM Doctor.FollowupReferral
    WHERE AppointmentID = @AppointmentID;
END;
