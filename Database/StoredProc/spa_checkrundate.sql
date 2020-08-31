SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Narendra Shrestha
-- Create date: 01/01/2010
-- Description:	SP to check run date falls in holyday calander or not.
-- =============================================
IF OBJECT_ID('spa_checkrundate','p') IS NOT NULL
DROP PROC [dbo].[spa_checkrundate]
GO
CREATE PROCEDURE [dbo].[spa_checkrundate] 
	@date VARCHAR(10),
	@holiday_calendar_id INT = NULL,
	@working_days_value_id INT = NULL
AS
DECLARE @curdate VARCHAR(10)
DECLARE @msg VARCHAR(MAX)
DECLARE @error INT
DECLARE @default_holiday_id INT
SELECT @default_holiday_id = calendar_desc FROM default_holiday_calendar
BEGIN
	SET @curdate = dbo.FNADateFormat(getdate())
	SET @date = dbo.FNADateFormat(@date)
	SET @error = 0
	IF (@date < @curdate)
		BEGIN
			SET @error = 1
		END
	IF @holiday_calendar_id IS NOT NULL
		BEGIN
			
			IF EXISTS (
				SELECT * 
				FROM holiday_group 
				WHERE @date IN (
					SELECT dbo.FNADateFormat(hol_date) 
					FROM holiday_group 
					WHERE hol_group_value_id = @default_holiday_id
				)
			)
			BEGIN
				SET @error = 1
			END
		END
	
	IF @working_days_value_id IS NOT NULL
		BEGIN
			IF EXISTS(
				SELECT * 
				FROM working_days 
				WHERE datepart(dw,@date) IN(
					SELECT weekday 
					FROM working_days 
					WHERE val = 0 
					AND block_value_id = @working_days_value_id
				)
			)
			BEGIN
				SET @error = 1
			END
		END
	
	IF @error = 1
		BEGIN
			EXEC spa_ErrorHandler -1, 'Holiday Group', 'spa_checkrundate', 'Error', 'The run date is invalid. Please make sure that the selected date is not a past date or does not fall on a holiday.', ''	
		END
	ELSE
		BEGIN
			EXEC spa_ErrorHandler 0, 'Holiday Group', 'spa_checkrundate', 'Success', 'Can run on selected date.', ''	
		END		
END
GO
