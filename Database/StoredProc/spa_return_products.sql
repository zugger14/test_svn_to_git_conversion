IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_return_products]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_return_products]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
/* SP Created By: Shushil Bohara 
 * sbohara@pioneersolutionsglobal.com
 * Created Dt: 3-August-2018
 * Description: List all available products as jurisdiction and tier from all the different sources/tables.
 * For: Sale deals products will be return to find REC of same products
 */
 * */
CREATE PROC [dbo].[spa_return_products]
	@source_deal_header_id VARCHAR(1000),
    @sell_deal_detail_id VARCHAR(1000),
	@jurisdiction VARCHAR(1000) = NULL,
	@not_jurisdiction VARCHAR(1000) = NULL,
	@tier_type VARCHAR(1000) = NULL,
	@nottier_type VARCHAR(1000) = NULL,
	@technology VARCHAR(1000) = NULL,
	@not_technology VARCHAR(1000) = NULL,
	@region_id VARCHAR(1000) = NULL,
	@not_region_id VARCHAR(1000) = NULL,
	@vintage_year VARCHAR(500) = NULL
AS

SET NOCOUNT ON
/*
DECLARE
	@source_deal_header_id VARCHAR(1000),
	@sell_deal_detail_id VARCHAR(1000),
	@jurisdiction VARCHAR(1000) = NULL,
	@not_jurisdiction VARCHAR(1000) = NULL,
	@tier_type VARCHAR(1000) = NULL,
	@nottier_type VARCHAR(1000) = NULL,
	@technology VARCHAR(1000) = NULL,
	@not_technology VARCHAR(1000) = NULL,
	@region_id VARCHAR(1000) = NULL,
	@not_region_id VARCHAR(1000) = NULL,
	@vintage_year VARCHAR(500) = NULL


SELECT 
	@source_deal_header_id=225350,
	@sell_deal_detail_id=2320761,
	@jurisdiction = NULL, --'50000013','50000012'
    @not_jurisdiction = NULL, --50000017, --NJ type_id = 10002
    @tier_type = Null,
    @nottier_type = NULL,
    @technology = NULL,
    @not_technology = NULL,
    @region_id = NULL,
    @not_region_id = NULL,
	@vintage_year = NULL --'2017'
--*/

DECLARE	@sql VARCHAR(MAX)

IF OBJECT_ID('tempdb..#tmp_deals') IS NOT NULL DROP TABLE #tmp_deals
IF OBJECT_ID('tempdb..#tmp_state_properties') IS NOT NULL DROP TABLE #tmp_state_properties
IF OBJECT_ID('tempdb..#tmp_gis_product') IS NOT NULL DROP TABLE #tmp_gis_product
IF OBJECT_ID('tempdb..#tmp_state_properties_in') IS NOT NULL DROP TABLE #tmp_state_properties_in
IF OBJECT_ID('tempdb..#product_info') IS NOT NULL DROP TABLE #product_info
IF OBJECT_ID('tempdb..#tmp_state_properties_detail') IS NOT NULL DROP TABLE #tmp_state_properties_detail

