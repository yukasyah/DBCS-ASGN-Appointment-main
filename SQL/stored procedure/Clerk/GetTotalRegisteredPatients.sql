CREATE PROCEDURE [Clerk].[GetTotalRegisteredPatients]
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT COUNT(*) AS TotalPatients
    FROM Patient.Patient;
END;
