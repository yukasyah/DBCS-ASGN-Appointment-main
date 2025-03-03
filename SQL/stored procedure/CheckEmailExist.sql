CREATE PROCEDURE Auth.CheckEmailExists
    @Email VARCHAR(255)
AS
BEGIN
    -- Return the count of users with the given email
    SELECT COUNT(*) AS count
    FROM [Auth].[UserAccount]
    WHERE Email = @Email;
END