-- Create a view in the Doctor schema that aggregates appointment data
CREATE VIEW Doctor.AppointmentDetails AS
SELECT 
    A.AppointmentID,
    P.PatientFullName,
    TS.Date AS AppointmentDate,
    TS.Time AS AppointmentTime,
    DTS.DoctorID
FROM 
    Clerk.Appointment A
JOIN 
    Clerk.DocTimeSlot DTS ON A.DocTimeSlotID = DTS.DocTimeSlotID
JOIN 
    Clerk.TimeSlot TS ON DTS.TimeSlotID = TS.TimeSlotID
JOIN 
    Patient.Patient P ON A.PatientID = P.PatientID
WHERE
    A.Status = 'Scheduled';

-- run this
-- GRANT SELECT ON Doctor.AppointmentDetails TO DoctorRole;
