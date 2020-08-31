
IF OBJECT_ID(N'[dbo].[spa_power_bi_report]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_power_bi_report]
GO

-- ===========================================================================================================
-- Author: navaraj@pioneersolutionsglobal.com
-- Create date: 10/24/2017
-- Description: Power bi reports
 
-- Params:
-- @flag     CHAR - Operation flag
-- ===========================================================================================================

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].spa_power_bi_report
	@flag CHAR(1) = NULL,
	@report_name VARCHAR(200) = NULL,
	@report_filter VARCHAR(MAX) = NULL,
	@runtime_user VARCHAR(100)  = NULL,
	@description VARCHAR(1000) = NULL,
	@is_published INT = 0,
	@power_bi_report_id INT = NULL,
	@paramset_id INT = NULL,
	@undock_opt VARCHAR(10) = NULL,
	@source_report VARCHAR(1000) = NULL,
	@report_url VARCHAR(5000) = NULL,
	@process_table VARCHAR(1000) = NULL,
	@param_tablix_id VARCHAR(100) = NULL,
	@batch_process_id VARCHAR(50) = NULL,
	@power_service_report_id VARCHAR(50) = NULL,
	@power_service_dataset_id VARCHAR(50) = NULL,
	@sec_filter_process_id VARCHAR(50) = NULL,
	@client_folder VARCHAR(100) = NULL

AS


SET @report_filter = dbo.FNAReplaceDYNDateParam(@report_filter)

IF ISNULL(@runtime_user, '') <> '' AND @runtime_user <> dbo.FNADBUser()   
BEGIN
	--EXECUTE AS USER = @runtime_user;
	DECLARE @contextinfo VARBINARY(128)
	SELECT @contextinfo = CONVERT(VARBINARY(128), @runtime_user)
	SET CONTEXT_INFO @contextinfo
END

SET NOCOUNT ON
DECLARE @sql VARCHAR(MAX)
DECLARE @is_admin INT
DECLARE @user_name VARCHAR(100) = dbo.FNADBUser()
DECLARE @u_paramset_id INT

DECLARE @power_bi_username VARCHAR(100)
DECLARE @power_bi_password VARCHAR(1000)
DECLARE @power_bi_client_id VARCHAR(100)
DECLARE @power_bi_group_id VARCHAR(100)
DECLARE @power_bi_gateway_id VARCHAR(100)

DECLARE @tablix_id INT
DECLARE @process_id VARCHAR(1000)

SELECT @is_admin = dbo.FNAIsUserOnAdminGroup(@user_name, 1)
DECLARE @check_report_admin_role INT = ISNULL(dbo.FNAReportAdminRoleCheck(@user_name), 0)
select @power_bi_username = power_bi_username, @power_bi_password = dbo.FNADecrypt(power_bi_password), @power_bi_client_id = power_bi_client_id, @power_bi_group_id = power_bi_group_id, @power_bi_gateway_id = power_bi_gateway_id from connection_string

IF @flag = 'i'
BEGIN
	--SET @runtime_user = 'farrms_admin'
	IF  EXISTS (select 1 from power_bi_report where [name] = @report_name)
	BEGIN
		update power_bi_report
			set [name]= @report_name
			,[owner]= @runtime_user
			,[is_system]= 0
			,[description] = @description
			,[is_published] = @is_published
			,[source_report] = @source_report
			,[process_table] = @process_table

		WHERE  [name] = @report_name
	END
	ELSE
	BEGIN
		insert into power_bi_report([name],[owner],[is_system],[description],[is_published],[source_report],[process_table])
		SELECT @report_name, @runtime_user, 0, @description, @is_published, @source_report, @process_table
	END

END
ELSE IF @flag = 'd'
BEGIN
	DELETE from power_bi_report where [name] = @report_name
END
ELSE IF @flag = 'f'
BEGIN
	select 
		@u_paramset_id= rpm.report_paramset_id
	from 
		report_paramset rpm 
		inner join report_page rp on rp.report_page_id = rpm.page_id
		inner join report_page_tablix rpt on rp.report_page_id = rpt.page_id	
		inner join power_bi_report pbr on pbr.source_report = rpm.paramset_hash
		WHERE 1 = 1 
				and rp.is_deployed = 1
				AND pbr.power_bi_report_id = @power_bi_report_id
	EXEC spa_rfx_format_filter @flag='f', @paramset_id=@u_paramset_id, @parameter_string=@report_filter
