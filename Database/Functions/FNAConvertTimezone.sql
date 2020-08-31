IF OBJECT_ID('[dbo].[FNAConvertTimezone]','fn') IS NOT NULL 
DROP FUNCTION [dbo].[FNAConvertTimezone]
GO 

CREATE FUNCTION [dbo].[FNAConvertTimezone] (
	@DATE AS DATETIME,
	@convert_from INT=0 -- 0- convert to user time, 1- convert to server time
)
RETURNS DATETIME
AS
BEGIN

	DECLARE @time_zone_from AS INT
	DECLARE @time_zone_to AS INT
	DECLARE @NEWDATE DATETIME

	-- Find Out System Defined Time Zone
	SELECT @time_zone_from= var_value
	FROM         
			adiha_default_codes_values
	WHERE     
			(instance_no = 1) AND (default_code_id = 36) AND (seq_no = 1)


	SELECT @time_zone_to=timezone_id from application_users where user_login_id=dbo.FNAdbuser()

	IF @time_zone_to IS NULL
		SET @time_zone_to=@time_zone_from

	

	-- Check to see if the provided timezone for the source datetime is in GMT or UTC time
	-- If it is not then convert the provided datetime to UTC time
	IF NOT @time_zone_from IN (13)
	BEGIN
		IF @convert_from=0
			SELECT @NEWDATE = dbo.FNAGetUTCTTime(@Date,@time_zone_from)
		ELSE
			SELECT @NEWDATE = dbo.FNAGetUTCTTime(@Date,@time_zone_to)		
	END
	ELSE
	-- If the provided datetime is in UTC or GMT time then set the NEWTIME variable to this value
	BEGIN
		SET @NEWDATE = @Date
	END

	-- Check to see if the provided conversion timezone is GMT or UTC
	-- If it is then no conversion is needed.
	-- If it is not then convert the provided datetime to the desired timezone
	IF NOT @time_zone_to IN (13)
	BEGIN
		IF @convert_from=0
			SELECT @NEWDATE = dbo.FNAGetLOCALTime(@NEWDATE,@time_zone_to)
		ELSE
			SELECT @NEWDATE = dbo.FNAGetLOCALTime(@NEWDATE,@time_zone_from)
	END


	-- Return the new date that has been converted from UTC time
	RETURN @NEWDATE
END



