CREATE PROCEDURE Doctor.GetCompletedAppointments
    @DoctorID INT
AS
BEGIN
    DECLARE @StartDate DATE, @EndDate DATE;

    SET @StartDate = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);

    SET @EndDate = EOMONTH(GETDATE());

    SELECT 
        COUNT(*) AS TotalCompletedAppointments
    FROM 
        Clerk.Appointment AS a
    JOIN 
        Clerk.DocTimeSlot AS dts ON a.DocTimeSlotID = dts.DocTimeSlotID
    JOIN
        Clerk.TimeSlot AS ts ON dts.TimeSlotID = ts.TimeSlotID
    WHERE 
        dts.DoctorID = @DoctorID
        AND a.Status = 'Completed'
        AND ts.Date BETWEEN @StartDate AND @EndDate;
END
