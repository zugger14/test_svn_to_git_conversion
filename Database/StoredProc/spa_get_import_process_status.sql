IF OBJECT_ID(N'spa_get_import_process_status', N'P') IS NOT NULL
DROP PROCEDURE spa_get_import_process_status
 GO 

/**
	Stored procedure for import drilldown.

	Parameters
	@process_id: Process_id
	@user_login_id: User login ID
	@rule_name: Rule Name
	@import_source: Import Source
	@batch_process_id: Batch process ID

	@batch_report_param: Batch report parameters 
	@enable_paging: Enable paging flag
					'1' = enable, 
					'0' = disable 
	@page_size: Page size
	@page_no: Page Number
*/

CREATE PROCEDURE [dbo].[spa_get_import_process_status]
	@process_id VARCHAR(100),
	@user_login_id VARCHAR(50),
	@rule_name varchar(200) = NULL,
	@import_source VARCHAR(200) = NULL
	, @batch_process_id VARCHAR(250) = NULL
	, @batch_report_param VARCHAR(500) = NULL  
	, @enable_paging INT = 0  -- '1' = enable, '0' = disable 
	, @page_size INT = NULL
	, @page_no INT = NULL 

AS
SET NOCOUNT ON

/*******************************************1st Paging Batch START**********************************************/
DECLARE @str_batch_table VARCHAR(8000)
DECLARE @sql_paging VARCHAR(8000)
DECLARE @is_batch BIT

SET @str_batch_table = '' 

SET @user_login_id = dbo.FNADBUser()  

SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END

IF @is_batch = 1
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)

IF @enable_paging = 1 -- paging processing 
BEGIN 
	IF @batch_process_id IS NULL 
		SET @batch_process_id = dbo.FNAGetNewID()

	SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no) 

	-- retrieve data from paging table instead of main table 
	IF @page_no IS NOT NULL  
	BEGIN 
		SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no)  
		EXEC (@sql_paging)  
		RETURN  
	END 
END
/*******************************************1st Paging Batch END**********************************************/ 
/* 
declare
	@process_id VARCHAR(50) = '49524653_05B8_410B_BD71_53CBC39B5AC1',
	@user_login_id VARCHAR(50) = 'bmanandhar',
	@rule_name varchar(200) = NULL,
	@import_source VARCHAR(200) = NULL
	
--*/

DECLARE @url       VARCHAR(500)
DECLARE @desc      VARCHAR(500)
DECLARE @url1      VARCHAR(500)
DECLARE @desc1     VARCHAR(500)
DECLARE @url_deal  VARCHAR(500)

--If @run_process_step = 1

DECLARE	@process_table VARCHAR(MAX)					
SET @process_table = dbo.FNAProcessTableName('ixp_rec_inventory', 'missing_deals', @process_id)	

IF OBJECT_ID('tempdb..#temp_source_system_data_import_status') IS NOT NULL
	DROP TABLE #temp_source_system_data_import_status

IF @import_source='Regression Testing' AND @rule_name IS NOT NULL
BEGIN	
	--Added fro new regression
	IF(OBJECT_ID(dbo.FNAProcessTableName(REPLACE(LTRIM(RTRIM(@rule_name)), ' ', '_'), @user_login_id, @process_id)) IS NULL)
	BEGIN
		SET @desc = 'SELECT * ' + @str_batch_table + ' FROM adiha_process.dbo.'+ QUOTENAME(REPLACE(dbo.FNAProcessTableName(@rule_name, @user_login_id, @process_id), 'adiha_process.dbo.',''))
	END
	ELSE
	BEGIN 
		--old regression 
		-- SET @desc = 'SELECT * ' + @str_batch_table + ' FROM '+ dbo.FNAProcessTableName(REPLACE(LTRIM(RTRIM(@rule_name)), ' ', '_'), @user_login_id, @process_id)
		-- Using below logic because FNAProcessTAbleName will not return table name with QUOTENAME. Can be replaced by above commented logic when the function is updated.
		SET @desc = 'SELECT * ' + @str_batch_table + ' FROM adiha_process.dbo.'+ QUOTENAME(REPLACE(dbo.FNAProcessTableName(@rule_name, @user_login_id, @process_id), 'adiha_process.dbo.',''))
	END

	EXEC (@desc)
