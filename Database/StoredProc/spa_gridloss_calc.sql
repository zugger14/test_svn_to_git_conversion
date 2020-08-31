IF OBJECT_ID(N'dbo.[spa_gridloss_calc]', N'P') IS NOT NULL
    DROP PROC dbo.[spa_gridloss_calc]
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 /**
	Calculate gridloss of deals in portfolio

	Parameters : 
	@subsidiary : Subsidiary filter to process
	@deal_type : Deal Type filter to process
	@block_type_group : Block Type Group filter to process
	@block_type_group_onpeak : Block Type Group Onpeak filter to process
	@block_type_group_offpeak : Block Type Group Offpeak filter to process
	@block_type_group_weekend : Block Type Group Weekend filter to process
	@calc_deal_id : Deal Id  filter to process
	@pv_party : Pv Party filter to process
	@location_grid : Location Grid  filter to process
	@region_name : Region Name filter to process

  */


CREATE PROC dbo.[spa_gridloss_calc]
	@subsidiary VARCHAR(200) = 'Power',
	@deal_type CHAR(1) = 'p',
	@block_type_group INT = 292082,
	@block_type_group_onpeak INT = 292079,
	@block_type_group_offpeak INT = 292080,
	@block_type_group_weekend INT = 292081,
	@calc_deal_id INT = 121158,
	@pv_party VARCHAR(200) = 'RWEST-NL-BV',
	@location_grid VARCHAR(200) = 'Elia',
	@region_name VARCHAR(200) = 'Normal'
AS

--DECLARE @subsidiary                VARCHAR(100)
--DECLARE @deal_type                 CHAR(1)
--DECLARE @block_type_group          INT
--DECLARE @block_type_group_onpeak   INT
--DECLARE @block_type_group_offpeak  INT
--DECLARE @block_type_group_weekend  INT
--DECLARE @calc_deal_id              INT

--DECLARE @pv_party                  VARCHAR(200),
--        @location_grid             VARCHAR(200),
--        @region_name               VARCHAR(200)

IF OBJECT_ID(N'tempdb..#deal', N'U') IS NOT NULL
	DROP TABLE #deal
IF OBJECT_ID(N'tempdb..#calculated_values', N'U') IS NOT NULL
	DROP TABLE #calculated_values
IF OBJECT_ID(N'tempdb..#report_hourly_position_profile', N'U') IS NOT NULL
	DROP TABLE #report_hourly_position_profile	
IF OBJECT_ID(N'tempdb..#total_deals', N'U') IS NOT NULL
	DROP TABLE #total_deals	

	--DECLARE @subsidiary                VARCHAR(100)
	--DECLARE @deal_type                 CHAR(1)
	--DECLARE @block_type_group          INT
	--DECLARE @block_type_group_onpeak   INT
	--DECLARE @block_type_group_offpeak  INT
	--DECLARE @block_type_group_weekend  INT
	--DECLARE @calc_deal_id              INT

	--DECLARE @pv_party                  VARCHAR(200),
	--		@location_grid             VARCHAR(200),
	--		@region_name               VARCHAR(200)
	        
	DECLARE @pv_party_id               INT
	DECLARE @location_grid_id          INT
	DECLARE @region_id                 INT

	SET @subsidiary = 'Power'
	SET @deal_type = 'p'
	SET @calc_deal_id = 121158
	SET @pv_party = 'RWEST NL BV'
	SET @location_grid = 'Elia'
	SET @region_name = 'Normal'


