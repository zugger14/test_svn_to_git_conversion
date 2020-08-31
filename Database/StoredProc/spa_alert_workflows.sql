IF OBJECT_ID(N'[dbo].[spa_alert_workflows]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_alert_workflows]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2012-11-03
-- Description: CRUD operations for table alert_workflows
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_alert_workflows]
    @flag CHAR(1),
    @alert_workflow_id INT = NULL,
    @alert_sql_id INT = NULL,
	@workflow_id INT = NULL
AS
DECLARE @DESC VARCHAR(500)
IF @flag = 'i'
BEGIN
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM alert_workflows aw WHERE aw.workflow_id = @workflow_id AND aw.alert_sql_id = @alert_sql_id)
		BEGIN
			EXEC spa_ErrorHandler -1,
		     'alert_workflows',
		     'spa_alert_workflows',
		     'Error',
		     'Workflow already exists for selected SQL.',
		     ''
		    RETURN
		END
		INSERT INTO alert_workflows (alert_sql_id, workflow_id)
		SELECT @alert_sql_id, @workflow_id
		
		EXEC spa_ErrorHandler 0,
		     'alert_workflows',
		     'spa_alert_workflows',
		     'Success',
		     'Successfully inserted data.',
		     ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		EXEC spa_ErrorHandler @@ERROR,
		     'alert_workflows',
		     'spa_alert_workflows',
		     'Error',
		     @DESC,
		     ''
	END CATCH
END
ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
		UPDATE alert_workflows
		SET alert_sql_id = @alert_sql_id,
			workflow_id = @workflow_id
		WHERE alert_workflows_id = @alert_workflow_id
		
		EXEC spa_ErrorHandler 0,
		     'alert_workflows',
		     'spa_alert_workflows',
		     'Success',
		     'Successfully updated data.',
		     ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to update Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		EXEC spa_ErrorHandler @@ERROR,
		     'alert_workflows',
		     'spa_alert_workflows',
		     'Error',
		     @DESC,
		     ''
	END CATCH
END
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		DELETE FROM alert_workflows WHERE alert_workflows_id = @alert_workflow_id		
		EXEC spa_ErrorHandler 0,
		     'alert_workflows',
		     'spa_alert_workflows',
		     'Success',
		     'Successfully deleted data.',
		     ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to delete Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		EXEC spa_ErrorHandler @@ERROR,
		     'alert_workflows',
		     'spa_alert_workflows',
		     'Error',
		     @DESC,
		     ''
	END CATCH	
END
ELSE IF @flag = 's'
BEGIN
	SELECT aw.alert_workflows_id [Workflow ID],
	       as1.alert_sql_name [Rule Name],
	       prc.risk_control_description [Workflow Description]	       
	FROM   alert_workflows aw
	LEFT JOIN process_risk_controls prc ON aw.workflow_id = prc.risk_control_id
	LEFT JOIN alert_sql as1 ON as1.alert_sql_id = aw.alert_sql_id
	WHERE aw.alert_sql_id = @alert_sql_id
END
ELSE IF @flag = 'a'
BEGIN
	SELECT aw.alert_workflows_id,
	       aw.alert_sql_id,
	       aw.workflow_id,
	       prh.process_id,
	       prd.risk_description_id
	FROM   alert_workflows aw
	INNER JOIN process_risk_controls prc ON prc.risk_control_id = aw.workflow_id
	INNER JOIN process_risk_description prd ON prd.risk_description_id = prc.risk_description_id
	INNER JOIN process_control_header prh ON prh.process_id = prd.process_id 
	WHERE  aw.alert_workflows_id = @alert_workflow_id
END
ELSE IF @flag = 'x' -- get workflow id for dropdown
BEGIN
	SELECT prc.risk_control_id,
	       prc.risk_control_description
	FROM   process_risk_controls prc
END