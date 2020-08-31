
/****** Object:  StoredProcedure [dbo].[spa_cube_MTM]    Script Date: 12/09/2011 14:45:52 ******/
IF EXISTS (SELECT * FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'dbo.[spa_update_contract_volume]') AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE dbo.[spa_update_contract_volume]  
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO  

-- ===============================================================================================================  
-- Author: padhikari@pioneersolutionsglobal.com  
-- Create date: 2012-01-25  
-- Description: Logic To Update Contract Volume.  
-- exec [spa_update_contract_volume]  
-- Params:  
-- @contracts VARCHAR(5000) = 'B2B Power Metered Bulk,B2B Power Profiled'  
-- ===============================================================================================================  
CREATE PROC dbo.[spa_update_contract_volume]  
 @contracts VARCHAR(5000) = NULL  
AS  
  
DECLARE @sql        VARCHAR(MAX) --,@contracts VARCHAR(5000) 
  
--TODO: Enter Contract IDs  
--23 B2B Power Profiled  
--23 B2B Power Metered Bulk  
--SELECT * FROM contract_group WHERE contract_id IN (23,24) 

--UPDATE sdd  
--SET    deal_volume = 0 
--FROM   source_deal_detail sdd  
--       INNER JOIN #deals d ON  d.source_deal_header_id = sdd.source_deal_header_id  
       
       
IF @contracts IS NULL  
	SET @contracts = '23,24'  
	--SET @contracts = '55,56'
  
IF OBJECT_ID('tempdb..#contracts') IS NOT NULL  
    DROP TABLE #contracts  
  
CREATE TABLE #contracts ([contract_id] INT,[contract_name] VARCHAR(500) COLLATE DATABASE_DEFAULT)  
  
SET @sql = 'INSERT INTO #contracts  
			SELECT DISTINCT contract_id, contract_name   
            FROM contract_group cg  
			WHERE cg.contract_id IN ('+@contracts+')'  
EXEC(@sql)  
  
IF OBJECT_ID('tempdb..#deals') IS NOT NULL  
    DROP TABLE #deals  
      
SELECT sdd.source_deal_header_id,
       SUM(sdd.deal_volume) [vol]
INTO #deals
FROM   source_deal_header sdh
       INNER JOIN #contracts c ON  c.contract_id = sdh.contract_id
       INNER JOIN source_deal_detail sdd ON  sdd.source_deal_header_id = sdh.source_deal_header_id
       INNER JOIN contract_group cg ON  sdh.contract_id = cg.contract_id
--WHERE sdh.source_deal_header_id IN (51128)
GROUP BY
       sdd.source_deal_header_id
  
-- SELECT * FROM #deals --WHERE vol = 0
--RETURN  


  
IF OBJECT_ID('tempdb..#total_calc') IS NOT NULL  
    DROP TABLE #total_calc  

IF OBJECT_ID('tempdb..#total_fraction') IS NOT NULL  
    DROP TABLE #total_fraction 
    
      
CREATE TABLE #total_calc
(
	source_deal_header_id  INT,
	source_deal_detail_id  INT,
	term_start             DATETIME,
	Leg                    INT,
	[contract_volume]      NUMERIC(38, 20)
)  
 
CREATE TABLE #total_fraction
(
	curve_id INT,
	location_id INT,
	term_year INT,
	total_fraction NUMERIC(38, 20)
)

DECLARE @baseload_block_define_id VARCHAR(10)

SELECT @baseload_block_define_id = CAST(value_id AS VARCHAR(10))
FROM   static_data_value
WHERE  [type_id] = 10018
       AND code LIKE 'Base Load'


