IF OBJECT_ID(N'[dbo].[spa_alert_sql]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_alert_sql]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
 /**
	Operation/Setup for Alert Rule setup

	Parameters :
	@flag : Flag
			's'-- Get Alert Rules
			'd'-- Delete Alert Rules
			'i'-- Insert Alert Rules
			'u'-- Update Alert Rules
			'a'-- Get Details about alert rules
			'x'-- Check the syntax of alert tsql
			'y'-- Change rule based to sql based
	@alert_sql_id :  Id of the Alert Rule (alert_sql_id FROM alert_sql)
	@name : Name of Alert Sql
	@tsql : Tsql to be executed in the Alert
	@message : Message. [Not in use] 
	@workflow_only : Workflow Only [Not in use]
	@notification_type : static_data_type - Type_id = 750
	@active : 'y' - active, 'n'- inactive
	@alert_type : 's' - SQL Based, 'r' - Rule Based
	@rule_category : static_data_type - type_id = 20600
	@system_rule : System Rule
	@alert_category : 's' - Simple Alert, 'w' - Workflow
	@show_unused_rule : Shows the rule which has not been mapped to any workflow
 */

CREATE PROCEDURE [dbo].[spa_alert_sql]
    @flag CHAR(1),
    @alert_sql_id INT = NULL,
    @name VARCHAR(200) = NULL,
    @tsql VARCHAR(MAX) = NULL,
    @message VARCHAR(500) = NULL,
    @workflow_only CHAR(1) = NULL,
    @notification_type INT = NULL,
    @active CHAR(1) = NULL,
    @alert_type CHAR(1) = NULL,
    @rule_category INT = NULL,
    @system_rule CHAR(1) = NULL,
	@alert_category VARCHAR(100) = NULL,
	@show_unused_rule INT = NULL
AS

SET NOCOUNT ON

/*

declare
 @flag CHAR(1)='x',
    @alert_sql_id INT = NULL,
    @name VARCHAR(200) = NULL,
    @tsql VARCHAR(8000) = 'SELECT  ''@prod_date'' prod_date,0 [hr],0 [mins],
ROUND(CASE WHEN  dbo.FNARECCurve(''@prod_date'',''@as_of_date'',516, 1,0,0,null  ,null) IS NOT NULL THEN dbo.FNARECCurve(''@prod_date'',''@as_of_date'',516, 1,0,0,null  ,null) 
 ELSE 
  CASE WHEN dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1)=2 THEN dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,-1,0,0,0) adiha_add(dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,1,0,0,0)-dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,-1,0,0,0) )/(3-1)*(2-1) 
   WHEN dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1) BETWEEN 4 AND 5 THEN dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,3-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0) adiha_add(dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,6-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0)-dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,3-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0))/(3)*(dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1)-3) 
   WHEN dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1) BETWEEN 7 AND 11 THEN dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,6-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0) adiha_add(dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,12-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0)-dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,6-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0))/(6)*(dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1)-6) 
   WHEN dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1) BETWEEN 13 AND 23 THEN dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,12-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0) adiha_add(dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,24-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0)-dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,12-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0))/(12)*(dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1)-12) 
   WHEN dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1) BETWEEN 25 AND 35 THEN dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,24-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0) adiha_add(dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,36-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0)-dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,24-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0))/(12)*(dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1)-24) 
   WHEN dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1) BETWEEN 37 AND 59 THEN dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,36-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0) adiha_add(dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,60-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0)-dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,36-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0))/(24)*(dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1)-36) 
   WHEN dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1) BETWEEN 61 AND 83 THEN dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,60-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0) adiha_add(dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,84-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0)-dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,60-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0))/(24)*(dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1)-60) 
   WHEN dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1) BETWEEN 85 AND 119 THEN dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,84-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0) adiha_add(dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,120-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0)-dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,84-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0))/(36)*(dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1)-84) 
   WHEN dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1) BETWEEN 121 AND 239 THEN dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,120-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0) adiha_add(dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,240-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0)-dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,120-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0))/(120)*(dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1)-120) 
   WHEN dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1) BETWEEN 241 AND 359 THEN dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,240-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0) adiha_add(dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,360-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0)-dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,516,0,240-dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1),0,0,0))/(120)*(dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,516,1)-240) 
  END 
 END/100, 5) [value]
 --[__final_output__]',
    @message VARCHAR(500) = NULL,
    @workflow_only CHAR(1) = NULL,
    @notification_type INT = NULL,
    @active CHAR(1) = NULL,
    @alert_type CHAR(1) = NULL
    
    
--*/

DECLARE @desc    VARCHAR(500)
DECLARE @err_no  INT
DECLARE @return_value INT
DECLARE @is_admin  INT,
        @user_id   VARCHAR(100)

SET @user_id = dbo.FNADBUser()
SELECT @is_admin = dbo.FNAIsUserOnAdminGroup(@user_id, 1)

SET @tsql = REPLACE(@tsql, 'adiha_add', '+')

IF @flag = 's'
BEGIN
	SELECT	CASE 
				WHEN asl.alert_category = 's' THEN 'Rule'
				WHEN asl.alert_category = 'w' THEN ISNULL(sdv_mo.code,'Alert')
				WHEN asl.alert_type = 's' THEN 'SQL Based'
				ELSE 'Rule Based' 
			END AS [Category],
			asl.alert_sql_name AS [Rule_Name],
			asl.alert_sql_id AS [Alert SQL ID],
           --asl.[message] AS [Message],
           sdv.code AS [Notification Type],
           CASE 
                WHEN asl.workflow_only = 'n' THEN 'No'
                WHEN asl.workflow_only = 'y' THEN 'Yes'
           END AS [WorkFlow Only],
           CASE 
                WHEN asl.is_active = 'n' THEN 'No'
                WHEN (asl.is_active = 'y' OR asl.is_active IS NULL) THEN 'Yes'
           END AS [Active],
           CASE 
                WHEN asl.alert_type = 'r' THEN 'Rule Based'
                WHEN asl.alert_type = 's' THEN 'SQL Based'
           END AS [Alert Type],
           CASE WHEN asl.rule_category = -1 THEN 'General' ELSE sdv_category.code END [Rule Category],
           CASE WHEN asl.system_rule = 'y' THEN 'Yes' ELSE 'No' END [System Rule],
           CASE WHEN asl.system_rule = 'n' THEN 'y' ELSE CASE WHEN @is_admin = 1 THEN 'y' ELSE 'n' END END [Updatable],
		   me.module_events_id [module_events_id] 
    FROM alert_sql asl 
    INNER JOIN static_data_value sdv ON  asl.notification_type = sdv.value_id
    LEFT JOIN (
		SELECT DISTINCT sdv.[value_id], sdv.code 
		FROM static_data_value sdv WHERE type_id = 20600
		UNION ALL 
		SELECT DISTINCT module_id, 'UDT - ' + udt_name [code]
		FROM 
		workflow_module_event_mapping mp
		INNER JOIN user_defined_tables udt ON ABS(mp.module_id) = udt_id
		WHERE mp.module_id < -1 AND mp.is_active = 1
	) sdv_category ON  asl.rule_category = sdv_category.value_id 
	LEFT JOIN event_trigger et ON et.alert_id = asl.alert_sql_id
	LEFT JOIN module_events me ON me.module_events_id = et.modules_event_id
	LEFT JOIN (
		SELECT DISTINCT sdv.[value_id], sdv.code 
		FROM static_data_value sdv WHERE type_id = 20600
		UNION ALL 
		SELECT DISTINCT module_id, 'UDT - ' + udt_name [code]
		FROM 
		workflow_module_event_mapping mp
		INNER JOIN user_defined_tables udt ON ABS(mp.module_id) = udt_id
		WHERE mp.module_id < -1 AND mp.is_active = 1
	)  sdv_mo ON sdv_mo.value_id = me.modules_id
	WHERE asl.is_active LIKE CASE WHEN ISNULL(@active, 'b') = 'b' THEN '%' ELSE @active END
    AND asl.system_rule LIKE CASE WHEN ISNULL(@system_rule, 'b') = 'b' THEN '%' ELSE @system_rule END
    AND asl.alert_type LIKE CASE WHEN @alert_type IN ('s', 'r') THEN @alert_type ELSE '%' END
    AND ISNULL(CAST(asl.rule_category AS VARCHAR(10)), '%') LIKE CASE WHEN CAST(@rule_category AS VARCHAR(10)) IS NOT NULL THEN CAST(@rule_category AS VARCHAR(10)) ELSE '%' END
	AND CASE WHEN @alert_category IS NULL THEN 
			CASE WHEN asl.alert_category = 'c' OR asl.alert_category IS NULL THEN '1' ELSE '2' END
		ELSE 
			CASE WHEN asl.alert_category = 'w' THEN '1' ELSE '2' END 
		END = '1'
	AND asl.alert_sql_id > 0
	UNION
	SELECT 'Unused Rule' [Category],
			asl.alert_sql_name AS [Rule_Name],
			asl.alert_sql_id AS [Alert SQL ID],
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL
	FROM alert_sql asl
	LEFT JOIN event_trigger et
		ON et.alert_id = asl.alert_sql_id
	LEFT JOIN workflow_event_action wet
		ON wet.alert_id = asl.alert_sql_id
	WHERE et.event_trigger_id IS NULL AND wet.event_action_id IS NULL
	AND asl.alert_sql_id > 0 AND ISNULL(@show_unused_rule,0) = 1
  ORDER BY category,alert_sql_name ASC
END
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		IF EXISTS (SELECT 1 FROM alert_sql WHERE alert_sql_id = @alert_sql_id AND system_rule = 'y' AND @is_admin = 0)
		BEGIN
			EXEC spa_ErrorHandler -1,
				 'alert_sql',
				 'spa_alert_sql',
				 'Error',
				 'User do not have permission to delete system rules.',
				 ''		    
		    RETURN
		END
		
		DELETE FROM alert_users WHERE alert_sql_id = @alert_sql_id
		DELETE FROM alert_workflows WHERE alert_sql_id = @alert_sql_id
		DELETE FROM alert_actions_events WHERE alert_id = @alert_sql_id
		DELETE FROM alert_actions WHERE alert_id = @alert_sql_id
		DELETE FROM alert_table_where_clause WHERE alert_id = @alert_sql_id
		DELETE FROM alert_conditions WHERE rules_id = @alert_sql_id		
		DELETE FROM alert_table_relation WHERE alert_id = @alert_sql_id
		DELETE FROM alert_rule_table WHERE alert_id = @alert_sql_id
		DELETE FROM alert_sql WHERE alert_sql_id = @alert_sql_id

		UPDATE process_risk_controls
		SET trigger_primary = NULL
		WHERE trigger_primary = @alert_sql_id
		
		UPDATE process_risk_controls
		SET trigger_secondary = NULL
		WHERE trigger_secondary = @alert_sql_id

		EXEC spa_ErrorHandler 0,
		     'alert_sql',
		     'spa_alert_sql',
		     'Success',
		     'Successfully deleted data.',
		     ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		    ROLLBACK
		
		IF ERROR_MESSAGE() = 'CatchError'
		    SET @desc = 'Fail to delete Data ( Errr Description:' + @desc + ').'
		ELSE
		    SET @desc = 'Fail to delete Data ( Errr Description:' + ERROR_MESSAGE() + ').'
		
		SELECT @err_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @err_no,
		     'alert_sql',
		     'spa_alert_sql',
		     'Error',
		     @desc,
		     ''
	END CATCH
END
If @flag = 'i'
BEGIN
	BEGIN TRY
		DECLARE @sql_id INT
		
		IF EXISTS(SELECT 1 FROM alert_sql as1 WHERE as1.alert_sql_name = @name)
		BEGIN
			EXEC spa_ErrorHandler -1,
			 'alert_sql',
			 'spa_alert_sql',
			 'Error',
			 'Name already Exists.',
			 ''
			 RETURN
		END
		
		INSERT INTO alert_sql (workflow_only, [message], notification_type, alert_sql_name, is_active, alert_type, rule_category, system_rule)
		SELECT @workflow_only, @message, @notification_type, @name, @active, @alert_type, @rule_category, @system_rule
		
		SET @sql_id = SCOPE_IDENTITY()
		EXEC spa_ErrorHandler 0,
			 'alert_sql',
			 'spa_alert_sql',
			 'Success',
			 'Alert Successfully Inserted.',
			 @sql_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		EXEC spa_ErrorHandler @@ERROR,
			 'alert_sql_statement',
			 'spa_alert_sql_statement',
			 'Failed.',
			 @DESC,
			 ''
	END CATCH
END
ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM alert_sql as1 WHERE as1.alert_sql_name = @name AND alert_sql_id <> @alert_sql_id)
		BEGIN
			EXEC spa_ErrorHandler -1,
			 'alert_sql',
			 'spa_alert_sql',
			 'Error',
			 'Name already Exists.',
			 ''
			 RETURN
		END
		
		UPDATE alert_sql
		SET workflow_only = @workflow_only,
			[message] = @message,
			notification_type = @notification_type,
			alert_sql_name = @name,
			is_active = @active,
			alert_type = @alert_type,
			rule_category = @rule_category,
			system_rule = @system_rule
		WHERE alert_sql_id = @alert_sql_id
		
		EXEC spa_ErrorHandler 0,
			 'alert_sql_statement',
			 'spa_alert_sql_statement',
			 'Success',
			 'Alert Successfully Updated.',
			 @alert_sql_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to update Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		EXEC spa_ErrorHandler @@ERROR,
			 'alert_sql_statement',
			 'spa_alert_sql_statement',
			 'Failed.',
			 @DESC,
			 ''
	END CATCH
