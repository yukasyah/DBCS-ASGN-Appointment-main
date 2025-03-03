-- Add to user account
CREATE PROCEDURE Auth.InsertUserAccount
    @Email VARCHAR(255),
    @Password VARCHAR(255),
    @RoleID INT,
    @IsActive BIT,
    @CreatedAt DATETIME,
    @UpdatedAt DATETIME
AS
BEGIN
    INSERT INTO Auth.UserAccount (Email, Password, RoleID, IsActive, CreatedAt, UpdatedAt)
    VALUES (@Email, @Password, @RoleID, @IsActive, @CreatedAt, @UpdatedAt);
END;