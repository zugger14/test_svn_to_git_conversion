
IF OBJECT_ID(N'spa_run_simplex_solver_package') IS NOT NULL
    DROP PROC spa_run_simplex_solver_package
GO
/**
	Operations for simplex solver package, mostly called from script task.
	Parameters
	@process_id		: Process ID used for process tables
	@flag			: 'n' Run solver ssis package
					  'r' Gather receipt side location information, called from script task
					  'd' Gather delivery side location information, called from script task
					  'm' Gather MDQ data information, called from script task
					  'u' Update process table with solver decisions values
	@user_login_id	:
*/
CREATE PROC spa_run_simplex_solver_package
	@process_id  VARCHAR(100)
	, @flag CHAR(1) = 'n'
	, @user_login_id varchar(500) = NULL	
AS
/*
DECLARE @process_id  VARCHAR(100)
	, @flag CHAR(1) = 'n'
	, @user_login_id VARCHAR(500) = NULL	

SELECT @flag='m', @process_id='604727B5_520E_43C6_9B1F_8776CB2EA3B5', @user_login_id='adangol'

--*/

DECLARE @root VARCHAR(1024)
DECLARE @ssis_path VARCHAR(1024)
DECLARE @spa VARCHAR(8000)
DECLARE @proc_desc VARCHAR(1024)
DECLARE @job_name VARCHAR(1024)
DECLARE @sql VARCHAR(MAX)

IF @process_id IS NULL
    SET @process_id = dbo.FNAGetNewID()
	
--DECLARE @user_login_id VARCHAR(1024)

SET @user_login_id = replace(replace(isnull(@user_login_id,dbo.FNADBUser()), '.', '_'), '-', '_')

DECLARE @contractwise_detail_mdq_group VARCHAR(500) = dbo.FNAProcessTableName('contractwise_detail_mdq_group', @user_login_id, @process_id)
DECLARE @solver_decisions VARCHAR(500) = dbo.FNAProcessTableName('solver_decisions', @user_login_id, @process_id)
DECLARE @storage_constraint VARCHAR(500)= dbo.FNAProcessTableName('storage_constraint', @user_login_id, @process_id)
DECLARE @storage_position VARCHAR(500)= dbo.FNAProcessTableName('storage_position', @user_login_id, @process_id)
DECLARE @opt_deal_detail_pos VARCHAR(500) = dbo.FNAProcessTableName('opt_deal_detail_pos', @user_login_id, @process_id)
DECLARE @location_pos_info VARCHAR(500) = dbo.FNAProcessTableName('location_pos_info', @user_login_id, @process_id)
DECLARE @hourly_pos_info VARCHAR(500) = dbo.FNAProcessTableName('hourly_pos_info', @user_login_id, @process_id)

BEGIN TRY
IF @flag = 'n' --Run solver ssis package
BEGIN
	DECLARE @ssis_cmd_parameter NVARCHAR(2500) = 'PS_ProcessID=' + @process_id + ',PS_user_name=' + @user_login_id
	
	DECLARE @result_output NVARCHAR(MAX)
	EXEC spa_execute_ssis_package_using_clr 'PRJ_Simplex_Solver','Simplex_Solver', @ssis_cmd_parameter, NULL, 'n','n', @result_output OUTPUT
	
	DECLARE @decision_table VARCHAR(1024)
	SET @decision_table = dbo.FNAProcessTableName('solver_decisions', @user_login_id, @process_id)
	EXEC spa_print @decision_table
	--EXEC spa_ErrorHandler 0
	--    ,    'solver_optmization'
	--    ,    'spa_run_simplex_solver_package'
	--    ,    'Success'
	--    ,    'Solver optimization run successfully.'
	--    ,    @decision_table
