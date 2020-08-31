IF OBJECT_ID(N'[dbo].[spa_status_rule_activity]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_status_rule_activity]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2012-03-29
-- Description: CRUD operations for table status_rule_activity

-- Params:
-- @flag CHAR(1) - Operation flag
-- @status_rule_activity_id - activity id
-- @status_rule_detail_id INT - status rule detail id,
-- @event_id INT - event id,
-- @workflow_activity_id INT - workflow id
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_status_rule_activity]
    @flag CHAR(1),
    @status_rule_activity_id INT = NULL,
    @status_rule_detail_id INT = NULL,
    @event_id INT = NULL,
    @workflow_activity_id INT = NULL,
    @workflow_function_id INT = NULL
AS
IF @flag = 's'
BEGIN
	SELECT sra.status_rule_activity_id [ID],
	       sra.status_rule_detail_id [Detail ID],
	       sdv.code [Event],
	       prc.userFuncionDesc [Workflow Function],
	       rsk.risk_control_description [Activity]
	FROM   status_rule_activity sra
	       INNER JOIN status_rule_detail srd ON  srd.status_rule_detail_id = sra.status_rule_detail_id
	       LEFT JOIN static_data_value sdv ON  sra.event_id = sdv.value_id AND sdv.[type_id] = 19500
	       LEFT JOIN process_functions prc ON  sra.workflow_function_id = prc.functionId
	       LEFT JOIN process_functions_listing_detail pfld ON pfld.listId = sra.workflow_activity_id
	       LEFT JOIN process_risk_controls rsk ON rsk.risk_control_id = pfld.risk_control_id
	WHERE  sra.status_rule_detail_id = @status_rule_detail_id
END
ELSE IF @flag = 'a'
BEGIN
    SELECT sra.status_rule_activity_id,
	       sra.status_rule_detail_id,
	       sra.event_id,
	       sra.workflow_activity_id,
	       prc.userFuncionDesc,
	       sra.workflow_function_id
	FROM   status_rule_activity sra
	LEFT JOIN process_functions prc ON sra.workflow_activity_id = prc.functionId 
	WHERE  sra.status_rule_activity_id = @status_rule_activity_id
END
ELSE IF @flag = 'i'
BEGIN
    BEGIN TRY
    	INSERT INTO status_rule_activity
    	(
    		event_id,
    		workflow_activity_id,
    		status_rule_detail_id,
    		workflow_function_id
    	)
    	VALUES
    	(
    		@event_id,
    		@workflow_activity_id,
    		@status_rule_detail_id,
    		@workflow_function_id
    	)
    	
    	EXEC spa_ErrorHandler 0,
    	     'status_rule_activity',
    	     'spa_status_rule_activity',
    	     'Success',
    	     'Data Successfully Saved.',
    	     ''
	END TRY
    BEGIN CATCH
		DECLARE @desc    VARCHAR(500)
		DECLARE @err_no  INT
		DECLARE @err_msg VARCHAR(200)
		SET @err_msg = ERROR_MESSAGE()
	    	
		SET @desc = 'Fail to insert Data ( Errr Description:' + @err_msg + ').'
		
		SELECT @err_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @err_no,
			 'status_rule_activity',
			 'spa_status_rule_activity',
			 'Error',
			 @desc,
			 @err_msg
    END CATCH
END

ELSE IF @flag = 'u'
BEGIN
    BEGIN TRY
    	UPDATE status_rule_activity
    	SET
    		workflow_activity_id = @workflow_activity_id,
    		workflow_function_id = @workflow_function_id
    	WHERE status_rule_activity_id = @status_rule_activity_id    		
    	
    	EXEC spa_ErrorHandler 0,
    	     'status_rule_activity',
    	     'spa_status_rule_activity',
    	     'Success',
    	     'Data Successfully Saved.',
    	     ''
	END TRY
    BEGIN CATCH
		DECLARE @desc1    VARCHAR(500)
		DECLARE @err_no1  INT
		DECLARE @err_msg1 VARCHAR(200)
		SET @err_msg1 = ERROR_MESSAGE()
	    	
		SET @desc = 'Fail to insert Data ( Errr Description:' + @err_msg1 + ').'
		
		SELECT @err_no1 = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @err_no1,
			 'status_rule_activity',
			 'spa_status_rule_activity',
			 'Error',
			 @desc1,
			 @err_msg1
    END CATCH
END
ELSE IF @flag = 'd'
BEGIN
    BEGIN TRY
		DELETE 
		FROM   status_rule_activity
		WHERE  status_rule_activity_id = @status_rule_activity_id
		
		EXEC spa_ErrorHandler 0,
		     'status_rule_activity',
		     'spa_status_rule_activity',
		     'Success',
		     'Data Successfully Deleted.',
		     ''
	END TRY
	BEGIN CATCH
		DECLARE @err_msg2 VARCHAR(200)
		SET @err_msg2 = ERROR_MESSAGE()
		EXEC spa_ErrorHandler -1,
		     'status_rule_activity',
		     'spa_status_rule_activity',
		     'DB Error',
		     'Deletion failed.',
		     @err_msg2
	END CATCH 
    
    
END