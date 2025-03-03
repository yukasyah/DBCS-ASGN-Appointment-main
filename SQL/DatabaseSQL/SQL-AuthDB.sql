-- Drop tables if they exist
IF OBJECT_ID('Auth.UserAccount', 'U') IS NOT NULL DROP TABLE Auth.UserAccount;
IF OBJECT_ID('Emp.AccountActivation', 'U') IS NOT NULL DROP TABLE Emp.AccountActivation;
IF OBJECT_ID('Auth.AccountRole', 'U') IS NOT NULL DROP TABLE Auth.AccountRole;

-- Create schemas if they don't exist
IF NOT EXISTS (SELECT *
FROM sys.schemas
WHERE name = 'Auth')
BEGIN
    EXEC('CREATE SCHEMA Auth')
END

IF NOT EXISTS (SELECT *
FROM sys.schemas
WHERE name = 'Emp')
BEGIN
    EXEC('CREATE SCHEMA Emp')
END

-- Table Creation
CREATE TABLE Auth.AccountRole
(
    RoleID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    RoleName VARCHAR(50) NOT NULL
)

CREATE TABLE Emp.AccountActivation
(
    PendingID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    SecurityCode CHAR(16) NOT NULL,
    IsUsed BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    ExpiryAt DATETIME NOT NULL DEFAULT DATEADD(DAY, 1, GETDATE()),
    RoleID INT FOREIGN KEY REFERENCES Auth.AccountRole(RoleID) NOT NULL
)

CREATE TABLE Auth.UserAccount
(
    UserID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL,
    RoleID INT FOREIGN KEY REFERENCES Auth.AccountRole(RoleID),
    IsActive BIT NOT NULL,
    CreatedAt DATETIME NOT NULL,
    UpdatedAt DATETIME NOT NULL
)

-- Data Insertion
-- Role
INSERT INTO Auth.AccountRole
VALUES
    ('Doctor'),
    ('Clerk'),
    ('Patient');

INSERT INTO Auth.AccountActivation
    (Email, SecurityCode, RoleID)
VALUES
    ('faraha@radiummedical.com', '7IcpARXIamwTEKN8', 1),
    ('weicj@radiummedical.com', 'vVmHVzVr7dESVpQd', 1),
    ('jdavis@radiummedical.com', 'QPsY692hcdw6Gn6X', 1),
    ('aminah34@radiummedical.com', 'tUf4nY6sKFb7W7R2', 2),
    ('chunhao08@radiummedical.com', 'hai7NXnC7Tmc18A7', 2),
    ('ravis@radiummedical.com', 'whL07a0aVtsTilfD', 2);

select *
from Auth.UserAccount;