--select * from static_data_value where value_id in (292057,292055,292056)block type
--select * from static_data_value where value_id in (292036,292033,292065)grid, region and pv party
----select * from static_data_value where type_id=11150----region (Normal 292036)
----select * from source_minor_location where region=292036 and grid_value_id=292033
---select * from deal_detail_hour where source_deal_header_id =60440



	SELECT @pv_party_id = value_id FROM static_data_value sdv WHERE  sdv.[type_id] = 18300 AND code = @pv_party        
	SELECT @location_grid_id = value_id FROM static_data_value sdv WHERE  sdv.[type_id] = 18000 AND code = @location_grid
	SELECT @region_id = value_id FROM static_data_value sdv WHERE  sdv.[type_id] = 11150 AND code = @region_name
	
	SELECT DISTINCT sdh.source_deal_header_id INTO #deal
	FROM source_deal_header sdh
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN static_data_value sdv ON sdd.pv_party = @pv_party_id
	INNER JOIN source_minor_location sml ON sdd.location_id = sml.source_minor_location_id
		AND sml.grid_value_id = @location_grid_id AND sml.region = @region_id
	INNER JOIN source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1
		AND sdh.source_system_book_id2 = ssbm.source_system_book_id2
		AND sdh.source_system_book_id3 = ssbm.source_system_book_id3
		AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
	INNER JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id AND book.hierarchy_level = 0
	INNER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id AND stra.hierarchy_level = 1
	INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id AND sub.hierarchy_level = 2
	WHERE sub.entity_name = @subsidiary 
		AND sdh.physical_financial_flag = @deal_type 
		AND sdh.source_deal_header_id <> @calc_deal_id


	-- GET DEALS FROM report_hourly_position_deal
		--INSERT INTO	#calculated_values	
	
	SELECT 
		rhpd.term_start,
		SUM(rhpd.hr1) [hr1],
		SUM(rhpd.hr2) [hr2],
		SUM(rhpd.hr3) [hr3],
		SUM(rhpd.hr4) [hr4],
		SUM(rhpd.hr5) [hr5],
		SUM(rhpd.hr6) [hr6],
		SUM(rhpd.hr7) [hr7],
		SUM(rhpd.hr8) [hr8],
		SUM(rhpd.hr9) [hr9],
		SUM(rhpd.hr10) [hr10],
		SUM(rhpd.hr11) [hr11],
		SUM(rhpd.hr12) [hr12],
		SUM(rhpd.hr13) [hr13],
		SUM(rhpd.hr14) [hr14],
		SUM(rhpd.hr15) [hr15],
		SUM(rhpd.hr16) [hr16],
		SUM(rhpd.hr17) [hr17],
		SUM(rhpd.hr18) [hr18],
		SUM(rhpd.hr19) [hr19],
		SUM(rhpd.hr20) [hr20],
		SUM(rhpd.hr21) [hr21],
		SUM(rhpd.hr22) [hr22],
		SUM(rhpd.hr23) [hr23],
		SUM(rhpd.hr24) [hr24],
		SUM(rhpd.hr25) [hr25]		
	INTO #total_deals 
	FROM 
		report_hourly_position_deal rhpd 
		INNER JOIN #deal d ON rhpd.source_deal_header_id=d.source_deal_header_id
		INNER JOIN source_deal_detail sdd ON rhpd.term_start BETWEEN sdd.term_start AND sdd.term_end 
			AND rhpd.source_deal_detail_id=sdd.source_deal_detail_id
		INNER JOIN source_minor_location smlm ON smlm.source_minor_location_id=sdd.location_id	
	WHERE sdd.pv_party = @pv_party_id 
		AND smlm.grid_value_id = @location_grid_id 
		AND smlm.region = @region_id
	GROUP BY
		rhpd.term_start
		
		
