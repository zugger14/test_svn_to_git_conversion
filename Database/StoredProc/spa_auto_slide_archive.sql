

/****** Object:  StoredProcedure [dbo].[spa_auto_slide_archive]    Script Date: 08/08/2014 12:51:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_auto_slide_archive]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_auto_slide_archive]
GO



/****** Object:  StoredProcedure [dbo].[spa_auto_slide_archive]    Script Date: 08/08/2014 12:51:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ===============================================================================================================
-- Create date: 2012-02-17
-- Description:	This SP will invoke partition sliding by executing spa_slide_range_left_window_datetime
-- params :
-- @table_name = name of table on which sliding needs to be performed 
-- ===============================================================================================================

CREATE PROC [dbo].[spa_auto_slide_archive]
@archive_type_value_id VARCHAR(150) -- Partition ID
AS
SET NOCOUNT, XACT_ABORT ON;
DECLARE @frequency				VARCHAR(1)
DECLARE @partition_function		VARCHAR(100)
DECLARE @file_group				VARCHAR(20)
DECLARE @partition_scheme		VARCHAR(100)
DECLARE @archive_status			VARCHAR(1)
DECLARE @stage_table			VARCHAR(100)
DECLARE @archive_table			VARCHAR(100)
DECLARE @run_date				DATETIME = GETDATE()
DECLARE @arch_date				DATETIME
DECLARE @value_id				NUMERIC
DECLARE	@db_user				VARCHAR(100)
DECLARE @partition_key			VARCHAR(25)
DECLARE @parti_key_value		INT
DECLARE @table_name				VARCHAR(100)
DECLARE @sql					VARCHAR(MAX)
declare @tran_stat_count		numeric
DECLARE @tran_stat_f			varchar(1)
DECLARE @granule				INT
DECLARE @no_partitions			INT
DECLARE @archive_frequency      VARCHAR(1)


	
BEGIN
	SET @db_user = dbo.FNADBUser()
	BEGIN TRY
		
		select @tran_stat_count =  count(distinct tran_status) from archive_data_policy where archive_type_value_id = @archive_type_value_id
		if @tran_stat_count = 1 
		BEGIN 
			SELECT @tran_stat_f =    tran_status from archive_data_policy where archive_type_value_id = @archive_type_value_id
			IF @tran_stat_f = 'C' 
				set @sql = 'UPDATE archive_data_policy  SET tran_status = ''F'' where archive_type_value_id = ' + @archive_type_value_id 
				print @sql 
				exec (@sql)
		END
		
		CREATE TABLE #arch_status(to_slide BIT)
				 
		DECLARE list_arch_policy_tbls CURSOR LOCAL FOR
		
		SELECT main_table_name, main_table_name, where_field, archive_frequency FROM archive_data_policy
		WHERE archive_type_value_id = @archive_type_value_id and tran_status <> 'C'
		ORDER BY sequence
		OPEN list_arch_policy_tbls;
		
		FETCH NEXT FROM list_arch_policy_tbls INTO @table_name, @stage_table, @partition_key, @archive_frequency
		WHILE @@FETCH_STATUS = 0
		BEGIN
				DECLARE cur_status CURSOR LOCAL FOR
				SELECT no_partitions, frequency, function_name, filegroup, scheme_name, archive_status,  table_name,granule
				FROM dbo.partition_config_info pci
				INNER JOIN dbo.SplitCommaSeperatedValues(@table_name) spcv ON pci.table_name = spcv.item
				WHERE del_flg = 'N'

				OPEN cur_status;
		 
				FETCH NEXT FROM cur_status INTO @no_partitions, @frequency, @partition_function, @file_group, @partition_scheme, @archive_status,  @archive_table, @granule
				WHILE @@FETCH_STATUS = 0
				BEGIN
					set @sql = 'UPDATE archive_data_policy  SET tran_status = ''I'' where main_table_name = ''' + @table_name + ''''
					print @sql 
					exec (@sql)
					

					BEGIN TRAN
					
					PRINT('Now processing Parition ID: ' + @table_name)
					--SELECT  @run_date = MIN(CAST(prv.value AS DATETIME)) 
					--FROM sys.partition_functions AS pf
					--INNER JOIN sys.partition_range_values AS prv ON	prv.function_id = pf.function_id
					--WHERE pf.name = @partition_function;
					
					--IF	@frequency = 'd' 
					--	SET @parti_key_value = 0
					--ELSE
					--	SET	@parti_key_value = 1  
					--print @granule
					TRUNCATE TABLE #arch_status
					
					EXEC('
					DECLARE @retention_period AS VARCHAR(10)
					DECLARE @reten_boundary DATE
					DECLARE @partition_start_boundary DATE

					SELECT @partition_start_boundary = CAST(prv.value AS DATE) FROM sys.partition_functions AS pf JOIN sys.partition_range_values AS prv ON prv.function_id = pf.function_id
					WHERE pf.name = ''' + @partition_function + '''  AND prv.boundary_id=1
					
					SELECT @retention_period = adpd.retention_period * -1 FROM archive_data_policy_detail adpd
					INNER JOIN archive_data_policy adp ON adp.archive_data_policy_id = adpd.archive_data_policy_id
					WHERE adpd.table_name = ''' + @table_name + ''' AND adp.archive_type_value_id = ' + @archive_type_value_id + '
					print ''retention_period: '' + @retention_period
					SET @reten_boundary = DATEADD(' + @archive_frequency + ', CAST(@retention_period AS INT), GETDATE() )
					
					INSERT INTO #arch_status(to_slide)
					SELECT 
					CASE WHEN ''' + @archive_frequency + ''' = ''m'' THEN 
						CASE WHEN @partition_start_boundary <= DATEADD(month, DATEDIFF(month, 0, @reten_boundary), 0) THEN 1 ELSE 0 END
					WHEN ''' + @archive_frequency + ''' = ''d'' THEN 
					 	CASE WHEN @partition_start_boundary <= @reten_boundary THEN 1 ELSE 0 END
					ELSE 0	
					END
					       
					print ''partition_start_boundary:'' 
					print @partition_start_boundary 
					print ''Retain boundary:'' 
					print cast(@reten_boundary as varchar(10))
					 
					/*
						INSERT INTO #arch_status(to_slide)
						SELECT 1 FROM (
						SELECT MAX(' + @partition_key + ') where_field FROM ' + @table_name + '
						WHERE $PARTITION.' + @partition_function + '(' + @partition_key + ') = 1
						) a
						WHERE a.where_field < DATEADD(' + @archive_frequency + ', CAST(@retention_period AS INT), GETDATE() )
					*/
					
					')
					
					IF EXISTS(SELECT 1 FROM #arch_status WHERE to_slide = 1)
						EXEC dbo.spa_slide_range_left_window_datetime @run_date,@frequency, @partition_function, @file_group, @partition_scheme, @archive_status, @stage_table, @granule
					ELSE
						PRINT 'Partition1 boundary is greater than currentDate - Retention Period. Sliding skipped.'
					
					--SELECT @value_id = value_id FROM static_data_value WHERE code = @stage_table AND TYPE_ID = 2175 
					--SET @arch_date = DATEADD(d, 1, @run_date)
					
					--EXEC spa_archive_data @value_id, @arch_date,'AUTO_SLIDE_ARCHIVE', @db_user, NULL
					--set @sql = 'UPDATE STATISTICS ' + @table_name + ';'
					--print @sql 
					--exec (@sql)
					
						--DBCC SHRINKFILE(templog, 1)
						--DBCC SHRINKFILE(templog1, 1)
						--DBCC FREESYSTEMCACHE('ALL');
						--DBCC FREESESSIONCACHE;
						--DBCC SHRINKDATABASE (N'trm_test', TRUNCATEONLY) 
						--DBCC SHRINKDATABASE (N'tempdb', TRUNCATEONLY) 
		
					PRINT('Processing Completed for Parition ID: ' + @table_name)
					COMMIT TRAN
					set @sql = 'UPDATE archive_data_policy  SET tran_status = ''C'' where main_table_name = ''' + @table_name + ''''
					print @sql 
					exec (@sql)
					FETCH NEXT FROM cur_status INTO @no_partitions, @frequency, @partition_function, @file_group, @partition_scheme, @archive_status,  @archive_table,@granule
				END;
				CLOSE cur_status;
				DEALLOCATE cur_status;
			FETCH NEXT FROM list_arch_policy_tbls INTO @table_name, @stage_table, @partition_key, @archive_frequency
		END
		CLOSE list_arch_policy_tbls;
		DEALLOCATE list_arch_policy_tbls;	 
		
	END TRY
	BEGIN CATCH
		PRINT 'Error: ' + ERROR_MESSAGE()
		IF CURSOR_STATUS('local', 'cur_status') > = 0 
		BEGIN
			CLOSE cur_status
			DEALLOCATE cur_status;
		END
		IF CURSOR_STATUS('local', 'list_arch_policy_tbls') > = 0 
		BEGIN
			
			
			CLOSE list_arch_policy_tbls
			DEALLOCATE list_arch_policy_tbls
			
			
		END
		IF @@TRANCOUNT >0
		print 'ERROR IN ARCHIVING' 
		ROLLBACK TRAN
	END CATCH
END






GO


