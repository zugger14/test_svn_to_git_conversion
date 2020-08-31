IF OBJECT_ID(N'[dbo].[spa_ixp_data_audit_report]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_data_audit_report] 
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rgiri@pioneersolutionsglobal.com
-- Create date: 2013-11-26
-- Description: Description of the functionality in brief.6
 
-- Params:
-- EXEC spa_ixp_data_audit_report 's', '2012-10-25', '2013-11-27', '671', NULL
-- @import_flag CHAR(1) - Description of param2
-- @param1 VARCHAR(100) - Description of param3
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_ixp_data_audit_report]   
    @flag AS CHAR(1),
	@start_date VARCHAR(30) = NULL,
	@end_date VARCHAR(30) = NULL,
	@ixp_rules VARCHAR(30) = NULL,
	@import_user VARCHAR(250) = NULL,
	@import_source INT = NULL,
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL

AS
BEGIN
	SET NOCOUNT ON

	/*******************************************1st Paging Batch START**********************************************/
	DECLARE @str_batch_table VARCHAR(8000)
	DECLARE @user_login_id VARCHAR(50)
	DECLARE @sql_paging VARCHAR(8000)
	DECLARE @is_batch bit
			 
	SET @str_batch_table = ''
	SET @user_login_id = dbo.FNADBUser() 

	SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END		

	IF @is_batch = 1
		SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)

	IF @enable_paging = 1 --paging processing
	BEGIN
		IF @batch_process_id IS NULL
			SET @batch_process_id = dbo.FNAGetNewID()
		
		SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)

		--retrieve data from paging table instead of main table
		IF @page_no IS NOT NULL  
		BEGIN
			SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no)    
			EXEC (@sql_paging)  
			RETURN  
		END
	END
	/*******************************************1st Paging Batch END**********************************************/ 

	DECLARE @sql VARCHAR(MAX)
	DECLARE @url            VARCHAR(500)
	DECLARE @desc           VARCHAR(500)
	DECLARE @url_deal       VARCHAR(500)
	DECLARE @rules_code 	VARCHAR(500)
	DECLARE @import_source_code 	VARCHAR(500)

	--SELECT * FROM import_data_files_audit
	IF @ixp_rules IS NOT NULL
		SELECT @rules_code = ir.ixp_rules_name FROM  ixp_rules ir WHERE ir.ixp_rules_id = @ixp_rules

		
	IF @import_source IS NOT NULL
		SELECT @import_source_code =  it.ixp_tables_name FROM  ixp_tables it WHERE it.ixp_tables_id = @import_source	
	

	IF @flag = 's'
	BEGIN
		SET @sql='
			SELECT DISTINCT 
				   idfa.dir_path [Rule],
				   --idfa.imp_file_name [Module],
				   dbo.FNAdateformat(CAST(idfa.as_of_date AS VARCHAR(50))) [As of Date],
				   ' + CASE WHEN @import_source IS NOT NULL THEN ' CASE WHEN sdis.code = ''Error'' THEN ''<font color = red> ERROR Found </font> '' ELSE ''Success'' END '
					   ELSE
						  ' CASE 
								WHEN STATUS = ''c'' THEN ''Completed''
								WHEN STATUS = ''p'' THEN ''Processing''
								WHEN STATUS = ''w'' THEN ''Warning''
								WHEN STATUS = ''s'' THEN ''Success''
								WHEN STATUS = ''f'' THEN ''<font color = red> Invalid Format </font> ''
								ELSE ''<font color=red> ERROR Found </font>''
						   END '
					   END + ' [Status], 
				   --' + CASE WHEN @import_source IS NULL THEN 'it1.ixp_tables_description' ELSE 'it.ixp_tables_description' END + ' [Table],
				   idfa.elapsed_time [Elapsed Time (Seconds)],
				   ''<a target="_blank" href="./spa_html.php?spa=exec spa_get_import_process_status '''''' + idfa.process_id + '''''',''''''+ idfa.create_user + '''''', ''''''+ replace(dir_path,''Rules:'','''') + '''''',' + ISNULL('''''' + @import_source_code + '''''', 'NULL') + '&__user_name__='' + idfa.create_user+ ''">'' + idfa.process_id + ''.</a>''[Process ID],
				   dbo.FNAGetUserName(idfa.create_user) [Import User],
				   idfa.create_ts [Import Time]
				   '+ @str_batch_table + ' 
			FROM import_data_files_audit idfa
			INNER JOIN source_system_data_import_status sdis 
				ON  idfa.process_id = sdis.process_id 
				AND sdis.source = ' + ISNULL('''' + @import_source_code + '''','sdis.source') + '
				AND sdis.rules_name = REPLACE(idfa.dir_path, ''RULES:'', '''')
			INNER JOIN ixp_tables it ON it.ixp_tables_name = sdis.source
			LEFT JOIN ixp_tables it1 ON it1.ixp_tables_name = idfa.import_source
			WHERE   1=1 '
			SET @sql = @sql + ' AND convert(varchar(10),idfa.as_of_date,120) BETWEEN ISNULL(''' + @start_date + ''', ''1900-01-01'') AND ISNULL(''' + @end_date + ''', ''9999-01-01'')'
		
			IF @ixp_rules IS NOT NULL
				SET @sql = @sql + ' AND dir_path LIKE ''%' + @rules_code + '%'''
		
			IF @import_source IS NOT NULL
				SET @sql = @sql + ' AND ISNULL(sdis.source, idfa.import_source) = ''' + @import_source_code + ''''
			
			IF @import_user IS NOT NULL
				SET @sql = @sql + ' AND idfa.create_user = ''' + @import_user + ''''
			
				SET @sql = @sql + ' ORDER by idfa.create_ts DESC '
		--PRINT (@sql)
		EXEC(@sql)
	END

/*******************************************2nd Paging Batch START**********************************************/
	--update time spent and batch completion message in message board
	IF @is_batch = 1
	BEGIN
		SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)   
		EXEC(@str_batch_table)                   

		SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_ixp_data_audit_report', 'Data Import Export Audit Report')         
		EXEC(@str_batch_table)        
		RETURN
	END

	--if it is first call from paging, return total no. of rows and process id instead of actual data
	IF @enable_paging = 1 AND @page_no IS NULL
	BEGIN
		SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
		EXEC(@sql_paging)
	END
	/*******************************************2nd Paging Batch END**********************************************/	
END
--SELECT * FROM import_data_files_audit