END
ELSE IF @flag = 'r' --Gather receipt side location information, called from script task
BEGIN
	SET @sql = '
	SELECT CAST(d.from_loc_id AS INT ) [Id]
	    , d.from_loc [Description]
	    , CAST(d.from_rank AS INT ) [Rank]
	    , CAST(COALESCE(MAX(sp.position), IIF(SUM(d.supply_position) < 0, 0, MAX(lpi.total_pos)), 0) AS FLOAT ) [FixedPosition]
	    , CAST(COALESCE(MAX(sp.position), IIF(SUM(d.supply_position) < 0, 0, MAX(lpi.total_pos)), 0) AS FLOAT ) [Position]                    
        , ISNULL(
			IIF(MAX(d.granularity) = 982, MAX(s.from_max_withdrawal) / 24, SUM(s.from_max_withdrawal))
		  , 999999999) [max_withdrawal]                   
        , ISNULL(
			IIF(MAX(d.granularity) = 982, MAX(s.from_min_withdrawal) / 24, SUM(s.from_min_withdrawal))
		  , 0) [min_withdrawal]
        , ISNULL(SUM(s.from_ratchet_limit), 999999999) [ratchet_limit]
                   
    FROM ' + @contractwise_detail_mdq_group + ' d
    INNER JOIN  ' + @storage_constraint + ' s ON d.box_id = s.box_id 
    LEFT JOIN ' + @storage_position + ' sp ON sp.location_id = d.from_loc_id  AND sp.type= ''w'' 
	LEFT JOIN ' + @location_pos_info + ' lpi ON lpi.location_id = d.from_loc_id  AND lpi.market_side= ''supply'' 
	WHERE d.box_type = ''no_proxy'' AND d.path_id <> 0 AND d.path_ormdq > 0
	GROUP BY d.from_loc_id, d.from_loc, d.from_rank
    ORDER BY d.from_rank, d.from_loc
	'
	EXEC(@sql)
END
ELSE IF @flag = 'd' --Gather delivery side location information, called from script task
BEGIN
	SET @sql = '
	SELECT CAST(d.to_loc_id AS INT ) [Id]
	    , d.to_loc [Description]
	    , CAST(d.to_rank AS INT) [Rank]
	    , ISNULL(ABS(CAST(CASE WHEN MAX(sp.type) = ''i'' THEN 999999999 ELSE IIF(MAX(lpi.total_pos) > 0, 0, MAX(lpi.total_pos)) END AS FLOAT )), 0) [FixedPosition]
	    , ISNULL(ABS(CAST(CASE WHEN MAX(sp.type) = ''i'' THEN 999999999 ELSE IIF(MAX(lpi.total_pos) > 0, 0, MAX(lpi.total_pos)) END  AS FLOAT )), 0) [Position]  
        , ISNULL(
			IIF(MAX(d.granularity) = 982, MAX(s.to_max_injection) / 24, SUM(s.to_max_injection))
		  , 999999999)  [max_injection]                   
        , ISNULL(
			IIF(MAX(d.granularity) = 982, MAX(s.to_min_injection) / 24, SUM(s.to_min_injection))
		  , 0) [min_injection]
        , ISNULL(SUM(s.to_ratchet_limit), 999999999) [ratchet_limit]
         
    FROM ' + @contractwise_detail_mdq_group + ' d
    INNER JOIN  ' + @storage_constraint + ' s ON d.box_id = s.box_id
    LEFT JOIN ' + @storage_position + ' sp ON sp.location_id = d.to_loc_id  AND sp.type= ''i'' 
	LEFT JOIN ' + @location_pos_info + ' lpi ON lpi.location_id = d.to_loc_id  AND lpi.market_side= ''demand'' 
	WHERE d.box_type = ''no_proxy'' 
		AND d.path_id <> 0 
		AND d.path_id IS NOT NULL
		AND d.path_ormdq > 0
	GROUP BY d.to_loc_id, d.to_loc, d.to_rank
    ORDER BY d.to_rank, d.to_loc
	'
	EXEC(@sql)
