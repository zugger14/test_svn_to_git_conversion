/****** Object:  UserDefinedFunction [dbo].[FNARFXReplaceReportParams]    Script Date: 07/30/2009 09:26:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FNARFXReplaceReportParams]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARFXReplaceReportParams]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**	
	Function to replace parameters with its respective values in report query

	Parameters:
	@sql_stmt : SQL Statement
	@criteria : Criteria
	@paramset_id : Paramset Id
	Returns: Report Query with values
*/ 

CREATE FUNCTION [dbo].FNARFXReplaceReportParams(
	@sql_stmt		VARCHAR(MAX)
	, @criteria		VARCHAR(MAX) = NULL
	, @paramset_id INT = NULL
)
RETURNS VARCHAR(MAX)
AS

/*
declare @sql_stmt		VARCHAR(MAX) ='SELECT  [DDV1].[term_start] AS [Term Start], [DDV1].[term_end] AS [Term End], [DDV1].[source_deal_header_id] AS [Deal ID], [DDV1].[deal_type] AS [Deal Type], [DDV1].[total_volume] AS [Total Volume] FROM adiha_process.dbo.report_dataset_DDV_dev_admin_0ED3B70F_96F1_44CB_A1A9_0813DBF1ACEA [DDV1] WHERE (  (''@source_deal_header_id'' = ''NULL'' OR DDV1.[source_deal_header_id] = ''@source_deal_header_id'') 
AND (''@location'' = ''NULL'' OR DDV1.[location] = ''@location'') 
AND (''NULL'' IN (@deal_type) OR DDV1.[deal_type] NOT IN ( @deal_type) ))'
	, @criteria		VARCHAR(5000) = 'sub_id=116,stra_id=117,book_id=118,sub_book_id=114!115,source_deal_header_id=NULL,location=NULL,deal_type=Physical!Capacity NG'
	, @paramset_id int = 37281
--*/
BEGIN
	DECLARE @next_param		VARCHAR(max)
	DECLARE @value			VARCHAR(max)
	DECLARE @parameter		VARCHAR(max)
	DECLARE @index_equal	INT 
	DECLARE @index			INT
	DECLARE @as_of_date		VARCHAR(20)

	SET @index = 1
	SET @index_equal = 1
	--SET @criteria = REPLACE(@criteria, ' ', '') -- get rid of white spaces


	declare @tbl_text_in_param table (paramset_id int, column_name varchar(500),operator int,widget_id int,initial_value varchar(max))
	
	insert into @tbl_text_in_param
	select rdp.paramset_id, dsc.name [column_name], rp.operator, dsc.widget_id
		, rp.initial_value
	from report_dataset_paramset rdp
	inner join report_param rp on rp.dataset_paramset_id = rdp.report_dataset_paramset_id
	inner join data_source_column dsc on dsc.data_source_column_id = rp.column_id
	
	where rdp.paramset_id = @paramset_id
		and rp.operator IN (9,10) --operators: IN, NOT IN
		and dsc.widget_id = 1
		and dsc.datatype_id IN (1,5) 
		--and nullif(rp.initial_value, '') is not null

	--return
	
	
	IF @criteria IS NOT NULL AND @criteria <> ''
	BEGIN
		/** modify string criteria to order parameter by length of filter string. so that replacement issue of same prefix can be avoided because the bigger filter string length (@as_of_date_to) is first replaced and then only small filter string length(@as_of_date).
		E.g:if criteria has '@as_of_date' and '@as_of_date_to' as a filter values, then previous replace replaces as_of_date for both filters hence creating error [2017-01-01_to]. Now if we reorder the criteria string on filter string length by descending order then firstly long length filter will be processed hence no issue with similar prefix replacement
		 **/
	
		declare @cr_modified varchar(MAX) = ''
		declare @tbl_filter table (filter_string varchar(max), str_len int)
		declare @tbl_filter_exploded table (filter_string varchar(max), filter_col varchar(200), filter_value varchar(max), filter_col_str_len int)

		--explode each filter to remove duplicate and take those having values from duplicates
		insert into @tbl_filter_exploded
		select scsv.item filter_string
			,substring(scsv.item, 0, CHARINDEX('=',scsv.item,0)) filter_col
			,iif(substring(scsv.item, CHARINDEX('=',scsv.item,0)+1, len(scsv.item))='NULL',null,substring(scsv.item, CHARINDEX('=',scsv.item,0)+1, len(scsv.item))) filter_value
			,len(stuff(scsv.item, CHARINDEX('=',scsv.item,0),len(scsv.item),'')) filter_col_str_len
		
		from dbo.SplitCommaSeperatedValues(@criteria) scsv
		
		--replace sql null with string null to build report filter
		insert into @tbl_filter
		select tfx.filter_col + '=' 
			+ isnull(iif(max(tip.column_name) is not null,dbo.FNARFXParseComplexParameterValues(max(tfx.filter_value)),max(tfx.filter_value)),'NULL') [filter_value]
			, max(tfx.filter_col_str_len) filter_col_str_len
		from @tbl_filter_exploded tfx
		left join @tbl_text_in_param tip on tip.column_name = tfx.filter_col
		group by tfx.filter_col
		--order by filter_col_str_len desc
		
		--select '@tbl_text_in_param',* from @tbl_text_in_param
		--select '@tbl_filter_exploded',* from @tbl_filter_exploded
		--select '@tbl_filter',* from @tbl_filter
		--return
		SELECT @cr_modified = STUFF(
			(SELECT ','  + tfb.filter_string
			from @tbl_filter tfb
			order by str_len desc
			FOR XML PATH(''))
		, 1, 1, '')

		
		set @criteria = isnull(nullif(@cr_modified,''), @criteria)


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

			--regain data comma that was present on filter value
			if nullif(@parameter, '') is not null
				set @value = replace(replace(replace(@value, '_-_', ','),'[',''),']','')
			--END
			
			--Handle dynamic as of date
			IF CHARINDEX('DATE.', @value ) > 0 
			BEGIN
				SET @value = dbo.FNAResolveCustomAsOfDate(@value, DEFAULT)
			END
	
			--PRINT @parameter + '=' + @value
			
			SET @sql_stmt = REPLACE(@sql_stmt, @parameter, @value)

			IF (@parameter = '@pnl_as_of_date' OR @parameter = '@as_of_date')
				SET @as_of_date = @value

			--chop off the processed part from @criteria
			SET @criteria = SUBSTRING(@criteria, @index + 1, LEN(@criteria))
			--PRINT '@criteria:' + @criteria
		END
	END
	
	RETURN(@sql_stmt)
	--print @sql_stmt
END



