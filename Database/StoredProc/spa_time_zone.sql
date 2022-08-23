SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Get timezone

	Parameters 
	@flag :  Operation flag that decides the action to be performed. Does not accept NULL.
		's' : select all time zone
		'c' : Convert local time to UTC time
	@localtime : Date to be converted

*/
CREATE OR ALTER PROC [dbo].[spa_time_zone]
	@flag CHAR(1)
	, @localtime DATETIME = NULL

AS
BEGIN
	IF @flag='s'
	BEGIN
		SELECT NULL, NULL		
		UNION ALL		
		SELECT 
			 timezone_id,timezone_name 
		FROM 
			[TIME_ZONES]
	END

	ELSE IF @flag='c'
	BEGIN 
		DECLARE @default_code_value INT
		SELECT  @default_code_value = [dbo].[FNAGetDefaultCodeValue](36, 1) --system_time_zone id
		
		SELECT dbo.FNAGetUTCTTime( @localtime, @default_code_value) [utc_time] 
	END
END
