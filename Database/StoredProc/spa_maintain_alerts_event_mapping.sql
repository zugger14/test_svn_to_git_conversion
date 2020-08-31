IF OBJECT_ID(N'[dbo].[spa_maintain_alerts_event_mapping]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_maintain_alerts_event_mapping]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: bbishural@pioneersolutionsglobal.com
-- Create date: 2011-08-22
-- Description: CRUD operations for table time_zone
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_maintain_alerts_event_mapping]
    @flag CHAR(1),
    @module_events_id INT = NULL,
    @module_id INT = NULL,
    @event_id INT = NULL,
    @alert_id INT = NULL 
AS
 
DECLARE @SQL VARCHAR(MAX)
 
IF @flag = 's'
BEGIN
	SELECT me.module_events_id AS [ModuleEventID],
		   sdv.code AS [Module], 
	       sdv1.code AS [Event],
	       modules_id AS [ModuleID],
	       event_id AS [EventID]
	FROM   module_events me
	       LEFT JOIN static_data_value sdv ON  sdv.value_id = me.modules_id
	       LEFT JOIN static_data_value sdv1 ON  sdv1.value_id = me.event_id
	WHERE  sdv.[type_id] = 20600 AND sdv1.[type_id] = 20500 
END
ELSE IF @flag = 'a'
BEGIN
    --SELECT A MATCHED ROW FROM THE TABLE
    SELECT me.module_events_id AS [ModuleEventID],
	       modules_id AS [ModuleID],
	       event_id AS [Event]
	FROM   module_events me
	       LEFT JOIN static_data_value sdv ON  sdv.value_id = me.modules_id
	       LEFT JOIN static_data_value sdv1 ON  sdv1.value_id = me.event_id
    WHERE  module_events_id = @module_events_id
    
END
ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM module_events WHERE modules_id = @module_id AND event_id = @event_id)
		BEGIN
			EXEC spa_ErrorHandler -1,
		     'module_events',
		     'spa_maintain_alerts_event_mapping',
		     'Error',
		     'Could not insert the data. The combination of module and event already exists.',
		     ''
			RETURN
		END
		
		INSERT INTO module_events (
			modules_id,
			event_id
		)
		VALUES (
			@module_id,
			@event_id
		)
		
		EXEC spa_ErrorHandler 0,
		     'module_events',
		     'spa_maintain_alerts_event_mapping',
		     'Success',
		     'Insert Successfully.',
		     ''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1,
		     'module_events',
		     'spa_maintain_alerts_event_mapping',
		     'Error',
		     'Could not insert the data.',
		     ''
	END CATCH
END 
ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM module_events WHERE modules_id = @module_id AND event_id = @event_id AND module_events_id <> @module_events_id )
		BEGIN
			EXEC spa_ErrorHandler -1,
		     'module_events',
		     'spa_maintain_alerts_event_mapping',
		     'Error',
		     'Could not update the data. The combination of module and event already exists.',
		     ''
			RETURN
		END
		
		UPDATE module_events
		SET    modules_id = @module_id,
			   event_id = @event_id
		WHERE  module_events_id = @module_events_id
		
		EXEC spa_ErrorHandler 0,
				 'module_events',
				 'spa_maintain_alerts_event_mapping',
				 'Success',
				 'Update Successfully.',
				 ''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1,
				 'module_events',
				 'spa_maintain_alerts_event_mapping',
				 'Error',
				 'Couldnot update the data.',
				 ''
	END CATCH
	
END
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		DELETE 
		FROM   module_events
		WHERE  module_events_id = @module_events_id
		
		EXEC spa_ErrorHandler 0,
		     'module_events',
		     'spa_maintain_alerts_event_mapping',
		     'Success',
		     'Update Successfully.',
		     ''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1,
		     'module_events',
		     'spa_maintain_alerts_event_mapping',
		     'Success',
		     'Could not delete the data.',
		     ''
	END CATCH
    