END
ELSE IF @flag = 'r'
BEGIN
	DECLARE @current_db_name varchar(200) = db_name();
	
	DECLARE @process_tables  VARCHAR(MAX)
	SELECT @process_tables = process_table, @source_report = source_report from power_bi_report where power_bi_report_id = @power_bi_report_id
	
	----- fetch refport filters with secondary filters START
		
		declare @sec_filter_pt2 varchar(1000) = dbo.FNAProcessTableName('rfx_secondary_filters_info', @user_name, @sec_filter_process_id)
		if object_id(@sec_filter_pt2) is not null 
		begin
			if object_id('tempdb..##tmp_report_filter_pbi2') is not null drop table ##tmp_report_filter_pbi2
			SET @sql = 'SELECT [col_name] + ''='' + ISNULL(CAST([filter_value] AS VARCHAR(1000)),''NULL'') AS report_filter into ##tmp_report_filter_pbi2 FROM ' + @sec_filter_pt2
			EXEC(@sql)
			select @report_filter = @report_filter + ','+ report_filter from ##tmp_report_filter_pbi2			
			if object_id('tempdb..##tmp_report_filter_pbi2') is not null drop table ##tmp_report_filter_pbi2
			
		end
	----- ----- fetch refport filters with secondary filters END

	DECLARE tablix_Cursor4 CURSOR FOR  
		select 
			rpm.report_paramset_id, 
			pbr.[name],
			rpt.report_page_tablix_id, 
			a.item
		from 
			report_paramset rpm 
			inner join report_page rp on rp.report_page_id = rpm.page_id
			outer apply(
				SELECT report_page_tablix_id, ROW_NUMBER() OVER(ORDER BY report_page_tablix_id) AS row_num
					FROM report_page_tablix WHERE page_id = rp.report_page_id 
			) rpt
			inner join power_bi_report pbr on pbr.source_report = rpm.paramset_hash
			outer apply (
				SELECT item, ROW_NUMBER() OVER(ORDER BY item) as row_num
				from dbo.SplitCommaSeperatedValues(@process_tables)				
			) as a
			WHERE 1 = 1 
					and rp.is_deployed = 1
					AND pbr.power_bi_report_id = @power_bi_report_id
					AND a.row_num = rpt.row_num
		OPEN tablix_Cursor4;  
		FETCH NEXT FROM tablix_Cursor4 INTO @u_paramset_id, @report_name,@tablix_id,@process_id;  
		
		WHILE @@FETCH_STATUS = 0  
		BEGIN
		if @report_filter <> 'NULL' AND @report_filter IS NOT NULL
		begin
			/*
			SET @sql = '
			DECLARE @cmd varchar(4000)
			DECLARE cmds CURSOR FOR
			SELECT ''drop table adiha_process.dbo.['' + Table_Name + '']''
			FROM adiha_process.INFORMATION_SCHEMA.TABLES
			WHERE Table_Name LIKE ''%' + @process_id + '''

			OPEN cmds
			WHILE 1 = 1
			BEGIN
				FETCH cmds INTO @cmd
				IF @@fetch_status != 0 BREAK
				EXEC(@cmd)
			END
			CLOSE cmds;
			DEALLOCATE cmds;

			'
			EXEC(@sql)
			*/
			--set @user_name = 'power_bi'
	
			EXEC spa_rfx_run_sql @paramset_id = @u_paramset_id, @component_id = @tablix_id, @criteria = @report_filter, @temp_table_name = NULL, @display_type = 't', @runtime_user = @user_name, @is_html = 'p' , @is_refresh = 0 , @batch_process_id = @process_id
		end
		FETCH NEXT FROM tablix_Cursor4 INTO @u_paramset_id, @report_name,@tablix_id,@process_id;  
		END;  
	CLOSE tablix_Cursor4;  
	DEALLOCATE tablix_Cursor4;
	select 'success' [error_code], @report_name [report_name],@source_report [source_report], 'adiha_process.dbo.batch_report_power_bi_' + @process_id [process_id], @report_url [report_url], @undock_opt [undock_opt], @report_filter [report_filter], @power_bi_username power_bi_username, @power_bi_password power_bi_password, @power_bi_client_id power_bi_client_id, @power_bi_group_id power_bi_group_id
