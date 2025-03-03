IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetReferralView' AND schema_id = SCHEMA_ID('Clerk'))
    DROP PROCEDURE [Clerk].[GetReferralView]
GO

CREATE PROCEDURE [Clerk].[GetReferralView]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        fr.ReferralID,
        CONVERT(varchar, fr.[Date], 23) as [Date],
        CONVERT(varchar(8), fr.[Time], 108) as [Time],
        fr.Status,
        fr.Purpose
    FROM 
        Doctor.FollowupReferral fr
    ORDER BY 
        fr.[Date] DESC, fr.[Time] DESC;
END;