--SELECT @baseload_block_define_id
INSERT INTO #total_fraction
SELECT
	sdh.curve_id,
	sdh.location_id,
	term_year,
	SUM(ISNULL(hb.hr1, 0)* CAST(ISNULL(ddh.Hr1, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr2, 0)* CAST(ISNULL(ddh.Hr2, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr3, 0)* CAST(ISNULL(ddh.Hr3, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr4, 0)* CAST(ISNULL(ddh.Hr4, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr5, 0)* CAST(ISNULL(ddh.Hr5, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr6, 0)* CAST(ISNULL(ddh.Hr6, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr7, 0)* CAST(ISNULL(ddh.Hr7, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr8, 0)* CAST(ISNULL(ddh.Hr8, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr9, 0)* CAST(ISNULL(ddh.Hr9, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr10, 0)* CAST(ISNULL(ddh.Hr10, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr11, 0)* CAST(ISNULL(ddh.Hr11, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr12, 0)* CAST(ISNULL(ddh.Hr12, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr13, 0)* CAST(ISNULL(ddh.Hr13, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr14, 0)* CAST(ISNULL(ddh.Hr14, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr15, 0)* CAST(ISNULL(ddh.Hr15, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr16, 0)* CAST(ISNULL(ddh.Hr16, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr17, 0)* CAST(ISNULL(ddh.Hr17, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr18, 0)* CAST(ISNULL(ddh.Hr18, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr19, 0)* CAST(ISNULL(ddh.Hr19, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr20, 0)* CAST(ISNULL(ddh.Hr20, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr21, 0)* CAST(ISNULL(ddh.Hr21, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr22, 0)* CAST(ISNULL(ddh.Hr22, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr23, 0)* CAST(ISNULL(ddh.Hr23, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr24, 0)* CAST(ISNULL(ddh.Hr24, 0) AS NUMERIC(38, 20))) total_fraction  
FROM

	#contracts cg	
	CROSS APPLY(
		SELECT DISTINCT sdd.source_deal_header_id,contract_id,curve_id,location_id, YEAR(term_start) term_year from source_deal_detail sdd
			INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id=sdh.source_deal_header_id
			INNER JOIN #deals d ON d.source_deal_header_id = sdh.source_deal_header_id
		WHERE sdh.contract_id = cg.contract_id
	)sdh
	INNER JOIN source_price_curve_def spcd ON  sdh.curve_id = spcd.source_curve_def_id  
	LEFT JOIN source_minor_location sml ON  sdh.location_id = sml.source_minor_location_id  
    LEFT JOIN deal_detail_hour ddh ON  ddh.profile_id = CASE WHEN sdh.contract_id  = 23 THEN sml.profile_id  ELSE sml.proxy_profile_id  END
        AND YEAR(ddh.term_date) = sdh.term_year
	LEFT JOIN dbo.vwDealTimezone tz on  sdh.source_deal_header_id=tz.source_deal_header_id
			and tz.curve_id=isnull(sdh.curve_id,-1)  and tz.location_id=isnull(sdh.location_id,-1) 
    LEFT JOIN hour_block_term hb ON  hb.block_define_id = ISNULL(spcd.block_define_id,@baseload_block_define_id)  
        AND ddh.term_date = hb.term_date  
        AND hb.block_type = 12000 
		AND hb.dst_group_value_id = tz.dst_group_value_id
WHERE
	ISNULL(sml.calculation_method,'t')='p'        
GROUP BY
	sdh.curve_id,sdh.location_id,term_year
	
	

		
INSERT INTO #total_calc  
SELECT sdd.source_deal_header_id,  
       sdd.source_deal_detail_id,  
       MAX(sdd.term_start) [term_start],  
       sdd.Leg,  
       (  
           sdd.standard_yearly_volume *  
           SUM(
           		ISNULL(hb.hr1, 0)* CAST(ISNULL(ddh.Hr1, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr2, 0)* CAST(ISNULL(ddh.Hr2, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr3, 0)* CAST(ISNULL(ddh.Hr3, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr4, 0)* CAST(ISNULL(ddh.Hr4, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr5, 0)* CAST(ISNULL(ddh.Hr5, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr6, 0)* CAST(ISNULL(ddh.Hr6, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr7, 0)* CAST(ISNULL(ddh.Hr7, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr8, 0)* CAST(ISNULL(ddh.Hr8, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr9, 0)* CAST(ISNULL(ddh.Hr9, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr10, 0)* CAST(ISNULL(ddh.Hr10, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr11, 0)* CAST(ISNULL(ddh.Hr11, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr12, 0)* CAST(ISNULL(ddh.Hr12, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr13, 0)* CAST(ISNULL(ddh.Hr13, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr14, 0)* CAST(ISNULL(ddh.Hr14, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr15, 0)* CAST(ISNULL(ddh.Hr15, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr16, 0)* CAST(ISNULL(ddh.Hr16, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr17, 0)* CAST(ISNULL(ddh.Hr17, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr18, 0)* CAST(ISNULL(ddh.Hr18, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr19, 0)* CAST(ISNULL(ddh.Hr19, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr20, 0)* CAST(ISNULL(ddh.Hr20, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr21, 0)* CAST(ISNULL(ddh.Hr21, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr22, 0)* CAST(ISNULL(ddh.Hr22, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr23, 0)* CAST(ISNULL(ddh.Hr23, 0) AS NUMERIC(38, 20)) +
           		ISNULL(hb.hr24, 0)* CAST(ISNULL(ddh.Hr24, 0) AS NUMERIC(38, 20)))   
           
       )/ISNULL(NULLIF(MAX(tot.[total_fraction]),0),1) [Volume]  
  
FROM
    #deals d
	INNER JOIN source_deal_detail sdd ON d.source_deal_header_id = sdd.source_deal_header_id
	INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id=sdh.source_deal_header_id
	INNER JOIN #contracts  cg On cg.contract_id=sdh.contract_id
	INNER JOIN source_price_curve_def spcd ON  sdd.curve_id = spcd.source_curve_def_id  
	LEFT JOIN source_minor_location sml ON  sdd.location_id = sml.source_minor_location_id  
    LEFT JOIN deal_detail_hour ddh ON  ddh.profile_id = CASE WHEN sdh.contract_id  = 23 THEN sml.profile_id  ELSE sml.proxy_profile_id  END
    --LEFT JOIN deal_detail_hour ddh ON  ddh.profile_id = CASE WHEN sdh.contract_id  = 55 THEN sml.profile_id  ELSE sml.proxy_profile_id  END
        AND ddh.term_date BETWEEN sdd.term_start AND sdd.term_end  
	INNER JOIN dbo.vwDealTimezone tz on  sdd.source_deal_header_id=tz.source_deal_header_id
			AND tz.curve_id=isnull(sdd.curve_id,-1)  and tz.location_id=isnull(sdd.location_id,-1) 
    LEFT JOIN hour_block_term hb ON  hb.block_define_id = ISNULL(spcd.block_define_id,@baseload_block_define_id)  
        AND ddh.term_date = hb.term_date  
        AND hb.block_type = 12000
		AND hb.dst_group_value_id=tz.dst_group_value_id  
	LEFT JOIN #total_fraction tot ON tot.curve_id = sdd.curve_id
		AND tot.location_id = sdd.location_id
		AND tot.term_year = YEAR(sdd.term_start)

--WHERE sdd.deal_volume = 0 
GROUP BY 
		sdd.Leg, 
		YEAR(ddh.term_date), 
		MONTH(ddh.term_date), 
		sdd.source_deal_header_id, 
		sdd.source_deal_detail_id, 
		sdd.standard_yearly_volume  

--select * from #total_calc

--SELECT * FROM #total_calc ORDER BY source_deal_header_id,source_deal_detail_id, Leg, term_start
--RETURN

UPDATE sdd  
SET    deal_volume = tc.contract_volume   
FROM   source_deal_detail sdd  
       INNER JOIN #total_calc tc ON  sdd.source_deal_detail_id = tc.source_deal_detail_id  
   
  
--select * from source_deal_detail where source_deal_header_id=51132  order by term_start
--select 30
