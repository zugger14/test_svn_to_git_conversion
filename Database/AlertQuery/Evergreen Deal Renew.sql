DECLARE @process__id VARCHAR(100)
, @header_fields VARCHAR(MAX) = ''
, @detail_fields VARCHAR(MAX) = ''
, @header_process_table VARCHAR(100)
, @detail_process_table VARCHAR(100)
, @user_name VARCHAR(50)
, @detail_columns VARCHAR(MAX) = ''
, @sql_command NVARCHAR(MAX)
, @max_term_end DATETIME
, @term_frequency CHAR(1)
, @from_date DATETIME 
, @to_date DATETIME
, @max_day_in_year INT
, @max_day_in_mnth INT
, @max_day_in_quarter INT
, @max_day_in_sem_annual INT
, @source_deal_header_id INT
, @granularity CHAR(10)

SELECT @max_day_in_sem_annual = DATEDIFF(DAY, CURRENT_TIMESTAMP, DATEADD(MONTH, 6, CURRENT_TIMESTAMP)) --sem annually
SELECT @max_day_in_quarter = DATEDIFF(DAY, CURRENT_TIMESTAMP, DATEADD(MONTH, 3, CURRENT_TIMESTAMP)) --quaterly
SELECT @max_day_in_mnth = DATEDIFF(DAY, CURRENT_TIMESTAMP, DATEADD(MONTH, 1, CURRENT_TIMESTAMP)) --month
SELECT @max_day_in_year = DATEDIFF(DAY, CURRENT_TIMESTAMP, DATEADD(YEAR, 1, CURRENT_TIMESTAMP)) --year

SET @user_name = dbo.FNADBUser()

IF OBJECT_ID('tempdb..#temp_deals') IS NOT NULL
 	DROP TABLE #temp_deals

IF OBJECT_ID('tempdb..#temp_deal_detail') IS NOT NULL
 	DROP TABLE #temp_deal_detail
CREATE TABLE #temp_deal_detail (old_detail_id INT, new_detail_ids VARCHAR(MAX))
	
IF OBJECT_ID('tempdb..#temp_message') IS NOT NULL
 	DROP TABLE #temp_message
CREATE TABLE #temp_message ([Report Message] VARCHAR(500))

IF OBJECT_ID('tempdb..#temp_deal_template_details') IS NOT NULL
 	DROP TABLE #temp_deal_template_details
CREATE TABLE #temp_deal_template_details (	
	pricing_process__id VARCHAR(100)
)

---10000188 Cancel Date
---10000187 Cancellation Alert Days
---10000186 Cancellation Notice Days
---10000185 Renew Granularity

-- Deals which are Evergreen and not reached Cancel Date
SELECT * INTO #temp_deals FROM (
SELECT source_deal_header_id, entire_term_End, renew_granularity, cancellation_notice_days,  evergreen_deal, cancel_date
FROM
(
  SELECT sdh.source_deal_header_id, sdh.entire_term_End
  , CASE WHEN uddft.field_name = -10000185 THEN 'renew_granularity' 
	  WHEN uddft.field_name = -10000186 THEN 'cancellation_notice_days' 
	  WHEN uddft.field_name = -10000184 THEN 'evergreen_deal' 
	  WHEN uddft.field_name = -10000188 THEN 'cancel_date' END field_name
  , uddf.udf_value
FROM source_deal_header sdh 
INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_Id = sdh.template_id
INNER JOIN user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id 
	AND sdh.source_deal_header_id = uddf.source_deal_header_id 
	
) d
PIVOT
(
  MAX(udf_value)
  FOR field_name in ( renew_granularity, cancellation_notice_days, evergreen_deal, cancel_date)
) piv 
) aa  WHERE evergreen_deal = 'y' AND ISNULL(cancel_date, '9999-12-31') > CURRENT_TIMESTAMP


DECLARE @evergreen_deal_cur CURSOR, @pricing_proc_id VARCHAR(100), @tbl_deal_detail_new_old_id VARCHAR(200)
, @new_detail_ids VARCHAR(MAX), @old_detail_id INT, @price_process_table VARCHAR(200) ,@sql VARCHAR(MAX)
SET @evergreen_deal_cur = CURSOR FOR
SELECT source_deal_header_id, renew_granularity FROM #temp_deals td 
WHERE cancellation_notice_days IS NOT NULL 
AND DATEDIFF(DAY, CURRENT_TIMESTAMP, entire_term_End) <= cancellation_notice_days 
UNION 
SELECT source_deal_header_id, renew_granularity FROM #temp_deals td 
WHERE cancellation_notice_days IS NULL 
AND
ABS(DATEDIFF(DAY,ISNULL(entire_term_End,'9999-12-31'),CURRENT_TIMESTAMP)) <
CASE WHEN renew_granularity = 'm' THEN @max_day_in_mnth
	WHEN renew_granularity = 'd' THEN 1
	WHEN renew_granularity = 'a' THEN @max_day_in_year
	WHEN renew_granularity = 'q' THEN @max_day_in_quarter
	WHEN renew_granularity = 's' THEN @max_day_in_sem_annual
