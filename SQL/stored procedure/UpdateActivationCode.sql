CREATE PROCEDURE Emp.UpdateActivationCode
    @PendingID INT
AS
BEGIN
    UPDATE Emp.AccountActivation
    SET IsUsed = 1
    WHERE PendingID = @PendingID;
END;