----------------------
	INSERT INTO #total_deals
	SELECT 
		rhpd.term_start,
		SUM(rhpd.hr1) [hr1],
		SUM(rhpd.hr2) [hr2],
		SUM(rhpd.hr3) [hr3],
		SUM(rhpd.hr4) [hr4],
		SUM(rhpd.hr5) [hr5],
		SUM(rhpd.hr6) [hr6],
		SUM(rhpd.hr7) [hr7],
		SUM(rhpd.hr8) [hr8],
		SUM(rhpd.hr9) [hr9],
		SUM(rhpd.hr10) [hr10],
		SUM(rhpd.hr11) [hr11],
		SUM(rhpd.hr12) [hr12],
		SUM(rhpd.hr13) [hr13],
		SUM(rhpd.hr14) [hr14],
		SUM(rhpd.hr15) [hr15],
		SUM(rhpd.hr16) [hr16],
		SUM(rhpd.hr17) [hr17],
		SUM(rhpd.hr18) [hr18],
		SUM(rhpd.hr19) [hr19],
		SUM(rhpd.hr20) [hr20],
		SUM(rhpd.hr21) [hr21],
		SUM(rhpd.hr22) [hr22],
		SUM(rhpd.hr23) [hr23],
		SUM(rhpd.hr24) [hr24],
		SUM(rhpd.hr25) [hr25]		
	FROM 
		report_hourly_position_profile rhpd 
		INNER JOIN #deal d ON rhpd.source_deal_header_id=d.source_deal_header_id
		INNER JOIN source_deal_detail sdd ON rhpd.term_start BETWEEN sdd.term_start AND sdd.term_end 
			AND rhpd.source_deal_detail_id=sdd.source_deal_detail_id
		INNER JOIN source_minor_location smlm ON smlm.source_minor_location_id=sdd.location_id	
	WHERE sdd.pv_party = @pv_party_id 
		AND smlm.grid_value_id = @location_grid_id 
		AND smlm.region = @region_id
	GROUP BY
		rhpd.term_start
			
	CREATE INDEX IDX_1 ON #total_deals(term_start)	
		
		
