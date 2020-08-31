IF OBJECT_ID(N'dbo.spa_handle_load_forecast_staging_table_DST_hours', N'P') IS NOT NULL
	DROP PROCEDURE dbo.spa_handle_load_forecast_staging_table_DST_hours
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================================================================================
-- Create date: 2011-05-18
-- Description: Updates DST hours for hours where DST is applied in load forecast staging tables (e.g.stage_deal_detail_hour_001)
-- Params:
-- @flag VARCHAR(1) - s: Update is done in final staging table (150 partition tables stage_deal_detail_hour_001, stage_deal_detail_hour_002)
--					  c: Update is done in split CSV staging table (e.g. adiha_process.dbo.load_forecast_csv_new_format_farrms_admin_1234)
-- @tbl_name VARCHAR(200) - Staging table name in case of @flag = f

-- ===============================================================================================================================
CREATE PROCEDURE dbo.spa_handle_load_forecast_staging_table_DST_hours
	@flag VARCHAR(1) = 's'
	, @tbl_name VARCHAR(200) = NULL
AS

SET NOCOUNT ON;

DECLARE @sql VARCHAR(5000)

IF @flag = 's'
BEGIN
	DECLARE @partition_no INT, @partition_count INT  
	DECLARE @stage_table_name VARCHAR(300)
	
	SET @partition_no = 1
	
	SELECT @partition_count = MAX(partition_id) FROM log_partition WHERE tbl_name = 'deal_detail_hour'  

	WHILE @partition_no <= @partition_count  
	BEGIN  
		SET @stage_table_name = 'stage_deal_detail_hour_' + RIGHT('000' + CAST(@partition_no AS VARCHAR(5)), 3)  
			
		--sum hr3 and hr25 for DST end date for CSV files
		SET @sql = 'UPDATE tmp
					SET hr3 = hr3 + hr25
					FROM ' + @stage_table_name + ' tmp
					INNER JOIN mv90_DST mv ON mv.date = tmp.term_date 
						AND mv.insert_delete = ''i''
					WHERE RIGHT([file_name], 4) = ''.csv'''
					
		--PRINT(@sql)    
		EXEC(@sql)
		
		--copy hr3 from DST start date (2011-03-27) to hr25 DST end date (2011-10-30), also update hr25 of DST end date with hr3+hr25 for LRS files
		SET @sql = 'UPDATE tmp_end
					SET tmp_end.hr25 = tmp_start.hr3, tmp_end.hr3 = tmp_end.hr3 + tmp_start.hr3 
					FROM ' + @stage_table_name + ' tmp_end
					INNER JOIN mv90_DST mv ON tmp_end.term_date = mv.date AND mv.insert_delete = ''i''
					INNER JOIN 
					(
						SELECT sddh.hr3, sddh.profile_id, [file_name]
						FROM ' + @stage_table_name + ' sddh
						INNER JOIN mv90_DST mv ON sddh.term_date = mv.date AND mv.insert_delete = ''d''
					) tmp_start ON tmp_end.profile_id = tmp_start.profile_id AND tmp_start.[file_name] = tmp_end.[file_name]
					WHERE RIGHT(tmp_end.[file_name], 4) <> ''.csv''' 
		exec spa_print @sql
		EXEC(@sql)
					
		--clear hr3 from DST start date (2011-03-27) for LRS files
		SET @sql = 'UPDATE tmp
					SET hr3 = NULL
					FROM ' + @stage_table_name + ' tmp
					INNER JOIN mv90_DST mv ON mv.date = tmp.term_date
						 AND mv.insert_delete = ''d''
					WHERE RIGHT([file_name], 4) <> ''.csv'''
					  
		--PRINT(@sql)    
		EXEC(@sql)    
		SET @partition_no = @partition_no + 1 
	END
END
ELSE
BEGIN
	--Update second 3rd hours DST to 25 for new CSV format
	SET @sql = 'UPDATE t
				SET t.[hour] = 25
				FROM ' + @tbl_name + ' t
				INNER JOIN 
				(
					--get second 3rd DST hour
					SELECT MAX(tcsv.id) id FROM ' + @tbl_name + ' tcsv
					INNER JOIN mv90_DST mv ON CONVERT(VARCHAR(10), mv.date, 120) = tcsv.term_date
						AND insert_delete = ''i''
					WHERE tcsv.[hour] = 3
					GROUP BY tcsv.term_date, tcsv.[hour]
				) dst_hr ON t.id = dst_hr.id'
	exec spa_print @sql    
	EXEC(@sql) 	
END
	
GO