END

ELSE IF @flag = 'w'
BEGIN
	
	select 
		@u_paramset_id= rpm.report_paramset_id, 
		@report_name = pbr.[name],
		@tablix_id =rpt.report_page_tablix_id, 
		@process_id = pbr.process_table

	from 
		report_paramset rpm 
		inner join report_page rp on rp.report_page_id = rpm.page_id
		inner join report_page_tablix rpt on rp.report_page_id = rpt.page_id	
		inner join power_bi_report pbr on pbr.source_report = rpm.paramset_hash
		WHERE 1 = 1 
				and rp.is_deployed = 1
				AND pbr.power_bi_report_id = @power_bi_report_id
	
	
	set @process_id = REPLACE(newid(),'-','_')
	
	EXEC spa_rfx_run_sql @paramset_id = @u_paramset_id, @component_id = @tablix_id, @criteria = @report_filter, @temp_table_name = NULL, @display_type = 't', @runtime_user = @user_name, @is_html = 'y' , @is_refresh = 0 , @batch_process_id = @process_id

	
	DECLARE @msg NVARCHAR(MAX)
	DECLARE @doc_path NVARCHAR(MAX)

	SET @process_table = 'adiha_process.dbo.batch_report_' + CAST(@user_name AS varchar(100)) + '_' + @process_id
	select @doc_path = document_path + '\power_bi\'+@process_id+'.csv' from connection_string

	SET @sql = 'IF NOT EXISTS(select 1 from '+ @process_table +') 
			begin 
				select ''success'' [errorcode], ''' + @report_name+ ''' [report_name],''No Data found.'' [process_id] 
				RETURN
			end'
	EXEC(@sql)

	EXEC spa_export_to_csv @process_table,@doc_path,'y',',','n','n','y','y', @msg OUTPUT
	
	IF @msg = 1
	begin
		SET @sql = '
		DECLARE @cmd1 varchar(4000)
		DECLARE cmds1 CURSOR FOR
		SELECT ''drop table adiha_process.dbo.['' + Table_Name + '']''
		FROM adiha_process.INFORMATION_SCHEMA.TABLES
		WHERE Table_Name LIKE ''%' + @process_id + '''

		OPEN cmds1
		WHILE 1 = 1
		BEGIN
			FETCH cmds1 INTO @cmd1
			IF @@fetch_status != 0 BREAK
			EXEC(@cmd1)
		END
		CLOSE cmds1;
		DEALLOCATE cmds1;

		'
		EXEC(@sql)

		select 'success' [error_code], @report_name [report_name], @process_id [process_id]
	end
	ELSE
		select 'failed' [error_code], @report_name [report_name], 'Try Again!' [process_id]
END

