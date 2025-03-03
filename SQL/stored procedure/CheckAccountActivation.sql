CREATE PROCEDURE Emp.CheckAccountActivation
    @Email VARCHAR(255)
AS
BEGIN
    SELECT * 
    FROM Emp.AccountActivation
    WHERE Email = @Email AND IsUsed = 0 AND ExpiryAt > GETDATE();
END;
