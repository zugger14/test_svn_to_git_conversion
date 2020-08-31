IF OBJECT_ID(N'[dbo].[spa_rfx_report_dataset_relationship]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_report_dataset_relationship]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: padhikari@pioneersolutionsglobal.com
-- Create date: 2012-09-04
-- Description: Save operations for New reporting Form
 
-- Params:
-- @flag - Operation Flag                       
-- @process_id Operation Process ID
-- @report_dataset_id Parent Dataset Involved
-- @report_id 

--SAMPLE USE : EXEC [spa_rfx_report_dataset_relationship] 'i', '06205D01_C778_4D98_96A0_AF2FB281DFA4', NULL, NULL, 55
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_rfx_report_dataset_relationship]
	@flag CHAR(1),
	@process_id VARCHAR(50),
	@report_dataset_id INT = NULL,
	@report_id INT = NULL,
	@xml TEXT = NULL,
	@sql_relationship VARCHAR(MAX) = NULL
AS
SET NOCOUNT ON -- NOCOUNT is set ON since returning row count has side effects on exporting table feature
/*
declare @flag CHAR(1),
	@process_id VARCHAR(50),
	@report_dataset_id INT = NULL,
	@report_id INT = NULL,
	@xml VARCHAR(MAX) = NULL,
	@sql_relationship VARCHAR(MAX) = NULL

select  @flag='a',@process_id='D9CB3B3E_842B_41F5_80FF_8395C2BBA234',@report_dataset_id='49392'
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo

--*/
DECLARE @user_name                        VARCHAR(50)   
DECLARE @rfx_report                       VARCHAR(200)
DECLARE @rfx_report_dataset               VARCHAR(200)
DECLARE @rfx_report_dataset_relationship  VARCHAR(200)
DECLARE @rfx_data_source_column            VARCHAR(200)
DECLARE @rfx_report_tablix_column                  VARCHAR(200)
DECLARE @rfx_report_chart_column                  VARCHAR(200)
DECLARE @rfx_report_gauge_column                  VARCHAR(200)
DECLARE @sql                              VARCHAR(8000)
	
SET @user_name = dbo.FNADBUser()
SET @rfx_report = dbo.FNAProcessTableName('report', @user_name, @process_id)
SET @rfx_report_dataset = dbo.FNAProcessTableName('report_dataset', @user_name, @process_id)
SET @rfx_report_dataset_relationship = dbo.FNAProcessTableName('report_dataset_relationship', @user_name, @process_id)
SET @rfx_data_source_column = dbo.FNAProcessTableName('data_source_column', @user_name, @process_id)
SET @rfx_report_tablix_column = dbo.FNAProcessTableName('report_tablix_column', @user_name, @process_id)
SET @rfx_report_chart_column = dbo.FNAProcessTableName('report_chart_column', @user_name, @process_id)
SET @rfx_report_gauge_column = dbo.FNAProcessTableName('report_gauge_column', @user_name, @process_id)

