IF OBJECT_ID('spa_stage_table_archive') IS NOT NULL
DROP PROC dbo.spa_stage_table_archive
GO

-- ===============================================================================================================
-- Create date: 2012-02-17
-- Description:	This Proc will run in ARCHIVE SERVER to execute SPA_ARCHIVE_DATA
-- Params:
-- 
-- @table_name 
-- ===============================================================================================================

CREATE PROC dbo.spa_stage_table_archive
@value_id INT -- Partition ID

AS
/*
--exec dbo.spa_auto_slide_archive '1','2010-09-29'

--*/
--SET NOCOUNT, XACT_ABORT ON;
DECLARE @run_date		DATETIME
DECLARE @arch_date		DATETIME
DECLARE	@db_user		VARCHAR(100)
DECLARE @stage_table	VARCHAR(100)
DECLARE @where_field	VARCHAR(100)
DECLARE @dbase_name		VARCHAR(100)
DECLARE @frequency		VARCHAR(1)
DECLARE @table_name		VARCHAR(100)

BEGIN
	SET @db_user = dbo.FNADBUser()
	--SET @stage_table = @table_name 
	
		DECLARE tblCursor_arch CURSOR FOR
			
			SELECT  adp.where_field, adpd.archive_db, adp.archive_frequency, adp.staging_table_name, sdv.value_id, adp.main_table_name
			FROM archive_data_policy_detail adpd 
			INNER JOIN archive_data_policy adp ON  adpd.archive_data_policy_id = adp.archive_data_policy_id 
			INNER JOIN static_data_value sdv  ON adp.archive_type_value_id = sdv.value_id 
			AND sdv.type_id = 2150  AND is_arch_table = 0 --AND adp.sequence = 1
			AND sdv.value_id = @value_id
			CREATE TABLE #tmp_rundate (part_key DATETIME)
			OPEN tblCursor_arch
				FETCH NEXT FROM tblCursor_arch into @where_field, @dbase_name, @frequency, @stage_table, @value_id, @table_name
				WHILE @@FETCH_STATUS = 0
				BEGIN
					BEGIN TRY
					
							EXEC spa_print '**************************ARCHIVING STARTED FOR TABLE ', @table_name, '*******************************' 
							EXEC ('INSERT INTO #tmp_rundate  SELECT MAX(DISTINCT '+ @where_field + ' )   FROM  ' + @dbase_name + '.dbo.' + @stage_table +';')
							--SELECT @run_date = part_key FROM #tmp_rundate
							SET @run_date = GETDATE()
							EXEC spa_print @run_date
							--SELECT @value_id = value_id FROM static_data_value WHERE code = @table_name AND TYPE_ID = 2175 
							--SET @arch_date = CASE @frequency WHEN 'm' THEN DATEADD(d, 1, DATEADD(m, 1, @run_date)) WHEN 'd' THEN DATEADD(d, 1, @run_date) END 
							SET @arch_date = @run_date
							EXEC spa_print @arch_date
							EXEC spa_print @table_name
							EXEC spa_print @stage_table
							EXEC spa_print 'value id', @value_id
							EXEC spa_print @arch_date
							EXEC spa_archive_data @value_id, @arch_date,'AUTO_SLIDE_ARCHIVE', @db_user, NULL

					END TRY
					BEGIN CATCH
						EXEC spa_print 'Error: ' --+ ERROR_MESSAGE()
						
					END CATCH
					EXEC spa_print '**************************ARCHIVING COMPLETED FOR TABLE ', @table_name, '*******************************' 
					FETCH NEXT FROM tblCursor_arch into @where_field, @dbase_name, @frequency, @stage_table, @value_id, @table_name
				END
				--SELECT @where_field = where_field, @dbase_name = archive_db, @frequency = archive_frequency, @stage_table = staging_table_name
			--FROM archive_data_policy_detail adpd 
			--INNER JOIN archive_data_policy adp ON  adpd.archive_data_policy_id = adp.archive_data_policy_id 
			--INNER JOIN static_data_value sdv  ON adp.archive_type_value_id = sdv.value_id 
			--AND sdv.type_id = 2175  AND is_arch_table = 0 --AND adp.sequence = 1
			--AND sdv.code = @table_name 
				close tblCursor_arch
				DEALLOCATE tblCursor_arch
END




			