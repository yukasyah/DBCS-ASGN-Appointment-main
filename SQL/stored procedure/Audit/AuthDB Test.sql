-- Generate New Security Code if security code expired
EXEC Emp.GenerateNewSecurityCode 
@Email ='chunhao08@radiummedical.com',
@NewSecurityCode = 'XkzIkUZ0cwERRF1';

INSERT INTO Auth.AccountRole
VALUES
    ('Admin');

DELETE FROM Auth.AccountRole
WHERE RoleName = 'Admin';