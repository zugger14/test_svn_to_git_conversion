

IF OBJECT_ID(N'spa_copy_prior_mtm_job', N'P') IS NOT NULL
	DROP PROCEDURE spa_copy_prior_mtm_job
GO 

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: gkoju@pioneersolutionsglobal.com
-- Create date: 2013-06-04
-- Description: CRUD operations for table time_zone
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- @as_of_date_copy VARCHAR(20) - As of date from
-- @as_of_date_from VARCHAR(20) - As of date to
-- @user_login_id VARCHAR(50) - db user
-- @batch_process_id VARCHAR(150) --batch process id
-- @batch_report_param VARCHAR(5000) - batch parameters
-- ===========================================================================================================

CREATE PROC [dbo].[spa_copy_prior_mtm_job]
@flag CHAR(1),
@as_of_date_copy VARCHAR(20),
@as_of_date_from VARCHAR(20),
@user_login_id VARCHAR(50) = NULL,
@batch_process_id VARCHAR(150) = NULL,
@batch_report_param VARCHAR(5000) = NULL

AS

/* test case 
DECLARE @flag char(1),@as_of_date_copy varchar(20),@as_of_date_from varchar(20),@batch_process_id varchar(150)
SET @flag='c'
SET @as_of_date_from='2007-12-28'
SET @as_of_date_copy='2008-04-30'
DROP TABLE #temp_deals
DROP TABLE #idx_filter
*/

SET NOCOUNT ON

DECLARE @desc VARCHAR(3000)
DECLARE @find_deal_start VARCHAR(20)
DECLARE @temp_table_name VARCHAR(300)
DECLARE @report_name VARCHAR(250) = ''
DECLARE @csv_ts	VARCHAR(1000)	

SET @find_deal_start = 'MA[_]%'
SET @user_login_id = ISNULL(@user_login_id, dbo.FNADBUser())
SET @batch_process_id = ISNULL(@batch_process_id, dbo.FNAGetNewID())

SELECT sdh.source_deal_header_id, sdh.deal_id  
	INTO #temp_deals
FROM source_deal_header sdh 
WHERE sdh.deal_id LIKE @find_deal_start

CREATE TABLE #idx_filter (index_name VARCHAR(150) COLLATE DATABASE_DEFAULT   NULL)

INSERT INTO #idx_filter(index_name)
SELECT clm1_value 
FROM generic_mapping_values g 
INNER JOIN generic_mapping_header h ON g.mapping_table_id = h.mapping_table_id
	AND h.mapping_name = 'Freeze MTM' AND clm2_value = 'n'
		
--insert into #idx_filter(index_name)
--select 	('MEFF%QUARTER%') union all select
--		('MEFF%YEAR%') union all select
--		('NORDICQUARTER%')union all select
--		('NORDICYEAR%') 
	
	
DECLARE @st_criteria VARCHAR(MAX)	

SET @st_criteria = NULL				
SELECT @st_criteria = ISNULL(@st_criteria + ' OR ', '') + '  spcd.source_curve_def_id =' + index_name FROM #idx_filter
	
--set @st_criteria= ' spcd.curve_name like '''
--select @st_criteria=@st_criteria + index_name +''' or spcd.curve_name like ''' from #idx_filter
--set @st_criteria=' and not (' + LEFT(@st_criteria,len(@st_criteria)-25)+')'

IF @st_criteria IS NOT NULL
	SET @st_criteria = ' AND NOT (' + @st_criteria + ')'
ELSE
	SET @st_criteria = ''

DECLARE @table_name	VARCHAR(75)
SET @table_name = dbo.FNAGetProcessTableName(@as_of_date_from, 'source_deal_pnl') 

DECLARE @table_name_copy VARCHAR(75)
SET @table_name_copy = dbo.FNAGetProcessTableName(@as_of_date_copy, 'source_deal_pnl') 

DECLARE @sql_str VARCHAR(5000)
DECLARE @job_name VARCHAR(500)
SET @job_name = ''

SET @sql_str = '
				DELETE pnl
				--select *  
				FROM ' + @table_name_copy + ' pnl 
				INNER JOIN #temp_deals sdh on pnl.source_deal_header_id=sdh.source_deal_header_id
				INNER JOIN source_deal_pnl sdp ON sdp.source_deal_header_id = sdh.source_deal_header_id 
					AND sdp.term_start = pnl.term_start
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdp.source_deal_header_id 
					AND sdp.term_start = sdd.term_start 
					AND sdd.leg = 1 
				INNER JOIN source_price_curve_def spcd on sdd.curve_id = spcd.source_curve_def_id
				WHERE sdp.pnl_as_of_date = ''' + @as_of_date_from + ''' AND 
					pnl.pnl_as_of_date = ''' + @as_of_date_copy  + '''' + @st_criteria
--PRINT ISNULL(@sql_str, '@sql_str IS NULL')
EXEC (@sql_str)