IF @flag = 'i'
BEGIN	
	DECLARE @idoc  INT
	--SET @xml = '
	--		<Root>
	--			<PSRecordset Dataset="5" DatasetFrom="5" ColumnFrom="66" DatasetTo="7" ColumnTo="71"></PSRecordset>
	--			<PSRecordset Dataset="5" DatasetFrom="5" ColumnFrom="64" DatasetTo="6" ColumnTo="58"></PSRecordset>
	--			<PSRecordset Dataset="7" DatasetFrom="7" ColumnFrom="67" DatasetTo="6" ColumnTo="57"></PSRecordset>
	--			<PSRecordset Dataset="7" DatasetFrom="7" ColumnFrom="67" DatasetTo="6" ColumnTo="57"></PSRecordset>
	--			<PSRecordset Dataset="7" DatasetFrom="7" ColumnFrom="67" DatasetTo="6" ColumnTo="57"></PSRecordset>
	--		</Root>'
			
		--Create an internal representation of the XML document.
	EXEC sp_xml_preparedocument @idoc OUTPUT,@xml

	-- Create temp table to store the report_name and report_hash
	IF OBJECT_ID('tempdb..#rfx_rdr') IS NOT NULL
		DROP TABLE #rfx_rdr

	-- Execute a SELECT statement that uses the OPENXML rowset provider.
	SELECT Dataset [dataset_id],
		   DatasetFrom [from_dataset_id],
		   DatasetTo [to_dataset_id],
		   ColumnFrom [from_column_id],
			   ColumnTo [to_column_id],
			   JoinType [join_type]
	INTO #rfx_rdr
	FROM   OPENXML(@idoc, '/Root/PSRecordset', 1)
	WITH (
	   Dataset		VARCHAR(10),
	   DatasetFrom	VARCHAR(20),
	   DatasetTo	VARCHAR(20),
	   ColumnFrom	VARCHAR(20),
		   ColumnTo		VARCHAR(20),
		   JoinType		VARCHAR(2)
	)
	--select * from #rfx_rdr
	SET @sql = '
	DELETE FROM ' + @rfx_report_dataset_relationship + ' WHERE dataset_id IN (
		SELECT rd.[dataset_id] FROM #rfx_rdr rd	
	)

	if not exists (select top 1 1 from  #rfx_rdr where from_dataset_id = -1)
	begin
		INSERT INTO ' + @rfx_report_dataset_relationship + '([dataset_id], [from_dataset_id], [to_dataset_id], [from_column_id], [to_column_id], [join_type])
		SELECT [dataset_id], [from_dataset_id], [to_dataset_id], [from_column_id], [to_column_id], [join_type] FROM #rfx_rdr
	end
	
	                
	UPDATE ' + @rfx_report_dataset + '
	SET is_free_from = ''0'' WHERE report_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10))
	    
    EXEC spa_print @sql
	EXEC (@sql)

	DECLARE @run_job_name VARCHAR(1000) =  'RFX Generate Dataset Sample CSV (' + @process_id+ '^' + RIGHT(CONVERT(DECIMAL(38,12),GETDATE()), 12) + ')'
	DECLARE @user_login_id VARCHAR(100) = dbo.fnadbuser()
	SET @sql  = 'spa_rfx_report_dataset_generate_csv_dhx @flag=''g'', @process_id=''' + @process_id+ ''', @parameter_values='''''

	DECLARE @report_dataset_csv_cols VARCHAR(500) = dbo.FNAProcessTableName('report_dataset_csv_cols', @user_name, @process_id)
		
	IF OBJECT_ID(@report_dataset_csv_cols) IS NOT NULL
	EXEC('drop table ' + @report_dataset_csv_cols)
	
	EXEC spa_rfx_report_dataset_dhx @flag = 'f1', @process_id=@process_id, @report_dataset_id=@report_dataset_id
	EXEC spa_run_sp_as_job @run_job_name= @run_job_name, @spa=@sql, @proc_desc='Generate Dataset CSV files.', @user_login_id=@user_login_id, @job_subsystem='TSQL'

    IF @@ERROR <> 0
        EXEC spa_ErrorHandler @@ERROR,
             'Reporting FX',
             'spa_rfx_report_dataset_relationship',
             'DB Error',
             'Fail to save data.',
             ''
    ELSE
        EXEC spa_ErrorHandler 0,
             'Reporting FX',
             'spa_rfx_report_dataset_relationship',
             'Success',
             'Data successfully saved.',
             @process_id
    
END

IF @flag = 's'
BEGIN
    SET @sql = 'SELECT rd.[report_dataset_id],
                       dsc.[data_source_column_id],
                       rd.[alias] + ''.'' + dsc.[name] AS [name], 
                       dsc.alias,
                       dsc.[name] AS [column_name] 
                FROM   ' + @rfx_report_dataset + ' rd
                JOIN data_source ds ON  rd.source_id = ds.data_source_id
                JOIN data_source_column dsc ON  dsc.source_id = ds.data_source_id
                WHERE  rd.report_id = ' + CAST(@report_id AS VARCHAR(10)) + '
                ORDER BY dsc.alias, rd.root_dataset_id ASC'
    EXEC spa_print @sql 
    EXEC (@sql)
END

IF @flag = 'h'
BEGIN
    SET @sql = 'SELECT  rd.[report_dataset_id],
						CASE WHEN rd.[root_dataset_id] IS NULL THEN ds.[name]+'' (''+rd.[alias]+'')'' 
							 WHEN rd.[root_dataset_id] IS NOT NULL THEN '' - ''+ds.[name]+'' (''+rd.[alias]+'')'' 
						END AS [name],
						CASE WHEN rd.[root_dataset_id] IS NULL THEN CAST(rd.[report_dataset_id] AS VARCHAR) 
							 WHEN rd.[root_dataset_id] IS NOT NULL THEN CAST(rd.[root_dataset_id] AS VARCHAR)+''_''+CAST(rd.[report_dataset_id] AS VARCHAR)  
						END AS sorter
				FROM ' + @rfx_report_dataset + ' rd
				JOIN data_source ds ON ds.data_source_id = rd.source_id 
				WHERE rd.report_id = ' + CAST(@report_id AS VARCHAR(10)) + '
				ORDER BY sorter'
    EXEC spa_print @sql 
    EXEC (@sql) 
