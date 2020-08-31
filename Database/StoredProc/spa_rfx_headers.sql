IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_rfx_headers]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_rfx_headers]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Get Report Headers that includes tablix chart and gauge
	Parameters
	@flag				:	Selection variation flag
		's' => Return columns header names label with provided language
		'h'	=> Return column header names id
	@paramset_id		:	Report Paramset Id
	@runtime_user		:	Runtime user
	@page_id			:	Page
*/

CREATE PROCEDURE [dbo].[spa_rfx_headers]
		 @flag					CHAR(1) = 's'
		, @paramset_id			INT = NULL
		, @runtime_user			NVARCHAR(200) = NULL
		, @page_id				INT = NULL
	
AS

--DEBUG
-- EXEC spa_rfx_headers 's', 45188, 'navaraj'
--EXEC spa_rfx_headers @flag = 'h', @runtime_user = 'navaraj', @page_id = 43940

SET NOCOUNT ON -- NOCOUNT is set ON since returning row count has side effects on exporting table feature
	
IF ISNULL(@runtime_user, '') <> '' AND @runtime_user <> dbo.FNADBUser()   
BEGIN
	--EXECUTE AS USER = @runtime_user;
	DECLARE @contextinfo VARBINARY(128)
	SELECT @contextinfo = CONVERT(VARBINARY(128), @runtime_user)
	SET CONTEXT_INFO @contextinfo
END

DECLARE @language_id INT
SELECT @language_id = [language] FROM application_users WHERE user_login_id = @runtime_user
--SELECT @language_id = 101603

IF @flag = 's'
BEGIN
	DECLARE 
    @columns NVARCHAR(MAX) = '', 
    @sql     NVARCHAR(MAX) = '';

	SELECT @page_id = page_id FROM report_paramset WHERE report_paramset_id = @paramset_id

	if OBJECT_ID('tempdb..#tmp_report_header_alias') is not null drop table #tmp_report_header_alias
	if OBJECT_ID('tempdb..#tmp_report_header_cols') is not null drop table #tmp_report_header_cols

	SELECT
		tbl.alias, MAX(tbl.text_format_required) text_format_required
		INTO #tmp_report_header_alias
		FROM
		(
			SELECT rtc.alias, 0 AS text_format_required
			FROM
			report_page_tablix rpt 
			INNER JOIN report_tablix_column rtc ON rtc.tablix_id = rpt.report_page_tablix_id
			WHERE rpt.page_id = @page_id
			UNION ALL
			SELECT rcc.alias, 0 AS text_format_required
			FROM
			report_page_chart rpc
			INNER JOIN report_chart_column rcc ON rcc.chart_id = rpc.report_page_chart_id
			WHERE rpc.page_id = @page_id
			UNION ALL
			SELECT rpc.x_axis_caption alias, 0 AS text_format_required
			FROM
			report_page_chart rpc
			WHERE rpc.page_id = @page_id AND NULLIF(rpc.x_axis_caption,'') IS NOT NULL
			UNION ALL
			SELECT rpc.y_axis_caption alias, 0 AS text_format_required
			FROM
			report_page_chart rpc
			WHERE rpc.page_id = @page_id AND NULLIF(rpc.y_axis_caption,'') IS NOT NULL
			UNION ALL
			SELECT rpc.[name] alias, 1 AS text_format_required
			FROM report_page_chart rpc
			WHERE rpc.page_id = @page_id AND NULLIF(rpc.[name],'') IS NOT NULL
			UNION ALL
			SELECT 'No Data Available' alias, 0 AS text_format_required
			UNION ALL
			SELECT 'Total' alias, 0 AS text_format_required
			UNION ALL
			SELECT 'Sub Total' alias, 0 AS text_format_required

		) tbl
		GROUP BY tbl.alias
		
	SELECT
		REPLACE(REPLACE([dbo].[FNAReplaceSpecialChars](rtc.alias, '_'),'[','_'),']','_') AS alias, 
		ISNULL(lm.translated_keyword, CASE WHEN rtc.text_format_required = 1 THEN REPLACE(rtc.alias,'_',' ') ELSE rtc.alias END) As translated_keyword
		INTO #tmp_report_header_cols
		FROM
		#tmp_report_header_alias rtc
		OUTER APPLY (
			SELECT translated_keyword 
			FROM locale_mapping 
			WHERE language_id = @language_id AND LOWER(original_keyword) = LOWER(rtc.alias)
		) lm
	

	SELECT 
		@columns += QUOTENAME(alias) + ','
	FROM 
		#tmp_report_header_cols
		
	SET @columns = LEFT(@columns, LEN(@columns) - 1);

	-- construct dynamic SQL
	SET @sql ='
	SELECT * FROM   
	(
		SELECT 
			translated_keyword,
			alias
		FROM 
			#tmp_report_header_cols
	) t 
	PIVOT(
		MAX(translated_keyword) 
		FOR alias IN ('+ @columns +')
	) AS pivot_table;';

	-- execute the dynamic SQL
	EXECUTE sp_executesql @sql;

END
ELSE IF @flag = 'h'
BEGIN
	
	SELECT STUFF(
		(
		SELECT
		',' + REPLACE(REPLACE([dbo].[FNAReplaceSpecialChars](tbl.alias, '_'),'[','_'),']','_')
		FROM
		(
			SELECT rtc.alias
			FROM
			report_page_tablix rpt 
			INNER JOIN report_tablix_column rtc ON rtc.tablix_id = rpt.report_page_tablix_id
			WHERE rpt.page_id = @page_id
			UNION ALL
			SELECT rcc.alias
			FROM
			report_page_chart rpc
			INNER JOIN report_chart_column rcc ON rcc.chart_id = rpc.report_page_chart_id
			WHERE rpc.page_id = @page_id
			UNION ALL
			SELECT rpc.x_axis_caption alias
			FROM
			report_page_chart rpc
			WHERE rpc.page_id = @page_id AND NULLIF(rpc.x_axis_caption,'') IS NOT NULL
			UNION ALL
			SELECT rpc.y_axis_caption alias
			FROM
			report_page_chart rpc
			WHERE rpc.page_id = @page_id AND NULLIF(rpc.y_axis_caption,'') IS NOT NULL
			UNION ALL
			SELECT rpc.[name] alias
			FROM report_page_chart rpc
			WHERE rpc.page_id = @page_id AND NULLIF(rpc.[name],'') IS NOT NULL
			UNION ALL
			SELECT 'No Data Available' alias
			UNION ALL
			SELECT 'Total' alias
			UNION ALL
			SELECT 'Sub Total' alias

		) tbl
		GROUP BY tbl.alias
		FOR XML PATH('')
		)
		,1,1,'') as header_list


END
GO
