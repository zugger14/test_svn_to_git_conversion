IF OBJECT_ID('dbo.FNAPlattsDate','FN') IS NOT NULL
DROP FUNCTION dbo.FNAPlattsDate
GO
/*
	Author : Vishwas Khanal
	Dated  : 01.25.2009
	Description : This function is used to find the date when the import process is in schedule.
*/
CREATE FUNCTION dbo.FNAPlattsDate
(	
	@flag CHAR(1) = NULL
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @date DATETIME  ,
			@date_y DATETIME,
			@date_d DATETIME
			
	SELECT @date = CONVERT(DATETIME,GETDATE(),11)
	SELECT @date_y = DATEADD(d,-1,@date)


	IF DATEPART(w,@date_y) = 1
		SELECT @date_y = DATEADD(d,-2,@date_y)
	ELSE IF DATEPART(w,@date_y) = 7
		SELECT 	@date_y = DATEADD(d,-1,@date_y)

	IF  DATEPART(w,@date_y) = 2
		SELECT @date_d = DATEADD(d,-3,@date_y)
	ELSE
		SELECT @date_d = DATEADD(d,-1,@date_y)
	
	RETURN CASE @flag 
				WHEN 'y' THEN @date_y 
				WHEN 'k' THEN @date_d
				ELSE GETDATE()
			END
END











