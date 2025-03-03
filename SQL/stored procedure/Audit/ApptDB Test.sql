UPDATE Employee.Doctor
SET DoctorName = 'Farah Ahmadx'
WHERE DoctorEmail = 'faraha@radiummedical.com';

UPDATE Employee.Doctor
SET DoctorName = 'Farah Ahmad'
WHERE DoctorEmail = 'faraha@radiummedical.com';

INSERT INTO Employee.Clerk
VALUES
    ('myname', 'myname@radiummedical.com', '0127768443');

DELETE FROM Employee.Clerk
WHERE ClerkEmail = 'myname@radiummedical.com';