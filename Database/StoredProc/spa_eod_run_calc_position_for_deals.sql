IF OBJECT_ID(N'[dbo].[spa_eod_run_calc_position_for_deals]', N'P') IS NOT NULL
    DROP PROC [dbo].[spa_eod_run_calc_position_for_deals]
GO

-- ============================================================================================================================
-- Author: Pawan Adhikari
-- Create date: 2012-03-09 08:45PM
-- Description: Run Calculate Position for Deals.
--              
-- Params:
-- ============================================================================================================================
CREATE PROC [dbo].[spa_eod_run_calc_position_for_deals]
AS
BEGIN
	
	--- Deals having Total Volume 0
	DECLARE @spa             VARCHAR(MAX),
			@job_name        VARCHAR(150),
			@user_login_id   VARCHAR(30),
			@effected_deals  VARCHAR(150),
			@st              VARCHAR(MAX),
			@process_id      VARCHAR(100),
			@term_start      VARCHAR(20),
			@term_end        VARCHAR(20)
	        	
	-- Now run Position calculation
	SET @term_start = CONVERT(VARCHAR(200), GETDATE(), 120) + ' 00:00:00.000' 
	SET @term_end = CONVERT(VARCHAR(20), GETDATE(), 120) + ' 23:59:59.000' 
	SET @user_login_id = 'farrms_admin'

	SET @process_id = dbo.FNAGetNewID()
	SET @effected_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)
	SET @st = 'CREATE TABLE ' + @effected_deals + '(source_deal_header_id INT, [action] varchar(1)) '

	exec spa_print @st
	EXEC (@st)

	-----######################### CHANGE HERE to SELECT the required deals
	SET @st='INSERT INTO '+@effected_deals +'
			 SELECT DISTINCT sdd.source_deal_header_id, ''u''
			 FROM   source_deal_detail sdd
			 INNER JOIN source_deal_header sdh ON  sdh.source_deal_header_id = sdd.source_deal_header_Id
			 WHERE  sdd.total_volume = 0
				AND sdh.update_ts BETWEEN '''+@term_start+''' AND '''+@term_end+''''
	EXEC (@st)

	SET @job_name = 'calc_deal_position_breakdown' + @process_id	
	EXEC [dbo].[spa_deal_position_breakdown] 'i', null, @user_login_id, @process_id

	SET @spa = 'spa_update_deal_total_volume NULL,'''+@process_id+''',0,1,''' + @user_login_id + ''''
	EXEC (@spa)
		
	-- Deals having Total Volume 0		
	--DECLARE @spa             VARCHAR(MAX),
	--        @job_name        VARCHAR(150),
	--        @user_login_id   VARCHAR(30),
	--        @effected_deals  VARCHAR(150),
	--        @st              VARCHAR(MAX),
	--        @process_id      VARCHAR(100) 
	        
	IF OBJECT_ID('adiha_process.dbo.forecast_avail') IS NOT NULL
		DROP TABLE adiha_process.dbo.forecast_avail

	CREATE TABLE adiha_process.dbo.forecast_avail(profile_id  INT, available   INT )

	INSERT INTO adiha_process.dbo.forecast_avail
	SELECT DISTINCT fp.profile_id,
		   fp.available
	FROM   source_deal_detail sdd
		   INNER JOIN source_deal_header sdh ON  sdd.source_deal_header_Id = sdh.source_deal_header_id
		   INNER JOIN source_minor_location sml ON  sdd.location_id = sml.source_minor_location_id
		   INNER JOIN forecast_profile fp ON  fp.profile_id = sml.profile_id
	WHERE total_volume IS NULL AND ((term_start >= '2011-01-01' AND ISNULL(sdh.internal_portfolio_id, -1) <> 212 )
								  OR ( term_start >= '2011-12-01' AND ISNULL(sdh.internal_portfolio_id, -1) = 212 ))
		AND deal_id NOT LIKE '%target%'
		AND ISNULL(fp.available, -1) = 1
		AND fp.profile_type = 17500

	UPDATE fp SET fp.available = NULL
	FROM forecast_profile fp
	INNER JOIN adiha_process.dbo.forecast_avail f ON  fp.profile_id = f.profile_id

	-- Now run Position calculation
	SET @user_login_id = 'farrms_admin'

	SET @process_id = dbo.FNAGetNewID()
	SET @effected_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)

	SET @st = 'CREATE TABLE ' + @effected_deals +'(source_deal_header_id  INT,[action] VARCHAR(1)) '
	exec spa_print @st
	EXEC (@st)

	-----######################### CHANGE HERE to SELECT the required deals

	SET @st='INSERT INTO '+@effected_deals +'
			 SELECT DISTINCT sdd.source_deal_header_id,''u''
			 FROM   source_deal_detail sdd
					INNER JOIN source_deal_header sdh ON  sdd.source_deal_header_id = sdh.source_deal_header_id
			 WHERE  sdd.total_volume IS NULL AND 
			 (
     			(term_start >= ''2011 -01 -01'' AND ISNULL(sdh.internal_portfolio_id, -1) <> 212)
						OR (term_start >= ''2011 -12 -01'' AND ISNULL(sdh.internal_portfolio_id, -1) = 212)
			 )AND deal_id NOT LIKE ''%target%'''
			
	EXEC (@st)
		
	SET @job_name = 'calc_deal_position_breakdown' + @process_id	
	EXEC [dbo].[spa_deal_position_breakdown] 'i', null, @user_login_id, @process_id

	SET @spa = 'spa_update_deal_total_volume NULL,''' + @process_id + ''',0,1,''' + @user_login_id + ''''	
	EXEC (@spa)
		
END	