END

IF @flag = 'c'
BEGIN
    SET @sql = 'SELECT rd.[report_dataset_id],
                   CASE WHEN CHARINDEX(''[adiha_process].[dbo].[batch_export_'', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], ''[batch_export_'') 
						 WHEN CHARINDEX(''[adiha_process].[dbo].[report_export_'', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], ''[report_export_'')
						ELSE ds.[name]
					END 
                    + '' ('' + rd.[alias] + '')'' AS [name]
                FROM   ' + @rfx_report_dataset + ' rd
                JOIN data_source ds ON  ds.data_source_id = rd.source_id
                WHERE  rd.root_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10)) + '
                ORDER BY [name]'
    EXEC spa_print @sql 
    EXEC (@sql)
END

IF @flag = 'l'
BEGIN
    SET @sql = 'SELECT 
					rd.report_dataset_id,
					CASE WHEN CHARINDEX(''[adiha_process].[dbo].[batch_export_'', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], ''[batch_export_'') 
						WHEN CHARINDEX(''[adiha_process].[dbo].[report_export_'', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], ''[report_export_'')
						ELSE ds.[name]
					END + '' ('' + case ds.type_id when 1 then ''View'' when 2 then ''SQL'' when 3 then ''Table'' else ''View'' end + '')'' AS [Name],
					rd.alias [Alias]
                FROM   ' + @rfx_report_dataset + ' rd
                JOIN data_source ds ON  ds.data_source_id = rd.source_id
                WHERE  rd.root_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10))
    EXEC spa_print @sql    
    EXEC (@sql)
END

IF @flag = 'j'
BEGIN
    SET @sql = 'SELECT rd.[report_dataset_id]
				, CASE WHEN CHARINDEX(''[adiha_process].[dbo].[batch_export_'', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], ''[batch_export_'') 
					WHEN CHARINDEX(''[adiha_process].[dbo].[report_export_'', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], ''[report_export_'')
					ELSE ds.[name]
				  END 
				+'' (''+rd.alias+'')'' [Name] , rd.alias[Alias] 
				FROM ' + @rfx_report_dataset + ' rd 
				JOIN data_source ds ON ds.data_source_id = rd.source_id
				WHERE rd.root_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10))+' OR rd.report_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10))
    EXEC spa_print @sql    
    EXEC (@sql)
END

IF @flag = 'd'
BEGIN

	IF OBJECT_ID('tempdb..#temp_validation_table') IS NOT NULL
	DROP TABLE #temp_validation_table

	Create table #temp_validation_table(value BIT)

   SET @sql =	'				INSERT INTO #temp_validation_table(value) 
								select * from (
								select 1 [col] from ' + @rfx_report_dataset + ' rd
								INNER join data_source_column dsc ON dsc.source_id = rd.source_id
								INNER join ' + @rfx_report_tablix_column  + ' rtc on  rtc.column_id = dsc.data_source_column_id
								where rd.report_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10)) + '								
								UNION 
								select 1 [col] from ' + @rfx_report_dataset + ' rd
								INNER join data_source_column  dsc ON dsc.source_id = rd.source_id								
								INNER JOIN ' + @rfx_report_chart_column + ' rcc on rcc.column_id = dsc.data_source_column_id
								where rd.report_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10)) + '
								UNION 
								select 1 [col] from ' + @rfx_report_dataset + ' rd
								INNER join data_source_column dsc ON dsc.source_id = rd.source_id
								INNER JOIN ' + @rfx_report_gauge_column + ' rgc on rgc.column_id = dsc.data_source_column_id
								where rd.report_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10)) + ')a'
		exec spa_print @sql
		EXEC(@sql)		
		
		IF EXISTS(Select 1 from #temp_validation_table)
		BEGIN
			EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_dataset_relationship', 'Error', 'Dataset used in report.', ''
		END
		ELSE 
		BEGIN
			SET @sql = 'DELETE FROM ' + @rfx_report_dataset + '
						WHERE report_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10)) + '  

						DELETE FROM ' + @rfx_report_dataset_relationship + ' 
						WHERE from_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10)) + ' or to_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10))
			exec spa_print @sql
			EXEC(@sql)
			EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_report_dataset_relationship', 'Success', 'Dataset deleted successfully.', ''
		END
