IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'ScheduleAppointment' AND schema_id = SCHEMA_ID('Clerk'))
    DROP PROCEDURE Clerk.ScheduleAppointment
GO

CREATE PROCEDURE Clerk.ScheduleAppointment
    @PatientID INT,
    @DoctorID INT,
    @TimeSlotID INT,
    @AppointmentDate DATE,
    @Purpose NVARCHAR(500),
    @ClerkID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRANSACTION;
        
    -- Create TimeSlot record
    DECLARE @Time TIME;
    SET @Time = CASE @TimeSlotID
        WHEN 1 THEN '09:00:00'
        WHEN 2 THEN '10:00:00'
        WHEN 3 THEN '11:00:00'
        WHEN 4 THEN '14:00:00'
        WHEN 5 THEN '15:00:00'
        WHEN 6 THEN '16:00:00'
    END;

    -- Validate the appointment date is not in the past
    IF @AppointmentDate < CAST(GETDATE() AS DATE)
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('Cannot schedule appointments in the past.', 16, 1);
        RETURN;
    END
    DECLARE @TimeSlotDBID INT;
    DECLARE @DocTimeSlotID INT;

    -- Insert TimeSlot
    INSERT INTO Clerk.TimeSlot (Date, Time)
    VALUES (@AppointmentDate, @Time);
    
    SET @TimeSlotDBID = SCOPE_IDENTITY();

    -- Create DocTimeSlot record
    INSERT INTO Clerk.DocTimeSlot (DoctorID, TimeSlotID, DTSAvailability, Reason)
    VALUES (@DoctorID, @TimeSlotDBID, 0, '');
    
    SET @DocTimeSlotID = SCOPE_IDENTITY();

    -- Verify doctor exists
    IF NOT EXISTS (SELECT 1 FROM Employee.Doctor WHERE DoctorID = @DoctorID)
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('Invalid doctor ID.', 16, 1);
        RETURN;
    END

    -- Verify patient exists
    IF NOT EXISTS (SELECT 1 FROM Patient.Patient WHERE PatientID = @PatientID)
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('Invalid patient ID.', 16, 1);
        RETURN;
    END

    -- Insert the appointment
    INSERT INTO [Clerk].[Appointment] (
        DocTimeSlotID,
        PatientID,
        Status,
        Purpose,
        ClerkID
    )
    VALUES (
        @DocTimeSlotID,
        @PatientID,
        'Scheduled',
        @Purpose,
        @ClerkID
    );

    -- Update the doctor time slot availability
    UPDATE Clerk.DocTimeSlot
    SET DTSAvailability = 0
    WHERE DocTimeSlotID = @DocTimeSlotID;

    COMMIT TRANSACTION;
    
    SELECT SCOPE_IDENTITY() AS AppointmentID;
END
GO