END
ELSE
BEGIN
	SELECT @url = './spa_html.php?__user_name__=' + @user_login_id + 
		'&spa=exec '+ CASE WHEN @import_source='Regression Testing' THEN 'spa_get_import_process_status ' ELSE 'spa_get_import_process_status_detail ' END+ '^' + @process_id + '^' 

	SELECT @url_deal = './spa_html.php?__user_name__=' + @user_login_id + 
		'&spa=exec spa_get_missing_deal_log ''' + @process_id + ''''

	SET @url = 'EXEC '+ CASE WHEN @import_source='Regression Testing' THEN 'spa_get_import_process_status ' ELSE 'spa_get_import_process_status_detail ' END + '^' + @process_id + '^' 
	select @desc = '<a  href="' + @url + '">' 
	SELECT  CASE 
					WHEN (code IN ('Error', 'Warning')) THEN '<font color="red"><b>' + code + 
						'</b></font>'
					ELSE code
			END AS Code,
			--module as [ImportFrom],
			COALESCE(rules_name, 'N/A') [Rule],
			CASE 
					WHEN (source = 'Schedule_log') THEN '<a target="_blank" href="' + @url 
						+ ',''' + source + '''' + '">' + source + '</a>'
		
				ELSE ISNULL(it.ixp_tables_description, source)
			END [source],
			type as [Type],
		CASE 
				WHEN ((code = 'Error' or code = 'Setup Error') and @import_source='Regression Testing' ) THEN
				CASE 
					WHEN code = 'Setup Error' THEN [description] 
					ELSE '<a href="javascript: second_level_drill(''' + @url +  + ',^'+@user_login_id+'^,^' + ISNULL(rules_name + '->', '') +source + '^,^Regression Testing^'')">' + [description] + '</a>'
					END 
				WHEN (code = 'Error') AND source = 'Static_Data' THEN 
					--'<a target="_blank" href="' + @url + ',null,''' + DESCRIPTION + ''',' + CASE 
					--																		 WHEN [module] LIKE 'Import%' THEN 'null'
					--																		 ELSE '''' + [module] + ''''
					--																	  END + '">' + [description] + '</a>'
					'<a href="javascript: second_level_drill(''' + @url + ',NULL,^' + DESCRIPTION + '^,' + CASE WHEN [module] LIKE 'Import%' THEN 'null'
																							ELSE '^' + [module] + '^' END + ''')">' + [description] + '</a>'	
				--	then '<a target="_blank" href="'+ @url + ','''+source+''','''+description+''',''' + [module] +''''+ '">'+[description]+'</a>'
				WHEN (code = 'Error') AND source = 'epa_allowance_data' THEN 
				--     '<a target="_blank" href="' + @url + ',''' + source + ''',''' + [type] + ''',' + 
					--CASE 
			--              WHEN [module] LIKE 'Import%' THEN 'null'
			--              ELSE '''' + [module] + ''''
			--         END + '">' + [description] + '</a>'
					'<a href="javascript: second_level_drill(''' + @url + ',^' + source + '^,^' + [type] + '^,' + CASE WHEN [module] LIKE 'Import%' THEN 'null'
																							ELSE '^' + [module] + '^' END + ''')">' + [description] + '</a>'
				WHEN (code = 'Error') AND source = 'RWE MTM' THEN 
					-- '<a target="_blank" href="' + @url + ',''' + source + ''',''' + description + '''' + '">' + [description] + '</a>'
						'<a href="javascript: second_level_drill(''' + @url + ',^' + source + '^,^' + description + '^'')">' + [description] + '</a>'

				WHEN (code = 'Warning') AND source = 'Static_Data' THEN 
			--       '<a target="_blank" href="' + @url + ',null,''' + DESCRIPTION + ''',' + 
					--CASE 
		--                 WHEN [module] LIKE 'Import%' THEN 'null'
		--                 ELSE '''' + [module] + ''''
		--            END + '">' + [description] + '</a>'

				'<a href="javascript: second_level_drill(''' + @url + ',NULL,^' + DESCRIPTION + '^,' + CASE WHEN [module] LIKE 'Import%' THEN 'null'
																							ELSE '^' + [module] + '^' END + ''')">' + [description] + '</a>'	
				WHEN (code = 'Warning') AND source = 'voided_deal' THEN 
					--'<a target="_blank" href="./spa_html.php?__user_name__=' + @user_login_id + '&spa=' + REPLACE(@url,'^','''') + ',''' + source + ''',null,' + CASE WHEN [module] LIKE 'Import%' THEN 'null'
					--                                                                        ELSE '''' + [module] + ''''
					--                                                                   END + '">' + [description] + '</a>'
				'<a href="javascript: second_level_drill(''' + @url + ',^' + source + '^,NULL,' + CASE WHEN [module] LIKE 'Import%' THEN 'null'
																							ELSE '^' + [module] + '^' END + ''')">' + [description] + '</a>'	
				WHEN (code = 'Warning') AND source = 'deal_update_confirmation' THEN 
					--'<a target="_blank" href="' + @url + ',''' + source + ''',null,' + CASE WHEN [module] LIKE 'Import%' THEN 'null'
					--                                                                        ELSE '''' + [module] + ''''
					--                                                                   END + '">' + [description] + '</a>'
				'<a href="javascript: second_level_drill(''' + @url + ',^' + source + '^,NULL,' + CASE WHEN [module] LIKE 'Import%' THEN 'null'
																							ELSE '^' + [module] + '^' END + ''')">' + [description] + '</a>'														

				WHEN (code = 'Warning') AND source = 'Foreign_key_violation' THEN 
					--'<a target="_blank" href="' + @url + ',''' + source + ''',null,' + CASE WHEN [module] LIKE 'Import%' THEN 'null'
					--                                                                        ELSE '''' + [module] + ''''
					--                                                                   END + '">' + [description] + '</a>'
				'<a href="javascript: second_level_drill(''' + @url + ',^' + source + '^,NULL,' + CASE WHEN [module] LIKE 'Import%' THEN 'null'
																							ELSE '^' + [module] + '^' END + ''')">' + [description] + '</a>'
				WHEN (code = 'Warning') AND source = 'uom_conversion' THEN 
					--'<a target="_blank" href="' + @url + ',''' + source + ''',null,' + CASE WHEN [module] LIKE 'Import%' THEN 'null'
					--                                                                        ELSE '''' + [module] + ''''
					--                                                                   END  + '">' + [description] + '</a>'
				'<a href="javascript: second_level_drill(''' + @url + ',^' + source + '^,NULL,' + CASE WHEN [module] LIKE 'Import%' THEN 'null'
																							ELSE '^' + [module] + '^' END + ''')">' + [description] + '</a>'
				WHEN (code = 'Success') AND module = 'Calc Embedded' THEN '<a href="javascript: second_level_drill(''' + @url + ',^' + source + '^'')">' + [description] + '</a>'
				WHEN (code = 'Error') AND source = 'Deal_Not_Found' THEN '<a href="javascript: second_level_drill(''' + @url_deal + ''')">' + [description] + '</a>'																	
				WHEN (code IN ('Error', 'Warning', 'Info') AND source <> 'Position') OR (source = 'Schedule_log') 
				THEN 
					CASE WHEN ssd.detail_process_id IS NOT NULL THEN '<a href="javascript: second_level_drill(''' + @url + ',^' + source + '^'')">' ELSE '' END 
				+ dbo.FNAStripHTML([description]) + 
			
				CASE WHEN ssd.detail_process_id IS NOT NULL THEN  '</a>' ELSE '' END
				ELSE [description]
			END  AS [Description],
		recommendation as Recommendation 
	INTO #temp_source_system_data_import_status
	FROM   source_system_data_import_status
	LEFT JOIN ixp_tables it ON source_system_data_import_status.source = it.ixp_tables_name
	OUTER APPLY(SELECT MAX(import_file_name) import_file_name, MAX(process_id) detail_process_id FROM source_system_data_import_status_detail WHERE process_id = ISNULL(source_system_data_import_status.master_process_id,source_system_data_import_status.Process_id)) ssd
	WHERE  process_id = @process_id  OR master_process_id =@process_id  
	AND COALESCE(rules_name, '') = COALESCE(@rule_name, rules_name, '')
	AND source =CASE WHEN @import_source='Regression Testing' then source else COALESCE(@import_source, source) END
	union all
	SELECT  CASE when (code = 'Error') then '<font color="red"><b>' + code + '</b></font>' 
		else code  end as code,
		--module,
		NULL AS [Rule],source,type,
		case when (code = 'Error') then '<a href="javascript: second_level_drill('''+ @url + ',^'+source+'^,null,' + CASE WHEN [module] LIKE 'Import%' THEN 'null' ELSE '^'+[module]+'^' end + ''')">'+[description]+'</a>'
		else description end  as [description],
		recommendation from source_system_data_import_status_vol where process_id=@process_id 
	
	IF OBJECT_ID (@process_table, N'U') IS NOT NULL 
	BEGIN
		EXEC('
			INSERT INTO #temp_source_system_data_import_status		
			SELECT DISTINCT ''<font color="red"><b> Error </b></font>'' 
				code,
				--module,
				''REC Inventory'' AS [Rule], 
				''Non-Existing Deal List'' [source], 
				''List of Missing Deals'' [type],
				''<a href="javascript: second_level_drill_2(''''Non-Existing Deal List'''', ''''' + @url + ',^'' + ''Non-Existing Deal List'' + ''^'''', 500, 500)">'' + ''List of Missing Deals'' + ''</a>'' [description],
				--''<a href="javascript: second_level_drill_2(''''''+ @url + '',^''+source+''^'''')">''+[type]+''</a>'' [description],
				''N/A''
			FROM ' + @process_table 
		)
	END

	EXEC('SELECT * ' + @str_batch_table + ' FROM #temp_source_system_data_import_status')
END

/*

SELECT * from source_system_data_import_status WHERE process_id='977B78BB_1D96_4262_9DFC_C30F315ED87F'

SELECT * from source_system_data_import_status_detail WHERE process_id='977B78BB_1D96_4262_9DFC_C30F315ED87F'

exec spa_get_import_process_status_detail '977B78BB_1D96_4262_9DFC_C30F315ED87F',null,'Deal Id not found','IAS39_MTM_20100731_134802.txt'
*/

/*******************************************2nd Paging Batch START**********************************************/
 
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@sql_paging)
 
   --TODO: modify sp and report name
   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_get_import_process_status_detail', 'spa_get_import_process_status_detail')
   EXEC(@sql_paging)  
 
   RETURN
END
 
--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
   EXEC(@sql_paging)
END
 
/*******************************************2nd Paging Batch END**********************************************/