-- Calculate with the factor		
	SELECT 
			@calc_deal_id source_deal_header_id,
			rhpd.term_start,
			MAX((spc.curve_value/100)) curve_value,
	--CASE WHEN MAX(hbt.Hr1) = 1 THEN CASE WHEN AVG(rhpd.Hr1) > 0 THEN (AVG(rhpd.Hr1) * spc.curve_value) ELSE 0 END ELSE AVG(rhpd.Hr1) END [Hr1],
			CASE WHEN SUM(rhpd.hr1)<0 THEN SUM(rhpd.Hr1*hbt.Hr1 * (spc.curve_value/100)) ELSE 0 END [Hr1], 
			CASE WHEN SUM(rhpd.hr2)<0 THEN SUM(rhpd.Hr2*hbt.Hr2 * (spc.curve_value/100)) ELSE 0 END [Hr2],
			CASE WHEN SUM(rhpd.hr3)<0 THEN SUM((rhpd.Hr3-rhpd.Hr25)*hbt.Hr3 * (spc.curve_value/100)) ELSE 0 END [Hr3],
			CASE WHEN SUM(rhpd.hr4)<0 THEN SUM(rhpd.Hr4*hbt.Hr4 * (spc.curve_value/100)) ELSE 0 END [Hr4],
			CASE WHEN SUM(rhpd.hr5)<0 THEN SUM(rhpd.Hr5*hbt.Hr5 * (spc.curve_value/100)) ELSE 0 END [Hr5],
			CASE WHEN SUM(rhpd.hr6)<0 THEN SUM(rhpd.Hr6*hbt.Hr6 * (spc.curve_value/100)) ELSE 0 END [Hr6],
			CASE WHEN SUM(rhpd.hr7)<0 THEN SUM(rhpd.Hr7*hbt.Hr7 * (spc.curve_value/100)) ELSE 0 END [Hr7],
			CASE WHEN SUM(rhpd.hr8)<0 THEN SUM(rhpd.Hr8*hbt.Hr8 * (spc.curve_value/100)) ELSE 0 END [Hr8],
			CASE WHEN SUM(rhpd.hr9)<0 THEN SUM(rhpd.Hr9*hbt.Hr9 * (spc.curve_value/100)) ELSE 0 END [Hr9],
			CASE WHEN SUM(rhpd.hr10)<0 THEN SUM(rhpd.Hr10*hbt.Hr10 * (spc.curve_value/100)) ELSE 0 END [Hr10],
			CASE WHEN SUM(rhpd.hr11)<0 THEN SUM(rhpd.Hr11*hbt.Hr11 * (spc.curve_value/100)) ELSE 0 END [Hr11],
			CASE WHEN SUM(rhpd.hr12)<0 THEN SUM(rhpd.Hr12*hbt.Hr12 * (spc.curve_value/100)) ELSE 0 END [Hr12],
			CASE WHEN SUM(rhpd.hr13)<0 THEN SUM(rhpd.Hr13*hbt.Hr13 * (spc.curve_value/100)) ELSE 0 END [Hr13],
			CASE WHEN SUM(rhpd.hr14)<0 THEN SUM(rhpd.Hr14*hbt.Hr14 * (spc.curve_value/100)) ELSE 0 END [Hr14],
			CASE WHEN SUM(rhpd.hr15)<0 THEN SUM(rhpd.Hr15*hbt.Hr15 * (spc.curve_value/100)) ELSE 0 END [Hr15],
			CASE WHEN SUM(rhpd.hr16)<0 THEN SUM(rhpd.Hr16*hbt.Hr16 * (spc.curve_value/100)) ELSE 0 END [Hr16],
			CASE WHEN SUM(rhpd.hr17)<0 THEN SUM(rhpd.Hr17*hbt.Hr17 * (spc.curve_value/100)) ELSE 0 END [Hr17],
			CASE WHEN SUM(rhpd.hr18)<0 THEN SUM(rhpd.Hr18*hbt.Hr18 * (spc.curve_value/100)) ELSE 0 END [Hr18],
			CASE WHEN SUM(rhpd.hr19)<0 THEN SUM(rhpd.Hr19*hbt.Hr19 * (spc.curve_value/100)) ELSE 0 END [Hr19],
			CASE WHEN SUM(rhpd.hr20)<0 THEN SUM(rhpd.Hr20*hbt.Hr20 * (spc.curve_value/100)) ELSE 0 END [Hr20],
			CASE WHEN SUM(rhpd.hr21)<0 THEN SUM(rhpd.Hr21*hbt.Hr21 * (spc.curve_value/100)) ELSE 0 END [Hr21],
			CASE WHEN SUM(rhpd.hr22)<0 THEN SUM(rhpd.Hr22*hbt.Hr22 * (spc.curve_value/100)) ELSE 0 END [Hr22],
			CASE WHEN SUM(rhpd.hr23)<0 THEN SUM(rhpd.Hr23*hbt.Hr23 * (spc.curve_value/100)) ELSE 0 END [Hr23],
			CASE WHEN SUM(rhpd.hr24)<0 THEN SUM(rhpd.Hr24*hbt.Hr24 * (spc.curve_value/100)) ELSE 0 END [Hr24],
			CASE WHEN SUM(rhpd.hr25)<0 THEN SUM(rhpd.Hr25*CASE WHEN add_dst_hour<=0 THEN 0 ELSE 1 END * (spc.curve_value/100)) ELSE 0 END [Hr25],
			add_dst_hour,
			MAX(hbt.curve_id) curve_id
		INTO 	#calculated_values	
	FROM 
	#total_deals rhpd
	OUTER APPLY(SELECT spcd.source_curve_def_Id,spcd.curve_id,hbt.term_date,Hr1,Hr2,Hr3,Hr4,Hr5,Hr6,Hr7,Hr8,Hr9,Hr10,Hr11,Hr12,
					Hr13,Hr14,Hr15,Hr16,Hr17,Hr18,Hr19,Hr20,Hr21,Hr22,Hr23,Hr24,add_dst_hour
				FROM  hour_block_term hbt INNER JOIN source_price_curve_def spcd
					ON hbt.block_define_id = spcd.block_define_id	
					AND spcd.source_curve_def_id IN(349,350,351)
					AND hbt.block_type = 12000
			WHERE hbt.term_date = rhpd.term_start
	) hbt 
	LEFT JOIN source_price_curve spc ON hbt.source_curve_def_id = spc.source_curve_def_id 
		AND YEAR(spc.maturity_date) = YEAR(hbt.term_date)
	
	GROUP BY  rhpd.term_start,add_dst_hour--,spcd.curve_id,rhpd.source_deal_header_id




CREATE INDEX IDEX_2 ON 	#calculated_values(term_start,add_dst_hour)


	--SELECT * FROM #calculated_values

	----TODO:Insert the calculated values into
	--INSERT INTO source_deal_detail_hour 
