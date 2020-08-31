--extended function of dbo.FNAConvertTimezone to get offset

IF OBJECT_ID(N'FNAGetUTCTimeWithOffset', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNAGetUTCTimeWithOffset]
GO 

CREATE FUNCTION [dbo].[FNAGetUTCTimeWithOffset]
(
	@datetime  DATETIME = NULL,
	@tz_from   INT = NULL
)
RETURNS VARCHAR(25)
AS
BEGIN
	
    DECLARE @hr INT, @min INT, @min_string VARCHAR(2)
    DECLARE @tz VARCHAR(6), @user_tz VARCHAR(19)

	IF @tz_from IS NULL BEGIN
		SELECT @tz_from = timezone_id FROM application_users a WHERE a.user_login_id =  dbo.FNADBUser()  
	END
	
    select @user_tz = CONVERT(VARCHAR(19), (dbo.FNAGetUTCTTime(ISNULL(@datetime, GETDATE()), @tz_from)), 127)

    SELECT @hr = tz.OFFSET_HR, @min = tz.OFFSET_MI FROM time_zones tz 
    INNER JOIN application_users a ON tz.timezone_id = a.timezone_id
    WHERE a.user_login_id = dbo.FNADBUser()
    
	--SELECT @hr = tz.OFFSET_HR, @min = tz.OFFSET_MI FROM time_zones tz WHERE tz.timezone_id = 14 --utc

    SET @min_string = CAST(@min AS VARCHAR(2))
    SET @tz = CASE WHEN @hr >= 0 THEN '+' + CAST(@hr AS VARCHAR(2)) ELSE CAST(@hr AS VARCHAR(3)) END + ':' +
              CASE WHEN LEN(@min_string) < 2 THEN @min_string + '0' ELSE @min_string END

    RETURN @user_tz + @tz 
END


















