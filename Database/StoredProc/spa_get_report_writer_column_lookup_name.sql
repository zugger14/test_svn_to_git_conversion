
IF OBJECT_ID(N'[dbo].[spa_get_report_writer_column_lookup_name]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_report_writer_column_lookup_name]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==================================================================================================================
-- Author:		<bbajracharya@pioneersolutionsglobal.com>
-- Create date: 2010-04-27
-- Description:	Gets the name of applied look-up filter column in Report Writer Report for given value.
--				Report Writer Criteria page shows lookup values in case of dropdown filters
--				eg. UOM dropdown. If now 'Tons' will be selected, its ID:526 will be passed in query
--				This function will retrieve Tons if given 526 to be shown in applied filters in final HTML report.
-- Params:	
--		@column_id		int	 - report writer column id
--		@filter_value	varchar(1000) - the Value (Name) for which ID need to be returned
-- eg: EXEC spa_get_report_writer_column_lookup_name 194, 526

-- History:
-- 2012-07-11 - <mmmandhar@pioneersolutionsglobal.com>
--	Used spa_execute_query to populate dropdown data so that other formats like [code, data] are also supported
-- ==================================================================================================================

CREATE PROCEDURE [dbo].[spa_get_report_writer_column_lookup_name] 
	@column_id		varchar(1000)	
	, @filter_value	varchar(1000)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @sql	varchar(8000)
		
	CREATE TABLE #tmp_lookup_table
	(
		id		VARCHAR(1000) COLLATE DATABASE_DEFAULT
		, val	varchar(1000) COLLATE DATABASE_DEFAULT
	)
	
	--get the query for reading all lookup values
	SELECT @sql = data_source FROM report_writer_column rwc WHERE rwc.report_column_id = @column_id
	
	INSERT INTO #tmp_lookup_table (id, val)
	EXEC spa_execute_query @sql
	
	SELECT * FROM #tmp_lookup_table WHERE id = @filter_value
END
