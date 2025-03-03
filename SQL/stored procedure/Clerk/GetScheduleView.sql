IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetScheduleView')
    DROP PROCEDURE [Clerk].[GetScheduleView]
GO

CREATE PROCEDURE [Clerk].[GetScheduleView]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        a.AppointmentID,
        a.DocTimeSlotID,
        FORMAT(ts.[Date], 'yyyy-MM-dd') as Date,
        CASE 
            WHEN ts.Time = '09:00:00' THEN '9:00 AM'
            WHEN ts.Time = '10:00:00' THEN '10:00 AM'
            WHEN ts.Time = '11:00:00' THEN '11:00 AM'
            WHEN ts.Time = '14:00:00' THEN '2:00 PM'
            WHEN ts.Time = '15:00:00' THEN '3:00 PM'
            WHEN ts.Time = '16:00:00' THEN '4:00 PM'
            ELSE CONVERT(varchar, ts.[Time], 100)
        END as Time,
        a.PatientID,
        p.PatientFullName as PatientName,
        d.DoctorName,
        a.Status,
        a.Purpose,
        a.ClerkID,
        c.ClerkName
    FROM 
        [Clerk].[Appointment] a
        INNER JOIN [Patient].[Patient] p ON a.PatientID = p.PatientID
        INNER JOIN [Clerk].[DocTimeSlot] dts ON a.DocTimeSlotID = dts.DocTimeSlotID
        INNER JOIN [Clerk].[TimeSlot] ts ON dts.TimeSlotID = ts.TimeSlotID
        INNER JOIN [Employee].[Doctor] d ON dts.DoctorID = d.DoctorID
        INNER JOIN [Employee].[Clerk] c ON a.ClerkID = c.ClerkID
    ORDER BY 
        ts.[Date], ts.[Time] ASC;
END
