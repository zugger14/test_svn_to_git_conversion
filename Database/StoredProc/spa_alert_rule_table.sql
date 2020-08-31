IF OBJECT_ID(N'[dbo].[spa_alert_rule_table]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_alert_rule_table]
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
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - Description of param3
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_alert_rule_table]
    @flag CHAR(1),
    @alert_rule_table_id INT = NULL,
    @alert_id INT = NULL,
    @table_id INT = NULL,
    @root_table_id INT = NULL,
    @table_alias VARCHAR(20) = NULL
AS
 
DECLARE @sql VARCHAR(MAX)
DECLARE @root_id INT
DECLARE @desc VARCHAR(5000)
DECLARE @err_no INT
 
IF @flag = 'x'
BEGIN
    SELECT atd.alert_table_definition_id,
           atd.logical_table_name
    FROM   alert_table_definition atd
END

IF @flag = 'i'
BEGIN
	BEGIN TRY		
		IF EXISTS(SELECT 1 FROM alert_rule_table art WHERE art.table_alias = @table_alias AND art.alert_id = @alert_id)
		BEGIN
			EXEC spa_ErrorHandler -1, 'alert_rule_table', 'spa_alert_rule_table', 'DB Error', 'Alias already exists.', ''
			RETURN
		END
		
		INSERT INTO alert_rule_table (alert_id, table_id, table_alias)
		VALUES (@alert_id, @table_id, @table_alias)
		
		
		SET @root_id = SCOPE_IDENTITY()
		
		EXEC spa_ErrorHandler 0, 'alert_rule_table', 'spa_alert_rule_table', 'Success', 'Successfully saved data.', @root_id
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @desc = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @err_no, 'alert_rule_table', 'spa_alert_rule_table', 'Error', @desc, ''
	END CATCH
END

IF @flag = 'u'
BEGIN
	BEGIN TRY		
		IF EXISTS(SELECT 1 FROM alert_rule_table art WHERE art.table_alias = @table_alias AND art.alert_id = @alert_id AND art.alert_rule_table_id <> @alert_rule_table_id)
		BEGIN
			EXEC spa_ErrorHandler -1, 'alert_rule_table', 'spa_alert_rule_table', 'DB Error', 'Alias already exists.', ''
			RETURN
		END
		
		UPDATE alert_rule_table
		SET table_id = @table_id,
			table_alias = @table_alias
		WHERE alert_rule_table_id = @alert_rule_table_id
		
		SET @root_id = @alert_rule_table_id
		
		EXEC spa_ErrorHandler 0, 'alert_rule_table', 'spa_alert_rule_table', 'Success', 'Successfully saved data.', @root_id
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @desc = 'Fail to update Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @err_no, 'alert_rule_table', 'spa_alert_rule_table', 'Error', @desc, ''
	END CATCH
END

IF @flag = 'r'
BEGIN
	BEGIN TRY		
		IF EXISTS(SELECT 1 FROM alert_rule_table art WHERE art.table_alias = @table_alias AND art.alert_id = @alert_id)
		BEGIN
			EXEC spa_ErrorHandler -1, 'alert_rule_table', 'spa_alert_rule_table', 'DB Error', 'Alias already exists.', ''
			RETURN
		END
		
		INSERT INTO alert_rule_table (alert_id, table_id, table_alias, root_table_id)
		VALUES (@alert_id, @table_id, @table_alias, @root_table_id)
		
		SET @root_id = @root_table_id
		
		EXEC spa_ErrorHandler 0, 'alert_rule_table', 'spa_alert_rule_table', 'Success', 'Successfully saved data.', @root_id
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @desc = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @err_no, 'alert_rule_table', 'spa_alert_rule_table', 'Error', @desc, ''
	END CATCH
END

IF @flag = 's'
BEGIN
	SELECT art.alert_id,art.alert_rule_table_id [TableId], art.table_id [Table], art.table_alias [Alias]
	FROM   alert_rule_table art
	INNER JOIN alert_table_definition atd
        ON  atd.alert_table_definition_id = art.table_id
    INNER JOIN alert_sql asl ON asl.alert_sql_id = art.alert_id
	WHERE asl.alert_sql_id = @alert_id ORDER BY art.root_table_id ASC
END

IF @flag = 'a'
BEGIN
	SELECT art.table_id [TableId], art.table_alias [Alias]
	FROM   alert_rule_table art
	WHERE art.alert_id = @alert_id AND art.root_table_id IS NULL
END

IF @flag = 'd'
BEGIN
BEGIN TRY
	DELETE FROM alert_table_relation WHERE from_table_id = @alert_rule_table_id OR to_table_id = @alert_rule_table_id
	DELETE FROM alert_table_where_clause WHERE table_id = @alert_rule_table_id
	DELETE FROM alert_rule_table WHERE alert_rule_table_id = @alert_rule_table_id
	
	
	EXEC spa_ErrorHandler 0, 'alert_rule_table', 'spa_alert_rule_table', 'Success', 'Delete Successful', ''
END TRY
BEGIN CATCH 
	IF @@TRANCOUNT > 0
	   ROLLBACK
 
	SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
	SELECT @err_no = ERROR_NUMBER()
 
	EXEC spa_ErrorHandler @err_no, 'alert_rule_table', 'spa_alert_rule_table', 'Error', 'Delete Failed', ''
END CATCH	
END