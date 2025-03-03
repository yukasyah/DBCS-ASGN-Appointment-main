CREATE PROCEDURE Doctor.CreateFollowUpReferral
    @AppointmentID INT,
    @Purpose VARCHAR(50),
    @VisitDate DATE,
    @VisitTime TIME
AS
BEGIN
    INSERT INTO Doctor.FollowupReferral (Date, Time, Status, Purpose, AppointmentID)
    VALUES (@VisitDate, @VisitTime, 'Pending', @Purpose, @AppointmentID);
END;
