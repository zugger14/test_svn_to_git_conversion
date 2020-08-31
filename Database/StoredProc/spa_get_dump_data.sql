

/****** Object:  StoredProcedure [dbo].[spa_get_dump_data]    Script Date: 08/24/2012 13:45:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_dump_data]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_dump_data]
GO



/****** Object:  StoredProcedure [dbo].[spa_get_dump_data]    Script Date: 08/24/2012 13:45:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[spa_get_dump_data] 
	@flag						VARCHAR(1),
	@archive_type_value_id		INT = NULL, --m: get as of date		t: archive table names
	@archive_tbl_sequence		INT = NULL,
	@as_of_date_from			VARCHAR(100) = NULL,
	@as_of_date_to				VARCHAR(100) = NULL
AS

SET NOCOUNT ON
DECLARE @st		VARCHAR(MAX)


IF @flag = 'm'
BEGIN
	DECLARE @frequency_type			CHAR(1)
	DECLARE @where_field			VARCHAR(100)
	DECLARE @is_archived_table  	BIT
	DECLARE @main_table_name		VARCHAR(100)
	DECLARE @fq_table_name			VARCHAR(100)
	DECLARE @archive_table_prefix	VARCHAR(50)
	DECLARE @tmp					VARCHAR (250)
	--ASSUMPTIONS: Date range is same for all archive tables (if multiple main tables are included in archive as in Allocation)
	
	--- Modification on 2nd May 2012. 
	
	
	SET @tmp = ''
	SELECT   @tmp = @tmp + '''' +  adp.main_table_name + '''' + ', '
	FROM archive_data_policy_detail adpd 
	INNER JOIN archive_data_policy adp ON adpd.archive_data_policy_id = adp.archive_data_policy_id
		AND adp.archive_type_value_id = @archive_type_value_id
		--AND adp.sequence = 1	--main sequence is always taken as 1 for data retrieval just as a convenience
		AND adpd.is_arch_table = 0 
	--SELECT  SUBSTRING(@tmp, 0, LEN(@tmp))
	
	SELECT @main_table_name = adp.main_table_name
		, @frequency_type = archive_frequency, @where_field = where_field 
	FROM archive_data_policy_detail adpd 
	INNER JOIN archive_data_policy adp ON adpd.archive_data_policy_id = adp.archive_data_policy_id
		AND adp.archive_type_value_id = @archive_type_value_id 
		--AND adp.sequence = 1	--main sequence is always taken as 1 for data retrieval just as a convenience
		AND adpd.is_arch_table = 0 

	SELECT @fq_table_name = ISNULL(adpd.archive_db + '.dbo.', '') + adpd.table_name, @is_archived_table = adpd.is_arch_table
		, @archive_table_prefix = REPLACE(adpd.table_name, adp.main_table_name, '')
	FROM archive_data_policy_detail adpd 
	INNER JOIN archive_data_policy adp ON  adpd.archive_data_policy_id = adp.archive_data_policy_id
		AND  adp.archive_type_value_id = @archive_type_value_id 
		--AND adp.sequence = 1 
		AND adpd.sequence = @archive_tbl_sequence
	
	CREATE TABLE #tmp_available_dates (
		as_of_date DATETIME
	)
	--PRINT @tmp
	--PRINT @main_table_name
	--PRINT @fq_table_name
	--PRINT @where_field
	
	DECLARE @sql_main AS VARCHAR(MAX)
	SET @sql_main = ''
	SELECT @sql_main = @sql_main + (CASE WHEN @sql_main = '' THEN '' ELSE ' UNION ALL ' END) + 
		'SELECT distinct 
		 (' +  adp.where_field +  ')
		   as_of_date
			FROM ' + ISNULL(adpd.archive_db + '.dbo.', '') + adpd.table_name  + ' WHERE ' + adp.where_field + ' BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ''''
		FROM archive_data_policy_detail adpd 
		INNER JOIN archive_data_policy adp ON  adpd.archive_data_policy_id = adp.archive_data_policy_id
			AND adp.archive_type_value_id = @archive_type_value_id
			and is_arch_table = 0 
		
			--GROUP BY adpd.table_name, adpd.archive_db, adp.main_table_name, adpd.sequence,adpd.is_arch_table,adp.where_field
			ORDER BY adp.where_field
	--EXEC (@sql_main)
	--PRINT @sql_main return
	--grab distinct normalized as_of_dates
	SET @st = '
		INSERT INTO #tmp_available_dates(as_of_date)
		SELECT MAX(as_of_date) as_of_date
		FROM process_table_location
		WHERE tbl_name IN (' +   SUBSTRING(@tmp, 0, LEN(@tmp)) + ') AND ISNULL(prefix_location_table, '''') = ''' + @archive_table_prefix + '''
		AND ISNULL(prefix_location_table, '''') != '''' 
		and as_of_date BETWEEN '''+@as_of_date_from+''' AND ''' +@as_of_date_to+'''
		GROUP BY ' + CASE @frequency_type WHEN 'm' THEN 'YEAR(as_of_date), MONTH(as_of_date)' ELSE 'as_of_date' END + 
		CASE WHEN ISNULL(@is_archived_table, 1) = 0 THEN
		' UNION ' + @sql_main
		--Original data stored in main table are not available in process_table_location, so main table should be accessed.
		--But all archived data will be available in process_table_location, so no need to read the archived table
		
		
				
		--SELECT MAX(' + @where_field + ') as_of_date 
		--FROM ' + @main_table_name + '
		--GROUP BY ' + CASE @frequency_type WHEN 'm' THEN 'YEAR(' + @where_field + '), MONTH(' + @where_field + ')' ELSE @where_field END
		ELSE
			''
		END
		
	
	
	--PRINT (@st)
	EXEC (@st)
	
	DECLARE @user_login_id VARCHAR(100)
	SET @user_login_id = dbo.FNADBUser()
	
	SELECT DISTINCT (CASE @frequency_type 
						--if further optimization needed, replace FNAGetGenericDate by its code content
						WHEN 'm' THEN dbo.FNAGetGenericDate(CONVERT(VARCHAR(8), as_of_date, 120) + '01', @user_login_id)
						ELSE dbo.FNAGetGenericDate(as_of_date, @user_login_id)
						END) [Date]
					, CONVERT(VARCHAR(7), as_of_date, 120) [Month]
					, (CASE @frequency_type 
						WHEN 'm' THEN CAST(CONVERT(VARCHAR(8), as_of_date, 120) + '01' AS DATETIME) 
						ELSE as_of_date 
					   END) [DateRaw] --added for sorting date
	FROM #tmp_available_dates
	ORDER BY DateRaw 
	
	--SET @st = 'SELECT DISTINCT (CASE ''' + @frequency_type + ''' WHEN ''m'' THEN dbo.FNADateFormat(CONVERT(VARCHAR(8), as_of_date, 120) + ''01'')
	--							ELSE dbo.FNADateFormat(as_of_date) END) [Date], CONVERT(VARCHAR(7), as_of_date, 120) [Month],
	--				  (CASE ''' + @frequency_type + ''' WHEN ''m'' THEN CAST(CONVERT(VARCHAR(8), as_of_date, 120) + ''01'' AS DATETIME) --added for sorting date
	--							ELSE CAST(CONVERT(VARCHAR(10), as_of_date, 120) AS DATETIME) END) [DateRaw]
	--			FROM process_table_location
	--			WHERE tbl_name = ''' + @fq_table_name + ''' AND ISNULL(prefix_location_table, '''') = '''  + '''' + 
	--			CASE WHEN ISNULL(@is_archived_table, 1) = 0 THEN
	--			' UNION
	--			--Original data stored in main table are not available in process_table_location, so main table should be accessed.
	--			--But all archived data will be available in process_table_location, so no need to read the archived table
	--			SELECT DISTINCT (CASE ''' + @frequency_type + ''' WHEN ''m'' THEN dbo.FNADateFormat(CONVERT(VARCHAR(8), ' + @where_field + ', 120) + ''01'')
	--								ELSE dbo.FNADateFormat(' + @where_field + ') END) [Date], CONVERT(VARCHAR(7), ' + @where_field + ', 120) [Month],
	--							(CASE ''' + @frequency_type + ''' WHEN ''m'' THEN CAST(CONVERT(VARCHAR(8), ' + @where_field + ', 120) + ''01'' AS DATETIME)
	--							ELSE CAST(CONVERT(VARCHAR(10), ' + @where_field + ', 120) AS DATETIME) END) [DateRaw] 
	--			FROM ' + @fq_table_name	
	--			ELSE
	--				''
	--			END +
	--			' ORDER BY DateRaw'
	--PRINT @st
	--EXEC(@st) 
END
ELSE IF @flag = 'r'
 BEGIN
    SELECT as_of_date , SUM(curve_value) FROM source_price_curve spc GROUP BY spc.as_of_date  	
  END
ELSE IF @flag = 't'
BEGIN 
	DECLARE @archive_at_link_server		CHAR(1)  
	IF EXISTS(SELECT 1 FROM archive_data_policy_detail adpd WHERE ISNULL(CHARINDEX('.', adpd.archive_db), 0) <> 0)  
	
		SET @archive_at_link_server = 'y'  
	ELSE   
		SET @archive_at_link_server = 'n'
	
	DECLARE @sql AS VARCHAR(MAX)
	
	SELECT @frequency_type = MIN(archive_frequency)
		FROM archive_data_policy
		WHERE archive_type_value_id = @archive_type_value_id 
		AND sequence = 1 
	
	SET @sql = ''
	
	--SELECT @sql = @sql + (CASE WHEN @sql = '' THEN '' ELSE ' UNION ALL ' END) + 
	--	'SELECT ''' + CAST(adpd.sequence   AS VARCHAR(2)) + ''' main_seq, 
	--	''' /*+ ISNULL(adpd.archive_db + '.dbo.', '') */+
	--	CASE WHEN adpd.is_arch_table = 0 THEN 'Main' ELSE  'Archive' + CAST(adpd.sequence -1  AS VARCHAR(2))  END + ''' descr,	
	--	  CASE WHEN MIN(' + MAX(CASE  '' + @frequency_type + '' WHEN 'm' THEN '(CONVERT(VARCHAR(8), ' + adp.where_field + ', 120) + ''01'' )' ELSE  adp.where_field  END) + ') IS NULL THEN '''' ELSE  (MIN(' + MAX(CASE '' + @frequency_type + '' WHEN 'm' THEN 'CONVERT(VARCHAR(8), ' + adp.where_field + ', 120) + ''01''' ELSE  adp.where_field  END) + '))
	--	  END as_of_date_min, 
	--	 CASE WHEN MIN(' + MAX(CASE  '' + @frequency_type + '' WHEN 'm' THEN '(CONVERT(VARCHAR(8), ' + adp.where_field + ', 120) + ''01'' )' ELSE  adp.where_field  END) + ') IS NULL THEN '''' ELSE  (MAX(' + MAX(CASE '' + @frequency_type + '' WHEN 'm' THEN 'CONVERT(VARCHAR(8), ' + adp.where_field + ', 120) + ''01''' ELSE  adp.where_field  END) + '))
	--	 END as_of_date_max		
	--	FROM ' + ISNULL(adpd.archive_db + '.dbo.', '') + adpd.table_name -- + ISNULL(prefix_location_table, '')
	SELECT @sql = @sql + (CASE WHEN @sql = '' THEN '' ELSE ' UNION ALL ' END) + 
		'SELECT ''' + CAST(adpd.sequence   AS VARCHAR(2)) + ''' main_seq, 
		''' /*+ ISNULL(adpd.archive_db + '.dbo.', '') */+
		CASE WHEN adpd.is_arch_table = 0 THEN 'Main' ELSE  'Archive' + CAST(adpd.sequence -1  AS VARCHAR(2))  END + ''' descr,	
		  ' + MAX(CASE  '' + @frequency_type + '' WHEN 'm' THEN '(CONVERT(VARCHAR(8), MIN(' + adp.where_field + '), 120) + ''01'' ' ELSE  adp.where_field  END) + ') as_of_date_min, 
		 ' + MAX(CASE  '' + @frequency_type + '' WHEN 'm' THEN '(CONVERT(VARCHAR(8), MAX(' + adp.where_field + '), 120) + ''01'' ' ELSE  adp.where_field  END) + ') as_of_date_max		
		FROM ' + ISNULL(adpd.archive_db + '.dbo.', '') + adpd.table_name +' WHERE ' +adp.where_field + ' BETWEEN ''' + @as_of_date_from+ ''' AND ''' +@as_of_date_to+ '''' -- + ISNULL(prefix_location_table, '')
	FROM archive_data_policy_detail adpd 
	INNER JOIN archive_data_policy adp ON  adpd.archive_data_policy_id = adp.archive_data_policy_id
		AND adp.archive_type_value_id = @archive_type_value_id
		--AND adp.sequence = 1 
		GROUP BY adpd.table_name, adpd.archive_db, adp.main_table_name, adpd.sequence,adpd.is_arch_table,adp.where_field
		ORDER BY adpd.sequence
	
	CREATE TABLE #temp_archive(main_seq VARCHAR(120), [description] VARCHAR(200), as_of_date_min DATETIME, as_of_date_max DATETIME)
	--INSERT INTO #temp_archive(main_seq, [description], as_of_date_min, as_of_date_max) SELECT NULL, NULL, NULL, NULL
	--PRINT(@sql)
	
	EXEC('INSERT INTO #temp_archive(main_seq, [description], as_of_date_min, as_of_date_max) ' + @sql)
	
	SELECT main_seq,
	       [description] + CASE 
						WHEN
							ISNULL(MIN(as_of_date_min), '') <> '' AND MAX(ISNULL(as_of_date_max, '')) <> ''
							THEN ' (' + dbo.FNADateFormat(MIN(as_of_date_min)) + ' : ' + dbo.FNADateFormat(MAX(as_of_date_max)) + ')'
						ELSE ''
					END descr,
	       main_seq + ',' + CASE 
							   WHEN ISNULL(MIN(as_of_date_min), '') <> '' THEN dbo.FNADateFormat(MIN(as_of_date_min))
							   ELSE ''
							END 
					+ ',' + CASE 
								WHEN ISNULL(MAX(as_of_date_max), '') <> '' THEN dbo.FNADateFormat(MAX(as_of_date_max))
								ELSE ''
					        END
					+ ',' + CAST(@archive_type_value_id AS VARCHAR(10)) date_range
	FROM   #temp_archive --WHERE (as_of_date_min IS NOT NULL OR  as_of_date_max IS NOT NULL)
	GROUP BY main_seq,  [description]
	ORDER BY main_seq
	
END 	
--ELSE IF @flag = 's'
--	BEGIN
--		SELECT  value_id, code, [description] FROM static_data_value WHERE [type_id] = 2150
--	END
--ELSE IF @flag = 'a'
--	BEGIN
--		SET @sql ='SELECT dbo.FNADateFormat(MIN(as_of_date)),dbo.FNADateFormat(MAX(as_of_date)) FROM '+@main_table_name --+ isnull(replace(@prefix_location_table,'main',''),'')
--		PRINT @sql
--		EXEC(@sql)	
--	END

GO


