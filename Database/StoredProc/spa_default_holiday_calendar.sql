IF OBJECT_ID(N'[dbo].[spa_default_holiday_calendar]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_default_holiday_calendar]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: bbishural@pioneersolutionsglobal.com
-- Create date: 2013-01-12
-- Description: CRUD operations for table default_holiday_calendar
 
-- Params:
-- @flag CHAR(1) - Operation flag

-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_default_holiday_calendar]
    @flag			CHAR(1),
    @id				INT = NULL,
    @def_code_id	INT = NULL,
    @calendar_desc	INT = NULL
AS

DECLARE @SQL VARCHAR(MAX)
 
IF @flag = 'a'
BEGIN
    SELECT def_code_id [Code ID],
           calendar_desc [Calendar Desc] 
    FROM   default_holiday_calendar
    WHERE  def_code_id = @def_code_id
END
ELSE IF @flag = 'i'
BEGIN
	INSERT INTO default_holiday_calendar
	(
	    def_code_id,
	    calendar_desc
	)
	VALUES
	(
	    @def_code_id,
	    @calendar_desc 
	)
	EXEC spa_ErrorHandler 0
		   , 'default_holiday_calendar' 
		   , 'spa_default_holiday_calendar'
		   , 'DB Error'
		   , 'Successfully inserted'
		   , ''
END
ELSE IF @flag = 'u'
BEGIN
	UPDATE default_holiday_calendar
	SET    calendar_desc = @calendar_desc
	WHERE  def_code_id = @def_code_id
	
	EXEC spa_ErrorHandler 0
		   , 'default_holiday_calendar' 
		   , 'spa_default_holiday_calendar'
		   , 'DB Error'
		   , 'Successfully updated'
		   , ''
END
