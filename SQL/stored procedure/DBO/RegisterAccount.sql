CREATE PROCEDURE Emp.RegisterAccount
    @Email VARCHAR(255),
    @SecurityCode VARCHAR(255),
    @RoleID INT
AS
BEGIN
    IF EXISTS (SELECT 1
    FROM Auth.AccountActivation
    WHERE Email = @Email)
    BEGIN
        RAISERROR('Email already registered', 16, 1);
    END
    ELSE
    BEGIN
        INSERT INTO Auth.AccountActivation
            (Email, SecurityCode, RoleID)
        VALUES
            (@Email, @SecurityCode, @RoleID);
    END
END;
