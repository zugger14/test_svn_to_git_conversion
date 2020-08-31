IF OBJECT_ID(N'[dbo].[spa_run_alert_message]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_run_alert_message]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spa_run_alert_message]
    @module_id			INT = NULL,
	@source_id			INT = NULL,
	@event_message_id	INT = NULL

AS

SET NOCOUNT ON;


DECLARE @sql VARCHAR(MAX)
DECLARE @process_id VARCHAR(100) = dbo.FNAGetNewID()
DECLARE @process_table VARCHAR(200) = 'adiha_process.dbo.alert_message_' + CAST(@source_id AS VARCHAR) + '_' + @process_id

DECLARE @primary_table VARCHAR(200)
SELECT @primary_table = atd.primary_column
FROM workflow_module_rule_table_mapping mp
INNER JOIN alert_table_definition atd ON mp.rule_table_id = atd.alert_table_definition_id
WHERE mp.module_id = @module_id AND atd.is_action_view = 'y' AND ISNULL(mp.is_active,0) = 1
		
DECLARE @alert_id INT = -99,
		@event_trigger_id INT,
		@workflow_group_id INT = -1


SET @sql = 'CREATE TABLE ' + @process_table + ' (' + @primary_table + ' INT)
		INSERT INTO ' + @process_table + ' (' + @primary_table + ')
		SELECT ' + CAST(@source_id AS VARCHAR)
EXEC(@sql)

IF EXISTS (SELECT 1 FROM workflow_event_message WHERE event_trigger_id IS NULL AND event_message_id = @event_message_id)
BEGIN
	INSERT INTO event_trigger (create_user)
	SELECT dbo.FNADBUser()
	SET @event_trigger_id = IDENT_CURRENT('event_trigger')

	UPDATE workflow_event_message
	SET event_trigger_id = @event_trigger_id
	WHERE event_message_id = @event_message_id
END
ELSE
BEGIN
	SELECT @event_trigger_id = event_trigger_id FROM workflow_event_message WHERE event_message_id = @event_message_id
END

INSERT INTO alert_output_status (alert_sql_id, process_id, published, event_trigger_id)
SELECT @alert_id, @process_id, 'n', @event_trigger_id

EXEC spa_process_outstanding_alerts 
			@activity_process_id = @process_id,
			@alert_id = @alert_id,
			@process_table = @process_table,
			@primary_table = @primary_table,
			@event_trigger_id = @event_trigger_id,
			@workflow_group_id = @workflow_group_id,
			@run_only_individual_step = 'y'