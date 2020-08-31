/****** Object:  UserDefinedFunction [dbo].[FNAReplaceRWParams]    Script Date: 07/30/2009 09:26:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAReplaceRWParams]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAReplaceRWParams]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===============================================================================================
-- Create date: 2009-07-30 09:50AM
-- Description:	Replaces parameters with its respective values in report query
-- Params:
--	
-- ===============================================================================================
CREATE FUNCTION [dbo].FNAReplaceRWParams(
	@sql_stmt		varchar(max)
	, @criteria		varchar(5000) = NULL
)
RETURNS varchar(max)
AS
BEGIN
	DECLARE @next_param		varchar(1000)
	DECLARE @value			varchar(1000)
	DECLARE @parameter		varchar(1000)
	DECLARE @index_equal	int 
	DECLARE @index			int
	DECLARE @as_of_date		varchar(20)

	SET @index = 1
	SET @index_equal = 1

	--SET @criteria = REPLACE(@criteria, ' ', '') -- get rid of white spaces
	IF @criteria IS NOT NULL AND @criteria <> ''
	BEGIN
		WHILE (@index <> 0)
		BEGIN
			SET @index = CHARINDEX(',', @criteria)
			--PRINT @index
			IF @index = 0 --only one name-value pair left
				SET @next_param = @criteria --take whole criteria as next_param as only one name-value pair left
			ELSE
				SET @next_param = SUBSTRING(@criteria, 1, @index - 1)
			
			SET @index_equal = CHARINDEX('=', @next_param, 1)

			--get param name
			SET @parameter = '@' + LTRIM(RTRIM(SUBSTRING(@next_param, 1, @index_equal - 1)))
			
			--get param value
			SET @value = LTRIM(RTRIM(SUBSTRING(@next_param, @index_equal + 1, LEN(@next_param))))
			
			--if book structure tree view filter available, replace underscore(!) with comma(,)
			/*
			IF EXISTS(SELECT 1 FROM Report_record rr 
						INNER JOIN report_writer_column rwc ON rwc.report_id = rr.report_id 
						LEFT OUTER JOIN report_where_column_required rwcr ON rwcr.column_name = rwc.column_name 
							AND	rr.report_tablename = rwcr.table_name
			          WHERE (rwc.filter_column = 'true' OR rwcr.where_required = 'Y')
							AND ISNULL(rwcr.control_type, rwc.control_type) = 'BSTREE'
							AND '@' + rwc.column_name = @parameter
			)
			
			BEGIN
			*/
			--comma (,) has been replaced by ! to parse them correctly in spa_html_header, so need to replace them back	
			SET @value = REPLACE(@value, '!', ',')
			--END
	
			--PRINT @parameter + '=' + @value
			
			SET @sql_stmt = REPLACE(@sql_stmt, @parameter, @value)

			IF (@parameter = '@pnl_as_of_date' OR @parameter = '@as_of_date')
				SET @as_of_date = @value

			--chop off the processed part from @criteria
			SET @criteria = SUBSTRING(@criteria, @index + 1, LEN(@criteria))
			--PRINT '@criteria:' + @criteria
		END
	END
	
	-------------Replace the tables that could be in archival tables
	--Replace ' with " to make it valid in all cases so that no escaping is required. Make sure QUOTED_IDENTIFIER is set OFF
	--to make the query valid.
	SET @sql_stmt = REPLACE(@sql_stmt, ' source_deal_pnl ', REPLACE(dbo.FNAGetProcessTableInternal(@as_of_date, 'source_deal_pnl'), '''', '"') + ' ')
	SET @sql_stmt = REPLACE(@sql_stmt, ' calcprocess_deals ', REPLACE(dbo.FNAGetProcessTableInternal(@as_of_date, 'calcprocess_deals'), '''', '"') + ' ')
	SET @sql_stmt = REPLACE(@sql_stmt, ' calcprocess_aoci_release ', REPLACE(dbo.FNAGetProcessTableInternal(@as_of_date, 'calcprocess_aoci_release'), '''', '"') + ' ')
	SET @sql_stmt = REPLACE(@sql_stmt, ' report_measurement_values ', REPLACE(dbo.FNAGetProcessTableInternal(@as_of_date, 'report_measurement_values'), '''', '"') + ' ')
	SET @sql_stmt = REPLACE(@sql_stmt, ' report_netted_gl_entry ', REPLACE(dbo.FNAGetProcessTableInternal(@as_of_date, 'report_netted_gl_entry'), '''', '"') + ' ')
	
	RETURN(@sql_stmt)

END




