-- Drop tables if they exist
IF OBJECT_ID('Doctor.FollowupReferral', 'U') IS NOT NULL DROP TABLE Doctor.FollowupReferral;
IF OBJECT_ID('Doctor.ClinicalRecords', 'U') IS NOT NULL DROP TABLE Doctor.ClinicalRecords;
IF OBJECT_ID('Clerk.Appointment', 'U') IS NOT NULL DROP TABLE Clerk.Appointment;
IF OBJECT_ID('Clerk.DocTimeSlot', 'U') IS NOT NULL DROP TABLE Clerk.DocTimeSlot;
IF OBJECT_ID('Clerk.TimeSlot', 'U') IS NOT NULL DROP TABLE Clerk.TimeSlot;
IF OBJECT_ID('Employee.Doctor', 'U') IS NOT NULL DROP TABLE Employee.Doctor;
IF OBJECT_ID('Employee.Clerk', 'U') IS NOT NULL DROP TABLE Employee.Clerk;
IF OBJECT_ID('Patient.MedicalProfile', 'U') IS NOT NULL DROP TABLE Patient.MedicalProfile;
IF OBJECT_ID('Patient.Patient', 'U') IS NOT NULL DROP TABLE Patient.Patient;

-- Create schemas if they don't exist
IF NOT EXISTS (SELECT *
FROM sys.schemas
WHERE name = 'Patient')
BEGIN
    EXEC('CREATE SCHEMA Patient')
END

IF NOT EXISTS (SELECT *
FROM sys.schemas
WHERE name = 'Employee')
BEGIN
    EXEC('CREATE SCHEMA Employee')
END

IF NOT EXISTS (SELECT *
FROM sys.schemas
WHERE name = 'Doctor')
BEGIN
    EXEC('CREATE SCHEMA Doctor')
END

IF NOT EXISTS (SELECT *
FROM sys.schemas
WHERE name = 'Clerk')
BEGIN
    EXEC('CREATE SCHEMA Clerk')
END

-- Create tables
CREATE TABLE Patient.Patient
(
    PatientID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    PatientFullName VARCHAR(100) NOT NULL,
    PatientEmail VARCHAR(255) UNIQUE NOT NULL,
    IC VARCHAR(12) NOT NULL,
    DOB DATE NOT NULL,
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('F','M')),
    PatientPhoneNum VARCHAR(15) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    MedicalInsuranceProvider VARCHAR(100) DEFAULT '-NA-'
);

CREATE TABLE Patient.MedicalProfile
(
    MedicalProfileID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    PatientID INT FOREIGN KEY REFERENCES Patient.Patient(PatientID) NOT NULL,
    BloodType CHAR(3) NOT NULL,
    Height DECIMAL(5, 2) NOT NULL,
    Weight DECIMAL(5, 2) NOT NULL,
    Allergies VARCHAR(255) DEFAULT 'No Allergies',
    ChronicCondition VARCHAR(255) DEFAULT 'No Conditions'
);

CREATE TABLE Employee.Clerk
(
    ClerkID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    ClerkName VARCHAR(50) NOT NULL,
    ClerkEmail VARCHAR(255) UNIQUE NOT NULL,
    ClerkPhoneNum VARCHAR(15)NOT NULL
);

CREATE TABLE Employee.Doctor
(
    DoctorID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    DoctorName VARCHAR(50) NOT NULL,
    DoctorEmail VARCHAR(255) UNIQUE NOT NULL,
    DoctorPhoneNum VARCHAR(15) NOT NULL,
    DepartmentName VARCHAR(50) NOT NULL
);

CREATE TABLE Clerk.TimeSlot
(
    TimeSlotID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    Date DATE NOT NULL,
    Time TIME NOT NULL
);

CREATE TABLE Clerk.DocTimeSlot
(
    DocTimeSlotID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    DoctorID INT FOREIGN KEY REFERENCES Employee.Doctor(DoctorID) NOT NULL,
    TimeSlotID INT FOREIGN KEY REFERENCES Clerk.TimeSlot(TimeSlotID) NOT NULL,
    DTSAvailability BIT NOT NULL,
    Reason VARCHAR(255)
);

