IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetAvailableDoctorsList' AND schema_id = SCHEMA_ID('Clerk'))
    DROP PROCEDURE Clerk.GetAvailableDoctorsList
GO

CREATE PROCEDURE Clerk.GetAvailableDoctorsList
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
        d.DoctorID,
        d.DoctorName,
        d.DoctorEmail,
        d.DoctorPhoneNum,
        d.DepartmentName
    FROM 
        Employee.Doctor d
        INNER JOIN Clerk.DocTimeSlot dts ON d.DoctorID = dts.DoctorID
    WHERE 
        dts.DTSAvailability = 1
    ORDER BY 
        d.DoctorName;
END
GO
