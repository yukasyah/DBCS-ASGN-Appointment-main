CREATE PROCEDURE Employee.GetDoctorDetails
    @DoctorID INT
AS
BEGIN
    SELECT * 
    FROM Employee.Doctor
    WHERE DoctorID = @DoctorID;
END;
