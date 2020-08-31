UPDATE
	mv90_dst
SET
	HOUR = 2
WHERE
	dst_group_value_id = 102200


UPDATE
	mv90_dst
SET
	HOUR = 3
WHERE
	dst_group_value_id = 102201


EXEC spa_generate_hour_block_term null,2000,2030

IF OBJECT_ID('tempdb..#temp_all_deals') IS NOT NULL
	DROP TABLE #temp_all_deals

SELECT source_deal_header_id
INTO #temp_all_deals
FROM source_deal_header 


DECLARE @process_id NVARCHAR(500) = dbo.FNAGetNewID()
DECLARE @user_login_id NVARCHAR(100) = dbo.FNADBUser()
DECLARE @report_position_deals NVARCHAR(600)

SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)

DECLARE @sql NVARCHAR(MAX)
SET @sql = '
	SELECT sdh.source_deal_header_id [source_deal_header_id], ''u'' [action]
	INTO ' + @report_position_deals + '
	FROM #temp_all_deals sdh
'
EXEC(@sql)

DECLARE @pos_job_name VARCHAR(200) =  'calc_position_breakdown_' + @process_id
SET @sql = 'spa_calc_deal_position_breakdown NULL,''' + @process_id + ''''
EXEC spa_run_sp_as_job @pos_job_name,  @sql, 'Position Calculation', @user_login_id


--select * from process_deal_position_breakdown where process_status = 1