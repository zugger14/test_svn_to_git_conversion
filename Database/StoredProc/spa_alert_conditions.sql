IF OBJECT_ID(N'[dbo].[spa_alert_conditions]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_alert_conditions]
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
CREATE PROCEDURE [dbo].[spa_alert_conditions]
    @flag CHAR(1),
    @alert_conditions_id INT = NULL,
    @rules_id INT = NULL,
    @alert_conditions_name VARCHAR(200) = NULL,
    @alert_conditions_description VARCHAR(800) = NULL,
	@grid_xml VARCHAR(MAX) = NULL
AS
SET NOCOUNT ON 
DECLARE @sql VARCHAR(MAX)
DECLARE @desc VARCHAR(500)
DECLARE @err_no INT
 
IF @flag = 's'
BEGIN
    SELECT DISTINCT	ac.alert_conditions_id,
			CASE WHEN aa.sql_statement IS NOT NULL THEN 'y' ELSE 'n' END AS is_sql,
			ac.alert_conditions_name [Name],
			ac.alert_conditions_description [Description]
	FROM alert_conditions AS ac
	LEFT JOIN alert_actions AS aa ON ac.rules_id = aa.alert_id AND ac.alert_conditions_id = aa.condition_id
	WHERE ac.rules_id = @rules_id    
END
ELSE IF @flag = 'a'
BEGIN
    SELECT ac.alert_conditions_id,
           ac.alert_conditions_name,
           ac.alert_conditions_description
    FROM alert_conditions ac
    WHERE ac.rules_id = @rules_id AND ac.alert_conditions_id = @alert_conditions_id    
END
ELSE IF @flag = 'i'
BEGIN
	IF EXISTS(SELECT 1 FROM alert_conditions ac WHERE ac.alert_conditions_name = @alert_conditions_name AND ac.rules_id = @rules_id)
	BEGIN
		EXEC spa_ErrorHandler -1,
		 'alert_sql',
		 'spa_alert_sql',
		 'Error',
		 'Condition name already exists.',
		 ''
		 RETURN
	END
	
	BEGIN TRY
		INSERT INTO alert_conditions (rules_id, alert_conditions_name, alert_conditions_description)
		SELECT @rules_id, @alert_conditions_name, @alert_conditions_description		
		DECLARE @recommendation NUMERIC(18,0) = SCOPE_IDENTITY()
		EXEC spa_ErrorHandler 0, 'alert_conditions', 'spa_alert_conditions', 'Success', 'Changes have been saved successfully.', @recommendation
	END TRY
	BEGIN CATCH	 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @desc = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no, 'alert_conditions', 'spa_alert_conditions', 'Error', @DESC, ''
	END CATCH
END
ELSE IF @flag = 'u'
BEGIN
	IF EXISTS(SELECT 1 FROM alert_conditions ac WHERE ac.alert_conditions_name = @alert_conditions_name AND ac.rules_id = @rules_id AND ac.alert_conditions_id <> @alert_conditions_id)
	BEGIN
		EXEC spa_ErrorHandler -1,
		 'alert_sql',
		 'spa_alert_sql',
		 'Error',
		 'Condition name already exists.',
		 ''
		 RETURN
	END
	
	BEGIN TRY
		UPDATE alert_conditions
		SET    alert_conditions_name = @alert_conditions_name,
		       alert_conditions_description = @alert_conditions_description
		WHERE  alert_conditions_id = @alert_conditions_id AND @rules_id = @rules_id
		
		EXEC spa_ErrorHandler 0, 'alert_conditions', 'spa_alert_conditions', 'Success', 'Changes have been saved successfully.', @alert_conditions_id
	END TRY
	BEGIN CATCH	 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @desc = 'Fail to update Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no, 'alert_conditions', 'spa_alert_conditions', 'Error', @DESC, ''
	END CATCH
END
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		--BEGIN TRANSACTION
			DELETE FROM alert_actions WHERE condition_id = @alert_conditions_id AND alert_id = @rules_id
			DELETE FROM alert_table_where_clause WHERE condition_id = @alert_conditions_id AND alert_id = @rules_id 
			DELETE FROM alert_conditions WHERE alert_conditions_id = @alert_conditions_id AND rules_id = @rules_id					
		--COMMIT TRANSACTION
		EXEC spa_ErrorHandler 0, 'alert_conditions', 'spa_alert_conditions', 'Success', 'Changes have been saved successfully.', ''
	END TRY
	BEGIN CATCH	 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to delete Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no, 'alert_conditions', 'spa_alert_conditions', 'Error', @DESC, ''
	END CATCH	
END