END
ELSE IF @flag = 'm' --Gather MDQ data information, called from script task
BEGIN
	SET @sql = '
	SELECT 
		CAST(d.from_loc_id AS INT ) [FromLocationId] , d.from_loc [FromLocation], CAST(d.to_loc_id AS INT ) [ToLocationId],
        d.to_loc [ToLocationName], ISNULL(d.loss_factor,0) AS  [LossFactor], CAST(d.path_id AS INT ) [PathId],
        d.path_name [PathName], CAST(ISNULL(sdvp.[description] , 9999999) AS INT) [Priority],
        CAST(ISNULL(d.contract_id,0) AS INT ) [ContractId], d.contract_name [ContractName],
        CAST(ISNULL(sdvc.[code] , 9999999) AS INT) [ContractRank], CAST(d.path_ormdq AS FLOAT) [MDQ],
		CAST(supply_adjust_factor AS FLOAT) [SupplyAdjustFactor], CAST(demand_adjust_factor AS FLOAT) [DemandAdjustFactor], 
		CAST(delivery_adjust_factor AS FLOAT) [DeliveryAdjustFactor]
		, CAST(d.term_start AS DATETIME) [TermStart]
		, ISNULL(d.hour, 0) [Hour]
		, d.granularity [Granularity]
		
		, [SupplyPosition] = ABS(CAST(ISNULL(IIF(d.from_loc_grp_name = ''storage'', sp_w.position, d.supply_position), 0) AS FLOAT))
		, [DemandPosition] = IIF(d.to_loc_grp_name = ''storage'', 9999999, ABS(CAST(ISNULL(d.demand_position, 0) AS FLOAT)))
		, [StorageType] = CASE WHEN d.from_loc_grp_name = ''storage'' THEN ''Withdrawal'' WHEN d.to_loc_grp_name = ''storage'' THEN ''Injection'' ELSE '''' END
		
	
	FROM ' + @contractwise_detail_mdq_group + ' d
	LEFT JOIN ' + @storage_position + ' sp_w ON sp_w.location_id = d.from_loc_id  AND sp_w.type= ''w'' 
	LEFT JOIN ' + @storage_constraint + ' s ON d.box_id = s.box_id
    LEFT JOIN counterparty_contract_rate_schedule ccrs ON  ccrs.path_id = d.path_id and ccrs.contract_id = d.contract_id 
    LEFT JOIN contract_group cg ON  d.contract_id = cg.contract_id 
    LEFT OUTER JOIN static_data_value sdvc ON  sdvc.value_id = ccrs.[RANK] AND sdvc.[type_id] = 32100 
    LEFT OUTER JOIN static_data_value sdvp ON  sdvp.value_id = d.priority_id AND sdvp.[type_id] = 31400 
	WHERE d.path_id <> 0 
		AND d.path_id IS NOT NULL 
		AND d.contract_id IS NOT NULL 
		AND d.box_type = ''no_proxy'' 
		AND d.path_ormdq > 0
	ORDER BY CAST(d.from_rank AS INT ), [FromLocation], CAST(d.to_rank AS INT), [ToLocationName], ISNULL(d.hour, 0)
	'
	--print(@sql)
	EXEC(@sql)
END
ELSE IF @flag = 'u' --Update process table with solver decisions values
BEGIN
	SET @sql = '
	UPDATE d
		SET d.received = di.received,
			d.delivered = di.delivery, 
			d.path_rmdq = d.path_rmdq - di.delivery
	FROM ' + @solver_decisions + ' di
	INNER JOIN ' + @contractwise_detail_mdq_group + ' d ON di.source_id = d.from_loc_id
		AND di.destination_id = d.to_loc_id
		AND di.path_id = d.path_id
		AND di.contract_id = d.contract_id
		AND ISNULL(di.[hour], 0) = ISNULL(d.[hour], 0)
	'

	EXEC(@sql)

end
END TRY
BEGIN CATCH
	DECLARE @errormsg VARCHAR(1024) 
	    SET @errormsg = ERROR_MESSAGE()
	    SET @errormsg += ' On Line Number : ' + CAST(ERROR_LINE() AS VARCHAR(100))
	    EXEC spa_ErrorHandler 1
	    ,    'solver_optmization'
	    ,    'spa_run_simplex_solver_package'
	    ,    'Error'
	    ,    'Error while running solver optimization'
	    ,    @errormsg
END CATCH