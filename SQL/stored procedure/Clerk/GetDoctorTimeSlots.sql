IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetDoctorTimeSlots' AND schema_id = SCHEMA_ID('Clerk'))
    DROP PROCEDURE Clerk.GetDoctorTimeSlots
GO

CREATE PROCEDURE Clerk.GetDoctorTimeSlots
    @DoctorID INT,
    @Date DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Create a table variable for the 6 fixed time slots
    DECLARE @TimeSlots TABLE (
        SlotID INT,
        Time VARCHAR(8),
        DisplayTime VARCHAR(8)
    )

    -- Insert the 6 fixed time slots
    INSERT INTO @TimeSlots VALUES
        (1, '09:00:00', '9:00 AM'),
        (2, '10:00:00', '10:00 AM'),
        (3, '11:00:00', '11:00 AM'),
        (4, '14:00:00', '2:00 PM'),
        (5, '15:00:00', '3:00 PM'),
        (6, '16:00:00', '4:00 PM')

    -- Return the time slots with doctor info
    SELECT 
        t.SlotID as TimeSlotID,
        t.DisplayTime as Time,
        d.DoctorID,
        d.DoctorName,
        d.DepartmentName,
        1 as DTSAvailability,
        @Date as AppointmentDate
    FROM 
        @TimeSlots t
        CROSS JOIN Employee.Doctor d
    WHERE 
        d.DoctorID = @DoctorID
    ORDER BY 
        t.SlotID;
END
GO
