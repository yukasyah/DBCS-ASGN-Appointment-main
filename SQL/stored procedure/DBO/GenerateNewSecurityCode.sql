CREATE PROCEDURE Emp.GenerateNewSecurityCode
    @Email VARCHAR(255),
    @NewSecurityCode CHAR(16)
AS
BEGIN
    DECLARE @CurrentExpiry DATETIME, 
            @CurrentSecurityCode CHAR(16),
            @IsUsed BIT;

    SELECT @CurrentExpiry = ExpiryAt,
        @CurrentSecurityCode = SecurityCode,
        @IsUsed = IsUsed
    FROM Emp.AccountActivation
    WHERE Email = @Email;

    IF @CurrentExpiry IS NULL
    BEGIN
        RAISERROR('Account with the specified email does not exist.', 16, 1);
        RETURN;
    END

    IF @IsUsed = 1
    BEGIN
        RAISERROR('Account has already been activated. Cannot generate a new security code.', 16, 1);
        RETURN;
    END

    IF @NewSecurityCode = @CurrentSecurityCode
    BEGIN
        RAISERROR('The new security code must be different from the current code.', 16, 1);
        RETURN;
    END

    UPDATE Emp.AccountActivation
    SET SecurityCode = @NewSecurityCode, 
        ExpiryAt = DATEADD(DAY, 1, GETDATE())
    WHERE Email = @Email;

    SELECT Email, SecurityCode, ExpiryAt
    FROM Emp.AccountActivation
    WHERE Email = @Email;

    PRINT 'Security code updated successfully.';
END
