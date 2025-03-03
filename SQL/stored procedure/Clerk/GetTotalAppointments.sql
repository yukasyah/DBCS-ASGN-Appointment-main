-- Create Clerk schema if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Clerk')
BEGIN
    EXEC('CREATE SCHEMA Clerk')
END
GO

-- Drop procedure if it exists
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'GetTotalAppointments' AND schema_id = SCHEMA_ID('Clerk'))
BEGIN
    DROP PROCEDURE [Clerk].[GetTotalAppointments]
END
GO

CREATE PROCEDURE [Clerk].[GetTotalAppointments]
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Return as a proper recordset with column name
    SELECT 
        COUNT(*) AS TotalAppointments
    FROM [Clerk].[Appointment];
END;
GO
