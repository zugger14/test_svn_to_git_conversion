IF OBJECT_ID(N'[dbo].[spa_alert_activity]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_alert_activity]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2012-12-12
-- Description: Execute alert activity
 
-- Params:
-- @id INT - Operation flag
-- @action_type INT - activity action type - 20801 - activate counterparty
--										   - 20802 - Approve Contract
--									       - 20803 - Validate Deal
-- @call_from - CHAR(1) - 'w' -- workflow 
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_alert_activity]
    @id INT,
    @action_type_id INT,
    @call_from CHAR(1) = NULL,
    @alert_table VARCHAR(500) = NULL,
    @risk_control_id INT = NULL,
    @process_id VARCHAR(500) = NULL
    
AS
DECLARE @DESC VARCHAR(1000)
declare @desc2 VARCHAR(1000)
DECLARE @sql VARCHAR(MAX)
DECLARE @contract_name VARCHAR(50)

IF @action_type_id = 20801
BEGIN
	BEGIN TRY
		DECLARE @counterparty_name NVARCHAR(1000)
		
		SELECT @counterparty_name = sc.counterparty_name
		FROM   source_counterparty sc
		WHERE  sc.source_counterparty_id = @id
		
		SET @DESC = 'Counterparty ' + @counterparty_name + ' has been activiated.'
		
		UPDATE counterparty_credit_info
		SET account_status = 10082
		WHERE Counterparty_id = @id
		
		IF @call_from = 'w'
		BEGIN
			SET @sql = 'INSERT INTO message_board (user_login_id, [source], [description], [TYPE], is_alert, is_alert_processed)
			SELECT CASE WHEN au.role_user = ''r'' THEN aru.user_login_id ELSE au.user_login_id END user_login_id,
				   ''Alert'',
				   ''' + @DESC + ''',
				   ''s'',
				   ''y'',
				   ''n''
			FROM ' + @alert_table + ' at 
			INNER JOIN alert_users au ON au.alert_sql_id = at.sql_id 
			LEFT JOIN application_role_user aru ON  aru.role_id = au.role_id
			WHERE id = ' + CAST(@id AS VARCHAR(30)) + ''
			EXEC(@sql)
			exec spa_print @sql
		END
		ELSE
		BEGIN
			EXEC spa_ErrorHandler 0
			, 'counterparty_credit_info'
			, 'spa_alert_activity'
			, 'Success'
			, @DESC
			, ''
		END
		 
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to activate Counterparty ( Errr Description:' + ERROR_MESSAGE() + ').'
	 	 
		EXEC spa_ErrorHandler -1
		   , 'counterparty_credit_info'
		   , 'spa_alert_activity'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH 
END
ELSE IF @action_type_id = 20803
BEGIN
	BEGIN TRY
		DECLARE @deal_name VARCHAR(50)
		
		SELECT @deal_name = sdh.deal_id
		FROM   source_deal_header sdh
		WHERE sdh.source_deal_header_id = @id
		
		SET @DESC = 'Deal - ' + @deal_name + ' (' + CAST(@id AS VARCHAR(20)) + ') has been validated.'
		
		UPDATE source_deal_header
		SET deal_status = 5605
		WHERE source_deal_header_id = @id
		
		IF @call_from = 'w'
		BEGIN
			SET @sql = 'INSERT INTO message_board (user_login_id, [source], [description], [TYPE], is_alert, is_alert_processed)
			SELECT CASE WHEN au.role_user = ''r'' THEN aru.user_login_id ELSE au.user_login_id END user_login_id,
				   ''Alert'',
				   ''' + @DESC + ''',
				   ''s'',
				   ''y'',
				   ''n''
			FROM ' + @alert_table + ' at 
			INNER JOIN alert_users au ON au.alert_sql_id = at.sql_id 
			LEFT JOIN application_role_user aru ON  aru.role_id = au.role_id
			WHERE source_deal_header_id = ' + CAST(@id AS VARCHAR(30)) + ''
			EXEC(@sql)
			exec spa_print @sql
		END
		ELSE
		BEGIN
			EXEC spa_ErrorHandler 0
			, 'source_deal_header'
			, 'spa_alert_activity'
			, 'Success'
			, @DESC
			, ''
		END
		 
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to validate Deal ( Errr Description:' + ERROR_MESSAGE() + ').'
	 	 
		EXEC spa_ErrorHandler -1
		   , 'source_deal_header'
		   , 'spa_alert_activity'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH 
END
ELSE IF @action_type_id IN (20802, 20804, 20805) -- Approve Contract
BEGIN
	BEGIN TRY
		SELECT @contract_name = cg.contract_name
		FROM contract_group cg
		WHERE cg.contract_id = @id
		
		DECLARE @status_id INT
		DECLARE @primary_trigger INT
		DECLARE @secondary_trigger INT
		SET @status_id = CASE @action_type_id
		                      WHEN 20802 THEN 1900
		                      WHEN 20804 THEN 1905
		                      WHEN 20805 THEN 1901
		                 END
		
		UPDATE contract_group 
		SET contract_status = @status_id
		WHERE contract_id = @id
		
		/* handle from spa_update_process
		IF @risk_control_id IS NOT NULL
		BEGIN
			SELECT @primary_trigger = trigger_primary
			FROM process_risk_controls
			WHERE risk_control_id = @risk_control_id AND action_type_on_complete = @action_type_id
			
			SELECT @secondary_trigger = trigger_primary
			FROM process_risk_controls
			WHERE risk_control_id = @risk_control_id AND action_type_on_complete = @action_type_id
			
			IF @primary_trigger IS NOT NULL
			BEGIN
				UPDATE alert_output_status
				SET    published = 'y'
				WHERE process_id = @process_id
				
				UPDATE alert_workflows
				SET workflow_trigger = 'y'
				WHERE alert_sql_id = @primary_trigger
				
				EXEC spa_insert_alert_output_status @primary_trigger, @process_id, NULL, NULL, NULL
				
				EXEC spa_run_alert_sql @primary_trigger, @process_id, NULL, NULL, NULL 
				
			END
			
			IF @secondary_trigger IS NOT NULL
			BEGIN
				UPDATE alert_output_status
				SET    published = 'y'
				WHERE process_id = @process_id
				
				UPDATE alert_workflows
				SET workflow_trigger = 'y'
				WHERE alert_sql_id = @secondary_trigger
				
				EXEC spa_insert_alert_output_status @secondary_trigger, @process_id, NULL, NULL, NULL
				EXEC spa_run_alert_sql @secondary_trigger, @process_id, NULL, NULL, NULL 
			END
		END
		ELSE
		BEGIN
			EXEC spa_ErrorHandler 0
			, 'Contract Approval'
			, 'spa_alert_activity'
			, 'Success'
			, @DESC
			, ''
		END
		*/ 
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to approve contract ( Errr Description:' + ERROR_MESSAGE() + ').'
	 	 
		EXEC spa_ErrorHandler -1
		   , 'Contract Approval'
		   , 'spa_alert_activity'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH 
END