BEGIN

	SELECT item AS source_deal_header_id
	INTO #tmp_deals
	FROM dbo.SplitCommaSeperatedValues(@source_deal_header_id) --BETWEEN 6342 AND 6367

	--Saving jurisdiction and region after splitting comma separated region values from state_properties
	SELECT DISTINCT t.item region_id,
		sp.state_value_id AS jurisdiction_id,
		spd.tier_id,
		spd.technology_id
	INTO #tmp_state_properties
	FROM state_properties sp
	INNER JOIN state_properties_details spd ON spd.state_value_id = sp.state_value_id
	OUTER APPLY (SELECT item FROM dbo.SplitCommaSeperatedValues(sp.region_id)) t


	SELECT td.source_deal_header_id, 
		gp.tier_id,
		gp.jurisdiction_id,
		region_id,
		gp.technology_id,
		gp.in_or_not,
		sdv.code AS vintage
	INTO #tmp_gis_product
	FROM #tmp_deals td
	INNER JOIN gis_product gp ON gp.source_deal_header_id = td.source_deal_header_id
	LEFT JOIN static_data_value sdv ON sdv.value_id = gp.vintage
		AND sdv.type_id = 10092

	SELECT tgp.source_deal_header_id,
		sp.tier_id,
		sp.jurisdiction_id,
		sp.region_id,
		sp.technology_id,
		tgp.in_or_not,
		tgp.vintage
	INTO #tmp_state_properties_detail
	FROM #tmp_gis_product tgp
	INNER JOIN #tmp_state_properties sp ON sp.region_id = tgp.region_id
		AND ISNULL(tgp.jurisdiction_id, sp.jurisdiction_id) = sp.jurisdiction_id
		AND ISNULL(tgp.tier_id, sp.tier_id) = sp.tier_id
		AND COALESCE(tgp.technology_id, sp.technology_id, -1) = ISNULL(sp.technology_id, -1)
	UNION
	SELECT tgp.source_deal_header_id,
		ISNULL(tgp.tier_id, sp.tier_id),
		ISNULL(tgp.jurisdiction_id, sp.jurisdiction_id),
		sp.region_id,
		ISNULL(tgp.technology_id, sp.technology_id),
		tgp.in_or_not,
		tgp.vintage 
	FROM #tmp_gis_product tgp
	INNER JOIN #tmp_state_properties sp ON ISNULL(tgp.jurisdiction_id, sp.jurisdiction_id) = sp.jurisdiction_id
	AND ISNULL(tgp.tier_id, sp.tier_id) = sp.tier_id
	AND COALESCE(tgp.technology_id, sp.technology_id, -1) = ISNULL(sp.technology_id, -1)
	AND tgp.region_id IS NULL

	SELECT DISTINCT
		tspi.source_deal_header_id,
		tspi.tier_id tier_id,
		tspi.jurisdiction_id,
		tspi.region_id region_id,
		tspi.technology_id,
		tspi.in_or_not,
		tspi.vintage
	INTO #tmp_state_properties_in
	FROM #tmp_state_properties_detail tspi

	SET @sql = '
		SELECT DISTINCT sdh.source_deal_header_id,
			sdd.source_deal_detail_id,
			COALESCE(cer.region_id,
					CASE WHEN gc.cnt IS NULL AND pro.region_id IS NOT NULL THEN pro.region_id
						WHEN COALESCE(gc.cnt, gis.cnt) IS NULL AND deal.region_id IS NOT NULL THEN deal.region_id
						WHEN COALESCE(gc.cnt, gis.cnt, head.cnt) IS NULL THEN gen.region_id
						ELSE NULL
					END) region_id,

			COALESCE(cer.state_id,
					CASE WHEN gc.cnt IS NULL AND pro.state_id IS NOT NULL THEN pro.state_id
						WHEN COALESCE(gc.cnt, gis.cnt) IS NULL AND deal.state_id IS NOT NULL THEN deal.state_id
						WHEN COALESCE(gc.cnt, gis.cnt, head.cnt) IS NULL THEN gen.state_id
						ELSE NULL
					END) state_value_id,

			COALESCE(cer.tier_type,
					CASE WHEN gc.cnt IS NULL AND pro.tier_type IS NOT NULL THEN pro.tier_type
						WHEN COALESCE(gc.cnt, gis.cnt) IS NULL AND deal.tier_type IS NOT NULL THEN deal.tier_type
						WHEN COALESCE(gc.cnt, gis.cnt, head.cnt) IS NULL THEN gen.tier_type
						ELSE NULL
					END) tier_value_id,

			COALESCE(cer.technology_id,
					CASE WHEN gc.cnt IS NULL AND pro.technology_id IS NOT NULL THEN pro.technology_id
						WHEN COALESCE(gc.cnt, gis.cnt) IS NULL AND deal.technology_id IS NOT NULL THEN deal.technology_id
						WHEN COALESCE(gc.cnt, gis.cnt, head.cnt) IS NULL THEN gen.technology_id
						ELSE NULL
					END) technology_id,

			--COALESCE(pro.region_id, deal.region_id, gen.region_id) region_id,
			--COALESCE(pro.state_id, deal.state_id, gen.state_id) state_value_id,
			--COALESCE(pro.tier_type, deal.tier_type, gen.tier_type) tier_value_id,
			--COALESCE(pro.technology_id, deal.technology_id, gen.technology_id) technology_id,

			sdd.term_start,
			sdd.term_end,
			COALESCE(cer.vintage, pro.vintage, deal.vintage, gen.vintage) vintage,
			sdh.match_type 
		FROM #tmp_deals td
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = td.source_deal_header_id
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id

		OUTER APPLY (SELECT DISTINCT 1 cnt 
						FROM Gis_Certificate gc 
						WHERE gc.source_deal_header_id = sdd.source_deal_detail_id 
						AND sdd.buy_sell_flag = ''b'') gc

			OUTER APPLY (SELECT DISTINCT 1 AS total, 
							tsp.region_id,
							gc.state_value_id state_id, 
							gc.tier_type, 
							tsp.technology_id,
							gc.year AS vintage,
							spd.banking_years
				FROM Gis_Certificate gc
				OUTER APPLY(SELECT MIN(spd.banking_years) banking_years
							FROM state_properties_details spd 
							WHERE spd.tier_id = gc.tier_type AND spd.state_value_id = gc.state_value_id) spd
				LEFT JOIN #tmp_state_properties tsp ON tsp.jurisdiction_id = gc.state_value_id
					AND tsp.tier_id = gc.tier_type
				LEFT JOIN static_data_value vin ON vin.value_id = gc.year
					AND vin.type_id = 10092
				WHERE gc.source_deal_header_id = sdd.source_deal_detail_id 
				AND sdd.buy_sell_flag = ''b'' ' +
				CASE WHEN @region_id IS NOT NULL THEN ' AND tsp.region_id IN  (' + @region_id + ')' ELSE '' END + 
				CASE WHEN @not_region_id IS NOT NULL THEN ' AND ISNULL(tsp.region_id, -1) NOT IN(' + @not_region_id + ')' ELSE '' END + 
				CASE WHEN @jurisdiction IS NOT NULL THEN ' AND gc.state_value_id IN (' + @jurisdiction + ')' ELSE '' END +
				CASE WHEN @not_jurisdiction IS NOT NULL THEN ' AND ISNULL(gc.state_value_id, -1) NOT IN (' + @not_jurisdiction + ')' ELSE '' END +
				CASE WHEN @tier_type IS NOT NULL THEN ' AND gc.tier_type IN (' + @tier_type + ')' ELSE '' END +
				CASE WHEN @nottier_type IS NOT NULL THEN ' AND ISNULL(gc.tier_type, -1) NOT IN (' + @nottier_type + ')' ELSE '' END +
				CASE WHEN @technology IS NOT NULL THEN ' AND tsp.technology_id IN  (' + @technology + ')' ELSE '' END + 
				CASE WHEN @not_technology IS NOT NULL THEN ' AND ISNULL(tsp.technology_id, -1) NOT IN  (' + @not_technology + ')' ELSE '' END + 
				CASE WHEN @vintage_year IS NOT NULL THEN ' AND vin.code IN ( ' + @vintage_year + ')' ELSE '' END + ') cer
					
			OUTER APPLY (SELECT DISTINCT 1 cnt 
						FROM #tmp_state_properties_in tspn 
						WHERE tspn.source_deal_header_id = td.source_deal_header_id) gis
				
			OUTER APPLY(SELECT DISTINCT 1 AS total, 
						gp.region_id,
						gp.jurisdiction_id AS state_id, 
						gp.tier_id AS tier_type,
						gp.technology_id,
						gp.vintage,
						spdd.banking_years
				FROM #tmp_state_properties_in gp
				OUTER APPLY(SELECT MIN(spd.banking_years) banking_years 
							FROM state_properties_details spd 
							WHERE spd.tier_id = gp.tier_id AND spd.state_value_id = gp.jurisdiction_id) spdd
				WHERE gp.source_deal_header_id = td.source_deal_header_id
				AND NOT EXISTS(SELECT DISTINCT 1 total
								FROM #tmp_state_properties_in gp1 
								WHERE gp1.source_deal_header_id = gp.source_deal_header_id 
								AND (gp1.region_id IS NULL OR gp1.region_id = gp.region_id)
								AND (gp1.jurisdiction_id IS NULL OR gp1.jurisdiction_id = gp.jurisdiction_id) 
								AND (gp1.tier_id IS NULL OR gp1.tier_id = gp.tier_id) 
								AND (gp1.technology_id IS NULL OR gp1.technology_id = gp.technology_id)
								AND gp1.in_or_not = 0)
				--AND gc.cnt IS NULL
				AND gp.in_or_not = 1 ' +
				CASE WHEN @region_id IS NOT NULL THEN ' AND gp.region_id IN (' + @region_id + ')' ELSE '' END +
				CASE WHEN @not_region_id IS NOT NULL THEN ' AND ISNULL(gp.region_id, -1) NOT IN (' + @not_region_id + ')' ELSE '' END +
				CASE WHEN @jurisdiction IS NOT NULL THEN ' AND gp.jurisdiction_id IN (' + @jurisdiction + ')' ELSE '' END +
				CASE WHEN @not_jurisdiction IS NOT NULL THEN ' AND ISNULL(gp.jurisdiction_id, -1) NOT IN (' + @not_jurisdiction + ')' ELSE '' END +
				CASE WHEN @tier_type IS NOT NULL THEN ' AND gp.tier_id IN (' + @tier_type + ')' ELSE '' END +
				CASE WHEN @nottier_type IS NOT NULL THEN ' AND ISNULL(gp.tier_id, -1) NOT IN (' + @nottier_type + ')' ELSE '' END +
				CASE WHEN @technology IS NOT NULL THEN ' AND gp.technology_id IN (' + @technology + ')' ELSE '' END +
				CASE WHEN @not_technology IS NOT NULL THEN ' AND ISNULL(gp.technology_id, -1) NOT IN (' + @not_technology + ')' ELSE '' END +
				CASE WHEN @vintage_year IS NOT NULL THEN ' AND (gp.vintage IS NULL OR gp.vintage IN (' + @vintage_year + '))' ELSE '' END + 
				') pro
	
			OUTER APPLY(SELECT 1 cnt 
				FROM source_deal_header sdhh 
				WHERE sdhh.source_deal_header_id = td.source_deal_header_id 
				AND COALESCE(sdhh.state_value_id, sdhh.tier_value_id) IS NOT NULL) head

			OUTER APPLY(SELECT DISTINCT 1 AS total, 
						tsp.region_id,
						sd.state_value_id AS state_id, 
						sd.tier_value_id AS tier_type,
						tsp.technology_id,
						vin.code AS vintage,
						spd.banking_years
				FROM source_deal_header sd
				OUTER APPLY(SELECT MIN(spd.banking_years) banking_years
							FROM state_properties_details spd 
							WHERE spd.tier_id = sd.tier_value_id AND spd.state_value_id = sd.state_value_id) spd
				LEFT JOIN #tmp_state_properties tsp ON tsp.jurisdiction_id = sd.state_value_id
					AND tsp.tier_id = sd.tier_value_id
				LEFT JOIN static_data_value vin ON vin.value_id = sdd.vintage
					AND vin.type_id = 10092
				WHERE sd.source_deal_header_id = td.source_deal_header_id
				--AND COALESCE(gc.cnt, gis.cnt) IS NULL
				--AND COALESCE(sd.state_value_id, sd.tier_value_id) IS NOT NULL 
				' +
				CASE WHEN @region_id IS NOT NULL THEN ' AND tsp.region_id IN  (' + @region_id + ')' ELSE '' END + 
				CASE WHEN @not_region_id IS NOT NULL THEN ' AND ISNULL(tsp.region_id, -1) NOT IN  (' + @not_region_id + ')' ELSE '' END + 
				CASE WHEN @jurisdiction IS NOT NULL THEN ' AND sd.state_value_id IN (' + @jurisdiction + ')' ELSE '' END +
				CASE WHEN @not_jurisdiction IS NOT NULL THEN ' AND ISNULL(sd.state_value_id, -1) NOT IN (' + @not_jurisdiction + ')' ELSE '' END +
				CASE WHEN @tier_type IS NOT NULL THEN ' AND sd.tier_value_id IN (' + @tier_type + ')' ELSE '' END +
				CASE WHEN @nottier_type IS NOT NULL THEN ' AND ISNULL(sd.tier_value_id, -1) NOT IN (' + @nottier_type + ')' ELSE '' END + 
				CASE WHEN @technology IS NOT NULL THEN ' AND tsp.technology_id IN (' + @technology + ')' ELSE '' END +
				CASE WHEN @not_technology IS NOT NULL THEN ' AND ISNULL(tsp.technology_id, -1) NOT IN (' + @not_technology + ')' ELSE '' END +
				CASE WHEN @vintage_year IS NOT NULL THEN ' AND (vin.code IN (' + @vintage_year + ') OR YEAR(sdd.term_start) IN (' + @vintage_year + '))' 
				ELSE '' END + 
				') deal

			OUTER APPLY(SELECT DISTINCT 1 AS total, 
						tsp.region_id,
						emtd.state_value_id state_id, 
						emtd.tier_id tier_type,
						tsp.technology_id,
						YEAR(sdd.term_start) vintage,
						spd.banking_years
				FROM rec_generator rg
				LEFT JOIN eligibility_mapping_template_detail emtd ON emtd.template_id = rg.eligibility_mapping_template_id
				OUTER APPLY(SELECT MIN(spd.banking_years) banking_years 
							FROM state_properties_details spd 
							WHERE spd.tier_id = emtd.tier_id AND spd.state_value_id = emtd.state_value_id) spd
				LEFT JOIN #tmp_state_properties tsp ON tsp.jurisdiction_id = emtd.state_value_id
					AND tsp.tier_id = emtd.tier_id
				WHERE rg.generator_id = sdh.generator_id
				--AND COALESCE(gc.cnt, gis.cnt, head.cnt) IS NULL 
				' +
				CASE WHEN @region_id IS NOT NULL THEN ' AND tsp.region_id IN  (' + @region_id + ')' ELSE '' END + 
				CASE WHEN @not_region_id IS NOT NULL THEN ' AND ISNULL(tsp.region_id, -1) NOT IN  (' + @not_region_id + ')' ELSE '' END + 
				CASE WHEN @jurisdiction IS NOT NULL THEN ' AND emtd.state_value_id IN (' + @jurisdiction + ')' ELSE '' END +
				CASE WHEN @not_jurisdiction IS NOT NULL THEN ' AND ISNULL(emtd.state_value_id, -1) NOT IN (' + @not_jurisdiction + ')' ELSE '' END +
				CASE WHEN @tier_type IS NOT NULL THEN ' AND emtd.tier_id IN (' + @tier_type + ')' ELSE '' END +
				CASE WHEN @nottier_type IS NOT NULL THEN ' AND ISNULL(emtd.tier_id, -1) NOT IN (' + @nottier_type + ')' ELSE '' END +
				CASE WHEN @technology IS NOT NULL THEN ' AND tsp.technology_id IN (' + @technology + ')' ELSE '' END +
				CASE WHEN @not_technology IS NOT NULL THEN ' AND ISNULL(tsp.technology_id, -1) NOT IN (' + @not_technology + ')' ELSE '' END + ') gen
		
		WHERE 1 = 1  AND COALESCE(cer.total, pro.total, deal.total, gen.total) > 0 ' +

		CASE WHEN @sell_deal_detail_id IS NOT NULL THEN ' AND sdd.source_deal_detail_id IN  (' + @sell_deal_detail_id + ')' ELSE '' END

	--PRINT(@sql)
	EXEC(@sql)
END