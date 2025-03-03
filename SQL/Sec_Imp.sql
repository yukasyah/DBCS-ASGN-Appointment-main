-- 1. Isolation of authentication information
/*
ApptDB - SQL-ApptDB.txt
AuthDB - SQL-AuthDB.txt
*/



-- 2. Change of Ownership

/*
---Prerequisite---
Databases: ApptDB, AuthDB
User Login: R_APPTDB_O, R_AUTHDB_O
*/

-- Change ApptDB dbo to a new owner
SELECT name, suser_sname(owner_sid) AS OWNER
FROM sys.databases
WHERE name = 'ApptDB';

ALTER AUTHORIZATION ON DATABASE::[ApptDB] TO [R_APPTDB_O];

SELECT name, suser_sname(owner_sid) AS OWNER
FROM sys.databases
WHERE name = 'ApptDB';

-- Change AuthDB dbo to a new owner
SELECT name, suser_sname(owner_sid) AS OWNER
FROM sys.databases
WHERE name = 'AuthDB';

ALTER AUTHORIZATION ON DATABASE::[AuthDB] TO [R_AUTHDB_O];

SELECT name, suser_sname(owner_sid) AS OWNER
FROM sys.databases
WHERE name = 'AuthDB';

-- 3. Role Creation
--- ApptDB ---
CREATE ROLE DoctorRole;
CREATE ROLE ClerkRole;
CREATE ROLE EmployeeRole;
CREATE ROLE PatientRole;

-- EmployeeRole
GRANT EXECUTE ON SCHEMA::Employee TO EmployeeRole;

-- DoctorRole
GRANT EXECUTE ON SCHEMA::Doctor TO DoctorRole;

-- ClerkRole
GRANT EXECUTE ON SCHEMA::Clerk TO ClerkRole;

-- PatientRole
GRANT EXECUTE ON SCHEMA::Patient TO PatientRole;

--- AuthDB ---
CREATE ROLE NotEmpRole;
CREATE ROLE EmpRole

GRANT EXECUTE ON SCHEMA::Auth TO NotEmpRole;
GRANT EXECUTE ON SCHEMA::Auth TO EmpRole;
GRANT EXECUTE ON SCHEMA::Emp TO EmpRole;



-- 4. Encryption Metadata
--TDE(do for both db)

--create master  key
USE Master; 
GO
CREATE MASTER KEY ENCRYPTION 
BY PASSWORD='key'; 
GO

--create cert
CREATE CERTIFICATE TDE_Cert 
WITH 
SUBJECT='Database_Encryption'; 
GO

--creating db encryption key
USE AuthDB 
GO 
CREATE DATABASE ENCRYPTION KEY 
WITH ALGORITHM = AES_256 
ENCRYPTION BY SERVER CERTIFICATE TDE_Cert; 
GO

--Turning On  TDE
ALTER DATABASE AuthDB 
SET ENCRYPTION ON; 
GO


-- make sure FILE EXIST (backing up cert)
BACKUP CERTIFICATE TDE_Cert 
TO FILE = 'C:\temp\TDE_Cert' 
WITH PRIVATE KEY (file='C:\temp\TDE_CertKey.pvk',
ENCRYPTION BY PASSWORD='key') 

-- TO USE BACKUP(create a new master key on another db)
USE Master; 
GO 
CREATE MASTER KEY ENCRYPTION BY PASSWORD='key'; 
GO

USE MASTER 
GO 
CREATE CERTIFICATE TDECert 
FROM FILE = 'C:\temp\TDE_Cert' 
WITH PRIVATE KEY (FILE = 'C:\temp\TDE_CertKey.pvk',
DECRYPTION BY PASSWORD = 'key' );


--TO CHECK IF DB IS ENCRYPTED--
SELECT
    db.name,
    db.is_encrypted,
    dm.encryption_state,
    dm.percent_complete,
    dm.key_algorithm,
    dm.key_length
FROM
    sys.databases db
    LEFT OUTER JOIN sys.dm_database_encryption_keys dm
        ON db.database_id = dm.database_id;
GO



------
--5. Securable Metadata---
--Code Signing
--ApptDB

--create master  key(if dont already have)
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'ApptDB';
GO

USE ApptDB;
GO

CREATE CERTIFICATE SchemaSigningCertificate
WITH SUBJECT = 'Certificate for Signing Stored Procedures'

ADD SIGNATURE TO OBJECT::[Patient].[InsertPatient]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Clerk].[DeleteAppointment]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Clerk].[GetAvailableDoctors]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Clerk].[GetAvailableDoctorsList]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Clerk].[GetDoctorTimeSlots]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Clerk].[GetNewPatients]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Clerk].[GetReferralView]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Clerk].[GetScheduleView]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Clerk].[GetTotalAppointments]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Clerk].[GetTotalRegisteredPatients]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Clerk].[ScheduleAppointment]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Patient].[GetMedicalRecords]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Patient].[GetPastAppointments]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Patient].[GetPatientDetails]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Patient].[GetPatientHealthData]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Patient].[GetUpcomingAppointments]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Patient].[InsertMedicalProfile]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Patient].[UpdatePatientProfile]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Doctor].[CheckFollowUpReferral]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Doctor].[CompleteAppointment]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Doctor].[CreateFollowUpReferral]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Doctor].[GetAppointmentDetails]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Doctor].[GetAppointmentsForDoctor]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Doctor].[GetCompletedAppointments]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Employee].[GetDoctorDetails]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Doctor].[GetDoctorIdByEmail]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Doctor].[GetRecentCompletedAppt]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE TO OBJECT::[Doctor].[SaveClinicalRecord]
BY CERTIFICATE [SchemaSigningCertificate];




---AuthDB---