--Batch
ELSE IF @flag = 'b'
begin
	declare @msg_board_desc varchar(5000)
	begin try
		--set @user_name = 'power_bi'
		DECLARE @paramset_hash varchar(200) 
		DECLARE @db_name varchar(200) = db_name();

		IF OBJECT_ID(N'tempdb..#temp_param_tablix', 'U') IS NOT NULL 
			DROP TABLE #temp_param_tablix
		IF OBJECT_ID(N'tempdb..#temp_process_table_name', 'U') IS NOT NULL 
			DROP TABLE #temp_process_table_name
		CREATE TABLE #temp_process_table_name(item VARCHAR(500) COLLATE DATABASE_DEFAULT, row_num INT)

		SELECT item, ROW_NUMBER() OVER(ORDER BY item) AS row_num 
		into #temp_param_tablix
		FROM dbo.SplitCommaSeperatedValues(@param_tablix_id) WHERE item NOT LIKE '%Item%'


		DECLARE @process_table_name_1 varchar(200) = ''
		DECLARE @process_table_name varchar(200) = ''
		DECLARE @cur_item_val VARCHAR(200) = ''
		DECLARE @cur_row_num INT
		DECLARE @tablix_count INT = 0
		DECLARE @process_tbl_count INT = 0
		DECLARE @is_new_or_exist_or_update CHAR(1) = 'n' --n-new e- exists u-Change in tablix count


		if exists (SELECT 1 from power_bi_report where [name] = @report_name AND process_table IS NOT NULL AND process_table <> '')
		begin
			SELECT @process_table_name = process_table from power_bi_report where [name] = @report_name
			INSERT INTO #temp_process_table_name(item, row_num) 
			SELECT item, ROW_NUMBER() OVER(ORDER BY item) from dbo.SplitCommaSeperatedValues(@process_table_name)
			
			-- check paramset count with process tables			
			SELECT @tablix_count = count(1) from #temp_param_tablix WHERE item NOT LIKE '%Item%'
			SELECT @process_tbl_count = count(1) from dbo.SplitCommaSeperatedValues(@process_table_name)

			SELECT @is_new_or_exist_or_update = 'e'
			IF (@tablix_count < @process_tbl_count)
			begin
				-- tablix is removed
				DELETE FROM #temp_process_table_name WHERE row_num > @tablix_count
				SELECT @is_new_or_exist_or_update = 'u'
			end
			else if (@tablix_count > @process_tbl_count)
			begin
				-- tablix is added
				DECLARE @site_value INT;
				SET @site_value = 0;

				WHILE @site_value < @tablix_count - @process_tbl_count
				BEGIN
					SET @process_table_name_1 =  CAST(@tablix_count + @site_value AS VARCHAR(2)) +  [dbo].[FNAGetNewID]();					
					SET @site_value = @site_value + 1;
					INSERT INTO #temp_process_table_name(item, row_num) VALUES (@process_table_name_1, @tablix_count + @site_value)
				END;
				SELECT @is_new_or_exist_or_update = 'u'
			end
			SET @process_table_name = ''
			SELECT @process_table_name += ',' + item from #temp_process_table_name ORDER BY row_num;
			
		end
		else
		begin
			SET @process_table_name = ''
			DECLARE tablix_Cursor CURSOR FOR  
			SELECT item, row_num  
			FROM #temp_param_tablix ORDER BY row_num;  
			OPEN tablix_Cursor;  
			FETCH NEXT FROM tablix_Cursor INTO @cur_item_val,@cur_row_num;  
			WHILE @@FETCH_STATUS = 0  
			   BEGIN
					SET @process_table_name_1 =  CAST(@cur_row_num AS VARCHAR(2)) + [dbo].[FNAGetNewID]();
					SET @process_table_name += ',' + @process_table_name_1;
					select @process_table_name
					INSERT INTO #temp_process_table_name(item, row_num) VALUES (@process_table_name_1, @cur_row_num)
				  FETCH NEXT FROM tablix_Cursor INTO @cur_item_val,@cur_row_num;   
			   END;  
			CLOSE tablix_Cursor;  
			DEALLOCATE tablix_Cursor;
		end
		SET @process_table_name = RIGHT(@process_table_name, LEN(@process_table_name) - 1);

		select @process_id = @process_table_name;
		select @paramset_hash = paramset_hash from report_paramset where report_paramset_id = @paramset_id

		EXEC spa_power_bi_report @flag = 'i', @report_name = @report_name, @runtime_user = @user_name, @description = '', @is_published =1, @source_report = @paramset_hash, @process_table = @process_id
		
		----- fetch refport filters with secondary filters START
		
		declare @sec_filter_pt varchar(1000) = dbo.FNAProcessTableName('rfx_secondary_filters_info', @runtime_user, @sec_filter_process_id)
		if object_id(@sec_filter_pt) is not null 
		begin
			if object_id('tempdb..##tmp_report_filter_pbi') is not null drop table ##tmp_report_filter_pbi
			SET @sql = 'SELECT [col_name] + ''='' + ISNULL(CAST([filter_value] AS VARCHAR(1000)),''NULL'') AS report_filter into ##tmp_report_filter_pbi FROM ' + @sec_filter_pt
			EXEC(@sql)
			select @report_filter = @report_filter + ','+ report_filter from ##tmp_report_filter_pbi			
			if object_id('tempdb..##tmp_report_filter_pbi') is not null drop table ##tmp_report_filter_pbi
			
		end
		----- ----- fetch refport filters with secondary filters END

		DECLARE @process_table_name_item VARCHAR(1000)
		DECLARE tablix_Cursor2 CURSOR FOR  
		SELECT a.item, b.item  
		FROM #temp_param_tablix as a inner join #temp_process_table_name as b on a.row_num = b.row_num ORDER BY a.item
		OPEN tablix_Cursor2;  
		FETCH NEXT FROM tablix_Cursor2 INTO @param_tablix_id, @process_table_name_item;  
		WHILE @@FETCH_STATUS = 0  
			BEGIN  
				SET @sql = '
					DECLARE @cmd' + @param_tablix_id + ' varchar(4000)
					DECLARE cmds' + @param_tablix_id + ' CURSOR FOR
					SELECT ''drop table adiha_process.dbo.['' + Table_Name + '']''
					FROM adiha_process.INFORMATION_SCHEMA.TABLES
					WHERE Table_Name LIKE ''%' + @process_table_name_item + '''

					OPEN cmds' + @param_tablix_id + '
					WHILE 1 = 1
					BEGIN
						FETCH cmds' + @param_tablix_id + ' INTO @cmd' + @param_tablix_id + '
						IF @@fetch_status != 0 BREAK
						EXEC(@cmd' + @param_tablix_id + ')
					END
					CLOSE cmds' + @param_tablix_id + ';
					DEALLOCATE cmds' + @param_tablix_id + ';

					'
					EXEC(@sql)
															
					EXEC spa_rfx_run_sql @paramset_id = @paramset_id, @component_id = @param_tablix_id, @criteria = @report_filter, @temp_table_name = NULL, @display_type = 't', @runtime_user = @user_name, @is_html = 'p' , @is_refresh = 0 , @batch_process_id = @process_table_name_item

				FETCH NEXT FROM tablix_Cursor2 INTO @param_tablix_id, @process_table_name_item;  
			END;  
		CLOSE tablix_Cursor2;  
		DEALLOCATE tablix_Cursor2;
		
		-------------------------------------------------
		--SELECT @process_table_name = @process_table_name_item;
		--select @process_id = @process_table_name;

		---- csv generation
		--DECLARE @process_table_csv VARCHAR(500) =''
		--DECLARE @doc_path_csv VARCHAR(500)=''
		--DECLARE @msg_csv NVARCHAR(MAX)
		--SET @process_table_csv = 'adiha_process.dbo.batch_report_' + CAST(@user_name AS varchar(100)) + '_' + @process_id
		--select @doc_path_csv = document_path + '\power_bi\'+@process_id+'.csv' from connection_string
		--EXEC spa_export_to_csv @process_table_csv,@doc_path_csv,'y',',','n','n','y','n', @msg_csv OUTPUT

		/****************generate script start****************************/
			DECLARE @dataset_count INT = 0;
			DECLARE @process_table_name_pbix NVARCHAR(500) 
			DECLARE @sql_pbix NVARCHAR(MAX),@sql2_pbix NVARCHAR(MAX), @cols_pbix NVARCHAR(MAX) = N'', @cols_list_pbix NVARCHAR(MAX) = N'', @cols_list_with_comma_pbix NVARCHAR(MAX) = N'', @msg_pbix NVARCHAR(MAX) = N'', @filename_pbix NVARCHAR(MAX) = N'', @output_pbix NVARCHAR(MAX) = N'';
						
			SET @msg_pbix = N''

			DECLARE tablix_Cursor3 CURSOR FOR  
			SELECT a.item, b.item  
			FROM #temp_param_tablix as a inner join #temp_process_table_name as b on a.row_num = b.row_num ORDER BY a.item
			OPEN tablix_Cursor3;  
			FETCH NEXT FROM tablix_Cursor3 INTO @param_tablix_id, @process_table_name_item;  
			WHILE @@FETCH_STATUS = 0  
				BEGIN  
					SET  @cols_pbix = N''
					SET @cols_list_pbix = N''
					SET @cols_list_with_comma_pbix = N''

					IF OBJECT_ID(N'tempdb..#powerbi_script', 'U') IS NOT NULL DROP TABLE #powerbi_script
					CREATE TABLE #powerbi_script(msg NVARCHAR(MAX) COLLATE DATABASE_DEFAULT)

					SET @process_table_name_pbix = 'adiha_process.dbo.batch_report_power_bi_' + @process_table_name_item
					SELECT @cols_pbix += N',[' + name + '] ' + system_type_name, @cols_list_pbix += N',[' + name + '] ', @cols_list_with_comma_pbix += CASE WHEN system_type_name = 'datetime' OR system_type_name = 'date' THEN N',''''''+ isnull(CAST([' + name + '] AS VARCHAR(500)),''2010-10-08'') +''''''' ELSE  N',''''''+ isnull(CAST([' + name + '] AS VARCHAR(500)),''120'') +''''''' END
					  FROM sys.dm_exec_describe_first_result_set(N'SELECT * FROM ' + @process_table_name_pbix, NULL, 1);

					SET @cols_pbix = STUFF(@cols_pbix, 1, 1, N'');
					SET @cols_list_pbix = STUFF(@cols_list_pbix, 1, 1, N'');
					SET @cols_list_with_comma_pbix = STUFF(@cols_list_with_comma_pbix, 1, 1, N'');
					SET @cols_list_with_comma_pbix = LEFT(@cols_list_with_comma_pbix, LEN(@cols_list_with_comma_pbix) - 4)

					SET @process_table_name_pbix = ISNULL(@process_table_name_pbix,'')
					SET @cols_pbix = ISNULL(@cols_pbix,'')
					SET @cols_list_pbix = ISNULL(@cols_list_pbix,'')
					SET @cols_list_with_comma_pbix = ISNULL(@cols_list_with_comma_pbix,'')

					SET @sql_pbix = N''
					SET @sql2_pbix = N''
					SET @sql_pbix += N'	
								DROP TABLE ' + @process_table_name_pbix + ';
								GO
								'
					SET @sql_pbix += N'
								CREATE TABLE ' + @process_table_name_pbix + '(' + @cols_pbix + ');'
					SET @sql_pbix += N'
								'

					SET @sql2_pbix += N'
								DECLARE @sql_inner1' + @param_tablix_id + ' NVARCHAR(MAX) = '' ' + @sql_pbix + ' '';
								DECLARE @sql_inner' + @param_tablix_id + ' NVARCHAR(MAX) = '''';
								SELECT TOP 10 @sql_inner' + @param_tablix_id + ' = @sql_inner' + @param_tablix_id + ' + ''INSERT INTO '+ @process_table_name_pbix +'(' + @cols_list_pbix + ') 
																	SELECT '+@cols_list_with_comma_pbix+' + '''''';''  from ' + @process_table_name_pbix + ';
								select @sql_inner1' + @param_tablix_id + ' + @sql_inner' + @param_tablix_id + ';
								'
				
					insert into  #powerbi_script
					EXEC(@sql2_pbix)
					
					SET @msg_pbix += '
								IF OBJECT_ID(''' + @process_table_name_pbix + ''') IS NOT NULL '	
					SELECT @msg_pbix = @msg_pbix + '
								' + msg from #powerbi_script
					
					SET @dataset_count += 1
					FETCH NEXT FROM tablix_Cursor3 INTO @param_tablix_id, @process_table_name_item;  
				END;  
			CLOSE tablix_Cursor3;  
			DEALLOCATE tablix_Cursor3;

			SET @msg_pbix = 'USE [Master]
								GO
								DECLARE @dbname nvarchar(128)
								SET @dbname = N''adiha_process''
								IF (NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE (''['' + name + '']'' = @dbname OR name = @dbname)))
								begin
	
									CREATE DATABASE [adiha_process]
								end
								GO
								USE adiha_process
								GO
								' + @msg_pbix

			SELECT @filename_pbix = document_path + '\power_bi\' + isnull(@process_table_name,'') + '.sql' from connection_string

			EXEC spa_write_to_file @content = @msg_pbix, @appendContent = '',@filename = @filename_pbix, @result = @output_pbix OUTPUT
		/****************generate script end****************************/

		DECLARE @template_path VARCHAR(1000)
		SELECT @template_path = SUBSTRING(cs.file_attachment_path,0,CHARINDEX('adiha_pm_html/',cs.file_attachment_path,0)) + 'force_download_archive.php?name='+isnull(@report_name,'')+ '&paramset_hash=' + @paramset_hash + '&dataset_count='+CAST(@dataset_count AS VARCHAR(4))+'&path=dev/shared_docs/power_bi/' + isnull(@process_table_name,'') + '.sql&new_exist_update=' + @is_new_or_exist_or_update + '&cfolder='+ isnull(@client_folder,'trmclient')+'&uname=' + power_bi_username + '&pwd=' + dbo.FNADecrypt(power_bi_password) FROM connection_string cs

		--dev/shared_docs/power_bi/files/template_for_report.pbit
		 set @msg_board_desc = 'Sample PowerBI Template process has completed (' + isnull(@report_name,'') + '). Process ID: ' + isnull(@process_table_name,'') + '  <a href="'  + @template_path + '" target="_blank" title="Download Template">Download</a>'
		EXEC  spa_message_board 'i', @runtime_user, null, 'Report Manager (Sample Power BI Template Generation)', @msg_board_desc, '', '', '', 'e', NULL
	end try
	begin catch
		set @msg_board_desc = 'Sample PowerBI Template process has been failed (' + isnull(@report_name,'') + ').'
		EXEC  spa_message_board 'i', @runtime_user, null, 'Report Manager (Sample Power BI Template Generation)', @msg_board_desc, '', '', '', 'e', NULL
	end catch