CREATE TABLE Clerk.Appointment
(
    AppointmentID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    DocTimeSlotID INT NOT NULL FOREIGN KEY REFERENCES Clerk.DocTimeSlot(DocTimeSlotID),
    PatientID INT NOT NULL FOREIGN KEY REFERENCES Patient.Patient(PatientID),
    Status VARCHAR(20) NOT NULL CHECK (Status in ('Scheduled', 'Completed', 'Rescheduled')),
    Purpose VARCHAR(50) NOT NULL,
    ClerkID INT NOT NULL FOREIGN KEY REFERENCES Employee.Clerk(ClerkID)
);

CREATE TABLE Doctor.ClinicalRecords
(
    RecordID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    AppointmentID INT NOT NULL FOREIGN KEY REFERENCES Clerk.Appointment(AppointmentID),
    Diagnosis VARCHAR(255) NOT NULL,
    TreatmentPlan VARCHAR(255),
    Medications VARCHAR(255),
    Notes VARCHAR(255),
    CreatedTimestamp DATETIME NOT NULL
);

CREATE TABLE Doctor.FollowupReferral
(
    ReferralID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    Date DATE NOT NULL,
    Time TIME NOT NULL,
    Status VARCHAR(20) NOT NULL CHECK (Status in ('Pending', 'Scheduled')),
    Purpose VARCHAR(50) NOT NULL,
    AppointmentID INT NOT NULL FOREIGN KEY REFERENCES Clerk.Appointment(AppointmentID),
);

-- Data insertion
-- Patient
-- INSERT ONLY FOR PLACEHOLDER PURPOSES (EXCEPT EMPLOYEE SCHEMA)
INSERT INTO Patient.Patient
VALUES
    ('James Smith', 'jsmith@outlook.com', '981231012255', '1998-12-31', 'M', '0132244859', 'L9-1, Solstice, Persiaran Bestari, Cyber 11, 63000 Cyberjaya, Selangor', 'AIA'),
    ('Samantha Lee', 'slee@gmail.com', '700124163322', '1970-01-24', 'F', '0123344879', '30, Lakefront, Persiaran Semarak Api, 63000 Cyberjaya, Selangor', NULL),
    ('Aarav Ramesh', 'aaravram@yahoo.com', '520701056011', '1957-07-01', 'M', '0150232151', '230, Mt Jade, Jln SBJ 2, 70200 Seremban, Negeri Sembilan', 'Allianz'),
    ('Wang Wei Ling', 'weiling36@gmail.com', '8409012258', '1984-09-01', 'F', '0173331149', '5, Jalan Kampung Maju Jaya, Kg Maju Jaya, 81300 Johor Bahru, Johor', 'AIA'),
    ('Muhammad Hakim', 'muakim1@yahoo.com', '900203012335', '1990-02-03', 'M', '0192304888', '99 Serin Residency, Jln Fauna 1, Cyberjaya, 63000 Cyberjaya, Selangor', NULL);

SELECT *
FROM Patient.Patient;

-- Medical profile
INSERT INTO Patient.MedicalProfile
VALUES
    (1, 'A-', 170.3, 79.5, 'Penicillin', 'Hypertension'),
    (2, 'O+', 160.0, 55.4, NULL, 'Asthma'),
    (3, 'B+', 180.25, 80.00, NULL, 'Diabetes'),
    (4, 'B+', 165.8, 60.00, 'Peanuts, Seafood', 'Asthma'),
    (5, 'A-', 170.9, 72.00, 'Aspirin', 'Diabetes');

SELECT *
FROM Patient.MedicalProfile;

-- Clerk
INSERT INTO Employee.Clerk
VALUES
    ('Aminah Binti Sulaiman', 'aminah34@radiummedical.com', '0132234567'),
    ('Tee Chun Hao', 'chunhao08@radiummedical.com', '0123345566'),
    ('Ravi Shankar', 'ravis@radiummedical.com', '0127768323');

SELECT *
FROM Employee.Clerk;

-- Doctor
INSERT INTO Employee.Doctor
    (DoctorName, DoctorEmail, DoctorPhoneNum, DepartmentName)
VALUES
    ('Farah Ahmad', 'faraha@radiummedical.com', '0195557788', 'Cardiology'),
    ('Chin Wei Jie', 'weicj@radiummedical.com', '0186677889', 'Endocrinology'),
    ('Davis Jacob', 'jdavis@radiummedical.com', '0186677889', 'Endocrinology');

SELECT *
FROM Employee.Doctor;

