
IF OBJECT_ID('[dbo].[spa_clr_error_log]') IS NOT NULL
    DROP PROC spa_clr_error_log
GO
CREATE PROC [dbo].[spa_clr_error_log]
@flag CHAR(1) = 's'
, @event_log_description	NVARCHAR(2048) = NULL
, @assembly_method	NVARCHAR(1024) = NULL
, @message	NVARCHAR(MAX) = NULL
, @inner_exception	NVARCHAR(MAX) = NULL
, @stack_trace	NVARCHAR(MAX) = NULL
, @param	NVARCHAR(1024) = NULL
, @process_id NVARCHAR(255) = NULL
, @process_log NVARCHAR(2048) = NULL
AS
BEGIN
	IF @flag = 'i'
	BEGIN
	    DECLARE @object_name VARCHAR(255)
	    SELECT @object_name = o.name
	    FROM   sys.assembly_modules am
	           INNER JOIN sys.assemblies a
	                ON  a.assembly_id = am.assembly_id
	           INNER JOIN sys.objects o
	                ON  o.object_id = am.object_id
	    WHERE  am.assembly_method = @assembly_method
	    
	    IF OBJECT_ID('tempdb..#process_logs') IS NOT NULL
	        DROP TABLE tempdb..#process_logs
	    
	    CREATE TABLE #process_logs
	    (
	    	Id                INT,
	    	[description]     NVARCHAR(1024) COLLATE DATABASE_DEFAULT
	    )
	    
	    DECLARE @idoc INT
	    EXECUTE sp_xml_preparedocument @idoc OUTPUT, @process_log
	    
	    INSERT INTO #process_logs
	    SELECT *
	    FROM   OPENXML(@idoc, '/ProcessLog/Log', 2)
	           WITH (Id VARCHAR(50), [Description] VARCHAR(50))
	    
	    INSERT INTO clr_error_log
	      (
	        [event_log_description],
	        [assembly_method],
	        [object_name],
	        [message],
	        [inner_exception],
	        [stack_trace],
	        [log_date],
	        [user_name],
	        [param],
	        [step_sequence],
	        [process_id],
	        [step_description]
	      )
	    SELECT l.[event_log_description],
	           l.[assembly_method],
	           l.[object_name],
	           l.[message],
	           l.[inner_exception],
	           l.[stack_trace],
	           l.[log_date],
	           l.[user_name],
	           l.[param],
	           pl.[id],
	           l.[process_id],
	           pl.[description]
	    FROM   #process_logs pl
	           RIGHT JOIN (
	                    SELECT @event_log_description [event_log_description],
	                           @assembly_method [assembly_method],
	                           @object_name [object_name],
	                           @message [message],
	                           @inner_exception [inner_exception],
	                           @stack_trace [stack_trace],
	                           GETDATE() [log_date],
	                           dbo.FNADBUser() [user_name],
	                           @param [param],
	                           @process_id [process_id]
	                ) l
	                ON  1 = 1
	END
	ELSE
	    SELECT *
	    FROM   clr_error_log
	    ORDER BY
	           clr_error_log_id DESC
END