END

IF @flag = 'a'
BEGIN
	
    SET @sql = '
	if OBJECT_ID(''tempdb..#tmp_ds_combnations'') is not null
		drop table #tmp_ds_combnations
	select 
		from_ds.root_dataset_id,
		from_ds.report_dataset_id from_dataset_id,
		from_ds.data_source_id from_source_id,
		from_ds.name from_source,
		to_ds.report_dataset_id to_dataset_id,
		to_ds.data_source_id to_source_id,
		to_ds.name to_source
	into #tmp_ds_combnations
	from (
		select 
		rd.report_dataset_id,max(rd.root_dataset_id) root_dataset_id,ds.data_source_id,ds.name
		from ' + @rfx_report_dataset + ' rd
		inner join data_source ds on ds.data_source_id = rd.source_id
		--inner join data_source_column dsc on dsc.source_id = ds.data_source_id
		where rd.root_dataset_id is not null and rd.root_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10)) + '
		group by rd.report_dataset_id,ds.data_source_id,ds.name
	) from_ds
	cross join (
		select 
		rd.report_dataset_id,max(rd.root_dataset_id) root_dataset_id,ds.data_source_id,ds.name
		from ' + @rfx_report_dataset + ' rd
		inner join data_source ds on ds.data_source_id = rd.source_id
		--inner join data_source_column dsc on dsc.source_id = ds.data_source_id
		where (rd.report_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10)) + ' or rd.root_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10)) + ')
		group by rd.report_dataset_id,ds.data_source_id,ds.name
	) to_ds
	where from_ds.report_dataset_id <> to_ds.report_dataset_id 

	--select ''#tmp_ds_combnations'',* from #tmp_ds_combnations

	if OBJECT_ID(''tempdb..#tmp_auto_join_result'') is not null
		drop table #tmp_auto_join_result

	select 
		identity(int,1,1) auto_join_id, 
		tdc.from_dataset_id, tdc.to_dataset_id, key_col.from_col_id, key_col.to_col_id
	into #tmp_auto_join_result
	from #tmp_ds_combnations tdc
	cross apply (
		select dsc_f.data_source_column_id from_col_id, dsc_t.data_source_column_id to_col_id, dsc_f.name [key_col_name]
		from data_source_column dsc_f
		cross apply (
			select dsc_t.name, dsc_t.data_source_column_id, dsc_t.key_column
			from data_source_column dsc_t 
			where dsc_t.name = dsc_f.name 
				and dsc_t.source_id = tdc.to_source_id 
		) dsc_t
		where (dsc_f.key_column = 1 or dsc_t.key_column = 1)
			and dsc_f.source_id = tdc.from_source_id 
	) key_col
	where not exists(
		select top 1 1 
		from ' + @rfx_report_dataset_relationship + ' rel
		where rel.from_dataset_id = tdc.from_dataset_id
	)
	--return
	--select ''#tmp_auto_join_result'',* from #tmp_auto_join_result

	/* 
	REMOVE DUPLICATE JOINS FROM THE AVAILABLE SET AS SWAPPING OF DATASETS MAY GIVE DUPLICATE JOIN CONDITIONS WHICH ARE EXTRA (NOT NEEDED) 
	e.g.
	from_dataset_id1 / cpty_id => to_dataset_id2 / cpty_id
	to_dataset_id2 / cpty_id => from_dataset_id1 / cpty_id
	*/
	if OBJECT_ID(''tempdb..#tmp_auto_join_result_filtered'') is not null
		drop table #tmp_auto_join_result_filtered
	select clause_set.from_dataset_id, clause_set.to_dataset_id, clause_set.from_col_id, clause_set.to_col_id, 1 connection_join
	into #tmp_auto_join_result_filtered
	from (
		SELECT tajr.*,group_string.group_string,dense_rank() over(partition by group_string.group_string order by tajr.from_dataset_id asc) rnk
		FROM #tmp_auto_join_result tajr
	
		OUTER APPLY (
			SELECT STUFF((SELECT '','' + CAST(sort_col AS VARCHAR(20)) FROM (VALUES(tajr.from_dataset_id), (tajr.to_dataset_id), (tajr.from_col_id), (tajr.to_col_id)) sort_set (sort_col)
			ORDER BY sort_col
			FOR XML PATH ('''')), 1, 1, '''') AS group_string
		) group_string
	) clause_set
	where clause_set.rnk = 1
	
	/* save auto joins of connected datasources  end*/
	
	
	SELECT rdr.report_dataset_relationship_id,
			rdr.join_type [connection_join],
			rdr.from_dataset_id [connecting_dataset],
			' + CAST(@report_dataset_id AS VARCHAR(10)) + ' [root_dataset],
			rdr.from_column_id [from_col],
			rdr.to_dataset_id [to_dataset],
			rdr.to_column_id [to_col]
	                       
    FROM   (
                SELECT report_dataset_id, rd.source_id
                FROM   ' + @rfx_report_dataset + ' rd
                WHERE  rd.root_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10)) + '
                        OR  rd.report_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10)) + '
            ) cum_rd
    INNER JOIN ' + @rfx_report_dataset_relationship + ' rdr ON  cum_rd.report_dataset_id = rdr.dataset_id
	union all
	select -1, connection_join, from_dataset_id, ' + CAST(@report_dataset_id AS VARCHAR(10)) + ', from_col_id, to_dataset_id, to_col_id
	from #tmp_auto_join_result_filtered
	order by [connecting_dataset], [to_dataset], [from_col]
	'
    EXEC spa_print @sql    
    EXEC (@sql)
END

--find order in which datasets should be processed to suggest auto-join
IF @flag = 'o'
BEGIN
    SET @sql = ';WITH cte_dataset_rel (dataset_id, source_id, relationship_level) 
	AS 
	( 
	 --main dataset
	 SELECT rd.report_dataset_id, rd.source_id, 0 relationship_level 
	 FROM  ' + @rfx_report_dataset + ' rd 
	 where rd.root_dataset_id IS NULL
	 AND rd.report_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10)) + '

	UNION all

	 --connected dataset
	 SELECT rd_child.report_dataset_id, rd_child.source_id, (cdr.relationship_level + 1) relationship_level 
	 FROM ' + @rfx_report_dataset + ' rd_child 
	 INNER JOIN cte_dataset_rel cdr ON rd_child.root_dataset_id = cdr.dataset_id
	)
	  
	SELECT  * FROM  cte_dataset_rel'
	EXEC spa_print @sql    
    EXEC (@sql)
    