DELETE sddh 
FROM 
	source_deal_detail sdd
	INNER JOIN source_deal_detail_hour sddh on sdd.source_deal_detail_id=sddh.source_deal_detail_id
	AND sdd.source_deal_header_id = @calc_deal_id
	

	INSERT INTO source_deal_detail_hour(source_deal_detail_id,term_date,hr,is_dst,volume,price,formula_id)
	SELECT 
			sdd.source_deal_detail_id,
			final.term_start,
			CASE WHEN is_dst>0 AND final.Hr=25 AND mv.id IS NOT NULL THEN 3 ELSE final.Hr END [hr],
			CASE WHEN is_dst>0 AND final.Hr=25 AND mv.id IS NOT NULL THEN 1 ELSE 0 END AS [is_dst],
			SUM(abs(final.Volume)) [volume],
			NULL AS [price],
			NULL AS [formula_id]
	FROM (
		SELECT 
			   term_start,
			   REPLACE(Hr, 'hr', '') AS [Hr],
			   SUM(Volume) volume,is_dst
		FROM (SELECT source_deal_header_id,term_start,add_dst_hour is_dst,
				hr1,hr2,hr3,hr4,hr5,hr6,
				hr7,hr8,hr9,hr10,hr11,hr12,
				hr13,hr14,hr15,hr16,hr17,hr18,
				hr19,hr20,hr21,hr22,hr23,hr24,hr25
				FROM #calculated_values 
			) p
		UNPIVOT
		(
			Volume FOR Hr IN(hr1,hr2,hr3,hr4,hr5,hr6,
				hr7,hr8,hr9,hr10,hr11,hr12,
				hr13,hr14,hr15,hr16,hr17,hr18,
				hr19,hr20,hr21,hr22,hr23,hr24,hr25)
		) AS unpvt
		
		GROUP BY term_start, REPLACE(Hr, 'hr', ''),is_dst
	) as final
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = @calc_deal_id
		AND YEAR(sdd.term_start) = YEAR(final.term_start)
		AND MONTH(sdd.term_start) = MONTH(final.term_start)
	 LEFT JOIN mv90_DST mv ON mv.date=final.term_start	
		AND mv.insert_delete='i'		
	WHERE
		((is_dst>0 AND final.Hr=25) OR (final.Hr<>25))
		--and MONTH(final.term_start)=10
	GROUP BY final.term_start, CASE WHEN is_dst>0 AND final.Hr=25 AND mv.id IS NOT NULL THEN 3 ELSE final.Hr END, sdd.source_deal_detail_id,
			CASE WHEN is_dst>0 AND final.Hr=25 AND mv.id IS NOT NULL THEN 1 ELSE 0 END
	--ORDER BY final.term_start,CAST(final.Hr AS INT) ASC



---####### update total volue
/*
------------######## 
-- This script checks for the NULL total volume
-- IF there is null total volume then make the avaiale flag of the profile to NULL
-- calculatte position, this way position will be calculated using fractions
-- update the avaiable flag to 1


*/
	DECLARE @spa            VARCHAR(MAX),
        @job_name       VARCHAR(150),
        @user_login_id  VARCHAR(30),
        @effected_deals VARCHAR(150),
        @st				VARCHAR(max),
        @process_id	    VARCHAR(100) 
        

		SET @user_login_id = 'farrms_admin'
	
			SET @process_id=dbo.FNAGetNewID()
			SET @effected_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)

			SET @st='CREATE TABLE '+ @effected_deals +'(source_deal_header_id INT, [action] varchar(1)) '
			exec spa_print @st
			exec(@st)


		-----######################### CHANGE HERE to SELECT the required deals
		
			SET @st='INSERT INTO '+@effected_deals +' SELECT '+CAST(@calc_deal_id AS VARCHAR)+',''u'' '
					
			exec(@st)
			
		

	SET @job_name = 'calc_deal_position_breakdown' + @process_id
		
	EXEC [dbo].[spa_deal_position_breakdown] 'i', null, @user_login_id, @process_id

	
	
	SET @spa = 'spa_update_deal_total_volume NULL,'''+@process_id+''',0,1,''' + @user_login_id + ''''	

	EXEC (@spa)
	


