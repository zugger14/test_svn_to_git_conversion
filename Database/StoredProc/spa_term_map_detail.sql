IF OBJECT_ID(N'[dbo].[spa_term_map_detail]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_term_map_detail]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Stored Procedure for Term mapping UI

	Parameters 
	@flag : Operation Flag
	@xml: Filter XML

*/

CREATE PROC [dbo].[spa_term_map_detail]
	@flag CHAR(1) = NULL
  ,	@xml XML = NULL
AS

SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX)
	, @term_code VARCHAR(100)	= NULL
	, @term_start VARCHAR(100) = NULL
	, @term_end VARCHAR(100) = NULL
	
IF @flag = 's'
BEGIN
	IF @xml IS NOT NULL
	BEGIN
		DECLARE @idoc INT

		EXEC sp_xml_preparedocument @idoc OUTPUT
			, @xml
      
		SELECT 
			@term_code = NULLIF(term_code, '') 
			, @term_start = NULLIF(term_start, '')
			, @term_end = NULLIF(term_end, '')
		FROM  OPENXML(@idoc, '/FormXML', 1)
		WITH (
			term_code VARCHAR(100) COLLATE DATABASE_DEFAULT
			, term_start DATETIME
			, term_end DATETIME
		)
	END

	SET @sql = '
		SELECT ttm.term_map_id [Mapping ID]
			, ttm.term_code [Term Code]
			, (
				CASE 
					WHEN ttm.date_or_block = ''d'' THEN ''Date''
					WHEN ttm.date_or_block = ''b'' THEN ''Block''
					WHEN ttm.date_or_block = ''m'' THEN ''Balance of Month''
					ELSE ''Relative''
				END
			) [Date/Block/Relative]
			, dbo.FNAUserDateFormat(ttm.term_start,dbo.FNADBUser()) [Term Start]
			, dbo.FNAUserDateFormat(ttm.term_end,dbo.FNADBUser()) [Term End]
			, sdv.code [Working Days]
			, sdv1.code [Holiday Calendar]
			, ttm.relative_days [Relative Days]
			, ttm.no_of_days [No of Days]
			, (
				CASE 
					WHEN ttm.holiday_include_exclude = ''i'' THEN ''Include''
					ELSE ''Exclude''
				END
			) [Holiday Include/Exclude]
		FROM term_map_detail ttm
		LEFT JOIN static_data_value sdv
			ON ttm.working_day_id = sdv.value_id
		LEFT JOIN static_data_value sdv1
			ON ttm.holiday_calendar_id = sdv1.value_id
		WHERE 1 = 1
	'
		
	IF @term_code IS NOT NULL 
	BEGIN
		SET @sql = @sql + ' AND term_code LIKE ''%' + @term_code + '%'''
	END
		
	IF @term_start IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND term_start >= dbo.FNAGetSQLStandardDate(''' + @term_start + ''')'
	END
		
	IF @term_end IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND term_end <= dbo.FNAGetSQLStandardDate(''' + @term_end + ''')'
	END

	EXEC (@sql)
END
