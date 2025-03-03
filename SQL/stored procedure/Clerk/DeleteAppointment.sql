IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'DeleteAppointment')
    DROP PROCEDURE [Clerk].[DeleteAppointment]
GO

CREATE PROCEDURE [Clerk].[DeleteAppointment]
    @AppointmentID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DocTimeSlotID INT;
    SELECT @DocTimeSlotID = DocTimeSlotID 
    FROM [Clerk].[Appointment] 
    WHERE AppointmentID = @AppointmentID;

    IF @DocTimeSlotID IS NULL
    BEGIN
        SELECT 'Error' as Result, 'Appointment not found' as Message;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
            DELETE FROM [Doctor].[FollowupReferral]
            WHERE AppointmentID = @AppointmentID;

            DELETE FROM [Doctor].[ClinicalRecords]
            WHERE AppointmentID = @AppointmentID;

            DELETE FROM [Clerk].[Appointment]
            WHERE AppointmentID = @AppointmentID;

            -- Reset the doctor time slot availability to make it available again
            UPDATE [Clerk].[DocTimeSlot]
            SET DTSAvailability = 1
            WHERE DocTimeSlotID = @DocTimeSlotID;

            -- Check if delete was successful
            IF @@ROWCOUNT > 0
            BEGIN
                COMMIT TRANSACTION;
                SELECT 'Success' as Result, 'Appointment deleted successfully' as Message;
            END
            ELSE
            BEGIN
                ROLLBACK TRANSACTION;
                SELECT 'Error' as Result, 'Failed to delete appointment' as Message;
            END
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 'Error' as Result, ERROR_MESSAGE() as Message;
    END CATCH
END