IF OBJECT_ID(N'[dbo].[spa_eod_process_status_log]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_eod_process_status_log]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ============================================================================================================================
-- Author: Pawan Adhikari
-- Create date: 2012-03-09 08:45PM
-- Description: Log EOD Process.
--              
-- Params:
-- @master_process_id varchar(120) - Master Process ID
-- @as_of_date varchar(10) - Date
-- ============================================================================================================================
CREATE PROCEDURE [dbo].[spa_eod_process_status_log]
	@master_process_id VARCHAR(120),
	@as_of_date VARCHAR(10) = NULL
AS

DECLARE @sql VARCHAR(MAX)
SET @sql = 'SELECT dbo.FNADateFormat(as_of_date) [As of Date], 
				   CASE WHEN (status = ''Error'') THEN ''<font color="red"><b>'' + [status] + ''</b></font>'' ELSE [status] END AS [Status],
				   [source] AS [Source],
				   REPLACE([message], ''dev/'', '''') AS [Description]--,
				   --[process_id] AS [Process ID]
			FROM   eod_process_status
			WHERE  1 = 1 '

IF @master_process_id IS NOT NULL
BEGIN
	SET @sql = @sql + ' AND master_process_id = ''' + @master_process_id + ''''
END

IF @as_of_date IS NOT NULL
BEGIN
	SET @sql = @sql + ' AND as_of_date BETWEEN CAST(''' + @as_of_date + ''' AS DATETIME) AND CAST(''' + @as_of_date + ' 23:59:59.997'' AS DATETIME)'
END

SET @sql = @sql + ' ORDER BY create_ts' 
EXEC spa_print @sql
EXEC(@sql)