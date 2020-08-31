

IF OBJECT_ID(N'[dbo].[spa_eod_process_status]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_eod_process_status]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ============================================================================================================================
-- Author: Pawan Adhikari
-- Create date: 2012-03-09 08:45PM
-- Description: EOD Log Process Status.
--              
-- Params:
-- @flag char(1) - flag
-- @eod_process_status_id INT = NULL
-- @as_of_date VARCHAR(10) = NULL
-- @step INT = NULL - EOD Step Static Data Value
-- @desc VARCHAR(500) =  NULL
-- ============================================================================================================================
CREATE PROCEDURE [dbo].[spa_eod_process_status]
	@flag CHAR(1),
	@eod_process_status_id INT = NULL,
	@as_of_date VARCHAR(10) = NULL,
	@step INT = NULL,
	@desc VARCHAR(500) =  NULL,
	@master_process_id VARCHAR(500) =  NULL
AS

DECLARE @sql VARCHAR(MAX)
DECLARE @source VARCHAR(600)


IF @flag = 's'
BEGIN
	
	SET @sql = 'SELECT eps.id AS [ID],
					   eps.master_process_id [Master Process ID],
					   --dbo.FNADateFormat(eps.as_of_date) [As of Date], 
					   eps.source AS [Source],
					   sdv.value_id [StepId],
					   CASE WHEN (eps.STATUS = ''ERROR'') THEN '' <font color=red> '' + eps.status + '' </font> '' ELSE eps.status END AS [Status],
					   dbo.FNAStripHTML(REPLACE(eps.message, ''dev / '', '''')) AS [Description]
				FROM   eod_process_status eps
				LEFT JOIN static_data_value sdv ON  eps.source = sdv.code
				WHERE  1 = 1'

	IF @as_of_date IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND eps.as_of_date BETWEEN CAST(''' + @as_of_date + ''' AS DATETIME) AND CAST(''' + @as_of_date + ' 23:59:59.997'' AS DATETIME)'
	END

	SET @sql = @sql + ' ORDER BY eps.id,eps.create_ts, sdv.value_id' 
	EXEC spa_print @sql
	EXEC(@sql)
END

IF @flag = 'a'
BEGIN
	
	SET @sql = 'SELECT eps.id AS [ID],
	                   eps.source,
	                   sdv.value_id [ValueId],
	                   eps.status,
	                   REPLACE(eps.message, ''dev / '', '''') AS [Description]
	            FROM   eod_process_status eps
	            LEFT JOIN static_data_value sdv ON  eps.source = sdv.code
	            WHERE  1 = 1'

	SET @sql = @sql + ' AND eps.id = ' + CAST(@eod_process_status_id AS VARCHAR(20)) + ''
	 
	EXEC spa_print @sql
	EXEC(@sql)
END

IF @flag = 'i'
BEGIN	
	              
    SELECT @source = sdv.code FROM static_data_value sdv WHERE  sdv.value_id = @step
    
	INSERT INTO eod_process_status
	  (
	    master_process_id,
	    process_id,
	    source,
	    [status],
	    [message],
	    as_of_date,
	    message_detail
	  )
	SELECT dbo.FNAGetNewID(),
	       dbo.FNAGetNewID(),
	       @source,
	       NULL,
	       @desc,
	       @as_of_date,
	       NULL
	
	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR, 'EoD Log Status', 'spa_eod_process_status', 'DB ERROR', 'ERROR Inserting EoD Log Information.', ''
	ELSE
	    EXEC spa_ErrorHandler 0, 'EoD Log Status', 'spa_eod_process_status', 'Success', 'EoD Log Information successfully inserted.', ''
END


IF @flag = 'u'
BEGIN
	
	SELECT @source = sdv.code FROM static_data_value sdv WHERE sdv.value_id = @step

	UPDATE eod_process_status
	SET source = @source,
		[message] = @desc,
		as_of_date = @as_of_date
	WHERE id = @eod_process_status_id

	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR, 'EoD Log Status', 'spa_eod_process_status', 'DB ERROR', 'ERROR Updating EoD Log Information.', ''
	ELSE
	    EXEC spa_ErrorHandler 0, 'EoD Log Status', 'spa_eod_process_status', 'Success', 'EoD Log Information successfully updated.', ''
END

IF @flag = 'd'
BEGIN
	
	DELETE FROM eod_process_status WHERE id = @eod_process_status_id	

	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR, 'EoD Log Status', 'spa_eod_process_status', 'DB ERROR', 'ERROR Deleting EoD Log Information.', ''
	ELSE
	    EXEC spa_ErrorHandler 0, 'EoD Log Status', 'spa_eod_process_status', 'Success', 'EoD Log Information successfully deleted.', ''
END

IF @flag = 'z'
BEGIN
	CREATE TABLE #eod_steps
	(
		[type_id]        [int] NOT NULL,
		[value_id]       [int] NOT NULL,
		[Code]           [varchar](500) COLLATE DATABASE_DEFAULT  NULL,
		[Description]    [varchar](500) COLLATE DATABASE_DEFAULT  NULL,
		[entity_id]      [int] NULL,
		[category_id]    [int] NULL,
		[category_name]  [varchar](50) COLLATE DATABASE_DEFAULT  NULL
	)

	INSERT INTO #eod_steps EXEC spa_StaticDataValues 's',	19700
	
	SELECT [type_id],
	       [value_id],
	       [Code],
	       [Description],
	       [entity_id],
	       [category_id],
	       [category_name]
	FROM   #eod_steps
	ORDER BY  value_id
END

IF @flag = 'r'
BEGIN
	
	SET @sql = 'SELECT eps.id AS [ID],
					  ISNULL(event_message_name,eps.source) AS [Source],
					   CASE 
							WHEN (eps.STATUS = ''ERROR'') THEN '' <font color=red> '' + eps.status + '' </font> '' 
							ELSE eps.status 
					   END AS [Status],
					   REPLACE(eps.message,''href="./'',''href="../../../adiha.php.scripts/'') AS [Description],
					   eps.create_ts
				FROM   eod_process_status eps
				LEFT JOIN workflow_activities wa ON wa.process_id = eps.process_id
				LEFT JOIN workflow_event_message wem ON wa.event_message_id = wem.event_message_id
				LEFT JOIN static_data_value sdv ON  eps.source = sdv.code
				WHERE  1 = 1'

	IF @as_of_date IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND eps.as_of_date BETWEEN CAST(''' + @as_of_date + ''' AS DATETIME) AND CAST(''' + @as_of_date + ' 23:59:59.997'' AS DATETIME)'
	END

	IF @master_process_id IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND eps.master_process_id =''' + @master_process_id + ''''
	END

	SET @sql = @sql + ' ORDER BY eps.id, eps.create_ts, sdv.value_id' 
	--PRINT @sql
	EXEC(@sql)
END