END
ELSE IF @flag = 'x' --select the data for alert event mapping grid
BEGIN
	SELECT event_trigger_id AS [EventID],
	       modules_event_id AS [ModuleID],
	       alert_id AS [AlertID],
	       as1.[alert_sql_name] AS [Alert]
	FROM   event_trigger et
	       INNER JOIN module_events me ON  me.module_events_id = et.modules_event_id
	       LEFT JOIN alert_sql as1 ON  as1.alert_sql_id = et.alert_id
	WHERE  me.module_events_id = @module_events_id
END
ELSE IF @flag = 'y' --to populate the alert id dropdown value
BEGIN
	DECLARE @is_admin  INT,
        @user_id   VARCHAR(100)

	SET @user_id = dbo.FNADBUser()
	SELECT @is_admin = dbo.FNAIsUserOnAdminGroup(@user_id, 1)
	
	SELECT asl.alert_sql_id,
	       asl.alert_sql_name
	FROM   alert_sql asl
	WHERE asl.system_rule = 'n' OR (asl.system_rule = 'y' AND @is_admin = 1)
END
ELSE IF @flag = 'z' --to insert on alert event grid
BEGIN
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM event_trigger WHERE modules_event_id = @module_events_id AND alert_id = @alert_id)
		BEGIN
			EXEC spa_ErrorHandler -1,
		     'event_trigger',
		     'spa_maintain_alerts_event_mapping',
		     'Error',
		     'Could not update the data. The combination of module and alert already exists.',
		     ''
			RETURN
		END
		
		INSERT INTO event_trigger
		(
			modules_event_id,
			alert_id
		)
		VALUES
		(
			@module_events_id,
			@alert_id
		)
		
		EXEC spa_ErrorHandler 0,
		     'event_trigger',
		     'spa_maintain_alerts_event_mapping',
		     'Success',
		     'Data inserted Successfully.',
		     ''
		
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1,
		     'event_trigger',
		     'spa_maintain_alerts_event_mapping',
		     'Error',
		     'Unable to insert the data',
		     ''
	END CATCH
END
ELSE IF @flag = 'v' --update the alert event grid
BEGIN
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM event_trigger WHERE event_trigger_id <> @event_id AND modules_event_id = @module_events_id AND alert_id = @alert_id)
		BEGIN
			EXEC spa_ErrorHandler -1,
		     'event_trigger',
		     'spa_maintain_alerts_event_mapping',
		     'Error',
		     'Could not update the data. The combination of module and alert already exists.',
		     ''
			RETURN
		END
		
		UPDATE event_trigger
		SET alert_id = @alert_id,
			modules_event_id = @module_events_id
		WHERE event_trigger_id = @event_id
		
		EXEC spa_ErrorHandler 0,
		     'event_trigger',
		     'spa_maintain_alerts_event_mapping',
		     'Success',
		     'Data updated Successfully.',
		     ''
		
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1,
		     'event_trigger',
		     'spa_maintain_alerts_event_mapping',
		     'Error',
		     'Unable to update the data',
		     ''
	END CATCH
END
ELSE IF @flag = 'w' --to select the corresponding alert id for event trigger id
BEGIN
	SELECT event_trigger_id , modules_event_id, alert_id
	FROM event_trigger
	WHERE event_trigger_id = @event_id
END
ELSE IF @flag = 'm' --delete the alert event grid
BEGIN
	BEGIN TRY
		DELETE FROM event_trigger
		WHERE event_trigger_id = @event_id
		
		EXEC spa_ErrorHandler 0,
		     'event_trigger',
		     'spa_maintain_alerts_event_mapping',
		     'Success',
		     'Data deleted Successfully.',
		     ''
		
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1,
		     'event_trigger',
		     'spa_maintain_alerts_event_mapping',
		     'Error',
		     'Unable to delete the data',
		     ''
	END CATCH
END