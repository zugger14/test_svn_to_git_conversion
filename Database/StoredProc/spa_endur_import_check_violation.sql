IF OBJECT_ID(N'dbo.spa_endur_import_check_violation', N'P') IS NOT NULL
	DROP PROCEDURE dbo.spa_endur_import_check_violation
GO

CREATE PROCEDURE dbo.spa_endur_import_check_violation
	  @parse_type				INT, --  mtm : 6, price : 4
	  @process_id VARCHAR(100) = NULL
  
AS

DECLARE @source_system_id VARCHAR(10)

SET @source_system_id = 2

IF @parse_type = 6
BEGIN
	DECLARE @deal_num_count INT, @user VARCHAR(100)
	
	SELECT @user = dbo.FNADBuser()

	SELECT smrd.deal_num deal_num, MAX(smrd.profile_end_date) profile_end_date, smrd.endur_run_date_for_files endur_run_date_for_files
	INTO #tmp_error_deal FROM adiha_process.dbo.stage_mtm_rwe_de smrd
	LEFT JOIN source_deal_header sdh ON  sdh.deal_id = smrd.deal_num AND sdh.source_system_id = @source_system_id
	LEFT JOIN adiha_process.dbo.stage_deals_rwe_de sdrd ON sdrd.reference_code = smrd.deal_num
	WHERE smrd.[file_name] IS NULL -- file name should be null during violation check.
	AND CONVERT(DATETIME, smrd.profile_end_date, 103) > CONVERT(DATETIME, smrd.endur_run_date_for_files, 103) --validate for forward only terms
	AND sdh.deal_id IS NULL
	AND sdrd.reference_code IS NULL
	GROUP BY smrd.deal_num,smrd.endur_run_date_for_files
	
	SELECT @deal_num_count = COUNT(*) FROM #tmp_error_deal
	
	IF @deal_num_count <> 0 
	BEGIN
		
		INSERT INTO source_system_data_import_status_detail(process_id, source, [type], [description],type_error)
		SELECT @process_id, 'RWE MTM', 'MTM Import', 'Data error for Deal ID:' + deal_num + ', term_start:'
		+ CONVERT(VARCHAR(10), CONVERT(DATETIME, DATEADD(MONTH, -1, DATEADD(DAY, 1, CONVERT(DATETIME, t.profile_end_date, 103))), 103), 103) -- term start is start day of term end month
		+ ', term_end :' + t.profile_end_date + ', pnl_as_of_date :' + t.endur_run_date_for_files
		, 'Deal Id not found'
		FROM  #tmp_error_deal t


		IF EXISTS(SELECT 1 FROM source_system_data_import_status_detail ssdisd WHERE ssdisd.process_id = @process_id)
		BEGIN

			INSERT INTO source_system_data_import_status(Process_id, code, module, [source], [type], [description])
			SELECT DISTINCT @process_id Process_id, 'Error' code, NULL module, 'RWE MTM' source, 'Import' [type], 'Deal Id not found' [description]
		END

	END
	
	SELECT @deal_num_count AS violations
      	
END

ELSE IF @parse_type = 4
BEGIN
	SELECT COUNT(ssrd.proj_index_id) AS violations FROM adiha_process.dbo.stage_spc_rwe_de ssrd
	LEFT JOIN source_price_curve_def spcd ON spcd.curve_id = ssrd.proj_index_id AND spcd.source_system_id = 20
	LEFT JOIN adiha_process.dbo.stage_deals_rwe_de sdrd ON sdrd.proj_index_curve_id = ssrd.proj_index_id
	WHERE ssrd.[file_name] IS NULL 
	AND spcd.curve_id IS NULL 
	AND ssrd.proj_index_id IS NULL

END 

