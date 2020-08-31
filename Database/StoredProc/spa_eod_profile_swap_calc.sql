IF OBJECT_ID(N'[dbo].[spa_eod_profile_swap_calc]', N'P') IS NOT NULL
    DROP PROC [dbo].[spa_eod_profile_swap_calc]
GO

-- ============================================================================================================================
-- Author: Pawan Adhikari
-- Create date: 2012-03-09 08:45PM
-- Description: Run Profile Swap Calculations.
--              
-- Params:
-- ============================================================================================================================

CREATE PROC [dbo].[spa_eod_profile_swap_calc]
AS
BEGIN
	
	DECLARE @profile_id      INT = NULL,
			@header_deal_id  INT = NULL

	IF OBJECT_ID('tempdb..#category_vs_profile') IS NOT NULL
		DROP TABLE #category_vs_profile

	IF OBJECT_ID('tempdb..#process_deal') IS NOT NULL
		DROP TABLE #process_deal

	IF OBJECT_ID('tempdb..#total_term_fraction') IS NOT NULL
		DROP TABLE #total_term_fraction

	DECLARE @baseload_block_type       VARCHAR(10),
			@baseload_block_define_id  VARCHAR(10),
			@internal_portfolio        VARCHAR(1000) = '''Gas-Profile-Swap'',''Power-Profile-Swap'''
	DECLARE @st                        VARCHAR(MAX)


	CREATE TABLE #category_vs_profile(category_id  INT, profile_id   INT)

	INSERT INTO #category_vs_profile(category_id,profile_id)
	VALUES(292075,40),(292345, 49),(292347, 49),(292343,49)

	INSERT INTO #category_vs_profile(category_id, profile_id) 
	SELECT DISTINCT sdd.category, fp.profile_id
	FROM   static_data_value sdv
	INNER JOIN forecast_profile fp ON  sdv.code = fp.external_id AND [TYPE_ID] = 18100
	INNER JOIN source_deal_detail sdd ON sdd.category = sdv.value_id
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
	INNER JOIN source_internal_portfolio sip ON sdh.internal_portfolio_id = sip.source_internal_portfolio_id 
		AND sip.internal_portfolio_id IN('Power-Profile-Swap','Gas-Profile-Swap')
		

	SET @baseload_block_type = '12000'	-- Internal Static Data
	SELECT @baseload_block_define_id = CAST(value_id AS VARCHAR(10)) 
	FROM static_data_value 
	WHERE [TYPE_ID] = 10018 AND code LIKE 'Base Load' -- External Static Data

	IF @baseload_block_define_id IS NULL
		SET @baseload_block_define_id = 'NULL'
		
	CREATE TABLE #process_deal
	(
		deal_detail_id   INT,
		profile_id       INT,
		block_define_id  INT,
		block_type_id    INT,
		commodity_id     INT,
		term_start       DATETIME,
		term_end         DATETIME,
		profile_type     INT
	)
			
	SET @st='INSERT INTO #process_deal
	           (
	             deal_detail_id,
	             profile_id,
	             term_start,
	             term_end,
	             block_define_id,
	             block_type_id,
	             commodity_id,
	             profile_type
	           )
	         SELECT DISTINCT sdd.source_deal_detail_id,
	                t.profile_id,
	                sdd.term_start,
	                sdd.term_end,
	                COALESCE(spcd.block_define_id,sdh.block_define_id,'+@baseload_block_define_id+'),
	                COALESCE(spcd.block_type, sdh.block_type, '+@baseload_block_type+'),
	                spcd.commodity_id,
	                fp.profile_type
	         FROM   source_deal_header sdh
	                INNER JOIN source_deal_detail sdd ON  sdh.source_deal_header_id = sdd.source_deal_header_id' 
					+CASE WHEN @header_deal_id IS NULL THEN '' ELSE ' AND sdh.source_deal_header_id = '+CAST(@header_deal_id AS VARCHAR) END +'
	                INNER JOIN source_internal_portfolio sip ON  sdh.internal_portfolio_id = sip.source_internal_portfolio_id
	                     AND sip.internal_portfolio_id IN ('+ @internal_portfolio +')
	                INNER JOIN #category_vs_profile t ON  t.category_id = sdd.category
	                LEFT JOIN source_price_curve_def spcd(NOLOCK) ON  spcd.source_curve_def_id = sdd.curve_id
	                LEFT JOIN forecast_profile fp ON  fp.profile_id = t.profile_id
				'
	exec spa_print @st
	EXEC(@st)


	CREATE TABLE #total_term_fraction
	(
		deal_detail_id     INT NOT NULL,
		tot_term_fraction  NUMERIC(38, 20) NULL,
		tot_yr_fraction    NUMERIC(38, 20) NULL
	)
	----term total for power (not GAS)
	SET @st = ' INSERT INTO #total_term_fraction(deal_detail_id,tot_term_fraction,tot_yr_fraction)
				SELECT sdd.deal_detail_id,tot_term.tot_fraction,tot_fraction_yr FROM 
				(SELECT * FROM #process_deal WHERE commodity_id <> -1) sdd
  				  OUTER APPLY (	SELECT  SUM(
						CASE WHEN ISNULL(hb.hr1,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr1,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr2,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr2,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr3,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr3,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr4,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr4,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr5,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr5,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr6,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr6,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr7,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr7,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr8,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr8,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr9,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr9,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr10,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr10,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr11,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr11,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr12,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr12,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr13,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr13,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr14,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr14,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr15,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr15,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr16,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr16,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr17,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr17,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr18,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr18,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr19,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr19,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr20,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr20,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr21,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr21,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr22,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr22,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr23,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr23,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr24,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr24,0) AS NUMERIC(38,20)) END ) tot_fraction
						FROM deal_detail_hour ddh WITH (NOLOCK)
							INNER JOIN hour_block_term hb WITH (NOLOCK) ON ddh.term_date=hb.term_date 
							AND ddh.profile_id=sdd.profile_id AND ddh.term_date BETWEEN sdd.term_start AND sdd.term_end
							AND hb.block_define_id=sdd.block_define_id AND hb.block_type=sdd.block_type_id	
				) tot_term 	
			 OUTER APPLY (SELECT  SUM(
						CASE WHEN ISNULL(hb.hr1,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr1,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr2,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr2,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr3,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr3,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr4,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr4,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr5,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr5,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr6,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr6,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr7,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr7,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr8,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr8,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr9,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr9,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr10,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr10,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr11,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr11,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr12,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr12,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr13,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr13,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr14,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr14,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr15,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr15,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr16,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr16,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr17,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr17,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr18,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr18,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr19,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr19,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr20,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr20,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr21,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr21,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr22,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr22,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr23,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr23,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr24,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr24,0) AS NUMERIC(38,20)) END ) tot_fraction_yr
						FROM deal_detail_hour ddh WITH (NOLOCK)
							INNER JOIN hour_block_term hb WITH (NOLOCK) ON ddh.term_date=hb.term_date 
							AND ddh.profile_id=sdd.profile_id AND YEAR(ddh.term_date) =YEAR(sdd.term_start)
							AND hb.block_define_id=sdd.block_define_id AND hb.block_type=sdd.block_type_id	--and sdd.profile_type=17502
				) tot_yr'
				
	EXEC spa_print @st
	EXEC(@st)	
			
	----term total for GAS
		
	SET @st = ' INSERT INTO #total_term_fraction(deal_detail_id,tot_term_fraction,tot_yr_fraction)
				SELECT	sdd.deal_detail_id,tot_term.tot_fraction,tot_yr.tot_fraction_yr FROM 
				(SELECT * FROM #process_deal WHERE commodity_id=-1) sdd
  				  OUTER APPLY (	SELECT SUM(tot_fraction) tot_fraction FROM (
					SELECT  
					CASE WHEN hb.term_date=sdd.term_start THEN  0 ELSE
						CASE WHEN ISNULL(hb.hr1,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr1,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr2,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr2,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr3,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr3,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr4,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr4,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr5,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr5,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr6,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr6,0) AS NUMERIC(38,20)) END 
					END	+
					CASE WHEN hb.term_date=sdd.term_end+1 THEN 0 ELSE 
						CASE WHEN ISNULL(hb.hr7,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr7,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr8,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr8,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr9,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr9,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr10,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr10,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr11,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr11,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr12,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr12,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr13,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr13,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr14,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr14,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr15,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr15,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr16,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr16,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr17,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr17,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr18,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr18,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr19,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr19,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr20,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr20,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr21,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr21,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr22,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr22,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr23,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr23,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr24,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr24,0) AS NUMERIC(38,20)) END 
					END tot_fraction
						FROM deal_detail_hour ddh WITH (NOLOCK)
						INNER JOIN hour_block_term hb WITH (NOLOCK) ON ddh.term_date=hb.term_date AND 
							ddh.profile_id=sdd.profile_id AND ddh.term_date BETWEEN sdd.term_start AND sdd.term_end+1
							AND hb.block_define_id=sdd.block_define_id AND hb.block_type=sdd.block_type_id
  		  		) a	
			) tot_term 
			 OUTER APPLY (SELECT SUM(tot_fraction_yr) tot_fraction_yr FROM (
					SELECT  
					CASE WHEN hb.term_date=sdd.term_start THEN  0 ELSE
						CASE WHEN ISNULL(hb.hr1,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr1,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr2,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr2,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr3,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr3,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr4,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr4,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr5,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr5,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr6,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr6,0) AS NUMERIC(38,20)) END 
					END	+
					CASE WHEN hb.term_date=sdd.term_end+1 THEN 0 ELSE 
						CASE WHEN ISNULL(hb.hr7,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr7,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr8,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr8,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr9,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr9,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr10,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr10,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr11,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr11,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr12,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr12,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr13,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr13,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr14,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr14,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr15,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr15,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr16,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr16,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr17,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr17,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr18,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr18,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr19,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr19,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr20,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr20,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr21,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr21,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr22,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr22,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr23,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr23,0) AS NUMERIC(38,20)) END +
						CASE WHEN ISNULL(hb.hr24,0)=0 THEN 0 ELSE CAST(ISNULL(ddh.Hr24,0) AS NUMERIC(38,20)) END 
					END tot_fraction_yr
						FROM deal_detail_hour ddh WITH (NOLOCK)
						INNER JOIN hour_block_term hb WITH (NOLOCK) ON ddh.term_date=hb.term_date AND 
							ddh.profile_id=sdd.profile_id AND YEAR(ddh.term_date)=YEAR(sdd.term_start)
							AND hb.block_define_id=sdd.block_define_id AND hb.block_type=sdd.block_type_id --and sdd.profile_type=17502
  		  		) a	
			) tot_yr '
	 
	 
	EXEC spa_print @st
	EXEC(@st)	
			
	CREATE INDEX indx_total_term_fraction11 ON  #total_term_fraction([deal_detail_id])	
		
	UPDATE sdd
	SET    deal_volume = sdd.standard_yearly_volume *
	       CASE 
	            WHEN pd.profile_type = 17502 THEN CAST(tot_term_fraction AS NUMERIC(24, 16)) / CAST(tot_yr_fraction AS NUMERIC(24, 16))
	            ELSE CAST(tot_term_fraction AS NUMERIC(24, 16))
	       END,
	       deal_volume_frequency = 't'
	FROM   source_deal_detail sdd
	       INNER JOIN #total_term_fraction t ON  sdd.source_deal_detail_id = t.deal_detail_id
	       INNER JOIN #process_deal pd ON  pd.deal_detail_id = t.deal_detail_id

		
	UPDATE sdh
	SET    internal_desk_id = 17300
	FROM   source_deal_header sdh
	       INNER JOIN (SELECT DISTINCT source_deal_header_id FROM source_deal_detail sdd
	                       INNER JOIN #total_term_fraction t ON  sdd.source_deal_detail_id = t.deal_detail_id
	        ) sdd ON  sdh.source_deal_header_id = sdd.source_deal_header_id


	UPDATE sdh
	SET    product_id = 4100
	FROM   source_deal_header sdh
	       INNER JOIN (SELECT DISTINCT source_deal_header_id FROM source_deal_detail sdd
	                       INNER JOIN #total_term_fraction t ON  sdd.source_deal_detail_id = t.deal_detail_id
	        ) sdd ON  sdh.source_deal_header_id = sdd.source_deal_header_id

	DECLARE @user_login_id   VARCHAR(50),
	        @process_id      VARCHAR(100),
	        @effected_deals  VARCHAR(250)
	
	SET @user_login_id = 'farrms_admin'		
	SET @process_id = dbo.FNAGetNewID()
	SET @effected_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)

	SET @st = 'CREATE TABLE ' + @effected_deals + '(source_deal_header_id INT, [action] varchar(1)) '
	exec spa_print @st
	EXEC(@st)


	-----######################### CHANGE HERE to SELECT the required deals

	SET @st='INSERT INTO '+@effected_deals +'
	         SELECT DISTINCT source_deal_header_id,''i''
	         FROM   source_deal_detail sdd
	         INNER JOIN #total_term_fraction t ON  sdd.source_deal_detail_id = t.deal_detail_id '
			
	EXEC(@st)
	
	EXEC spa_update_deal_total_volume NULL,@process_id,0,1,@user_login_id
	
END	