end

-- update power service report id and dataset id
ELSE IF @flag = 'p'
begin try
	
	update power_bi_report set [name] =  @report_name, powerbi_report_id = @power_service_report_id, powerbi_dataset_id = @power_service_dataset_id where [source_report] =  @source_report
	
	EXEC spa_ErrorHandler 0,
		'Power BI',
		'spa_power_bi_report',
		'Success',
		'Changes have been saved successfully.',
		''
end try
begin catch
	EXEC spa_ErrorHandler -1,
		'Power BI',
		'spa_power_bi_report',
		'DB Error',
		'Failed Inserting Record',
		''
end catch
ELSE IF @flag = 'q'
begin	
	select pbr.powerbi_report_id, 
			pbr.powerbi_dataset_id, 
			pbr.source_report,
			@power_bi_username power_bi_username,
			@power_bi_password power_bi_password,
			@power_bi_client_id power_bi_client_id,
			@power_bi_group_id power_bi_group_id,
			@power_bi_gateway_id power_bi_gateway_id,
			isnull(pbr.process_table,'NULL') process_table
		from power_bi_report pbr
			inner join report_paramset rpt on rpt.paramset_hash = pbr.source_report			
		where rpt.report_paramset_id =  @paramset_id
end
ELSE IF @flag = 'c'
BEGIN
	IF NOT EXISTS (SELECT 1 FROM report r inner join report_page rp on rp.report_id =r.report_id inner join report_paramset rpt on rpt.page_id = rp.report_page_id where rpt.report_paramset_id = @paramset_id)
		BEGIN
			EXEC spa_ErrorHandler -1,
				 'Power BI',
				 'spa_power_bi_report',
				 'Failed',
				 'Paramset does not exist.',
				 ''
			RETURN
		END
	ELSE IF @source_report = 'upload_powerbi' AND NOT EXISTS (SELECT 1 FROM power_bi_report pbr inner join report_paramset rprm on rprm.paramset_hash = pbr.source_report WHERE rprm.[name] = @report_name)
	BEGIN
		EXEC spa_ErrorHandler -1,
				 'Power BI',
				 'spa_power_bi_report',
				 'Failed',
				 'Please generate sample power bi report first.',
				 ''
			RETURN
	END
	ELSE
	BEGIN
		
			EXEC spa_ErrorHandler 0,
				 'Power BI',
				 'spa_power_bi_report',
				 'Success',
				 'Paramset exists.',
				 ''
			RETURN
	END
END
GO