-- Dynamic Authentication
CREATE PROCEDURE Auth.AuthenticateUser
    @Email VARCHAR(255),
    @RoleID INT
AS
BEGIN
    DECLARE @UserID INT, @Password VARCHAR(255), @StoredRoleID INT, @StoredEmail VARCHAR(255);

    SELECT @UserID = u.UserID, @Password = u.Password, @StoredRoleID = u.RoleID, @StoredEmail = u.Email
    FROM Auth.UserAccount u
    WHERE u.Email = @Email;

    IF @UserID IS NOT NULL
    BEGIN
        IF @StoredRoleID = @RoleID
        BEGIN
            SELECT @UserID AS UserID, @Password AS Password, @StoredRoleID AS RoleID, @StoredEmail AS Email;
        END
        ELSE
        BEGIN
            SELECT 'Invalid role for this user' AS ErrorMessage;
        END
    END
    ELSE
    BEGIN
        SELECT 'Invalid credentials' AS ErrorMessage;
    END
END;