-- TimeSlot
INSERT INTO Clerk.TimeSlot
VALUES
    ('2024-12-11', '09:00:00'),
    ('2024-12-11', '10:00:00'),
    ('2024-12-21', '09:00:00'),
    ('2024-12-21', '10:00:00'),
    ('2025-01-07', '09:00:00'),
    ('2025-01-07', '10:00:00'),
    ('2025-01-07', '09:00:00'),
    ('2025-01-07', '10:00:00');

SELECT *
FROM Clerk.TimeSlot;

-- DocTimeSlot
INSERT INTO Clerk.DocTimeSlot
    (DoctorID, TimeSlotID, DTSAvailability, Reason)
VALUES
    (1, 1, 1, ''),
    (2, 1, 1, ''),
    (3, 1, 1, ''),
    (1, 2, 1, ''),
    (2, 2, 1, ''),
    (3, 2, 1, ''),
    (1, 3, 1, ''),
    (2, 3, 1, ''),
    (3, 3, 1, ''),
    (1, 4, 1, ''),
    (2, 4, 1, ''),
    (3, 4, 1, ''),
    (1, 5, 0, 'Annual Leave'),
    (2, 5, 1, ''),
    (3, 5, 1, ''),
    (1, 6, 0, 'Annual Leave'),
    (2, 6, 1, ''),
    (3, 6, 1, '');

SELECT *
FROM Clerk.DocTimeSlot;

-- view timeslot (date & time) for each doctor
SELECT
    Clerk.DocTimeSlot.DocTimeSlotID,
    Employee.Doctor.DoctorName,
    Employee.Doctor.DepartmentName,
    Clerk.TimeSlot.Date,
    Clerk.TimeSlot.Time
FROM
    Employee.Doctor
    INNER JOIN
    Clerk.DocTimeSlot ON Employee.Doctor.DoctorID = Clerk.DocTimeSlot.DoctorID
    INNER JOIN
    Clerk.TimeSlot ON Clerk.DocTimeSlot.TimeSlotID = Clerk.TimeSlot.TimeSlotID;


-- Appointment
INSERT INTO Clerk.Appointment
VALUES
    (1, 1, 'Completed', 'Cardiology consultation', 1),
    -- Hypertension
    (16, 1, 'Scheduled', 'Cardiology follow-up', 1),
    -- Hypertension
    (2, 5, 'Completed', 'Endocrinology consultation', 2),
    -- Diabetes
    (5, 3, 'Completed', 'Endocrinology consultation', 1),
    -- Diabetes
    (14, 3, 'Scheduled', 'Endocrinology follow-up', 2),
    -- Diabetes
    (3, 4, 'Completed', 'Pulmonology consultation', 3),
    -- Asthma
    (8, 5, 'Scheduled', 'Endocrinology consultation', 2),
    -- Diabetes
    (15, 2, 'Scheduled', 'Pulmonology consultation', 3);
-- Asthma

SELECT
    A.*,
    TS.Date,
    TS.Time
FROM
    Clerk.Appointment A
    JOIN
    Clerk.DocTimeSlot DTS ON A.DocTimeSlotID = DTS.DocTimeSlotID
    JOIN
    Clerk.TimeSlot TS ON DTS.TimeSlotID = TS.TimeSlotID;

-- ClinicalRecord
INSERT INTO Doctor.ClinicalRecords
VALUES
    (1, 'Hypertension', 'Regular BP monitoring', 'Amlodipine', 'Hypertension consultation. Patient requires follow up.', '2024-12-11'),
    (3, 'Diabetes', 'Diet control and insulin therapy', 'Insulin', 'Patient reported frequent hyperglycemia.', '2024-12-11'),
    (4, 'Diabetes', 'Glycemic control improvement', 'Metformin', 'Patient requires regular follow-ups.', '2024-12-11'),
    (6, 'Asthma', 'Asthma action plan and inhaler usage', 'Salbutamol inhaler', 'Patient has mild persistent asthma.', '2024-12-11');


-- FollowupReferral
INSERT INTO Doctor.FollowupReferral
VALUES
    ('2025-01-07', '10:00:00', 'Scheduled', 'Cardiology follow-up for BP assessment', 1),
    ('2025-01-07', '09:00:00', 'Scheduled', 'Endocrinology follow-up for diabetes monitoring', 4);
