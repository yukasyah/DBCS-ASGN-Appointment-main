CREATE PROCEDURE Doctor.GetDoctorIdByEmail
    @Email NVARCHAR(255)
AS
BEGIN
    SELECT DoctorID
    FROM Employee.Doctor
    WHERE DoctorEmail = @Email;
END
