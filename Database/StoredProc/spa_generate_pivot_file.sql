IF OBJECT_ID(N'[dbo].[spa_generate_pivot_file]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_generate_pivot_file]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/**
	Purpose			: Generate csv file for pivot feature in view report.
	Created By		: rajiv@pioneersolutionsglobal.com
	Created Date	: 2008-09-09
	Modified By		: sligal@pioneersolutionsglobal.com

	Parameters 
	@paramset_id	: report_paramset_id from view report to process for pivot.
	@component_id	: component_id (item_id i.e. tablix_id,chart_id,gauge_id,etc) of the report item.
	@criteria		: Report filter criterias to run the report.
	@server_path	: Valid file path to save the generated csv file.
	@report_name	: Used as a filename for generated csv file.
	@file_name		: Filename of the pivot file

*/
CREATE PROCEDURE [dbo].[spa_generate_pivot_file]    
	@paramset_id			INT = NULL
	, @component_id			INT = NULL
	, @criteria				VARCHAR(max) = NULL
	, @server_path			VARCHAR(2000) = NULL
	, @report_name			VARCHAR(200) = NULL
	, @file_name			VARCHAR(300) = NULL
AS
/*
declare @paramset_id			INT = NULL
	, @component_id			INT = NULL
	, @criteria				VARCHAR(5000) = NULL
	, @server_path			VARCHAR(2000) = NULL
	, @report_name			VARCHAR(200) = NULL

select @paramset_id=17390, @component_id=5746, @criteria='sub_id=1586,stra_id=1587,book_id=1590,sub_book_id=1358', @server_path='D:\Farrms\TRMTracker_New_Framework_Trunk\FARRMS\trm\adiha.php.scripts\dev\shared_docs\temp_Note', @report_name='deal detail chart'

--*/

SET NOCOUNT ON 
DECLARE @SQL VARCHAR(MAX)

BEGIN
    DECLARE @output_table		VARCHAR(300)
    DECLARE @process_id			VARCHAR(200) = dbo.FNAGetNewId()
    DECLARE @user_name          VARCHAR(100) = dbo.FNADBUser()
    DECLARE @full_file_path     VARCHAR(2000)
    DECLARE @output_table1		VARCHAR(300) -- To store table data after rounding and user dateformat conversion
	DECLARE @process_id1		VARCHAR(200) = dbo.FNAGetNewId()
    DECLARE @sql_query			VARCHAR(MAX)
	DECLARE @select_string		VARCHAR(MAX)
	
	IF @server_path IS NULL
		SELECT @server_path = document_path + '\temp_Note\' FROM connection_string

    SET @output_table = dbo.FNAProcessTableName('report_output_table', @user_name, @process_id)
	SET @output_table1 = dbo.FNAProcessTableName('report_output_table', @user_name, @process_id1)

	declare @display_type char(10) = 't'
	select top 1 @display_type = u.[display_type]
	from (
		select t.report_page_tablix_id [item_id], case when t.no_header is not null then 't' else null end [display_type] 
		from report_page_tablix t 
		where t.report_page_tablix_id=@component_id
		union all
		select c.report_page_chart_id [item_id], case when c.chart_properties is not null then 'c' else null end [display_type] 
		from report_page_chart c 
		where c.report_page_chart_id=@component_id
		union all
		select g.report_page_gauge_id [item_id], case when g.gauge_label_column_id is not null then 'g' else null end [display_type] 
		from report_page_gauge g 
		where g.report_page_gauge_id=@component_id
	) u
    
	EXEC [spa_rfx_run_sql] @paramset_id=@paramset_id, @component_id=@component_id, @criteria=@criteria, @temp_table_name=@output_table, @display_type=@display_type

	-- Creating the new table to insert data after rounding and date conversion.
	
	IF OBJECT_ID('tempdb..#temp_date_fields') IS NOT NULL
		DROP TABLE #temp_date_fields
		
	CREATE TABLE #temp_date_fields (
		field_name VARCHAR(500) COLLATE DATABASE_DEFAULT
	)
	DECLARE @date_split_string VARCHAR(MAX)
	
	if @display_type = 't'
	begin
		SELECT @sql_query = STUFF(( SELECT CASE WHEN rtc.render_as = 4 THEN ',[' + rtc.alias + '] VARCHAR(200) , [' +  rtc.alias + '(Year)] VARCHAR(100), ' + '[' +  rtc.alias + '(Month)] VARCHAR(100), ' + '[' +  rtc.alias + '(Day)] VARCHAR(100) ' ELSE ',[' + rtc.alias + '] VARCHAR(200)' END
							FROM report_tablix_column rtc
							WHERE rtc.tablix_id = @component_id
							ORDER BY rtc.alias
							FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(8000)'),
								1, 1, '' )
								
	end
	else if @display_type = 'c'
	begin
		SELECT @sql_query = STUFF(( SELECT ',[' + rcc.alias + '] VARCHAR(200)'
							FROM report_chart_column rcc
							WHERE rcc.chart_id = @component_id
							ORDER BY rcc.alias
							FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(8000)'),
								1, 1, '' )							
	end
	else if @display_type = 'g'
	begin
		SELECT @sql_query = STUFF(( SELECT ',[' + rgc.alias + '] VARCHAR(200)'
							FROM report_gauge_column rgc
							WHERE rgc.gauge_id = @component_id
							ORDER BY rgc.alias
							FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(8000)'),
								1, 1, '' )
	END
	
	SET @sql_query = 'CREATE TABLE ' + @output_table1 + '(' + @sql_query + ')'
	EXEC(@sql_query)
	
	-- Rounding and date converion and inserting into new table
	if @display_type = 't'
	begin
		SELECT @sql_query = STUFF((SELECT ',' + 
									CASE WHEN rtc.render_as = 2 
										THEN 'CAST([' + rtc.alias + '] AS NUMERIC(38, ' + CAST(CASE rtc.rounding WHEN -1 THEN 2 ELSE rtc.rounding END AS VARCHAR) + ')) AS [' + rtc.alias + ']'  
									WHEN rtc.render_as = 4
									THEN
										CASE WHEN rtc.date_format = 1
											THEN 'CONVERT(VARCHAR,[' + rtc.alias + '], 101) AS [' + rtc.alias + ']'
										WHEN rtc.date_format = 2 
											THEN 'CONVERT(VARCHAR,[' + rtc.alias + '], 101) + '' '' + CAST(DATEPART(hh,[' + rtc.alias + '])  AS VARCHAR(10)) + '':'' + CAST(DATEPART(mm,[' + rtc.alias + '])  AS VARCHAR(10)) AS [' + rtc.alias + ']'
										WHEN rtc.date_format = 3 
											THEN 'CONVERT(VARCHAR,[' + rtc.alias + '], 101) + '' '' + CAST(DATEPART(hh,[' + rtc.alias + '])  AS VARCHAR(10)) + '':'' + CAST(DATEPART(mi,[' + rtc.alias + '])  AS VARCHAR(10)) + '':'' + CAST(DATEPART(ss,[' + rtc.alias + '])  AS VARCHAR(10)) AS [' + rtc.alias + ']'
										WHEN rtc.date_format = 4 
											THEN 'CONVERT(VARCHAR,[' + rtc.alias + '], 110) AS [' + rtc.alias + ']'
										WHEN rtc.date_format = 5 
											THEN 'CONVERT(VARCHAR,[' + rtc.alias + '], 110) + '' '' + CAST(DATEPART(hh,[' + rtc.alias + ']) AS VARCHAR(10)) + '':'' + CAST(DATEPART(mm,' + rtc.alias + ') AS [' + rtc.alias + ']'
										WHEN rtc.date_format = 6 
											THEN 'CONVERT(VARCHAR,[' + rtc.alias + '], 110) + '' '' + CAST(DATEPART(hh,[' + rtc.alias + ']) AS VARCHAR(10)) + '':'' + CAST(DATEPART(mi,[' + rtc.alias + ']) AS VARCHAR(10)) + '':'' + CAST(DATEPART(ss,[' + rtc.alias + ']) AS VARCHAR(10)) AS [' + rtc.alias + ']'
										WHEN rtc.date_format = 7 
											THEN 'CONVERT(VARCHAR,[' + rtc.alias + '], 103) AS [' + rtc.alias + ']'
										WHEN rtc.date_format = 8 
											THEN 'CONVERT(VARCHAR,[' + rtc.alias + '], 103) + '' '' + CAST(DATEPART(hh,[' + rtc.alias + ']) AS VARCHAR(10)) + '':'' + CAST(DATEPART(mm,' + rtc.alias + ') AS [' + rtc.alias + ']'
										WHEN rtc.date_format = 9 
											THEN 'CONVERT(VARCHAR,[' + rtc.alias + '], 103) + '' '' + CAST(DATEPART(hh,[' + rtc.alias + ']) AS VARCHAR(10)) + '':'' + CAST(DATEPART(mi,[' + rtc.alias + ']) AS VARCHAR(10)) + '':'' + CAST(DATEPART(ss,[' + rtc.alias + ']) AS VARCHAR(10)) AS [' + rtc.alias + ']'
										WHEN rtc.date_format = 10 
											THEN 'CONVERT(VARCHAR,[' + rtc.alias + '], 105) AS [' + rtc.alias + ']'
										WHEN rtc.date_format = 11
											THEN 'CONVERT(VARCHAR,[' + rtc.alias + '], 105) + '' '' + CAST(DATEPART(hh,[' + rtc.alias + ']) AS VARCHAR(10)) + '':'' + CAST(DATEPART(mm,' + rtc.alias + ') AS [' + rtc.alias + ']'
										WHEN rtc.date_format = 12
											THEN 'CONVERT(VARCHAR,[' + rtc.alias + '], 105) + '' '' + CAST(DATEPART(hh,[' + rtc.alias + ']) AS VARCHAR(10)) + '':'' + CAST(DATEPART(mi,[' + rtc.alias + ']) AS VARCHAR(10)) + '':'' + CAST(DATEPART(ss,[' + rtc.alias + ']) AS VARCHAR(10)) AS [' + rtc.alias + ']'
										WHEN rtc.date_format = 13
											THEN 'CONVERT(VARCHAR,[' + rtc.alias + '], 104) AS [' + rtc.alias + ']'
										WHEN rtc.date_format = 14
											THEN 'CONVERT(VARCHAR,[' + rtc.alias + '], 104) + '' '' + CAST(DATEPART(hh,[' + rtc.alias + ']) AS VARCHAR(10)) + '':'' + CAST(DATEPART(mm,' + rtc.alias + ') AS [' + rtc.alias + ']'
										WHEN rtc.date_format = 15
											THEN 'CONVERT(VARCHAR,[' + rtc.alias + '], 104) + '' '' + CAST(DATEPART(hh,[' + rtc.alias + ']) AS VARCHAR(10)) + '':'' + CAST(DATEPART(mi,[' + rtc.alias + ']) AS VARCHAR(10)) + '':'' + CAST(DATEPART(ss,[' + rtc.alias + ']) AS VARCHAR(10)) AS [' + rtc.alias + ']'
										ELSE 
											'dbo.FNADateFormat([' + rtc.alias + ']) AS [' + rtc.alias + ']'
										END
										+ + ', YEAR([' +  rtc.alias + ']), ' + 'DATENAME(month, [' +  rtc.alias + ']), ' + 'DAY([' +  rtc.alias + '])'
									ELSE
										'[' + rtc.alias + ']'
									END
								 
								FROM report_tablix_column rtc
								WHERE rtc.tablix_id = @component_id
								ORDER BY rtc.alias
								FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(8000)'),
								1, 1, '' )

		SELECT @select_string = STUFF(( SELECT CASE WHEN rtc.render_as = 4 THEN ',[' + rtc.alias + '] , [' +  rtc.alias + '(Year)], ' + '[' +  rtc.alias + '(Month)], ' + '[' +  rtc.alias + '(Day)]'  ELSE ',[' + rtc.alias + ']' END
							FROM report_tablix_column rtc
							WHERE rtc.tablix_id = @component_id
							ORDER BY rtc.alias
							FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(8000)'),
								1, 1, '' )
	end
	else if @display_type = 'c'
	begin
		SELECT @sql_query = STUFF((SELECT ',' + 
									CASE WHEN rd.name = 'FLOAT' 
										THEN 'CAST([' + rtc.alias + '] AS NUMERIC(38, 2)) AS [' + rtc.alias + ']'  
										WHEN rd.name = 'DATETIME'
										THEN 'dbo.FNADateFormat([' + rtc.alias + ']) AS VARCHAR(10)) AS [' + rtc.alias + ']'
										
									ELSE
										'[' + rtc.alias + ']'
									END
								 
								FROM report_chart_column rtc
								INNER JOIN data_source_column dsc ON rtc.column_id = dsc.data_source_column_id
								INNER JOIN report_datatype rd ON dsc.datatype_id = rd.report_datatype_id
								WHERE rtc.chart_id = @component_id
								ORDER BY rtc.alias
								FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(8000)'),
								1, 1, '' )

		SELECT @select_string = STUFF(( SELECT ',[' + rtc.alias + ']'
							FROM report_chart_column rtc
							WHERE rtc.chart_id = @component_id
							ORDER BY rtc.alias
							FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(8000)'),
								1, 1, '' )
	end
	else if @display_type = 'g'
	begin
		SELECT @sql_query = STUFF((SELECT ',' + 
									CASE WHEN rd.name = 'FLOAT' 
										THEN 'CAST([' + rtc.alias + '] AS NUMERIC(38, 2)) AS [' + rtc.alias + ']'  
										WHEN rd.name = 'DATETIME'
										THEN 'dbo.FNADateFormat([' + rtc.alias + ']) AS VARCHAR(10)) AS [' + rtc.alias + ']'
										
									ELSE
										'[' + rtc.alias + ']'
									END
								 
								FROM report_gauge_column rtc
								INNER JOIN data_source_column dsc ON rtc.column_id = dsc.data_source_column_id
								INNER JOIN report_datatype rd ON dsc.datatype_id = rd.report_datatype_id
								WHERE rtc.gauge_id = @component_id
								ORDER BY rtc.alias
								FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(8000)'),
								1, 1, '' )

		SELECT @select_string = STUFF(( SELECT ',[' + rtc.alias + ']'
							FROM report_gauge_column rtc
							WHERE rtc.gauge_id = @component_id
							ORDER BY rtc.alias
							FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(8000)'),
								1, 1, '' )
	END

	SET @select_string = 'INSERT INTO ' + @output_table1 + ' (' + @select_string + ') '
	SET @sql_query = @select_string + ' SELECT ' + @sql_query + ' FROM ' + @output_table
	--PRINT(@sql_query)
	EXEC(@sql_query)

	--INSERT NULL VALUES ROW SO THAT ATLEAST ONE ROW EXISTS THAT CAN BE PLOTTED ON PIVOT AREA ELSE 0 ROWS WILL GIVE ISSUES.
	declare @output_table1_column_count int

	select @output_table1_column_count = count(*)
	from adiha_process.INFORMATION_SCHEMA.COLUMNS WITH(NOLOCK) 
	WHERE table_catalog = 'adiha_process' and table_name = replace(@output_table1, 'adiha_process.dbo.','')

	SET @SQL = '
	if not exists(select top 1 1 from ' + @output_table1 + ')
	begin
		insert into ' + @output_table1 + '
		values(' + stuff(replicate(',NULL',@output_table1_column_count),1,1,'') + ')
	end
	'
	exec(@SQL)
	
	DECLARE @return_value INT = 0
	IF @file_name IS NULL
	BEGIN
		SET @return_value = 1
		SET @file_name = @report_name + convert(varchar(30), getdate(),112) + replace(convert(varchar(30), getdate(),114),':','') + '.csv'
    END

	SET @full_file_path = @server_path + '\' + @file_name
    --EXEC spa_dump_csv_v2 @output_table1, @full_file_path, 'n', ',', 'n'
    DECLARE @result NVARCHAR(1024)
	EXEC spa_export_to_csv @output_table1, @full_file_path, 'y', ',', 'n','y','n','y',@result OUTPUT

	IF @return_value = 1
	BEGIN
		SELECT @file_name [path]
	END
END
-- Clean up Process Tables Used after the scope is completed when Debug Mode is Off.
DECLARE @debug_mode VARCHAR(128) = REPLACE(CONVERT(VARCHAR(128), CONTEXT_INFO()), 0x0, '')

IF ISNULL(@debug_mode, '') <> 'DEBUG_MODE_ON'
BEGIN
	SET @output_table = REPLACE(@output_table, 'adiha_process.dbo.', '')
	SET @output_table1 = REPLACE(@output_table1, 'adiha_process.dbo.', '')

	EXEC spa_clear_all_temp_table NULL, @output_table
	EXEC spa_clear_all_temp_table NULL, @output_table1
END
