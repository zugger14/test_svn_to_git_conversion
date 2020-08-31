
/****** Object:  UserDefinedFunction [dbo].[FNAGetNextAvailDate]    Script Date: 02/13/2012 17:33:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetNextAvailDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAGetNextAvailDate]
GO


/****** Object:  UserDefinedFunction [dbo].[FNAGetNextAvailDate]    Script Date: 02/13/2012 17:33:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*
Author : Vishwas Khanal
Dated  : 27.Jan.2010
Desc   : This is used to skip the week ends and holidays and find the next available date.
Proj   : ladwp			 
Defect : 1280
*/

CREATE FUNCTION [dbo].[FNAGetNextAvailDate]
( 
	@date datetime,
	@due_date_type int=null,
	@holiday_groupId int=null
)	
RETURNS DATETIME AS	
BEGIN
	-- select dbo.FNAGetNextAvailDate ('2009-12-31',970,default)
	DECLARE	@count INT,
			@limit_count INT,			
			@avail_date DATETIME 

	SELECT @count = 0,
		   @limit_count = CASE @due_date_type 
							WHEN 970 THEN 6				-- 6th business day
							WHEN 978 THEN 15			-- 15th business day
							WHEN 985 THEN 10			-- 10th business day
							WHEN 984 THEN 20			-- 20th business day
							WHEN 979 THEN 10			-- 10th business day

							WHEN 971 THEN 1				-- 20th of the month or first business day after
							WHEN 977 THEN 1				-- 25th of the month or first buiness day after
							ELSE 1
								
						END 

		IF @due_date_type IN (970,978,985,984,979,1)
		BEGIN
			--SELECT @avail_date = dateadd(dd,1,@date)
			 SELECT @avail_date = @date

			WHILE 1=1
			BEGIN					
				IF NOT EXISTS(
					SELECT 'x' from holiday_group
					WHERE hol_group_value_id = @holiday_groupId 
						AND (hol_date = @avail_date OR DATEPART(dw,@avail_date) = 7 OR  DATEPART(dw,@avail_date) = 1))
							SELECT @count = @count + 1			
											
					IF @count = @limit_count BREAK		
					ELSE
						SELECT @avail_date = dateadd(dd,1,@avail_date)							
			END
		END		
		ELSE IF @due_date_type  IN (971,977)
		BEGIN
			SELECT @avail_date = CAST(CAST (YEAR(@date) AS VARCHAR)+'-'+CAST(MONTH(@date) AS VARCHAR)+'-01' AS DATETIME)
			SELECT @avail_date = CASE @due_date_type WHEN 971 THEN DATEADD(dd,20,@avail_date) ELSE DATEADD(dd,25,@avail_date) END
		
			WHILE 1=1
			BEGIN											
				IF NOT EXISTS(
					SELECT 'x' from holiday_group
					WHERE hol_group_value_id = @holiday_groupId 
						AND (hol_date = @avail_date OR DATEPART(dw,@avail_date) = 7 OR  DATEPART(dw,@avail_date) = 1))
							SELECT @count = @count + 1			
											
					IF @count = @limit_count BREAK		
					ELSE
						SELECT @avail_date = dateadd(dd,1,@avail_date)						
			END
		END 		
		RETURN @avail_date
END

GO


