IF OBJECT_ID(N'[dbo].[spa_import_trigger]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_import_trigger]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2008-09-09
-- Description: Description of the functionality in brief.
 
-- Params:
-- @flag CHAR(1)        - operation flag - b - trigger before import, a - trigger after import
-- @sql VARCHAR(MAX)    - sql statement 
-- ===============================================================================================================

CREATE PROCEDURE [dbo].[spa_import_trigger]   
    @flag CHAR(1),
    @sql VARCHAR(MAX) = NULL,
    @process_id VARCHAR(300) = NULL,
    @trigger_output INT OUTPUT
AS
DECLARE @message_board_status VARCHAR(200)
DECLARE @user_name VARCHAR(200)
DECLARE @job_name VARCHAR(500)
DECLARE @trigger_job_name VARCHAR(200)

SET @job_name = 'ImportData_' + @process_id 
SET @trigger_job_name = 'trigger_for_import_' + @process_id
SET @user_name = dbo.FNADBUser()
IF @flag = 'b'
BEGIN
    IF @sql IS NOT NULL 
    BEGIN
		BEGIN TRY
			SET @sql = REPLACE(@sql, '@process_id', @process_id)
			EXEC(@sql)
			SELECT @message_board_status = mb.[type] FROM message_board mb WHERE mb.job_name = @trigger_job_name
			
			IF @message_board_status = 's' OR @message_board_status IS NULL
			BEGIN
				SET @trigger_output = 1	
			END
			ELSE
			BEGIN
				SET @trigger_output = @@ERROR
			END
		END TRY
		BEGIN CATCH
			SET @trigger_output = @@ERROR
		END CATCH    	
    END    
    RETURN @trigger_output
END
IF @flag = 'a'
BEGIN
    IF @sql IS NOT NULL 
    BEGIN
		BEGIN TRY
			SET @sql = REPLACE(@sql, '@process_id', @process_id)
			EXEC(@sql)
			SET @trigger_output = 1			
		END TRY
		BEGIN CATCH
			SET @trigger_output = @@ERROR
		END CATCH    	
    END    
    RETURN @trigger_output
END