END

--grab key-columns of left sided (main) dataset
IF @flag = 'p'
BEGIN
	SET @sql = 'SELECT dsc.data_source_column_id, dsc.name, rfx_rd.report_dataset_id
				FROM ' + @rfx_report_dataset + ' rfx_rd 
				JOIN data_source ds ON rfx_rd.source_id = ds.data_source_id
				JOIN data_source_column dsc ON ds.data_source_id = dsc.source_id 
				WHERE (rfx_rd.root_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10)) + ' 
				OR rfx_rd.report_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10)) + ' )
				AND dsc.key_column = 1 ORDER by rfx_rd.report_dataset_id'
    EXEC spa_print @sql    
    EXEC (@sql)
    
END
--inserting into dataset
IF @flag = 'x'
BEGIN
	SET @sql = 'UPDATE ' + @rfx_report_dataset + '
				SET is_free_from = ''1'',
					relationship_sql = ''' + @sql_relationship +
				''' WHERE report_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10))	               
	EXEC spa_print @sql    
	EXEC (@sql)
	    
	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR,
	            'Reporting FX',
	            'spa_rfx_report_dataset_relationship',
	            'DB Error',
	            'Fail to save data.',
	            ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	            'Reporting FX',
	            'spa_rfx_report_dataset_relationship',
	            'Success',
	            'Data successfully saved.',
	            @process_id
END
	
IF @flag = 't'
BEGIN
	SET @sql = 'SELECT report_dataset_id, is_free_from, alias, relationship_sql
	            FROM ' + @rfx_report_dataset + 
	            ' WHERE report_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10))
	    	               
	EXEC spa_print @sql    
	EXEC (@sql)
END
IF @flag = 'k' --for dataset relationship grid from columns (combo) population on basis of dataset (from/to) selected
BEGIN
	SET @sql = '
	SELECT dsc.data_source_column_id, rd.alias + ''.'' + dsc.name
	from data_source_column dsc
	inner join ' + @rfx_report_dataset + ' rd on rd.source_id = dsc.source_id
	WHERE rd.report_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10)) + '
	order by dsc.name
	'
	    	               
	EXEC spa_print @sql    
	EXEC (@sql)
	
END

--debugg