END
ELSE IF @flag = 'a'
BEGIN
	SELECT as1.alert_sql_id,
	       as1.alert_sql_name,
	       as1.sql_statement,
	       as1.workflow_only,
	       as1.[message],
	       as1.notification_type,
	       as1.is_active,
	       as1.alert_type,
	       as1.rule_category, 
	       as1.system_rule
	FROM   alert_sql as1
	WHERE  as1.alert_sql_id = @alert_sql_id
END
ELSE IF @flag = 'x' -- syntax checking
BEGIN
	DECLARE @return INT 
	EXEC @return = spa_check_sql_syntax @tsql
	
	IF @return = 0 
	BEGIN
		EXEC spa_ErrorHandler 0,
			 'alert_sql_statement',
			 'spa_alert_sql_statement',
			 'Success',
			 'SQL Statement is Valid.',
			 ''
	END
	ELSE IF @return = 1
	BEGIN
		EXEC spa_ErrorHandler -1,
			 'alert_sql_statement',
			 'spa_alert_sql_statement',
			 'Error',
			 'SQL Statement is Invalid.',
			 ''
	END 
END
ELSE IF @flag = 'y'
BEGIN
	BEGIN TRY
		EXEC @return_value = spa_check_sql_syntax @tsql

		IF @return_value = 1
		BEGIN
			EXEC spa_ErrorHandler -1,
				 'alert_sql_statement',
				 'spa_alert_sql_statement',
				 'Error',
				 'SQL Statement is Invalid.',
				 ''
			RETURN
		END
		
		UPDATE alert_sql
		SET sql_statement = @tsql
		WHERE alert_sql_id = @alert_sql_id		
		
		DELETE FROM alert_actions_events WHERE alert_id = @alert_sql_id
		DELETE FROM alert_actions WHERE alert_id = @alert_sql_id		
		DELETE FROM alert_conditions WHERE rules_id = @alert_sql_id
		DELETE FROM alert_table_where_clause WHERE alert_id = @alert_sql_id
		DELETE FROM alert_table_relation WHERE alert_id = @alert_sql_id
		DELETE FROM alert_rule_table WHERE alert_id = @alert_sql_id
		
		EXEC spa_ErrorHandler 0,
			 'alert_sql_statement',
			 'spa_alert_sql_statement',
			 'Success',
			 'SQL Successfully Updated.',
			 @alert_sql_id
			 
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			   ROLLBACK
		 
		SET @DESC = 'Fail to update Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		EXEC spa_ErrorHandler @@ERROR,
			 'alert_sql_statement',
			 'spa_alert_sql_statement',
			 'Failed.',
			 @DESC,
			 ''
	END CATCH	
END