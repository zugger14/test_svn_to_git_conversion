
IF OBJECT_ID(N'[dbo].[spa_rfx_report_dataset_generate_csv_dhx]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_report_dataset_generate_csv_dhx]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[spa_rfx_report_dataset_generate_csv_dhx]
	@flag				CHAR(1),
	@process_id			varchar(50) = null,
	@parameter_values	VARCHAR(MAX) = NULL
	--@csv_write_path		VARCHAR(2000) = NULL
AS
/*
declare @flag				CHAR(1),
	@process_id			varchar(50) = null,
	@parameter_values	VARCHAR(MAX) = NULL,
	@csv_write_path		VARCHAR(2000) = NULL

	select @flag='g', @csv_write_path='D:\FARRMS\TRMTracker_Trunk\FARRMS\trm\adiha.php.scripts\dev\report_manager_views\', @process_id='17CF3DE8_2F0B_40B0_BE7C_204D86741277', @parameter_values='sub_id=NULL,stra_id=NULL,book_id=NULL,sub_book_id=NULL,locatin_ids=NULL,meter_ids=NULL,profile_ids=NULL,report_id=NULL,term_end=NULL,term_start=NULL'

	declare @f varbinary(128) set @f=convert(varbinary(128),'debug_mode_on')
	set context_info @f

--*/
SET NOCOUNT ON  -- NOCOUNT is set ON since returning row count has side effects on exporting table feature
DECLARE @user_name   	VARCHAR(50) = dbo.FNADBUser()  
DECLARE @sql         	VARCHAR(MAX)
DECLARE @sqln         	NVARCHAR(MAX)

DECLARE @rfx_report_dataset  VARCHAR(1000) = dbo.FNAProcessTableName('report_dataset', @user_name, @process_id)
DECLARE @rfx_report_dataset_relationship VARCHAR(1000) = dbo.FNAProcessTableName('report_dataset_relationship', @user_name, @process_id)
DECLARE @report_dataset_csv_cols VARCHAR(1000) = dbo.FNAProcessTableName('report_dataset_csv_cols', @user_name, @process_id)
DECLARE @report_dataset_csv_file_info VARCHAR(1000) = dbo.FNAProcessTableName('report_dataset_csv_file_info', @user_name, @process_id)
DECLARE @csv_export_table_name VARCHAR(1000) = dbo.FNAProcessTableName('csv_export_table_name', @user_name, @process_id)

declare @batch_identifier varchar(25) = '--[__batch_report__]'
DECLARE @view_identifier CHAR(1) = '{'


declare @success_file_count int = 0
declare @total_file_count int = 0

declare @document_path varchar(200)
declare @csv_file_folder varchar(1000)
declare @err_msg varchar(max)

select @document_path = cs.document_path, @csv_file_folder = cs.document_path + '\report_manager_views'
from connection_string cs

--create folder for storing csv files
if(dbo.FNACheckWriteAccessToFolder(@csv_file_folder) = -1)
begin
	exec spa_create_folder @folder_path=@csv_file_folder,@result=@sqln output
	if(@sqln <> '1')
	begin
		set @err_msg = 'Destination Folder (' +@csv_file_folder + ') could not be created.'
		raiserror(@err_msg, 16, 1)
	end
end


if @flag = 'g'
begin try
	--begin tran
	/** BUILD REPORT FILTER WITH SECONDARY FILTERS START **/
	DECLARE @rfx_report_filter_string VARCHAR(500) = dbo.FNAProcessTableName('rfx_report_filter_string', @user_name, @process_id)

	-- dumps result to process table @rfx_report_filter_string
	exec spa_rfx_report_paramset_dhx @flag='q', @xml=@parameter_values, @process_id=@process_id, @result_to_table=@rfx_report_filter_string
	
	SET @sqln = '
	SELECT @parameter_values = rfs.report_filter  
	FROM ' + @rfx_report_filter_string + '  rfs
	'
	EXEC sp_executesql @sqln, N'@parameter_values VARCHAR(max) OUTPUT', @parameter_values OUT
	
	/** BUILD REPORT FILTER WITH SECONDARY FILTERS START **/

	declare @data_source_process_id_c1 varchar(50)
	
	
	IF OBJECT_ID('tempdb..#tmp_cur_csv_select') IS NOT NULL
		DROP TABLE #tmp_cur_csv_select
	CREATE TABLE #tmp_cur_csv_select (
		[csv_file_name] VARCHAR(5000) COLLATE DATABASE_DEFAULT, [report_dataset_id] INT, [source_id] INT, [is_connected] int
	)
	
	SET @sql = '
	INSERT INTO #tmp_cur_csv_select([csv_file_name], [report_dataset_id], [source_id], [is_connected])
	select ''' + @csv_file_folder + '\'' + ds_cols.csv_file_name csv_file_name, ds_cols.report_dataset_id, ds_cols.source_id, ds_cols.is_connected
	from ' + @report_dataset_csv_cols + ' ds_cols
	cross join connection_string cs
	where ds_cols.csv_file_name is not null
	group by ds_cols.csv_file_name, ds_cols.report_dataset_id, ds_cols.source_id, ds_cols.is_connected
	'
	exec spa_print @sql
	EXEC(@sql)
	

	if OBJECT_ID(@report_dataset_csv_file_info) is not null
	exec('drop table ' + @report_dataset_csv_file_info)
	set @sql = '
	select ''' + @csv_file_folder + '\'' + ds_cols.csv_file_name csv_file_name, ds_cols.report_dataset_id, 0 file_exists, cast('''' as varchar(5000)) file_error_message
	into ' + @report_dataset_csv_file_info + '
	from ' + @report_dataset_csv_cols + ' ds_cols
	cross join connection_string cs
	where ds_cols.csv_file_name is not null
	group by ds_cols.csv_file_name, ds_cols.report_dataset_id, ds_cols.source_id
	'
	exec spa_print @sql
	exec(@sql)
	--select * from #tmp_cur_csv_select
	--return

	select @total_file_count = count(*) from #tmp_cur_csv_select

	/* cursor existence check, if exists and empty close and deallocate */
	IF (SELECT CURSOR_STATUS('local','cur_csv')) >= -1
	BEGIN
		IF (SELECT CURSOR_STATUS('local','cur_csv')) > -1
		BEGIN
			CLOSE cur_csv
		END
		DEALLOCATE cur_csv
	END

	declare cur_csv cursor local
	for
	select * from #tmp_cur_csv_select

	declare @csv_file_name_c varchar(200), @report_dataset_id_c int, @source_id_c int, @is_connected_c int
	open cur_csv
	fetch next from cur_csv into @csv_file_name_c, @report_dataset_id_c, @source_id_c, @is_connected_c

	while @@FETCH_STATUS = 0
	begin
		DECLARE @select_clause VARCHAR(MAX) = ''
		DECLARE @select_clause_null VARCHAR(MAX) = ''
			--to do
		/******************************Datasource TSQL processing (if multiline) START*********************************/
		IF OBJECT_ID('tempdb..#tmp_cur_select') IS NOT NULL
			DROP TABLE #tmp_cur_select
		CREATE TABLE #tmp_cur_select (
			[tsql] VARCHAR(MAX) COLLATE DATABASE_DEFAULT, [alias] VARCHAR(MAX) COLLATE DATABASE_DEFAULT, [source_id] int, [root_dataset_id] int
		)

		SET @sql = '
		INSERT INTO #tmp_cur_select([tsql], [alias], [source_id], rd.root_dataset_id)
		SELECT ds.tsql 
			, ' + iif(@is_connected_c = 1, 'rd.alias', 'ds.alias') + ' [alias]
			, rd.source_id, rd.root_dataset_id
		FROM ' + @rfx_report_dataset + ' rd
		INNER JOIN data_source ds ON rd.source_id = ds.data_source_id 
		
		WHERE 1=1
			AND rd.report_dataset_id = ' + cast(@report_dataset_id_c as varchar(10)) + '
			or (
				rd.root_dataset_id = ' + cast(@report_dataset_id_c as varchar(10)) + '
				and exists(select top 1 1 from ' + @rfx_report_dataset_relationship + ' rdr where rdr.dataset_id = ' + cast(@report_dataset_id_c as varchar(10)) + ')
			)
		'
		exec spa_print @sql
		
		EXEC(@sql)
		--select * from #tmp_cur_select
		--return
		
		/* cursor existence check, if exists and empty close and deallocate */
		IF (SELECT CURSOR_STATUS('local','cur_data_source')) >= -1
		BEGIN
			IF (SELECT CURSOR_STATUS('local','cur_data_source')) > -1
			BEGIN
				CLOSE cur_data_source
			END
			DEALLOCATE cur_data_source
		END

		DECLARE cur_data_source CURSOR LOCAL FOR
		
		SELECT ds.[tsql], ds.[alias], ds.[source_id]
		FROM #tmp_cur_select ds
		order by ds.root_dataset_id
		
		DECLARE	@data_source_tsql_c1	VARCHAR(MAX)
		DECLARE @data_source_alias_c1	VARCHAR(50)	 
		DECLARE @data_source_id_c1		int	 
		set @data_source_process_id_c1 = '99_csv_99' --used unique process_id to identify process tables used on csv generation logic


		OPEN cur_data_source   
		FETCH NEXT FROM cur_data_source INTO @data_source_tsql_c1, @data_source_alias_c1, @data_source_id_c1 
		
		WHILE @@FETCH_STATUS = 0   
		BEGIN
		
			EXEC spa_rfx_handle_data_source_dhx
				@data_source_tsql_c1			
				, @data_source_alias_c1		
				, @parameter_values --@criteria					
				, @data_source_process_id_c1	
				, 1	--@handle_single_line_sql		
				, 0	--@validate
				, null
				, 'y'
				, @process_id


			select @select_clause += case when @select_clause = '' then '' else ',' end + STUFF(
				(SELECT ', ' + 'cast([' + @data_source_alias_c1 + '].[' + dsc.name + '] as varchar(3000))' + ' AS [' + @data_source_alias_c1 + '.' + dsc.name + ']'
				from data_source_column dsc
				where dsc.source_id = @data_source_id_c1
				FOR XML PATH(''))
			, 1, 1, '')

			select @select_clause_null += case when @select_clause_null = '' then '' else ', ' end + STUFF(
				(SELECT ', ' + '''''' + ' AS [' + @data_source_alias_c1 + '.' + dsc.name + ']'
				from data_source_column dsc
				where dsc.source_id = @data_source_id_c1
				FOR XML PATH(''))
			, 1, 1, '')

			FETCH NEXT FROM cur_data_source INTO @data_source_tsql_c1, @data_source_alias_c1, @data_source_id_c1
		END	
		
		CLOSE cur_data_source   
		DEALLOCATE cur_data_source
		--print @select_clause
		--return
		--print dbo.FNAProcessTableName('report_dataset_' + @data_source_alias_c1, dbo.FNADBUser(), @data_source_process_id_c1)
		/******************************Datasource TSQL processing (if multiline) END*********************************/

		/*****************************************Generate FROM clause START**************************************/		
		/*
		* All datasets are defined in report_dataset which can easily be retrieved using simple query. 
		* But relationship level needs to be identified so that first order dataset 
		* (those which are directly connected to main dataset) are picked first, instead of second order dataset 
		* (those which are connected to first order dataset). So CTE is used to resolve relationship level 
		*/
		DECLARE @from_clause VARCHAR(MAX)
		DECLARE @is_free_from BIT = 0 -- 0: free form is not used, 1: free from is used  
		DECLARE @relational_sql VARCHAR(MAX)
		DECLARE @view_index INT
			
		--SET @view_index = CHARINDEX(@view_identifier, @data_source_tsql)
		--PRINT 'View Index: ' + ISNULL(CAST(@view_index AS VARCHAR), '@view_index IS NULL')	
		
		SET @sqln = '
		IF EXISTS (
			SELECT 1
			FROM ' + @rfx_report_dataset + ' rd 
			WHERE rd.root_dataset_id IS NULL
				AND rd.report_dataset_id = ' + cast(@report_dataset_id_c as varchar(10)) + '
				
			AND rd.is_free_from = 1 
		)
		BEGIN 
			SET @is_free_from = 1
		END
		'
		EXEC sp_executesql @sqln, N'@is_free_from BIT OUTPUT', @is_free_from OUT
		--SELECT @is_free_from RETURN

		IF @is_free_from = 1 --having adv sql
		BEGIN 
			SET @sqln = '
			SELECT @relational_sql = ''FROM [''+ rd.alias + ''] '' + rd.relationship_sql
			FROM ' + @rfx_report_dataset + ' rd 
				
			WHERE rd.root_dataset_id IS NULL
				AND rd.report_dataset_id = ' + cast(@report_dataset_id_c as varchar(10)) + '
			'
			EXEC sp_executesql @sqln, N'@relational_sql VARCHAR(MAX) OUTPUT', @relational_sql OUT
			
			IF OBJECT_ID('tempdb..#temp_map') IS NOT NULL
				DROP TABLE #temp_map
			CREATE TABLE #temp_map 
			(
				start_index				INT	
				,report_dataset_id		VARCHAR(100) COLLATE DATABASE_DEFAULT
				,root_dataset_id		VARCHAR(100) COLLATE DATABASE_DEFAULT
				,source_id				INT
				, alias					VARCHAR(100) COLLATE DATABASE_DEFAULT
			)			
			
			SET @sql = '
			;WITH cte_dataset_hierarchy (report_dataset_id,  root_dataset_id, ALIAS, source_id, is_free_from, relationship_sql) 
					AS 
			( 
				SELECT  rd.report_dataset_id, rd.root_dataset_id
					, ' + iif(@is_connected_c = 1, 'rd.alias', 'ds.alias') + ' [alias]
					, rd.source_id, rd.is_free_from, rd.relationship_sql
						FROM ' + @rfx_report_dataset + ' rd 
						inner join data_source ds on ds.data_source_id = rd.source_id
						WHERE rd.root_dataset_id IS NULL
							AND rd.report_dataset_id = ' + cast(@report_dataset_id_c as varchar(10)) + '
				
				UNION ALL
				
				SELECT rd_child.report_dataset_id, rd_child.root_dataset_id
				, rd_child.alias, rd_child.source_id, rd_child.is_free_from, rd_child.relationship_sql
						FROM cte_dataset_hierarchy cdr
						INNER JOIN ' + @rfx_report_dataset + ' rd_child ON rd_child.root_dataset_id = cdr.report_dataset_id
			)
	
			INSERT INTO #temp_map(
				start_index,
				report_dataset_id,
				root_dataset_id,
				source_id,
				alias
			)
			SELECT  n, cdh.report_dataset_id, cdh.root_dataset_id, cdh.source_id, cdh.alias
			FROM cte_dataset_hierarchy cdh
			INNER JOIN ' + @rfx_report_dataset + ' rd ON rd.report_dataset_id = cdh.report_dataset_id
			LEFT JOIN dbo.seq pos_alias_name ON pos_alias_name.n <= LEN(''' + @relational_sql + ''')
				AND SUBSTRING(''' + @relational_sql + ''', pos_alias_name.n, LEN(''['' + cdh.alias + '']''))  = ''['' + rd.alias + '']''
			'
			EXEC(@sql)
			
			SELECT @relational_sql =  
				CASE WHEN CHARINDEX(@batch_identifier, MAX(ds.[tsql])) > 0 THEN
					STUFF(@relational_sql, MAX(tm.start_index), 0, dbo.FNAProcessTableName('report_dataset_' + MAX(tm.[alias]), dbo.FNADBUser(), @data_source_process_id_c1))
				ELSE
					STUFF(@relational_sql, MAX(tm.start_index), 0, '('+ MAX(ds.[tsql]) + ')')
				END 
			FROM #temp_map tm
			INNER JOIN data_source ds ON ds.data_source_id = tm.source_id
			GROUP BY start_index
			ORDER BY start_index DESC --start replacing the source from the end such that the position of the alias doesnt change.

			SELECT	@from_clause = @relational_sql
		END
		ELSE
		BEGIN
			IF OBJECT_ID('tempdb..#dataset_join_option') IS NOT NULL
			DROP TABLE #dataset_join_option
			
			SELECT dataset_join.* INTO #dataset_join_option 
			FROM ( 
				SELECT 1 [id], 'INNER JOIN ' [Description] UNION
				SELECT 2 [id], 'LEFT JOIN '  [Description] UNION
				SELECT 3 [id], 'FULL JOIN ' [Description] 
			) dataset_join	

			IF OBJECT_ID('tempdb..#tmp_cte_dataset_rel') IS NOT NULL
				DROP TABLE #tmp_cte_dataset_rel
			CREATE TABLE #tmp_cte_dataset_rel 
			(
				dataset_id				INT	
				, source_id		INT
				, [alias]		VARCHAR(100) COLLATE DATABASE_DEFAULT
				, from_alias				VARCHAR(100) COLLATE DATABASE_DEFAULT
				, from_column_id INT
				, to_alias VARCHAR(100) COLLATE DATABASE_DEFAULT
				, to_column_id INT
				, relationship_level INT
				, join_type INT
			)

			SET @sql = '
			;WITH cte_dataset_rel (dataset_id, source_id, [alias], from_alias, from_column_id, to_alias, to_column_id, relationship_level, join_type) 
			AS 
			( 
				--main dataset
					SELECT rd.report_dataset_id, rd.source_id, 
					' + iif(@is_connected_c = 1, 'rd.alias', 'ds.alias') + ' [alias],
					' + iif(@is_connected_c = 1, 'rd.alias', 'ds.alias') + ' from_alias, 
					NULL from_column_id, CAST(NULL AS VARCHAR(100)) to_alias, NULL to_column_id, 0 relationship_level , NULL join_type
				FROM ' + @rfx_report_dataset + ' rd
				INNER JOIN data_source ds ON rd.source_id = ds.data_source_id 
				WHERE rd.root_dataset_id IS NULL
					AND rd.report_dataset_id = ' + cast(@report_dataset_id_c as varchar(10)) + '
			
				UNION ALL
			
				--connected dataset
					SELECT rdr.from_dataset_id, rd_main.source_id, rd_main.[alias], rd_from.[alias] from_alias, rdr.from_column_id, cdr.from_alias to_alias, rdr.to_column_id, (cdr.relationship_level + 1) relationship_level ,rdr.join_type join_type
				FROM cte_dataset_rel cdr
				INNER JOIN ' + @rfx_report_dataset_relationship + ' rdr ON rdr.to_dataset_id = cdr.dataset_id
				INNER JOIN ' + @rfx_report_dataset + ' rd_from ON rdr.from_dataset_id = rd_from.report_dataset_id
				INNER JOIN ' + @rfx_report_dataset + ' rd_main ON rdr.from_dataset_id = rd_main.report_dataset_id
				WHERE rd_from.root_dataset_id = ' + cast(@report_dataset_id_c as varchar(10)) + '
		
			)
			INSERT INTO #tmp_cte_dataset_rel
			SELECT * FROM cte_dataset_rel
			'
			--print(@sql)
			EXEC(@sql)
			
			
		
		SELECT @from_clause = 
			STUFF(
			(
					SELECT CHAR(10) + (CASE WHEN MAX(relationship_level) = 0 THEN ' FROM ' ELSE 
						MAX(djo.[description]) 
																												 END) 
					+  CASE WHEN CHARINDEX(@batch_identifier, MAX(ds.[tsql])) > 0 
						THEN dbo.FNAProcessTableName('report_dataset_' + MAX(cte.[alias]), dbo.FNADBUser(), @data_source_process_id_c1)
								--WHEN CHARINDEX(@view_identifier, MAX(ds.[tsql])) > 0  AND CHARINDEX(@batch_identifier, dbo.FNAGetViewTsql(MAX(ds.[tsql]))) > 0 
								--	THEN  dbo.FNAProcessTableName('report_dataset_' + MAX(ds.[alias]), dbo.FNADBUser(), @data_source_process_id)--'('+ dbo.FNAGetViewTsql(MAX(ds.[tsql])) + ')'	
								WHEN CHARINDEX(@view_identifier, MAX(ds.[tsql])) > 0 
									THEN dbo.FNAProcessTableName('report_dataset_' + MAX(cte.[alias]), dbo.FNADBUser(), @data_source_process_id_c1)
						ELSE '(' + MAX(ds.[tsql]) + ')'
						END										--datasource
					+ ' ' + QUOTENAME(MAX(cte.[alias]))			--datasource [alias]
					+ ISNULL(' ON ' + MAX(join_cols), '') 		--join keys
				FROM
				(
						SELECT dataset_id, source_id, [alias], from_alias, from_column_id, to_alias, to_column_id, MAX(relationship_level) relationship_level, join_type
					FROM #tmp_cte_dataset_rel
						GROUP BY dataset_id, source_id, [alias], from_alias, from_column_id, to_alias, to_column_id, join_type
					--ORDER BY relationship_level
				) cte
				INNER JOIN data_source ds ON ds.data_source_id = cte.source_id
				OUTER APPLY (
					 SELECT
					   STUFF(
				   		(
				   		   SELECT DISTINCT ' AND ' + CAST((from_alias + '.' + QUOTENAME(dsc_from.name) + ' = ' + to_alias +  '.' + QUOTENAME(dsc_to.name)) AS VARCHAR(MAX)) 
						   FROM #tmp_cte_dataset_rel cdr_inner
						   INNER JOIN data_source_column dsc_from ON cdr_inner.from_column_id = dsc_from.data_source_column_id
						   INNER JOIN data_source_column dsc_to ON cdr_inner.to_column_id = dsc_to.data_source_column_id
						   WHERE cdr_inner.dataset_id = cte.dataset_id
						   FOR XML PATH(''), TYPE
					   ).value('.[1]', 'VARCHAR(MAX)'), 1, 5, '') join_cols
				) join_key_set
				LEFT  JOIN  #dataset_join_option djo ON djo.id = cte.join_type
				GROUP BY dataset_id, cte.join_type
				ORDER BY MAX(relationship_level), cte.join_type 
				FOR XML PATH(''), TYPE
			).value('.[1]', 'VARCHAR(MAX)'), 1, 1, '') 
		END
		--print '####'
		--print @select_clause	
		--print @from_clause
		--return
		if OBJECT_ID(@csv_export_table_name) is not null
		exec('drop table ' + @csv_export_table_name)
		set @sql = '
		select top 20 ' + @select_clause + '
		into ' + @csv_export_table_name + char(10) 
		+ @from_clause + '
		union all 
		select ' + @select_clause + char(10) + @from_clause + ' where 1=2
		'
		exec(@sql)
		exec spa_print @sql
		set @sql = '
		if not exists(select top 1 1 from ' + @csv_export_table_name + ')
		begin
			
			insert into ' + @csv_export_table_name + '
			select ' + @select_clause_null + '
		end
		'
		exec spa_print @sql
		exec(@sql)
		
		declare @result int = 0
		
		--select @csv_export_table_name [table_name], @csv_file_name_c [export_file_name], 'y' [include_column_headers], ',' [delimiter], 'n' [compress_file],'y' [use_date_conversion],'y' [strip_html],'y' [enclosed_with_quotes]
		EXEC spa_export_to_csv @table_name=@csv_export_table_name, @export_file_name=@csv_file_name_c, @include_column_headers='y', @delimiter=',', @compress_file='n',@use_date_conversion='y',@strip_html='y',@enclosed_with_quotes='y',@result=@result OUTPUT
		
		if @result = 1
		begin
			set @sql = '
			update csv_info
			set csv_info.file_exists = 1, csv_info.file_error_message = ''success''
			from ' + @report_dataset_csv_file_info + ' csv_info
			where csv_info.csv_file_name = ''' + @csv_file_name_c + '''
			'
			set @success_file_count = @success_file_count + 1
		end
		else
		begin
			set @sql = '
			update csv_info
			set csv_info.file_exists = 0, csv_info.file_error_message = error_message()
			from ' + @report_dataset_csv_file_info + ' csv_info
			where csv_info.csv_file_name = ''' + @csv_file_name_c + '''
			'
		end
		exec spa_print @sql
		exec(@sql)

		--RETURN
		/*****************************************Generate FROM clause END**************************************/
		fetch next from cur_csv into @csv_file_name_c, @report_dataset_id_c, @source_id_c, @is_connected_c
	end
	close cur_csv
	deallocate cur_csv
	
	declare @msg_board_desc varchar(5000) = 'Sample data generation process has completed. [Success/Total: ' + cast(@success_file_count as varchar(3)) + '/' +  cast(@total_file_count as varchar(3)) + ']'
	
	EXEC  spa_message_board 'i', @user_name, null, 'Report Manager (Sample Data Generation)', @msg_board_desc, '', '', '', 'e', NULL
	
	--commit
end try
begin catch
	
	set @err_msg = error_message()
	--rollback
	DECLARE @rfx_err_log VARCHAR(1000) = dbo.FNAProcessTableName('rfx_err_log', @user_name, @process_id)
	--LOG ERROR ON REPORT MANAGER ERROR LOG TABLE
	set @sql = '
	insert into ' + @rfx_err_log + '
	select ''spa_rfx_report_dataset_generate_csv_dhx'', ''' +  replace(@err_msg,'''','''''') + ''', getdate()
	'
	exec spa_print @sql
	exec(@sql)

	--close and deallocate cursors on error handling
	IF (SELECT CURSOR_STATUS('local','cur_data_source')) >= -1
	BEGIN
		IF (SELECT CURSOR_STATUS('local','cur_data_source')) > -1
		BEGIN
			CLOSE cur_data_source
		END
		DEALLOCATE cur_data_source
	END
	IF (SELECT CURSOR_STATUS('local','cur_csv')) >= -1
	BEGIN
		IF (SELECT CURSOR_STATUS('local','cur_csv')) > -1
		BEGIN
			CLOSE cur_csv
		END
		DEALLOCATE cur_csv
	END
	--RAISERROR ('Error on Sample Data Generation Process.', 16, 1)
	declare @desc varchar(5000) = 'Sample data generation process has failed. [Success/Total: ' + cast(@success_file_count as varchar(3)) + '/' +  cast(@total_file_count as varchar(3)) + ']'
	EXEC spa_message_board 'i', @user_name , NULL, 'Report Manager (Sample Data Generation)' , @desc , '', '', 'e', NULL
	
end catch


/** debug code start **/

/** debug code end **/
