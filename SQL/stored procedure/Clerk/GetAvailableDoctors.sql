IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetAvailableDoctors' AND schema_id = SCHEMA_ID('Clerk'))
    DROP PROCEDURE Clerk.GetAvailableDoctors
GO

CREATE PROCEDURE Clerk.GetAvailableDoctors
AS
BEGIN
    SET NOCOUNT ON;

    -- For dashboard count - all doctors are available since we create time slots on demand
    SELECT COUNT(*) AS AvailableDoctors
    FROM Employee.Doctor;
END
GO
