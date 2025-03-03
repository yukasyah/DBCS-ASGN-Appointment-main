-- Create Clerk schema if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Clerk')
BEGIN
    EXEC('CREATE SCHEMA Clerk')
END
GO

-- Drop procedure if it exists
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'GetNewPatients' AND schema_id = SCHEMA_ID('Clerk'))
BEGIN
    DROP PROCEDURE [Clerk].[GetNewPatients]
END
GO

CREATE PROCEDURE [Clerk].[GetNewPatients]
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Return as a proper recordset with column name
    SELECT 
        (SELECT COUNT(*) FROM Patient.Patient) AS NewPatients
END;
GO
