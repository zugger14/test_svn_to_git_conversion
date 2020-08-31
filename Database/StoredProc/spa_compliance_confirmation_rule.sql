IF OBJECT_ID('[dbo].[spa_compliance_confirmation_rule]','p') IS NOT NULL
DROP PROC [dbo].[spa_compliance_confirmation_rule]
GO

CREATE PROC [dbo].[spa_compliance_confirmation_rule]
@function_ids		VARCHAR(1000),
@action_type		CHAR(1),
@id					VARCHAR(1000), -- e.g Deal Id
@source				VARCHAR(150) = NULL,
@success_error_flag	CHAR(1) = 's',
@msg				VARCHAR(8000)= NULL,
@activity_id		VARCHAR(1000) = NULL,
@process_id			VARCHAR(200) = NULL,
@event_id			INT = NULL,
@deal_status_from	INT = NULL,
@deal_status_message INT = NULL,
@status_rule_detail_id VARCHAR(8000) = NULL
AS

DECLARE @function_id INT ,@user_login_id VARCHAR(50),@table_name VARCHAR(200),@sql VARCHAR(5000) 

BEGIN TRY
	
	SET @user_login_id = dbo.FNADBUser();
	SET @table_name = dbo.FNAProcessTableName('work_flow', @user_login_id,@process_id)	
	
	
	
	CREATE TABLE #activity(workflow_function_id INT,activity_id INT)
	
	IF @process_id IS NOT NULL
	BEGIN
		SET @sql = 'INSERT INTO #activity
				SELECT workflow_function_id,activity_id FROM '+@table_name
		
		EXEC(@sql)		
	END
	ELSE
	INSERT INTO #activity SELECT DISTINCT item,@activity_id FROM dbo.splitcommaseperatedvalues(@function_ids)
	
		
	
	
	
	DECLARE cur_status CURSOR LOCAL FOR
	SELECT DISTINCT workflow_function_id,activity_id from #activity
		
	OPEN cur_status;

	FETCH NEXT FROM cur_status INTO @function_id,@activity_id
	WHILE @@FETCH_STATUS = 0
	BEGIN
			
		EXEC spa_compliance_workflow @function_id, @action_type, @id, @source, @success_error_flag, @msg ,@activity_id, @event_id , @deal_status_from, @deal_status_message, @status_rule_detail_id
	
		FETCH NEXT FROM cur_status INTO @function_id,@activity_id
	END;

	CLOSE cur_status;
	DEALLOCATE cur_status;	
	
	
END TRY
BEGIN CATCH
	IF CURSOR_STATUS('local', 'cur_status') >= 0 
	BEGIN
		CLOSE cur_status
		DEALLOCATE cur_status;
	END
END CATCH