END

OPEN @evergreen_deal_cur
FETCH NEXT
FROM @evergreen_deal_cur INTO @source_deal_header_id, @granularity
WHILE @@FETCH_STATUS = 0
BEGIN	
	DELETE FROM #temp_deal_template_details
	DELETE FROM #temp_deal_detail

	SET @new_detail_ids = NULL

	SET @process__id = dbo.FNAgetnewID()
	
	EXEC spa_deal_update_new @flag='e', @source_deal_header_id=@source_deal_header_id, @call_from = 'fields_and_values', @process__id = @process__id, @udf_process__id = @process__id
	
	INSERT INTO #temp_deal_template_details
	EXEC spa_deal_update_new @flag='l', @source_deal_header_id=@source_deal_header_id, @view_deleted='n', @call_from = 'evergreen_alert'
	
	SELECT @pricing_proc_id = pricing_process__id FROM #temp_deal_template_details

	SELECT @detail_process_table = 'detail_field_values_' +  @user_name + '_' + @process__id 
	SELECT @detail_columns = @detail_columns + ', ' + c.name  
	FROM adiha_process.sys.[columns] c 
	INNER JOIN adiha_process.sys.tables t on t.object_id = c.object_id  
	WHERE t.name  = @detail_process_table
	AND c.name NOT IN ('id', 'term_start', 'term_end', 'source_deal_detail_id', 'deal_group', 'group_id')
	SELECT @detail_columns = SUBSTRING(@detail_columns, 2, LEN(@detail_columns))	
	
	SET @sql_command = 'SELECT @max_term_end = MAX(term_end) FROM adiha_process.dbo.' + @detail_process_table
	EXECUTE sp_executesql @sql_command, N'@max_term_end NVARCHAR(50) OUTPUT', @max_term_end=@max_term_end OUTPUT

	SELECT @term_frequency = udf_value FROM source_deal_header sdh 
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_Id = sdh.template_id
	INNER JOIN user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id 
		AND sdh.source_deal_header_id = uddf.source_deal_header_id AND uddft.field_name = -10000185
	WHERE sdh.source_deal_header_id = @source_deal_header_id 
	
	EXEC('
		ALTER TABLE adiha_process.dbo.' + @detail_process_table + '  
		ADD added_from_sdd_id VARCHAR(10) 
	')

	SET @from_date = dbo.FNAGetTermStartDate(@term_frequency, @max_term_end, 1)
	SET @to_date = dbo.FNAGetTermEndDate(@term_frequency, @from_date, 0)

	SET @sql_command = 'INSERT INTO adiha_process.dbo.' + @detail_process_table + ' (term_start, term_end, source_deal_detail_id, added_from_sdd_id, deal_group, group_id, ' + @detail_columns + ')
	SELECT TOP 1  ''' + CAST(@from_date AS VARCHAR(30)) + ''','''+ CAST(@to_date AS VARCHAR(30)) + ''', ''NEW_' + @process__id + ''', source_deal_detail_id, ''New Group'', ''New_' + @process__id + ''',' + @detail_columns + ' FROM adiha_process.dbo.' + @detail_process_table + '
	ORDER BY id DESC  '
	EXEC(@sql_command)

	SET @sql_command = 'SELECT  @max_term_end = ( select term_start, term_end, source_deal_detail_id, ISNULL(added_from_sdd_id,'''') added_from_sdd_id , deal_group, group_id, ' + @detail_columns + ' FROM adiha_process.dbo.'+ @detail_process_table +' FOR XML RAW(''GridROW''))'
	EXECUTE sp_executesql @sql_command, N'@max_term_end NVARCHAR(MAX) OUTPUT', @max_term_end=@detail_fields OUTPUT
	SELECT @detail_fields = '<GridXML>'+ @detail_fields +'</GridXML>'

	EXEC spa_deal_update_new  @flag='s',@source_deal_header_id=@source_deal_header_id, @detail_xml=@detail_fields
	, @pricing_process__id= @pricing_proc_id, @udf_process__id = @process__id, @process__id = @process__id	
	
	SET @tbl_deal_detail_new_old_id = dbo.FNAProcessTableName('deal_detail_new_old_id', @user_name, @process__id)
	EXEC('
	INSERT INTO #temp_deal_detail
	SELECT b.added_from_sdd_id , a.new_source_deal_detail_id FROM ' + @tbl_deal_detail_new_old_id + ' a
	OUTER APPLY (SELECT TOP 1 added_from_sdd_id FROM adiha_process.dbo.' + @detail_process_table + ' WHERE added_from_sdd_id IS NOT NULL) b
	')

	SELECT @old_detail_id = old_detail_id,  @new_detail_ids = COALESCE(@new_detail_ids + ',', '') + new_detail_ids
	FROM #temp_deal_detail
	
	EXEC [spa_deal_pricing_detail] @flag= 't', @mode='fetch', @source_deal_detail_id=@old_detail_id,@is_apply_to_all='y',@ids_to_apply_price=@new_detail_ids, @output = @pricing_proc_id OUTPUT
	--select * from adiha_process.dbo.pricing_xml_runaj_D453318D_4D88_4493_8430_E74A999DEA1C
	SET @price_process_table  = 'adiha_process.dbo.pricing_xml_' + @user_name + '_' + @pricing_proc_id
	
	SET @sql = '
			DECLARE @flag CHAR(1),
					@source_deal_detail_id INT,
					@xml_value VARCHAR(MAX),
					@apply_to_xml VARCHAR(MAX),
					@is_apply_to_all CHAR(1),
					@call_from VARCHAR(50),
					@process__id VARCHAR(200)

			DECLARE @get_source_deal_detail_id CURSOR
			SET @get_source_deal_detail_id = CURSOR FOR

					SELECT DISTINCT ''m'',
						   source_deal_detail_id,
						   p.xml_value,
						   p.apply_to_xml,
						   p.is_apply_to_all,
						   p.call_from,
						   p.process__id
					FROM ' + @price_process_table + ' p

			OPEN @get_source_deal_detail_id
			FETCH NEXT
			FROM @get_source_deal_detail_id INTO @flag, @source_deal_detail_id, @xml_value, @apply_to_xml, @is_apply_to_all, @call_from, @process__id
			WHILE @@FETCH_STATUS = 0
			BEGIN
				EXEC [dbo].[spa_deal_pricing_detail] @flag = @flag,
													@source_deal_detail_id = @source_deal_detail_id,
													@xml = @xml_value,
													@apply_to_xml = @apply_to_xml,
													@is_apply_to_all = @is_apply_to_all,
													@call_from = @call_from,
													@process__id = @process__id,
													@mode = ''save'',
													@xml_process__id = NULL
			FETCH NEXT
			FROM @get_source_deal_detail_id INTO @flag, @source_deal_detail_id, @xml_value, @apply_to_xml, @is_apply_to_all, @call_from, @process__id
			END
			CLOSE @get_source_deal_detail_id
			DEALLOCATE @get_source_deal_detail_id
		'

		EXEC (@sql)

	SET @granularity = CASE WHEN @granularity = 'm' THEN 'Monthly'
							WHEN @granularity = 'd' THEN 'Daily'
							WHEN @granularity = 'q' THEN 'Quaterly'
							WHEN @granularity = 'a' THEN 'Annual'
							WHEN @granularity = 's' THEN 'Semi Annual' 
						END

	INSERT INTO #temp_message
	SELECT @granularity + '(' + [dbo].[FNADateFormat](@from_date) + ' - ' + [dbo].[FNADateFormat](@to_date) + ') term has been added to Deal Id <span style="cursor:pointer" onClick="TRMWinHyperlink(10131010,'+ CAST(ISNULL(@source_deal_header_id, '') AS VARCHAR(10)) + ',''n'',''NULL'')"><font color=#0000ff><u><l>' + CAST(ISNULL(@source_deal_header_id, '') AS VARCHAR(1000)) + '<l></u></font></span>' 
	
	FETCH NEXT
	FROM @evergreen_deal_cur INTO @source_deal_header_id, @granularity
END
CLOSE @evergreen_deal_cur
DEALLOCATE @evergreen_deal_cur

IF NOT EXISTS (SELECT 1 FROM #temp_message)
BEGIN
	RETURN
END
ELSE
BEGIN
	SELECT * INTO staging_table.evergreen_deals_process_id_ad FROM #temp_message
END