---create master  key(if dont already have)
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'AuthDB';
GO

USE AuthDB;
GO

CREATE CERTIFICATE SchemaSigningCertificate
WITH SUBJECT = 'Certificate for Signing Stored Procedures'


ADD SIGNATURE
TO [Auth].[AuthenticateUser]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE
TO [Auth].[CheckAccountActivation]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE
TO [Auth].[CheckEmailExists]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE
TO [Auth].[InsertUserAccount]
BY CERTIFICATE [SchemaSigningCertificate];

ADD SIGNATURE
TO [Auth].[UpdateActivationCode]
BY CERTIFICATE [SchemaSigningCertificate];


--TO CHECK IF PROCEDURE SIGNED OR NOT--

DECLARE @thumbprint VARBINARY(20) ;
SET @thumbprint =
(
SELECT thumbprint
FROM sys.certificates
WHERE name LIKE '%SchemaSigningCertificate%'
) ;
SELECT entity_id
, SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(entity_id) AS
ProcedureName
, is_signed
, is_signature_valid
FROM sys.fn_check_object_signatures ('certificate', @thumbprint) cos
INNER JOIN sys.objects o
ON cos.entity_id = o.object_id
WHERE cos.type = 'SQL_STORED_PROCEDURE' ;
GO
---------

-- 6. db backup encryption 
-- apptDB 
USE master;
CREATE CERTIFICATE ApptDBBackupEncryptionCert
WITH SUBJECT = 'ApptDB Backup Encryption Certificate';
GO

BACKUP CERTIFICATE ApptDBBackupEncryptionCert
TO FILE = 'C:\Certificates\ApptDBBackupEncryptionCert.cer'
WITH PRIVATE KEY (
    FILE = 'C:\Keys\ApptDBBackupEncryptionCertPrivateKey.pvk',
    ENCRYPTION BY PASSWORD = 'Pa$$w0rd');

BACKUP DATABASE [ApptDB] TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\ApptDB_LogBackup_2025-01-04_11-06-15.bak' WITH FORMAT, INIT,  MEDIANAME = N'ApptDBEncrypted',  NAME = N'ApptDB-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, ENCRYPTION(ALGORITHM = AES_256, SERVER CERTIFICATE = [ApptDBBackupEncryptionCert]),  STATS = 10
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'ApptDB' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'ApptDB' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''ApptDB'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\ApptDB_LogBackup_2025-01-04_11-06-15.bak' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO

-- authDB
USE master;
CREATE CERTIFICATE AuthDBBackupEncryptionCert
WITH SUBJECT = 'AuthDB Backup Encryption Certificate';
GO

BACKUP CERTIFICATE AuthDBBackupEncryptionCert
TO FILE = 'C:\Certificates\AuthDBBackupEncryptionCert.cer'
WITH PRIVATE KEY (
    FILE = 'C:\Keys\AuthDBBackupEncryptionCertPrivateKey.pvk',
    ENCRYPTION BY PASSWORD = 'Pa$$w0rd');

BACKUP DATABASE [AuthDB] TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\AuthDB.bak' WITH FORMAT, INIT,  MEDIANAME = N'AuthDBEncrypted',  NAME = N'AuthDB-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, ENCRYPTION(ALGORITHM = AES_256, SERVER CERTIFICATE = [AuthDBBackupEncryptionCert]),  STATS = 10
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'AuthDB' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'AuthDB' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''AuthDB'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\AuthDB.bak' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO

---------------------------------------------------------------------------

-- 7. audit
-- server audit (R01 Login Audit)
USE [master]
GO
CREATE SERVER AUDIT [R01 Login Audit]
TO FILE 
(	FILEPATH = N'C:\SQLAudit\'
	,MAXSIZE = 256 MB
	,MAX_ROLLOVER_FILES = 2147483647
	,RESERVE_DISK_SPACE = OFF
) WITH (QUEUE_DELAY = 1000, ON_FAILURE = CONTINUE)
GO

-- server audit specification (ServerLoginAudit)
USE [master]
GO
CREATE SERVER AUDIT SPECIFICATION [ServerLoginAudit]
FOR SERVER AUDIT [R01 Login Audit]
ADD (FAILED_LOGIN_GROUP)
GO

-- enable server audit & spec
USE [master]
GO
ALTER SERVER AUDIT [R01 Login Audit] 
WITH (STATE = ON)
GO

USE [master]
GO
ALTER SERVER AUDIT SPECIFICATION [ServerLoginAudit] 
WITH (STATE = ON)
GO

-- db audit specification
USE [ApptDB]
GO
CREATE DATABASE AUDIT SPECIFICATION [R03 ApptDBAudit]
FOR SERVER AUDIT [R01 Login Audit]
ADD (INSERT ON DATABASE::[ApptDB] BY [db_owner]),
ADD (DELETE ON DATABASE::[ApptDB] BY [db_owner]),
ADD (UPDATE ON DATABASE::[ApptDB] BY [db_owner])
GO

USE [AuthDB]
GO
CREATE DATABASE AUDIT SPECIFICATION [R02 AuthDBAudit]
FOR SERVER AUDIT [R01 Login Audit]
ADD (INSERT ON DATABASE::[AuthDB] BY [db_owner]),
ADD (DELETE ON DATABASE::[AuthDB] BY [db_owner]),
ADD (UPDATE ON DATABASE::[AuthDB] BY [db_owner])
GO

USE [ApptDB]
GO
ALTER DATABASE AUDIT SPECIFICATION [R03 ApptDBAudit]
WITH (STATE = ON)
GO

USE [AuthDB]
GO
ALTER DATABASE AUDIT SPECIFICATION [R02 AuthDBAudit]
WITH (STATE = ON)
GO







