

IF OBJECT_ID(N'[dbo].[spa_populate_deal]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_populate_deal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2012-02-21
-- Description: Inserting deal ids into temporary tables

-- Params:
-- @flag CHAR(1) - Operation flag
-- @dealId VARCHAR(MAX) - list of deal ids.
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_populate_deal]
    @flag CHAR(1),
    @deal_id VARCHAR(MAX) = NULL,
	@debug_mode BIT = 0 
AS
BEGIN
SET NOCOUNT ON
	IF @flag = 'i'
	BEGIN
		DECLARE @user_login_id  VARCHAR(50),
				@temp_table      VARCHAR(200),
				@process_id VARCHAR(200)

		SET @user_login_id = dbo.FNADBUser()
		SET @process_id = dbo.FNAGetNewID()
		

		SET @temp_table = dbo.FNAProcessTableName(
				'source_deal_header_list',
				@user_login_id,
				@process_id
		)
		
		DECLARE @sql VARCHAR(8000)
		SET @sql = 'CREATE TABLE ' + @temp_table + 
            ' (
			sno INT IDENTITY(1,1), 
			source_deal_header_id VARCHAR(50)
		)'
        
		IF @debug_mode = 1
			EXEC spa_print @sql 
        
		EXEC (@sql)
        
        SET @sql = 'INSERT ' + @temp_table + 
            '(
					source_deal_header_id
		)' +
			' SELECT item FROM dbo.SplitCommaSeperatedValues( ''' + @deal_id + ''') scsv '
			        
        IF @debug_mode = 1
			EXEC spa_print @sql 
        EXEC (@sql)
        
        SELECT @temp_table, @deal_id
	END
END

--EXEC spa_populate_deal 'i', '1,2,3,4,5,6,7,8,9'
--SELECT * FROM adiha_process.dbo.source_deal_header_list_farrms_admin_A99FACA1_852B_4BD4_9F96_7CB0B11D293F