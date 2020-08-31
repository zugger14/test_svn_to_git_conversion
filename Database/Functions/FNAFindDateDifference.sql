IF OBJECT_ID(N'FNAFindDateDifference', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAFindDateDifference]
 GO 

-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2012-11-20
-- Description: Function to return time difference in week, days, hours, minutes and second
 
-- Params:
-- returns VARCHAR - date diff
-- ===========================================================================================================
CREATE FUNCTION [dbo].[FNAFindDateDifference]
(
	@created_date DATETIME
)
RETURNS VARCHAR(500)
AS
BEGIN
	DECLARE @current_date DATETIME;
	DECLARE @date_difference VARCHAR(5000)
	SET @current_date = GETDATE()

	DECLARE @weeks        VARCHAR(100),
	        @days     VARCHAR(100),
	        @hours    VARCHAR(100),
	        @minutes  VARCHAR(100),
	        @second   VARCHAR(100)
	 

SET @weeks = CAST(DATEDIFF(second, @created_date, @current_date) / 60 / 60 / 24 / 7 AS VARCHAR(50))
SET @days = CAST(DATEDIFF(second, @created_date, @current_date) / 60 / 60 / 24 % 7 AS VARCHAR(50))
SET @hours = CAST(DATEDIFF(second, @created_date, @current_date) / 60 / 60 % 24  AS VARCHAR(50))
SET @minutes = CAST(DATEDIFF(second, @created_date, @current_date) / 60 % 60 AS VARCHAR(50))
SET @second = CAST(DATEDIFF(second, @created_date, @current_date) % 60 AS VARCHAR(50))	

SET @date_difference = CASE 
                            WHEN @weeks <> 0 THEN @weeks + ' weeks '
                            ELSE ''
                       END 
                       + CASE 
                          WHEN @days <> 0 THEN @days + ' days '
                          ELSE ''
                         END 
					   + CASE 
                          WHEN @hours <> 0 THEN @hours + ' hours '
                          ELSE ''
					     END
				       + CASE 
						  WHEN @minutes <> 0 THEN @minutes + ' minutes '
						  ELSE ''
						 END
				       + CASE 
						  WHEN @second <> 0 THEN @second + ' seconds '
						  ELSE ''
						 END
					RETURN ISNULL(NULLIF(@date_difference, ''), '0 second ')
END