IF @flag = 'c'
BEGIN
	
	SET @temp_table_name = dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
	EXEC spa_print @temp_table_name
	--copy to a process table, so that it can be downloaded as a batch report
	SET @sql_str =  '
					SELECT	pnl.source_deal_header_id, sdh.deal_id AS [REF ID], pnl.term_start, pnl.term_end, pnl.leg, ''' + @as_of_date_copy + ''' AS pnl_as_of_date
							, pnl.und_pnl, pnl.und_intrinsic_pnl, pnl.und_extrinsic_pnl, pnl.dis_pnl, pnl.dis_intrinsic_pnl
							, pnl.dis_extrinisic_pnl, pnl.pnl_source_value_id, pnl.pnl_currency_id, pnl.pnl_conversion_factor
							, pnl.pnl_adjustment_value, pnl.deal_volume, ''' + @user_login_id + ''' create_user, GETDATE() create_ts, ''' + @user_login_id + ''' update_user, GETDATE() update_ts 
						INTO ' + @temp_table_name + '
					FROM ' + @table_name + ' pnl 
					INNER JOIN #temp_deals sdh ON pnl.source_deal_header_id = sdh.source_deal_header_id
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = pnl.source_deal_header_id 
						AND pnl.term_start=sdd.term_start 
						AND sdd.leg = 1 
					INNER JOIN source_price_curve_def spcd ON sdd.curve_id = spcd.source_curve_def_id
					WHERE pnl.pnl_as_of_date = ''' + @as_of_date_from + ''' AND pnl.term_start > CAST(''' + @as_of_date_copy + ''' AS DATETIME)
					' +  ISNULL(@st_criteria,'')

	--PRINT @sql_str
	EXEC(@sql_str)
	
	--copy data from process table to main table	
	--SET @sql_str = '
	--				INSERT ' + @table_name_copy + ' (source_deal_header_id, term_start, term_end, leg, pnl_as_of_date
	--												, und_pnl, und_intrinsic_pnl, und_extrinsic_pnl, dis_pnl, dis_intrinsic_pnl
	--												, dis_extrinisic_pnl, pnl_source_value_id, pnl_currency_id, pnl_conversion_factor
	--												, pnl_adjustment_value, deal_volume, create_user, create_ts, update_user, update_ts)
	--				SELECT	pnl.source_deal_header_id, term_start, term_end,leg,pnl_as_of_date
	--						, und_pnl,und_intrinsic_pnl, und_extrinsic_pnl, dis_pnl, dis_intrinsic_pnl
	--						, dis_extrinisic_pnl, pnl_source_value_id, pnl_currency_id, pnl_conversion_factor
	--						, pnl_adjustment_value, deal_volume,create_user, create_ts, update_user, update_ts
	--				FROM ' + @temp_table_name + ' pnl 
	--	'
	
	SET @sql_str = '
					MERGE ' + @table_name_copy + ' AS target
					USING (SELECT source_deal_header_id, term_start, term_end,leg,pnl_as_of_date
								, und_pnl,und_intrinsic_pnl, und_extrinsic_pnl, dis_pnl, dis_intrinsic_pnl
								, dis_extrinisic_pnl, pnl_source_value_id, pnl_currency_id, pnl_conversion_factor
								, pnl_adjustment_value, deal_volume,create_user, create_ts, update_user, update_ts
							FROM ' + @temp_table_name + ') 
							AS source (source_deal_header_id
										, term_start
										, term_end
										, leg
										, pnl_as_of_date
										, und_pnl
										, und_intrinsic_pnl
										, und_extrinsic_pnl
										, dis_pnl
										, dis_intrinsic_pnl
										, dis_extrinisic_pnl
										, pnl_source_value_id
										, pnl_currency_id
										, pnl_conversion_factor
										, pnl_adjustment_value
										, deal_volume
										, create_user
										, create_ts
										, update_user
										, update_ts)
					ON (target.source_deal_header_id = source.source_deal_header_id 
						AND target.pnl_as_of_date = source.pnl_as_of_date
						AND target.term_start = source.term_start
						AND target.term_end = source.term_end
						AND target.Leg = source.Leg
						AND target.pnl_source_value_id = source.pnl_source_value_id
					) --pnl_as_of_date, source_deal_header_id, term_start, term_end, Leg, pnl_source_value_id --unique key 
					WHEN MATCHED 
						THEN UPDATE 
							SET target.source_deal_header_id = source.source_deal_header_id,
								target.term_start = source.term_start,
								target.term_end = source.term_end,
								target.leg = source.leg,
								target.pnl_as_of_date = source.pnl_as_of_date,
								target.und_pnl = source.und_pnl,
								target.und_intrinsic_pnl = source.und_intrinsic_pnl,
								target.und_extrinsic_pnl = source.und_extrinsic_pnl,
								target.dis_pnl = source.dis_pnl,
								target.dis_intrinsic_pnl = source.dis_intrinsic_pnl,
								target.dis_extrinisic_pnl = source.dis_extrinisic_pnl,
								target.pnl_source_value_id = source.pnl_source_value_id,
								target.pnl_currency_id = source.pnl_currency_id,
								target.pnl_conversion_factor = source.pnl_conversion_factor,
								target.pnl_adjustment_value = source.pnl_adjustment_value,
								target.deal_volume = source.deal_volume,
								target.create_user = source.create_user,
								target.create_ts = source.create_ts,
								target.update_user = source.update_user,
								target.update_ts = source.update_ts
					WHEN NOT MATCHED THEN
						 INSERT (source_deal_header_id, term_start, term_end, leg, pnl_as_of_date
								, und_pnl, und_intrinsic_pnl, und_extrinsic_pnl, dis_pnl, dis_intrinsic_pnl
								, dis_extrinisic_pnl, pnl_source_value_id, pnl_currency_id, pnl_conversion_factor
								, pnl_adjustment_value, deal_volume, create_user, create_ts, update_user, update_ts)
						VALUES(source_deal_header_id, term_start, term_end,leg,pnl_as_of_date
								, und_pnl,und_intrinsic_pnl, und_extrinsic_pnl, dis_pnl, dis_intrinsic_pnl
								, dis_extrinisic_pnl, pnl_source_value_id, pnl_currency_id, pnl_conversion_factor
								, pnl_adjustment_value, deal_volume,create_user, create_ts, update_user, update_ts) 			
					;'
	EXEC spa_print @sql_str
	EXEC(@sql_str)
	
	EXEC('INSERT INTO source_system_data_import_status(process_id, code, module, source, type
														, [description], recommendation) 
		SELECT ''' + @batch_process_id + ''', ''Success'', ''Copy MTM'', ''Prior Value'', sdh.deal_id
				, ''Term Start:'' + CONVERT(varchar, MIN(pnl.term_start),105) + '', Term End:'' + CONVERT(varchar, MAX(pnl.term_end), 105) +
				'', Copied from:'' +  dbo.FNADateformat(''' + @as_of_date_from + '''), LTRIM(STR(SUM(pnl.und_pnl), 100, 2)) 
		FROM ' + @table_name + ' pnl 
		JOIN source_deal_header sdh ON pnl.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = pnl.source_deal_header_id 
			AND pnl.term_start=sdd.term_start 
			AND sdd.leg = 1 
		INNER JOIN source_price_curve_def spcd ON sdd.curve_id = spcd.source_curve_def_id
		WHERE pnl_as_of_date = ''' + @as_of_date_from + ''' AND pnl.term_start > CAST(''' + @as_of_date_copy + ''' AS DATETIME)
			AND sdh.deal_id LIKE ''' + @find_deal_start + '''
		GROUP BY sdh.deal_id')

	SET @desc = 'Copy prior MTM value from '+ dbo.FNADateformat(@as_of_date_from)  + ' to as of date ' + dbo.FNADateformat(@as_of_date_copy) + ' process completed.'
	SET @report_name = 'Copy MTM'
	
	SET @csv_ts = REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(20),GETDATE(),120),':',''), ' ', '_'), '-', '_') + '.csv'
	DECLARE @url VARCHAR(3000) = '../../adiha.php.scripts/dev/shared_docs/temp_Note/' + @report_name + '_' +  dbo.FNADBUser() + '_' + @csv_ts
	DECLARE @notification_process_id VARCHAR(50)
	
	SET @notification_process_id = dbo.FNAGetSplitPart(@batch_process_id, '_', 6)
	SELECT @desc =  @desc +
		CASE WHEN CHARINDEX('Temp_Note', csv_file_path)>0 OR csv_file_path IS NULL THEN '. Please <a target="_blank" href="' + @url + 
			'"><b>Click Here</a></b> to download.'
		ELSE 'Report has been saved at <b>' + csv_file_path + '</b>.' 
		END  
	FROM batch_process_notifications bpn 
	WHERE bpn.process_id = @notification_process_id
END
ELSE IF @flag = 'd'
BEGIN
	SET @report_name = 'Delete MTM'
	SET @desc = 'MTM value deleted for pnl as of date ' + dbo.FNADateformat(@as_of_date_copy) + ' process completed. '
	
	EXEC spa_ErrorHandler 0
			, 'Copy_Prior_MTM' -- Name the tables used in the query.
			, 'spa_copy_prior_mtm_job' -- Name the stored proc.
			, 'Success' -- Operations status.
			, 'Data Deleted Successfully.' -- Success message.
			,  NULL -- The reference of the data deleted.	
END

--required to update the message board message correctly, otherwise multiple message may appear while saving batch file.
SET @job_name = 'report_batch_' + @batch_process_id

EXEC  spa_message_board 
		@flag = 'u'
		, @user_login_id = @user_login_id
		, @source = @report_name
		, @description = @desc
		, @type = 's'
		, @job_name = @job_name
		, @process_id = @batch_process_id
		, @temptable_name = @temp_table_name
		, @email_enable = 'n'
		, @report_sp = @batch_report_param
		, @csv_filename = @csv_ts						
GO


